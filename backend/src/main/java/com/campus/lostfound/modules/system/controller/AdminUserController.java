package com.campus.lostfound.modules.system.controller;

import com.campus.lostfound.common.dto.request.AdminUserRoleUpdateRequest;
import com.campus.lostfound.common.dto.request.AdminUserStatusUpdateRequest;
import com.campus.lostfound.common.dto.request.UserUpdateRequest;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.service.UserService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * 管理端用户管理控制器
 */
@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {

    private final UserService userService;

    public AdminUserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ApiResponse<PageResponse<User>> listUsers(
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "role", required = false) String role,
            @RequestParam(value = "status", required = false) Integer status,
            @RequestParam(value = "verified", required = false) Boolean verified,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "pageSize", defaultValue = "10") int pageSize) {
        return ApiResponse.success(userService.adminQueryUsers(keyword, role, status, verified, page, pageSize));
    }

    @PutMapping("/{id}")
    public ApiResponse<User> updateUser(@PathVariable Long id,
                                        @Valid @RequestBody UserUpdateRequest request,
                                        @AuthenticationPrincipal User admin) {
        User user = userService.adminUpdateUser(
                admin.getId(),
                admin.getRole(),
                id,
                request.getEmail(),
                request.getPhone()
        );
        return ApiResponse.success(user);
    }

    @PutMapping("/{id}/role")
    public ApiResponse<User> changeRole(@PathVariable Long id,
                                        @Valid @RequestBody AdminUserRoleUpdateRequest request,
                                        @AuthenticationPrincipal User admin) {
        User user = userService.adminChangeRole(
                admin.getId(),
                admin.getRole(),
                id,
                request.getRole()
        );
        return ApiResponse.success(user);
    }

    @PutMapping("/{id}/status")
    public ApiResponse<User> changeStatus(@PathVariable Long id,
                                          @Valid @RequestBody AdminUserStatusUpdateRequest request,
                                          @AuthenticationPrincipal User admin) {
        User user = userService.adminChangeStatus(
                admin.getId(),
                admin.getRole(),
                id,
                request.getStatus()
        );
        return ApiResponse.success(user);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteUser(@PathVariable Long id, @AuthenticationPrincipal User admin) {
        userService.adminDeleteUser(admin.getId(), admin.getRole(), id);
        return ApiResponse.success("删除成功", null);
    }
}
