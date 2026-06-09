package com.campus.lostfound.modules.item.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.dto.request.ItemCreateRequest;
import com.campus.lostfound.common.dto.request.ItemQueryRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.common.service.RedisCacheService;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;
import com.campus.lostfound.modules.item.entity.ItemImage;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemImageRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.notification.entity.Notification;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import com.campus.lostfound.modules.item.service.ItemService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.common.constant.UserConstants;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 失物服务实现
 */
@Service
public class ItemServiceImpl implements ItemService {

    private static final Logger log = LoggerFactory.getLogger(ItemServiceImpl.class);

    private final ItemRepository itemRepository;
    private final ItemImageRepository itemImageRepository;
    private final MatchRepository matchRepository;
    private final ItemCompletionRequestRepository completionRequestRepository;
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final JdbcTemplate jdbcTemplate;
    private final RedisCacheService cacheService;
    private final ObjectMapper objectMapper;
    private final com.campus.lostfound.modules.notification.service.NotificationService notificationService;
    private final com.campus.lostfound.modules.match.service.MatchingService matchingService;

    public ItemServiceImpl(ItemRepository itemRepository,
                           ItemImageRepository itemImageRepository,
                           MatchRepository matchRepository,
                           ItemCompletionRequestRepository completionRequestRepository,
                           NotificationRepository notificationRepository,
                           UserRepository userRepository,
                           JdbcTemplate jdbcTemplate,
                           RedisCacheService cacheService,
                           ObjectMapper objectMapper,
                           com.campus.lostfound.modules.notification.service.NotificationService notificationService,
                           com.campus.lostfound.modules.match.service.MatchingService matchingService) {
        this.itemRepository = itemRepository;
        this.itemImageRepository = itemImageRepository;
        this.matchRepository = matchRepository;
        this.completionRequestRepository = completionRequestRepository;
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
        this.jdbcTemplate = jdbcTemplate;
        this.cacheService = cacheService;
        this.objectMapper = objectMapper;
        this.notificationService = notificationService;
        this.matchingService = matchingService;
    }

    @Override
    @Transactional
    public Item create(ItemCreateRequest request, Long userId) {
        Item item = new Item();
        item.setTitle(request.getTitle());
        item.setDescription(request.getDescription());
        item.setType(request.getType());
        item.setCategory(request.getCategory());
        item.setLocation(request.getLocation());
        item.setLostTime(request.getLostTime());
        item.setFoundTime(request.getFoundTime());
        item.setBrand(request.getBrand());
        item.setColor(request.getColor());
        item.setSerialNumber(normalizeSerialNumber(request.getSerialNumber()));
        item.setContactInfo(request.getContactInfo());
        item.setStatus(ItemConstants.Status.PENDING);
        item.setUserId(userId);
        item.setViewCount(0);
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());

        itemRepository.insert(item);
        saveImages(item.getId(), request.getImages());
        item.setImages(normalizeImageUrls(request.getImages()));

        // 向所有管理员发送审核提醒通知
        try {
            notifyAdminsForPendingItem(item);
        } catch (Exception e) {
            log.error("发送管理员审核提醒失败: itemId={}", item.getId(), e);
        }

