package com.campus.lostfound.modules.item.controller;

import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;
import com.campus.lostfound.modules.item.service.ItemCompletionRequestService;
import com.campus.lostfound.modules.system.entity.User;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/completion-requests")
public class AdminCompletionRequestController {

    private final ItemCompletionRequestService completionRequestService;

    public AdminCompletionRequestController(ItemCompletionRequestService completionRequestService) {
        this.completionRequestService = completionRequestService;
    }

    @GetMapping
    public ApiResponse<List<ItemCompletionRequest>> listPending() {
        return ApiResponse.success(completionRequestService.listPending());
    }

    @PutMapping("/{id}/review")
    public ApiResponse<Void> review(@PathVariable("id") Long id,
                                    @RequestParam("approved") boolean approved,
                                    @RequestParam(value = "reason", required = false) String reason,
                                    @AuthenticationPrincipal User admin) {
        String normalizedReason = StringUtils.hasText(reason) ? reason.trim() : null;
        if (!approved && !StringUtils.hasText(normalizedReason)) {
            throw new BusinessException("拒绝原因不能为空");
        }
        completionRequestService.review(id, admin.getId(), approved, normalizedReason);
        return ApiResponse.success(approved ? "审核通过" : "审核拒绝", null);
    }
}
