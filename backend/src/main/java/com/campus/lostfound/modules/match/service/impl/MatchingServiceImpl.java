package com.campus.lostfound.modules.match.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.match.service.MatchingService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Comparator;

@Service
public class MatchingServiceImpl implements MatchingService {

    /**
     * 匹配服务实现类
     *
     * 核心功能：
     * 1. match(itemId) - 对单个物品执行匹配算法
     * 2. matchAll() - 批量匹配所有物品
     * 3. saveMatch() - 保存匹配记录并发送通知
     * 4. confirmMatch() / rejectMatch() / cancelMatch() - 匹配操作
     *
     * 匹配流程：
     *   物品发布/审核通过 → match() → findCandidates() 查找候选
     *   → calculateScore() 计算分数 → 取TopK → saveMatch() 保存并通知
     */

    private static final Logger log = LoggerFactory.getLogger(MatchingServiceImpl.class);

    private final MatchRepository matchRepository;
    private final ItemRepository itemRepository;
    private final MatchingEngine matchingEngine;
    private final NotificationService notificationService;

    public MatchingServiceImpl(MatchRepository matchRepository, ItemRepository itemRepository, 
                               MatchingEngine matchingEngine, NotificationService notificationService) {
        this.matchRepository = matchRepository;
        this.itemRepository = itemRepository;
        this.matchingEngine = matchingEngine;
        this.notificationService = notificationService;
    }

    /**
     * 对单个物品执行匹配算法
     *
     * 流程：
     * 1. 查询物品信息（不存在则返回）
     * 2. 根据物品类型确定目标类型（LOST 找 FOUND，反之亦然）
     * 3. 调用 findCandidates() 查找候选物品（最多300个）
     * 4. 对每个候选调用 calculateScore() 计算匹配分数
     * 5. 筛选分数 > 0 的候选，按分数降序排序
     * 6. 取 TopK（最多20个）调用 saveMatch() 保存
     *
     * 触发时机：物品审核通过时、用户重新发布时
     */
    @Override
    @Transactional
    public void match(Long itemId) {
        // ========== 第一步：查询物品信息 ==========
        Item item = itemRepository.selectById(itemId);
        if (item == null) {
            log.warn("物品不存在: {}", itemId);
            return;
        }

        // ========== 第二步：确定目标类型 ==========
        // LOST（寻物）只能匹配 FOUND（招领），反之亦然
        String targetType = ItemConstants.Type.LOST.equals(item.getType())
                ? ItemConstants.Type.FOUND
                : ItemConstants.Type.LOST;

        // ========== 第三步：查找候选物品 ==========
        List<Item> candidates = findCandidates(item, targetType);
        log.info("物品{} 找到候选匹配 {} 个", itemId, candidates.size());

        // ========== 第四步：计算匹配分数 ==========
        List<ScoredCandidate> scored = new ArrayList<>();
        for (Item candidate : candidates) {
            BigDecimal score = calculateScore(item, candidate);
            // 分数 > 0 才会被保留（0 表示不匹配）
            if (score != null && score.compareTo(BigDecimal.ZERO) > 0) {
                scored.add(new ScoredCandidate(candidate, score));
            }
        }

        // ========== 第五步：按分数降序排序，取 TopK ==========
        scored.sort(Comparator.comparing(ScoredCandidate::score).reversed());
        int topK = Math.min(20, scored.size());  // 最多保存 20 条匹配

        // ========== 第六步：保存匹配记录（并发送通知） ==========
        for (int i = 0; i < topK; i++) {
            ScoredCandidate candidate = scored.get(i);
            saveMatch(item, candidate.item(), candidate.score());
        }
    }

