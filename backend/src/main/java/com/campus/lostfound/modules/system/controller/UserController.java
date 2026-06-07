package com.campus.lostfound.modules.system.controller;

import cn.dev33.satoken.stp.StpUtil;
import com.campus.lostfound.common.dto.request.UserUpdateRequest;
import com.campus.lostfound.common.dto.request.VerificationRequest;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.service.UserService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 用户控制器（集成 Sa-Token）
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/profile")
    public ApiResponse<User> getProfile(@AuthenticationPrincipal User user) {
        return ApiResponse.success(userService.getById(user.getId()));
    }

    /**
     * 更新用户信息
     */
    @PutMapping("/profile")
    public ApiResponse<User> updateProfile(@AuthenticationPrincipal User user,
                                          @Valid @RequestBody UserUpdateRequest request) {
        return ApiResponse.success(userService.updateProfile(user.getId(), request));
    }

    /**
     * 实名认证
     */
    @PostMapping("/verify")
    public ApiResponse<User> verify(@AuthenticationPrincipal User user,
                                   @Valid @RequestBody VerificationRequest request) {
        return ApiResponse.success(userService.verifyIdentity(user.getId(), request));
    }

    /**
     * 修改密码
     */
    @PostMapping("/change-password")
    public ApiResponse<Void> changePassword(@AuthenticationPrincipal User user,
                                           @RequestBody Map<String, String> request) {
        String oldPassword = request.get("oldPassword");
        String newPassword = request.get("newPassword");
        userService.changePassword(user.getId(), oldPassword, newPassword);
        return ApiResponse.success("密码修改成功", null);
    }

    /**
     * 更新通知设置
     */
    @PutMapping("/notification-settings")
    public ApiResponse<User> updateNotificationSettings(@AuthenticationPrincipal User user,
                                                       @RequestBody Map<String, Boolean> settings) {
        return ApiResponse.success(userService.updateNotificationSettings(user.getId(), settings));
    }

    /**
     * 用户注销
     */
    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        StpUtil.logout();
        return ApiResponse.success("注销成功", null);
    }

    /**
     * 检查登录状态
     */
    @GetMapping("/is-login")
    public ApiResponse<Boolean> isLogin() {
        return ApiResponse.success(StpUtil.isLogin());
    }
}
