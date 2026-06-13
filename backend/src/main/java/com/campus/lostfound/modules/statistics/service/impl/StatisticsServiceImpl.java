package com.campus.lostfound.modules.statistics.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.modules.common.service.RedisCacheService;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.statistics.service.StatisticsService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 统计服务实现
 */
@Service
public class StatisticsServiceImpl implements StatisticsService {

    private static final Logger log = LoggerFactory.getLogger(StatisticsServiceImpl.class);
    private static final List<String> PUBLIC_ITEM_STATUSES = Arrays.asList(
            ItemConstants.Status.APPROVED,
            ItemConstants.Status.FOUND_BACK,
            ItemConstants.Status.RETURNED
    );
    private static final List<String> RESOLVED_ITEM_STATUSES = Arrays.asList(
            ItemConstants.Status.FOUND_BACK,
            ItemConstants.Status.RETURNED
    );

    // 缓存Key
    private static final String CACHE_KEY_DASHBOARD = "dashboard";
    private static final String CACHE_KEY_OVERVIEW = "overview";
    private static final String CACHE_KEY_TODAY = "today";

    private final ItemRepository itemRepository;
    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    private final RedisCacheService cacheService;

    public StatisticsServiceImpl(ItemRepository itemRepository, MatchRepository matchRepository,
                                UserRepository userRepository,
                                RedisCacheService cacheService) {
        this.itemRepository = itemRepository;
        this.matchRepository = matchRepository;
        this.userRepository = userRepository;
        this.cacheService = cacheService;
    }

    @Override
    public Map<String, Object> getDashboard() {
        // 尝试从缓存获取
        @SuppressWarnings("unchecked")
        Map<String, Object> cached = (Map<String, Object>) cacheService.getStatistics(CACHE_KEY_DASHBOARD);
        if (cached != null) {
            log.debug("从缓存获取Dashboard数据");
            return cached;
        }

        Map<String, Object> dashboard = new LinkedHashMap<>();

        // 总用户数
        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        long totalUsers = userRepository.selectCount(userWrapper);
        dashboard.put("totalUsers", totalUsers);

        // 总失物数
        LambdaQueryWrapper<Item> itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(Item::getDeleted, 0);
        long totalItems = itemRepository.selectCount(itemWrapper);
        dashboard.put("totalItems", totalItems);

        // 寻物启示数
        itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(Item::getType, "LOST").eq(Item::getDeleted, 0);
        long totalLost = itemRepository.selectCount(itemWrapper);
        dashboard.put("totalLost", totalLost);

        // 失物招领数
        itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(Item::getType, "FOUND").eq(Item::getDeleted, 0);
        long totalFound = itemRepository.selectCount(itemWrapper);
        dashboard.put("totalFound", totalFound);

        // 匹配成功数
        LambdaQueryWrapper<Match> matchWrapper = new LambdaQueryWrapper<>();
        matchWrapper.eq(Match::getStatus, "CONFIRMED");
        long totalMatches = matchRepository.selectCount(matchWrapper);
        dashboard.put("totalMatches", totalMatches);

        // 待审核数
        itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(Item::getStatus, "PENDING").eq(Item::getDeleted, 0);
        long pendingItems = itemRepository.selectCount(itemWrapper);
        dashboard.put("pendingItems", pendingItems);

        // 已完成数
        long completedItems = countItemsByStatuses(RESOLVED_ITEM_STATUSES);
        dashboard.put("claimedItems", completedItems);

        // 认领成功率
        long claimRate = totalItems > 0 ? (completedItems * 100) / totalItems : 0;
        dashboard.put("claimRate", claimRate);

        // 今日新增
        LocalDateTime today = LocalDate.now().atStartOfDay();
        itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.ge(Item::getCreatedAt, today);
        long todayItems = itemRepository.selectCount(itemWrapper);
        dashboard.put("todayItems", todayItems);

        // 缓存5分钟
        cacheService.setStatistics(CACHE_KEY_DASHBOARD, dashboard);
        log.info("Dashboard: {}", dashboard);
        return dashboard;
    }