    /**
     * 查找候选匹配物品
     *
     * 查询条件：
     * 1. 物品类型相反（LOST 找 FOUND，或反之）
     * 2. 状态为已审核（APPROVED）
     * 3. 排除自己
     * 4. 排除已有匹配标记的物品（match_item_id 不为空）
     * 5. 如果有串号：精确匹配串号（最高优先级）
     * 6. 如果无串号：按类别相同 + 时间范围 ±60 天
     *
     * 限制：最多返回 300 个候选
     */
    private List<Item> findCandidates(Item item, String targetType) {
        String itemStatus = ItemConstants.Status.APPROVED;
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();

        // ========== 基础筛选条件 ==========
        wrapper.eq(Item::getType, targetType);        // 类型相反
        wrapper.eq(Item::getStatus, itemStatus);      // 状态为已审核
        wrapper.ne(Item::getId, item.getId());        // 排除自己
        // 排除已经有确认匹配的物品（match_item_id 不为空表示已匹配）
        wrapper.isNull(Item::getMatchItemId);

        // ========== 高级筛选条件 ==========
        String serial = item.getSerialNumber();
        if (serial != null && !serial.isBlank()) {
            // 有串号：精确匹配串号（最高优先级）
            wrapper.eq(Item::getSerialNumber, serial.trim().toUpperCase());
        } else {
            // 无串号：按类别 + 时间范围筛选
            if (item.getCategory() != null && !item.getCategory().isBlank()) {
                wrapper.eq(Item::getCategory, item.getCategory());
            }

            // 时间范围：丢失/拾取时间 ±60 天
            LocalDateTime refTime = ItemConstants.Type.LOST.equals(item.getType())
                    ? item.getLostTime()
                    : item.getFoundTime();
            if (refTime != null) {
                LocalDateTime start = refTime.minusDays(60);
                LocalDateTime end = refTime.plusDays(60);
                if (ItemConstants.Type.FOUND.equals(targetType)) {
                    wrapper.between(Item::getFoundTime, start, end);
                } else {
                    wrapper.between(Item::getLostTime, start, end);
                }
            }
        }

        Page<Item> page = new Page<>(1, 300);
        return itemRepository.selectPage(page, wrapper).getRecords();
    }

    @Override
    public BigDecimal calculateScore(Item item1, Item item2) {
        if (ItemConstants.Type.LOST.equals(item1.getType())) {
            MatchingEngine.LostItem lost = new MatchingEngine.LostItem(
                    item1.getCategory(),
                    item1.getLocation(),
                    item1.getBrand(),
                    item1.getColor(),
                    item1.getTitle(),
                    item1.getDescription(),
                    item1.getSerialNumber(),
                    item1.getLostTime()
            );
            MatchingEngine.FoundItem found = new MatchingEngine.FoundItem(
                    item2.getCategory(),
                    item2.getLocation(),
                    item2.getBrand(),
                    item2.getColor(),
                    item2.getTitle(),
                    item2.getDescription(),
                    item2.getSerialNumber(),
                    item2.getFoundTime()
            );
            return matchingEngine.calculateScore(lost, found);
        }

        MatchingEngine.FoundItem found = new MatchingEngine.FoundItem(
                item1.getCategory(),
                item1.getLocation(),
                item1.getBrand(),
                item1.getColor(),
                item1.getTitle(),
                item1.getDescription(),
                item1.getSerialNumber(),
                item1.getFoundTime()
        );
        MatchingEngine.LostItem lost = new MatchingEngine.LostItem(
                item2.getCategory(),
                item2.getLocation(),
                item2.getBrand(),
                item2.getColor(),
                item2.getTitle(),
                item2.getDescription(),
                item2.getSerialNumber(),
                item2.getLostTime()
        );
        return matchingEngine.calculateScore(lost, found);
    }

