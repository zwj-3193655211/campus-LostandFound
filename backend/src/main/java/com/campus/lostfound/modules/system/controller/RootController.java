package com.campus.lostfound.modules.system.controller;

import com.campus.lostfound.common.result.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/")
public class RootController {

    @GetMapping
    public ApiResponse<Map<String, Object>> root() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "Campus Lost & Found Platform");
        info.put("version", "1.0.0");
        info.put("status", "running");
        info.put("api", "/api");
        info.put("swagger", "/swagger-ui.html");
        return ApiResponse.success(info);
    }

    @GetMapping("/api")
    public ApiResponse<String> api() {
        return ApiResponse.success("Welcome to Campus Lost & Found API");
    }
}