    @Override
    public Map<String, Object> getPublicOverview() {
        // 强制重新计算，不使用缓存（修复统计数据显示问题）
        Map<String, Object> overview = new LinkedHashMap<>();
        
        // 统计公开状态的寻物数量（类型为 LOST）
        LambdaQueryWrapper<Item> lostWrapper = new LambdaQueryWrapper<>();
        lostWrapper.eq(Item::getDeleted, 0)
                   .in(Item::getStatus, PUBLIC_ITEM_STATUSES)
                   .eq(Item::getType, "LOST");
        long lostCount = itemRepository.selectCount(lostWrapper);
        
        // 统计公开状态的招领数量（类型为 FOUND）
        LambdaQueryWrapper<Item> foundWrapper = new LambdaQueryWrapper<>();
        foundWrapper.eq(Item::getDeleted, 0)
                    .in(Item::getStatus, PUBLIC_ITEM_STATUSES)
                    .eq(Item::getType, "FOUND");
        long foundCount = itemRepository.selectCount(foundWrapper);
        
        // 已解决物品数（FOUND_BACK + RETURNED）
        long resolvedCount = countItemsByStatuses(RESOLVED_ITEM_STATUSES);
        
        overview.put("lost", lostCount);
        overview.put("found", foundCount);
        overview.put("resolved", resolvedCount);
        overview.put("total", lostCount + foundCount);
        overview.put("matched", countConfirmedMatches());
        
        log.info("Public overview stats: lost={}, found={}, total={}, resolved={}, matched={}", 
                 lostCount, foundCount, lostCount + foundCount, resolvedCount, countConfirmedMatches());

        // 更新缓存
        cacheService.setStatistics(CACHE_KEY_OVERVIEW, overview);
        return overview;
    }

    @Override
    public Map<String, Object> getTodayStats() {
        // 尝试从缓存获取
        @SuppressWarnings("unchecked")
        Map<String, Object> cached = (Map<String, Object>) cacheService.getStatistics(CACHE_KEY_TODAY);
        if (cached != null) {
            log.debug("从缓存获取TodayStats数据");
            return cached;
        }

        Map<String, Object> stats = new LinkedHashMap<>();
        LocalDateTime today = LocalDate.now().atStartOfDay();

        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(Item::getCreatedAt, today);

        long lost = itemRepository.selectCount(wrapper.clone());
        wrapper.eq(Item::getType, "LOST");
        stats.put("newLost", itemRepository.selectCount(wrapper));

        wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(Item::getCreatedAt, today);
        wrapper.eq(Item::getType, "FOUND");
        stats.put("newFound", itemRepository.selectCount(wrapper));

        // 缓存1分钟（今日数据变化频繁）
        cacheService.setStatistics(CACHE_KEY_TODAY, stats);
        return stats;
    }

    @Override
    public Map<String, Object> getStatsByPeriod(String startDate, String endDate) {
        Map<String, Object> stats = new LinkedHashMap<>();
        LocalDateTime start = LocalDate.parse(startDate).atStartOfDay();
        LocalDateTime end = LocalDate.parse(endDate).atTime(23, 59, 59);

        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.between(Item::getCreatedAt, start, end);

        long total = itemRepository.selectCount(wrapper);
        stats.put("totalItems", total);

        wrapper.eq(Item::getType, "LOST");
        stats.put("lost", itemRepository.selectCount(wrapper));

        wrapper = new LambdaQueryWrapper<>();
        wrapper.between(Item::getCreatedAt, start, end);
        wrapper.eq(Item::getType, "FOUND");
        stats.put("found", itemRepository.selectCount(wrapper));

        return stats;
    }

    @Override
    public Map<String, Long> getPopularCategories() {
        Map<String, Long> categories = new LinkedHashMap<>();

        // 这是一个简化的实现，生产环境应该用SQL GROUP BY
        String[] cats = {"电子产品", "证件", "书籍", "衣物", "饰品", "钥匙", "钱包", "其他"};
        for (String cat : cats) {
            LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Item::getCategory, cat).eq(Item::getDeleted, 0);
            long count = itemRepository.selectCount(wrapper);
            if (count > 0) {
                categories.put(cat, count);
            }
        }

        return categories;
    }

    @Override
    public Map<String, Long> getPopularLocations() {
        // 从 items 表的 location 字段直接统计
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.select(Item::getLocation)
               .in(Item::getStatus, PUBLIC_ITEM_STATUSES)
               .eq(Item::getDeleted, 0)
               .isNotNull(Item::getLocation);
        
        List<Item> items = itemRepository.selectList(wrapper);
        
        // 统计每个位置的出现次数
        Map<String, Long> locations = new LinkedHashMap<>();
        for (Item item : items) {
            String location = item.getLocation();
            if (location != null && !location.trim().isEmpty()) {
                locations.put(location, locations.getOrDefault(location, 0L) + 1);
            }
        }
        
        // 按数量排序并取前 20 个
        return locations.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(20)
                .collect(java.util.stream.Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (e1, e2) -> e1,
                        LinkedHashMap::new
                ));
    }

    private long countItemsByStatuses(List<String> statuses) {
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Item::getDeleted, 0).in(Item::getStatus, statuses);
        return itemRepository.selectCount(wrapper);
    }

    private long countConfirmedMatches() {
        LambdaQueryWrapper<Match> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Match::getStatus, "CONFIRMED");
        return matchRepository.selectCount(wrapper);
    }
}
