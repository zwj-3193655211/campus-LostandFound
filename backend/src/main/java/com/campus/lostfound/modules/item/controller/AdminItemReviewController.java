package com.campus.lostfound.modules.item.controller;

import com.campus.lostfound.common.dto.request.ItemReviewRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.service.ItemService;
import com.campus.lostfound.modules.system.entity.User;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 管理员物品审核。
 *
 * 接口:
 *   GET  /api/admin/items/pending            - 列出待审核物品(简单列表)
 *   GET  /api/admin/items?status=PENDING     - 分页查(支持 status 过滤,适配仪表盘)
 *   PUT  /api/admin/items/{id}/review         - 审核(approved=true|false,reason 仅拒绝时必填)
 *
 * 权限:/api/admin/** 已被 WebSecurityConfig 限制为 SUPER_ADMIN / CAMPUS_ADMIN。
 */
@RestController
@RequestMapping("/api/admin/items")
public class AdminItemReviewController {

    private final ItemService itemService;

    public AdminItemReviewController(ItemService itemService) {
        this.itemService = itemService;
    }

    @GetMapping("/pending")
    public ApiResponse<List<Item>> listPending() {
        return ApiResponse.success(itemService.listPending());
    }

    @GetMapping
    public ApiResponse<PageResponse<Item>> list(
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "pageSize", defaultValue = "20") int pageSize) {
        return ApiResponse.success(itemService.adminListByStatus(status, page, pageSize));
    }

    @PutMapping("/{id}/review")
    public ApiResponse<Item> review(@PathVariable("id") Long id,
                                    @Valid @RequestBody ItemReviewRequest request,
                                    @AuthenticationPrincipal User admin) {
        if (request.getApproved() == null) {
            throw new BusinessException("approved 参数不能为空");
        }
        String reason = StringUtils.hasText(request.getReason()) ? request.getReason().trim() : null;
        if (!request.getApproved() && !StringUtils.hasText(reason)) {
            throw new BusinessException("拒绝原因不能为空");
        }
        Item updated = itemService.review(id, admin.getId(), request.getApproved(), reason);
        return ApiResponse.success(
                request.getApproved() ? "审核通过" : "审核拒绝",
                updated);
    }
}
