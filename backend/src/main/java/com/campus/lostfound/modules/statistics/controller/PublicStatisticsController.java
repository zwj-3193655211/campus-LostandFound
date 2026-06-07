package com.campus.lostfound.modules.statistics.controller;

import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.statistics.service.StatisticsService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 首页公开统计接口
 */
@RestController
@RequestMapping("/api/statistics")
public class PublicStatisticsController {

    private final StatisticsService statisticsService;

    public PublicStatisticsController(StatisticsService statisticsService) {
        this.statisticsService = statisticsService;
    }

    @GetMapping("/overview")
    public ApiResponse<Map<String, Object>> getOverview() {
        return ApiResponse.success(statisticsService.getPublicOverview());
    }

    @GetMapping("/categories")
    public ApiResponse<Map<String, Long>> getCategories() {
        return ApiResponse.success(statisticsService.getPopularCategories());
    }
}