    /**
     * 保存匹配记录
     *
     * 流程：
     * 1. 判断匹配类型：
     *    - 分数 = 1.00：SERIAL_EXACT（串号精确匹配）
     *    - 分数 >= 0.70：WEIGHTED（加权匹配）
     *    - 分数 < 0.70：NONE（不保存）
     * 2. 判断 lost/found 物品 ID
     * 3. 检查是否已存在相同匹配（去重）
     * 4. 创建 Match 对象并保存到数据库
     * 5. 如果是精确匹配：更新物品的 match_item_id 字段
     * 6. 发送通知给双方用户
     */
    private void saveMatch(Item item1, Item item2, BigDecimal score) {
        if (score == null || score.compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }

        String matchType;
        if (score.compareTo(new BigDecimal("1.00")) == 0) {
            matchType = "SERIAL_EXACT";
        } else if (matchingEngine.isMatch(score)) {
            matchType = "WEIGHTED";
        } else {
            matchType = "NONE";
        }

        if ("NONE".equals(matchType)) {
            return;
        }

        Long lostItemId = ItemConstants.Type.LOST.equals(item1.getType()) ? item1.getId() : item2.getId();
        Long foundItemId = ItemConstants.Type.FOUND.equals(item1.getType()) ? item1.getId() : item2.getId();

        LambdaQueryWrapper<Match> existingWrapper = new LambdaQueryWrapper<>();
        existingWrapper.eq(Match::getLostItemId, lostItemId);
        existingWrapper.eq(Match::getFoundItemId, foundItemId);
        Long existingCount = matchRepository.selectCount(existingWrapper);

        if (existingCount > 0) {
            log.debug("匹配记录已存在: item1={}, item2={}", item1.getId(), item2.getId());
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        Match match = new Match();
        match.setLostItemId(lostItemId);
        match.setFoundItemId(foundItemId);
        match.setScore(score);
        match.setMatchType(matchType);
        // 串号精确匹配直接确认，其他匹配需要用户确认
        match.setStatus("SERIAL_EXACT".equals(matchType) ? "CONFIRMED" : "PENDING");
        match.setIsRead(0);
        match.setCreatedAt(now);
        match.setUpdatedAt(now);

        matchRepository.insert(match);
        log.info("创建匹配: lost={}, found={}, score={}, type={}, status={}", lostItemId, foundItemId, score, matchType, match.getStatus());

        // 对于精确匹配，同时更新物品的匹配状态
        if ("SERIAL_EXACT".equals(matchType)) {
            updateItemMatchStatus(lostItemId, foundItemId, score);
        }

        try {
            notificationService.notifyMatchFound(lostItemId, match.getId());
            notificationService.notifyMatchFound(foundItemId, match.getId());
        } catch (Exception e) {
            log.error("发送匹配通知失败", e);
        }
    }

    private void updateItemMatchStatus(Long lostItemId, Long foundItemId, BigDecimal score) {
        try {
            Item lostItem = itemRepository.selectById(lostItemId);
            Item foundItem = itemRepository.selectById(foundItemId);
            
            if (lostItem != null) {
                lostItem.setMatchItemId(foundItemId);
                lostItem.setMatchScore(score);
                lostItem.setUpdatedAt(LocalDateTime.now());
                itemRepository.updateById(lostItem);
            }
            if (foundItem != null) {
                foundItem.setMatchItemId(lostItemId);
                foundItem.setMatchScore(score);
                foundItem.setUpdatedAt(LocalDateTime.now());
                itemRepository.updateById(foundItem);
            }
            log.info("更新物品匹配状态: lost={}, found={}", lostItemId, foundItemId);
        } catch (Exception e) {
            log.error("更新物品匹配状态失败", e);
        }
    }

    private record ScoredCandidate(Item item, BigDecimal score) {
    }

    /**
     * 批量匹配所有已审核的物品
     *
     * 流程：
     * 1. 查询所有状态为 APPROVED 的物品
     * 2. 两两组合（O(n²) 复杂度）
     * 3. 只对类型不同的物品（LOST vs FOUND）计算分数
     * 4. 调用 saveMatch() 保存匹配记录
     *
     * 注意：物品数量大时性能较差，谨慎使用
     */
    @Override
    @Transactional
    public void matchAll() {
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Item::getStatus, ItemConstants.Status.APPROVED);

        List<Item> items = itemRepository.selectList(wrapper);
        log.info("开始批量匹配，总物品数: {}", items.size());

        for (int i = 0; i < items.size(); i++) {
            for (int j = i + 1; j < items.size(); j++) {
                Item item1 = items.get(i);
                Item item2 = items.get(j);

                if (!item1.getType().equals(item2.getType())) {
                    BigDecimal score = calculateScore(item1, item2);
                    saveMatch(item1, item2, score);
                }
            }
        }

        log.info("批量匹配完成");
    }

    @Override
    public PageResponse<Match> getMatches(Long itemId, int page, int pageSize) {
        LambdaQueryWrapper<Match> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Match::getLostItemId, itemId)
                .or()
                .eq(Match::getFoundItemId, itemId);
        wrapper.ne(Match::getStatus, "REJECTED");
        wrapper.orderByDesc(Match::getScore);

