package com.campus.lostfound.modules.statistics.controller;

import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.statistics.service.StatisticsService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 统计控制�? */
@RestController
@RequestMapping("/api/admin/statistics")
public class StatisticsController {

    private final StatisticsService statisticsService;

    public StatisticsController(StatisticsService statisticsService) {
        this.statisticsService = statisticsService;
    }

    /**
     * 仪表盘数据
     */
    @GetMapping("/dashboard")
    public ApiResponse<Map<String, Object>> getDashboard() {
        return ApiResponse.success(statisticsService.getDashboard());
    }

    /**
     * 今日统计
     */
    @GetMapping("/today")
    public ApiResponse<Map<String, Object>> getTodayStats() {
        return ApiResponse.success(statisticsService.getTodayStats());
    }

    /**
     * 按时间段统计
     */
    @GetMapping("/period")
    public ApiResponse<Map<String, Object>> getStatsByPeriod(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        return ApiResponse.success(statisticsService.getStatsByPeriod(startDate, endDate));
    }

    /**
     * 热门类别
     */
    @GetMapping("/categories")
    public ApiResponse<Map<String, Long>> getPopularCategories() {
        return ApiResponse.success(statisticsService.getPopularCategories());
    }

    /**
     * 热门位置
     */
    @GetMapping("/locations")
    public ApiResponse<Map<String, Long>> getPopularLocations() {
        return ApiResponse.success(statisticsService.getPopularLocations());
    }
}