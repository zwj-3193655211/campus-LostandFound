package com.campus.lostfound.modules.system.controller;

import com.campus.lostfound.common.dto.request.LoginRequest;
import com.campus.lostfound.common.dto.request.RegisterRequest;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.system.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public ApiResponse<String> register(@Valid @RequestBody RegisterRequest request) {
        String result = authService.register(request);
        return ApiResponse.success(result);
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public ApiResponse<Object> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.success(authService.login(request));
    }

    /**
     * 刷新Token
     */
    @PostMapping("/refresh")
    public ApiResponse<java.util.Map<String, Object>> refresh(@RequestBody java.util.Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        java.util.Map<String, Object> result = authService.refreshToken(refreshToken);
        return ApiResponse.success(result);
    }
}