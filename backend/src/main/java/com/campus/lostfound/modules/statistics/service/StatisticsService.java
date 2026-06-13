package com.campus.lostfound.modules.statistics.service;

import java.util.Map;

/**
 * 统计服务接口
 */
public interface StatisticsService {

    /**
     * 获取仪表盘数据
     */
    Map<String, Object> getDashboard();

    /**
     * 获取首页公开统计
     */
    Map<String, Object> getPublicOverview();

    /**
     * 获取今日统计
     */
    Map<String, Object> getTodayStats();

    /**
     * 按时间段统计
     */
    Map<String, Object> getStatsByPeriod(String startDate, String endDate);

    /**
     * 获取热门失物类别
     */
    Map<String, Long> getPopularCategories();

    /**
     * 获取热门位置
     */
    Map<String, Long> getPopularLocations();
}
