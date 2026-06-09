package com.campus.lostfound.modules.item.controller;

import com.campus.lostfound.common.result.ApiResponse;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * 位置控制器
 */
@RestController
@RequestMapping("/api/locations")
public class LocationController {

    private static final List<String> LOCATIONS = Arrays.asList(
            "图书馆",
            "教学楼",
            "食堂",
            "宿舍",
            "体育馆",
            "操场",
            "行政楼",
            "实验室",
            "校医院",
            "校门口",
            "停车场",
            "超市",
            "快递点",
            "其他"
    );

    @GetMapping
    public ApiResponse<List<String>> getAllLocations() {
        return ApiResponse.success(LOCATIONS);
    }

    @GetMapping("/suggestions")
    public ApiResponse<List<String>> getSuggestions(@RequestParam(required = false) String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return ApiResponse.success(LOCATIONS);
        }
        String lowerKeyword = keyword.toLowerCase();
        List<String> suggestions = LOCATIONS.stream()
                .filter(loc -> loc.toLowerCase().contains(lowerKeyword))
                .toList();
        return ApiResponse.success(suggestions);
    }

    @PostMapping
    public ApiResponse<String> createLocation(@RequestBody Map<String, String> request) {
        String name = request.get("name");
        if (name == null || name.trim().isEmpty()) {
            return ApiResponse.error("位置名称不能为空");
        }
        if (!LOCATIONS.contains(name)) {
            LOCATIONS.add(name);
        }
        return ApiResponse.success(name);
    }

    @PutMapping("/{id}")
    public ApiResponse<String> updateLocation(@PathVariable int id, @RequestBody Map<String, String> request) {
        String name = request.get("name");
        if (id < 0 || id >= LOCATIONS.size()) {
            return ApiResponse.error("位置不存在");
        }
        if (name == null || name.trim().isEmpty()) {
            return ApiResponse.error("位置名称不能为空");
        }
        LOCATIONS.set(id, name);
        return ApiResponse.success(name);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteLocation(@PathVariable int id) {
        if (id < 0 || id >= LOCATIONS.size()) {
            return ApiResponse.error("位置不存在");
        }
        LOCATIONS.remove(id);
        return ApiResponse.success("删除成功", null);
    }
}