        return item;
    }

    @Override
    @Transactional
    public Item update(Long id, ItemCreateRequest request, Long userId) {
        Item item = getById(id);
        if (item == null) {
            throw new BusinessException("物品不存在");
        }

        if (!item.getUserId().equals(userId)) {
            throw new BusinessException("无权修改此物品");
        }
        if (!ItemConstants.Status.PENDING.equals(item.getStatus())) {
            throw new BusinessException("仅待审核物品允许修改");
        }

        item.setTitle(request.getTitle());
        item.setDescription(request.getDescription());
        item.setCategory(request.getCategory());
        item.setLocation(request.getLocation());
        item.setLostTime(request.getLostTime());
        item.setFoundTime(request.getFoundTime());
        item.setBrand(request.getBrand());
        item.setColor(request.getColor());
        item.setSerialNumber(normalizeSerialNumber(request.getSerialNumber()));
        item.setContactInfo(request.getContactInfo());
        item.setUpdatedAt(LocalDateTime.now());

        itemRepository.updateById(item);
        saveImages(item.getId(), request.getImages());
        item.setImages(normalizeImageUrls(request.getImages()));
        return item;
    }

    @Override
    @Transactional
    public void delete(Long id, Long userId) {
        Item item = getById(id);
        if (item == null) {
            throw new BusinessException("物品不存在");
        }

        if (!item.getUserId().equals(userId)) {
            throw new BusinessException("无权删除此物品");
        }
        if (!ItemConstants.Status.PENDING.equals(item.getStatus())) {
            throw new BusinessException("仅待审核物品允许删除");
        }

        itemRepository.deleteById(id);

        // 清除物品缓存和统计缓存
        cacheService.clearItemCache(id);
        cacheService.clearStatisticsCache();
    }

    @Override
    public Item getById(Long id) {
        Item item = itemRepository.selectById(id);
        if (item == null) {
            return null;
        }
        enrichItems(List.of(item));
        return item;
    }

    @Override
    public PageResponse<Item> query(ItemQueryRequest request) {
        Page<Item> page = new Page<>(request.getPage(), request.getPageSize());

        QueryWrapper<Item> wrapper = new QueryWrapper<>();

        if (request.getType() != null) {
            wrapper.eq("type", request.getType());
        }
        if (request.getCategory() != null) {
            wrapper.eq("category", request.getCategory());
        }
        if (request.getUserId() != null) {
            wrapper.eq("user_id", request.getUserId());
        }
        if (request.getStatus() != null) {
            wrapper.eq("status", request.getStatus());
        }
        if (request.getStatuses() != null && !request.getStatuses().isEmpty()) {
            wrapper.in("status", request.getStatuses());
        }
        if (request.getKeyword() != null && !request.getKeyword().isBlank()) {
            wrapper.and(w -> w.like("title", request.getKeyword())
                    .or().like("description", request.getKeyword())
                    .or().like("brand", request.getKeyword())
                    .or().like("color", request.getKeyword())
                    .or().like("serial_number", request.getKeyword())
                    .or().like("location", request.getKeyword()));
        }
        if (request.getStartTime() != null) {
            wrapper.and(w -> w.ge("lost_time", request.getStartTime()).or().ge("found_time", request.getStartTime()));
        }
        if (request.getEndTime() != null) {
            wrapper.and(w -> w.le("lost_time", request.getEndTime()).or().le("found_time", request.getEndTime()));
        }

        wrapper.orderByDesc("created_at");

        IPage<Item> result = itemRepository.selectPage(page, wrapper);
        enrichItems(result.getRecords());

        return PageResponse.of(result.getRecords(), result.getTotal(), 
                (int) result.getCurrent(), (int) result.getSize());
    }

    @Override
    @Transactional
    public void incrementViewCount(Long id) {
        jdbcTemplate.update("UPDATE items SET view_count = COALESCE(view_count, 0) + 1 WHERE id = ?", id);
    }

    public List<Item> findByIds(List<Long> ids) {
        return itemRepository.selectBatchIds(ids);
    }

    public List<Item> list(QueryWrapper<Item> wrapper) {
        return itemRepository.selectList(wrapper);
    }

    public Item updateById(Item item) {
        itemRepository.updateById(item);
        return item;
    }

    public Map<Long, Item> findByIdsAsMap(List<Long> ids) {
        return findByIds(ids).stream()
                .collect(Collectors.toMap(Item::getId, Function.identity()));
    }

    private void saveImages(Long itemId, List<String> imageUrls) {
        LambdaQueryWrapper<ItemImage> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(ItemImage::getItemId, itemId);
        itemImageRepository.delete(deleteWrapper);

        List<String> normalized = normalizeImageUrls(imageUrls);
        for (int i = 0; i < normalized.size(); i++) {
            ItemImage image = new ItemImage();
            image.setItemId(itemId);
            image.setImageUrl(normalized.get(i));
            image.setImageType(i == 0 ? "MAIN" : "DETAIL");
            image.setSortOrder(i);
            itemImageRepository.insert(image);
        }
    }

    private List<String> normalizeImageUrls(List<String> imageUrls) {
        if (imageUrls == null) {
            return List.of();
        }
        return imageUrls.stream()
                .filter(url -> url != null && !url.isBlank())
                .distinct()
                .limit(6)
                .toList();
    }

    private String normalizeSerialNumber(String serialNumber) {
        if (serialNumber == null) {
            return null;
        }
        String trimmed = serialNumber.trim();
        return trimmed.isEmpty() ? null : trimmed.toUpperCase();
    }

    @Override
    @Transactional
    public Item review(Long itemId, Long adminId, boolean approved, String reason) {
        Item item = itemRepository.selectById(itemId);
        if (item == null) {
            throw new BusinessException("物品不存在");
        }
        if (!ItemConstants.Status.PENDING.equals(item.getStatus())) {
            throw new BusinessException("仅待审核物品可被审核,当前状态: " + item.getStatus());
        }

        String newStatus = approved ? ItemConstants.Status.APPROVED : ItemConstants.Status.REJECTED;
        LocalDateTime now = LocalDateTime.now();

        // 条件原子更新:避免两个管理员同时审核造成的"双通过/双拒绝"
        com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<Item> updateWrapper =
                new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<>();
        updateWrapper.eq(Item::getId, itemId)
                .eq(Item::getStatus, ItemConstants.Status.PENDING)
                .set(Item::getStatus, newStatus)
                .set(Item::getUpdatedAt, now);
        int rows = itemRepository.update(null, updateWrapper);
        if (rows == 0) {
            // 并发场景:被其他管理员先一步审核了
            throw new BusinessException("该物品已被其他管理员审核");
        }

        // 重新读一次,拿最新状态
        Item updated = itemRepository.selectById(itemId);
        log.info("管理员 {} 审核物品 {} -> {} (approved={})", adminId, itemId, newStatus, approved);

        // 通知发布者(站内 + 邮件)
        try {
            notificationService.notifyVerificationResult(itemId, newStatus, reason);
        } catch (Exception e) {
            // 通知失败不影响主流程
            log.error("审核通知发送失败: itemId={}, status={}", itemId, newStatus, e);
        }

        // 审核通过:异步触发匹配(不阻塞事务)
        if (approved) {
            try {
                matchingService.match(itemId);
                log.info("物品 {} 审核通过后已触发匹配", itemId);
            } catch (Exception e) {
                log.error("审核通过后触发匹配失败: itemId={}", itemId, e);
            }
        }

        // 清除缓存
        cacheService.clearItemCache(itemId);
        cacheService.clearStatisticsCache();
        return updated;
    }

    @Override
    public List<Item> listPending() {
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Item::getStatus, ItemConstants.Status.PENDING)
                .orderByDesc(Item::getCreatedAt);
        List<Item> items = itemRepository.selectList(wrapper);
        enrichItems(items);
        return items;
    }

    @Override
    public com.campus.lostfound.common.result.PageResponse<Item> adminListByStatus(
            String status, int page, int pageSize) {
        // 列表查询(带 deleted=0 过滤)
        LambdaQueryWrapper<Item> listWrapper = new LambdaQueryWrapper<>();
        listWrapper.eq(Item::getDeleted, 0);
        if (status != null && !status.isBlank()) {
            listWrapper.eq(Item::getStatus, status);
        }
        listWrapper.orderByDesc(Item::getCreatedAt);
        List<Item> records = itemRepository.selectList(listWrapper);

        // 单独 count(绕开 selectPage 的 count 查询与 @TableLogic 冲突)
        LambdaQueryWrapper<Item> countWrapper = new LambdaQueryWrapper<>();
        countWrapper.eq(Item::getDeleted, 0);
        if (status != null && !status.isBlank()) {
            countWrapper.eq(Item::getStatus, status);
        }
        long total = itemRepository.selectCount(countWrapper);

        // 内存分页
        int fromIndex = Math.min((page - 1) * pageSize, records.size());
        int toIndex = Math.min(fromIndex + pageSize, records.size());
        List<Item> paged = records.subList(fromIndex, toIndex);
        enrichItems(paged);

        return com.campus.lostfound.common.result.PageResponse.of(
                paged, total, page, pageSize);
    }

    private void enrichItems(List<Item> items) {
        if (items == null || items.isEmpty()) {
            return;
        }

        List<Long> itemIds = items.stream().map(Item::getId).toList();
        List<Long> userIds = items.stream().map(Item::getUserId).distinct().toList();

        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.in(User::getId, userIds);
        Map<Long, String> userNameMap = userRepository.selectList(userWrapper).stream()
                .collect(Collectors.toMap(User::getId, User::getUsername));

        LambdaQueryWrapper<ItemImage> imageWrapper = new LambdaQueryWrapper<>();
        imageWrapper.in(ItemImage::getItemId, itemIds).orderByAsc(ItemImage::getSortOrder);
        Map<Long, List<String>> imageMap = itemImageRepository.selectList(imageWrapper).stream()
                .collect(Collectors.groupingBy(
                        ItemImage::getItemId,
                        Collectors.mapping(ItemImage::getImageUrl, Collectors.toList())
                ));

        LambdaQueryWrapper<Match> matchWrapper = new LambdaQueryWrapper<>();
        matchWrapper.and(w -> w.in(Match::getLostItemId, itemIds).or().in(Match::getFoundItemId, itemIds));
        Map<Long, Boolean> matchedMap = new HashMap<>();
        for (Match match : matchRepository.selectList(matchWrapper)) {
            boolean highConfidence = match.getScore() != null
                    && match.getScore().compareTo(ItemConstants.HIGH_CONFIDENCE_MATCH_THRESHOLD) >= 0;
            if (!highConfidence) {
                continue;
            }
            matchedMap.put(match.getLostItemId(), true);
            matchedMap.put(match.getFoundItemId(), true);
        }

        LambdaQueryWrapper<ItemCompletionRequest> completionWrapper = new LambdaQueryWrapper<>();
        completionWrapper.in(ItemCompletionRequest::getItemId, itemIds)
                .eq(ItemCompletionRequest::getStatus, ItemConstants.CompletionStatus.PENDING)
                .orderByDesc(ItemCompletionRequest::getCreatedAt);
        Map<Long, ItemCompletionRequest> completionMap = new HashMap<>();
        for (ItemCompletionRequest request : completionRequestRepository.selectList(completionWrapper)) {
            completionMap.putIfAbsent(request.getItemId(), request);
        }

        LambdaQueryWrapper<Notification> notificationWrapper = new LambdaQueryWrapper<>();
        notificationWrapper.in(Notification::getRelatedId, itemIds)
                .eq(Notification::getType, ItemConstants.NotificationType.SYSTEM)
                .eq(Notification::getTitle, ItemConstants.NotificationTitle.POTENTIAL_DOCUMENT_OWNER);
        Map<Long, Boolean> potentialOwnerNotifiedMap = new HashMap<>();
        for (Notification notification : notificationRepository.selectList(notificationWrapper)) {
            potentialOwnerNotifiedMap.put(notification.getRelatedId(), true);
        }

        for (Item item : items) {
            item.setImages(new ArrayList<>(imageMap.getOrDefault(item.getId(), List.of())));
            item.setHighConfidenceMatched(Boolean.TRUE.equals(matchedMap.get(item.getId())));
            item.setPotentialOwnerNotified(Boolean.TRUE.equals(potentialOwnerNotifiedMap.get(item.getId())));
            item.setUsername(userNameMap.get(item.getUserId()));
            ItemCompletionRequest request = completionMap.get(item.getId());
            if (request != null) {
                item.setPendingCompletionStatus(request.getStatus());
                item.setPendingCompletionTargetStatus(request.getTargetStatus());
            } else {
                item.setPendingCompletionStatus(null);
                item.setPendingCompletionTargetStatus(null);
            }
        }
    }

    /**
     * 向所有管理员发送物品待审核通知
     */
    private void notifyAdminsForPendingItem(Item item) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(User::getRole, UserConstants.ROLE_SUPER_ADMIN, UserConstants.ROLE_CAMPUS_ADMIN);
        List<User> admins = userRepository.selectList(wrapper);

        if (admins.isEmpty()) {
            log.warn("没有找到管理员，无法发送审核提醒通知");
            return;
        }

        String typeText = ItemConstants.Type.LOST.equals(item.getType()) ? "寻物" : "招领";
        String title = "新物品待审核";
        String content = String.format(
                "用户发布了一条新的%s信息【%s】，请及时审核。",
                typeText,
                item.getTitle()
        );

        for (User admin : admins) {
            try {
                notificationService.create(
                        admin.getId(),
                        ItemConstants.NotificationType.ITEM_PENDING,
                        title,
                        content,
                        item.getId()
                );
            } catch (Exception e) {
                log.error("发送审核提醒通知失败: adminId={}, itemId={}", admin.getId(), item.getId(), e);
            }
        }

        log.info("已向 {} 位管理员发送物品审核提醒通知: itemId={}", admins.size(), item.getId());
    }
}