        Page<Match> result = matchRepository.selectPage(new Page<>(page, pageSize), wrapper);
        return PageResponse.of(enrichMatches(result.getRecords()), result.getTotal(), page, pageSize);
    }

    @Override
    public PageResponse<Match> getAllMatches(int page, int pageSize) {
        LambdaQueryWrapper<Match> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Match::getCreatedAt);

        Page<Match> result = matchRepository.selectPage(new Page<>(page, pageSize), wrapper);
        return PageResponse.of(enrichMatches(result.getRecords()), result.getTotal(), page, pageSize);
    }

    @Override
    public PageResponse<Match> getUserMatches(Long userId, int page, int pageSize, String status) {
        LambdaQueryWrapper<Item> itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(Item::getUserId, userId);
        List<Item> myItems = itemRepository.selectList(itemWrapper);

        if (myItems.isEmpty()) {
            return PageResponse.of(new ArrayList<>(), 0, page, pageSize);
        }

        List<Long> itemIds = myItems.stream().map(Item::getId).toList();
        LambdaQueryWrapper<Match> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.in(Match::getLostItemId, itemIds).or().in(Match::getFoundItemId, itemIds));
        // 只显示匹配度>=70%的匹配
        wrapper.ge(Match::getScore, new BigDecimal("0.70"));
        // 如果有status筛选条件
        if (status != null && !status.isBlank()) {
            wrapper.eq(Match::getStatus, status);
        }
        // 按匹配度从高到低排序
        wrapper.orderByDesc(Match::getScore);

        Page<Match> result = matchRepository.selectPage(new Page<>(page, pageSize), wrapper);
        return PageResponse.of(enrichMatches(result.getRecords()), result.getTotal(), page, pageSize);
    }

    /**
     * 确认匹配（用户操作）
     *
     * 流程：
     * 1. 校验匹配记录存在且状态为 PENDING
     * 2. 校验用户是匹配物品的所有者
     * 3. 更新匹配状态为 CONFIRMED
     * 4. 更新双方物品的 match_item_id 和 match_score
     * 5. 删除其他涉及相同物品的待确认匹配（避免冲突）
     *
     * 权限：只有匹配物品的所有者可以确认
     */
    @Override
    @Transactional
    public void confirmMatch(Long matchId, Long userId) {
        Match match = matchRepository.selectById(matchId);
        if (match == null) {
            throw new BusinessException("匹配记录不存在");
        }
        if (!"PENDING".equals(match.getStatus())) {
            throw new BusinessException("只有待确认的匹配才能确认");
        }

        Item lostItem = itemRepository.selectById(match.getLostItemId());
        Item foundItem = itemRepository.selectById(match.getFoundItemId());
        validateMatchOwnership(userId, lostItem, foundItem);

        match.setStatus("CONFIRMED");
        match.setUpdatedAt(LocalDateTime.now());
        matchRepository.updateById(match);

        if (lostItem != null) {
            lostItem.setMatchItemId(foundItem.getId());
            lostItem.setMatchScore(match.getScore());
            lostItem.setUpdatedAt(LocalDateTime.now());
            itemRepository.updateById(lostItem);
        }
        if (foundItem != null) {
            foundItem.setMatchItemId(lostItem.getId());
            foundItem.setMatchScore(match.getScore());
            foundItem.setUpdatedAt(LocalDateTime.now());
            itemRepository.updateById(foundItem);
        }

        // 确认后，直接删除其他涉及相同物品的待确认匹配，避免同一物品存在冲突关系
        List<Long> itemIds = List.of(match.getLostItemId(), match.getFoundItemId());
        LambdaQueryWrapper<Match> otherMatchWrapper = new LambdaQueryWrapper<>();
        otherMatchWrapper.and(w -> w.in(Match::getLostItemId, itemIds).or().in(Match::getFoundItemId, itemIds));
        otherMatchWrapper.eq(Match::getStatus, "PENDING");
        otherMatchWrapper.ne(Match::getId, matchId); // 排除当前确认的匹配

        List<Match> otherMatches = matchRepository.selectList(otherMatchWrapper);
        if (!otherMatches.isEmpty()) {
            List<Long> otherMatchIds = otherMatches.stream().map(Match::getId).toList();
            matchRepository.deleteBatchIds(otherMatchIds);
            log.info("确认匹配 {} 后删除冲突的待确认匹配: {}", matchId, otherMatchIds);
        }

        log.info("用户{} 确认匹配 {}", userId, matchId);
    }

    /**
     * 拒绝匹配（用户操作）
     *
     * 流程：
     * 1. 校验匹配记录存在且状态为 PENDING
     * 2. 校验用户是匹配物品的所有者
     * 3. 更新匹配状态为 REJECTED（记录保留）
     *
     * 权限：只有匹配物品的所有者可以拒绝
     */
    @Override
    @Transactional
    public void rejectMatch(Long matchId, Long userId, String reason) {
        Match match = matchRepository.selectById(matchId);
        if (match == null) {
            throw new BusinessException("匹配记录不存在");
        }
        if (!"PENDING".equals(match.getStatus())) {
            throw new BusinessException("只有待确认的匹配才能拒绝");
        }

        Item lostItem = itemRepository.selectById(match.getLostItemId());
        Item foundItem = itemRepository.selectById(match.getFoundItemId());
        validateMatchOwnership(userId, lostItem, foundItem);

        match.setStatus("REJECTED");
        match.setUpdatedAt(LocalDateTime.now());
        matchRepository.updateById(match);

        log.info("用户{} 拒绝匹配 {}: {}", userId, matchId, reason);
    }

    /**
     * 取消匹配（用户操作）
     *
     * 两种情况：
     * 1. CONFIRMED → PENDING（取消已确认的匹配）
     *    - 清除双方物品的 match_item_id
     *    - 不触发新匹配，不发邮件
     * 2. REJECTED → PENDING（取消已拒绝的匹配）
     *    - 只修改匹配记录状态
     *    - 物品状态不变
     *
     * 权限：只有匹配物品的所有者可以取消
     */
    @Override
    @Transactional
    public void cancelMatch(Long matchId, Long userId) {
        Match match = matchRepository.selectById(matchId);
        if (match == null) {
            throw new BusinessException("匹配记录不存在");
        }

        Item lostItem = itemRepository.selectById(match.getLostItemId());
        Item foundItem = itemRepository.selectById(match.getFoundItemId());
        validateMatchOwnership(userId, lostItem, foundItem);

        if ("CONFIRMED".equals(match.getStatus())) {
            // 由匹配态取消：状态改回PENDING，不触发新匹配，不发邮件
            match.setStatus("PENDING");
            match.setUpdatedAt(LocalDateTime.now());
            matchRepository.updateById(match);
            
            // 清除两个物品的匹配标记，使其状态一致
            if (lostItem != null) {
                lostItem.setMatchItemId(null);
                lostItem.setMatchScore(null);
                lostItem.setUpdatedAt(LocalDateTime.now());
                itemRepository.updateById(lostItem);
            }
            if (foundItem != null) {
                foundItem.setMatchItemId(null);
                foundItem.setMatchScore(null);
                foundItem.setUpdatedAt(LocalDateTime.now());
                itemRepository.updateById(foundItem);
            }
            log.info("用户{} 取消匹配（状态改为待确认） {}", userId, matchId);
        } else if ("REJECTED".equals(match.getStatus())) {
            // 由拒绝态取消：只改状态为待确认，不触发新匹配
            match.setStatus("PENDING");
            match.setUpdatedAt(LocalDateTime.now());
            matchRepository.updateById(match);
            log.info("用户{} 取消拒绝（恢复为待确认） {}", userId, matchId);
        } else {
            throw new BusinessException("只能取消已确认或已拒绝的匹配");
        }
    }

    @Override
    public List<Match> getMyMatchNotifications(Long userId) {
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Item::getUserId, userId);
        List<Item> myItems = itemRepository.selectList(wrapper);

        List<Long> itemIds = new ArrayList<>();
        for (Item item : myItems) {
            itemIds.add(item.getId());
        }

        if (itemIds.isEmpty()) {
            return new ArrayList<>();
        }

        LambdaQueryWrapper<Match> matchWrapper = new LambdaQueryWrapper<>();
        matchWrapper.and(w -> w.in(Match::getLostItemId, itemIds).or().in(Match::getFoundItemId, itemIds));
        matchWrapper.eq(Match::getIsRead, 0);
        matchWrapper.orderByDesc(Match::getCreatedAt);

        return matchRepository.selectList(matchWrapper);
    }

    private void validateMatchOwnership(Long userId, Item lostItem, Item foundItem) {
        if (lostItem == null || foundItem == null) {
            throw new BusinessException("匹配关联的物品不存在");
        }

        boolean isOwner = userId.equals(lostItem.getUserId()) || userId.equals(foundItem.getUserId());
        if (!isOwner) {
            throw new BusinessException("无权操作该匹配记录");
        }
    }

    private List<Match> enrichMatches(List<Match> matches) {
        if (matches == null || matches.isEmpty()) {
            return matches;
        }

        List<Long> itemIds = new ArrayList<>();
        for (Match match : matches) {
            itemIds.add(match.getLostItemId());
            itemIds.add(match.getFoundItemId());
        }

        Map<Long, Item> itemMap = new HashMap<>();
        for (Item item : itemRepository.selectBatchIds(itemIds)) {
            itemMap.put(item.getId(), item);
        }

        for (Match match : matches) {
            Item lostItem = itemMap.get(match.getLostItemId());
            Item foundItem = itemMap.get(match.getFoundItemId());
            if (lostItem != null) {
                match.setLostItemTitle(lostItem.getTitle());
                match.setLostItemCategory(lostItem.getCategory());
            }
            if (foundItem != null) {
                match.setFoundItemTitle(foundItem.getTitle());
                match.setFoundItemCategory(foundItem.getCategory());
            }
        }

        return matches;
    }
}
