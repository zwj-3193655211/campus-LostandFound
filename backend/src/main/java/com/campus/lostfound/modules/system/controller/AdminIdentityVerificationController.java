package com.campus.lostfound.modules.system.controller;

import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.entity.UserIdentityVerification;
import com.campus.lostfound.modules.system.service.UserService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/identity-verifications")
public class AdminIdentityVerificationController {

    private final UserService userService;

    public AdminIdentityVerificationController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ApiResponse<List<UserIdentityVerification>> listPending() {
        return ApiResponse.success(userService.listPendingIdentityVerifications());
    }

    @GetMapping("/history")
    public ApiResponse<List<UserIdentityVerification>> listHistory() {
        return ApiResponse.success(userService.listIdentityVerificationHistory());
    }

    @PutMapping("/{id}/review")
    public ApiResponse<Void> review(@PathVariable Long id,
                                    @RequestParam("approved") boolean approved,
                                    @RequestParam(value = "reason", required = false) String reason,
                                    @AuthenticationPrincipal User admin) {
        userService.reviewIdentityVerification(id, admin.getId(), approved, reason);
        return ApiResponse.success(approved ? "实名认证审核通过" : "实名认证审核已拒绝", null);
    }
}
