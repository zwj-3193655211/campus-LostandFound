package com.campus.lostfound.modules.verification.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.service.DocumentOwnerMatchService;
import com.campus.lostfound.modules.match.service.MatchingService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.verification.entity.Verification;
import com.campus.lostfound.modules.verification.service.VerificationService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

/**
 * 审核控制器（管理员）
 */
@RestController
@RequestMapping("/api/admin")
public class VerificationController {

    private final VerificationService verificationService;
    private final ItemRepository itemRepository;
    private final NotificationService notificationService;
    private final MatchingService matchingService;
    private final DocumentOwnerMatchService documentOwnerMatchService;

    public VerificationController(VerificationService verificationService, ItemRepository itemRepository,
                                  NotificationService notificationService,
                                  MatchingService matchingService,
                                  DocumentOwnerMatchService documentOwnerMatchService) {
        this.verificationService = verificationService;
        this.itemRepository = itemRepository;
        this.notificationService = notificationService;
        this.matchingService = matchingService;
        this.documentOwnerMatchService = documentOwnerMatchService;
    }

    /**
     * 待审核物品列表
     */
    @GetMapping("/items/pending")
    public ApiResponse<?> getPendingItems() {
        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Item::getStatus, ItemConstants.Status.PENDING)
                .orderByAsc(Item::getCreatedAt);
        return ApiResponse.success(itemRepository.selectList(wrapper));
    }

    /**
     * 审核物品
     */
    @PutMapping("/items/{id}/approve")
    public ApiResponse<Void> approveItem(@PathVariable("id") Long id, @AuthenticationPrincipal User admin) {
        Item item = itemRepository.selectById(id);
        if (item == null) {
            return ApiResponse.error("物品不存在");
        }

        item.setStatus(ItemConstants.Status.APPROVED);
        itemRepository.updateById(item);

        try {
            matchingService.match(id);
            notificationService.notifyVerificationResult(id, "APPROVED", null);
            documentOwnerMatchService.notifyPotentialOwnerForItem(item);
        } catch (Exception e) {
            // 忽略通知失败
        }

        return ApiResponse.success("审核通过", null);
    }

    /**
     * 拒绝物品
     */
    @PutMapping("/items/{id}/reject")
    public ApiResponse<Void> rejectItem(@PathVariable("id") Long id,
                                     @RequestParam("reason") String reason,
                                     @AuthenticationPrincipal User admin) {
        String normalizedReason = normalizeReason(reason);
        validateRejectReason(normalizedReason);

        Item item = itemRepository.selectById(id);
        if (item == null) {
            return ApiResponse.error("物品不存在");
        }

        item.setStatus(ItemConstants.Status.REJECTED);
        itemRepository.updateById(item);

        // 发送通知
        try {
            notificationService.notifyVerificationResult(id, "REJECTED", normalizedReason);
        } catch (Exception e) {
            // 忽略通知失败
        }

        return ApiResponse.success("已拒绝", null);
    }

    /**
     * 认领审核列表
     */
    @GetMapping("/verifications")
    public ApiResponse<?> getVerifications(@RequestParam(value = "itemId", required = false) Long itemId) {
        return ApiResponse.success(verificationService.getVerifications(itemId));
    }

    /**
     * 审核认领申请
     */
    @PutMapping("/verifications/{id}/review")
    public ApiResponse<Void> reviewVerification(@PathVariable("id") Long id,
                                              @RequestParam("approved") boolean approved,
                                              @RequestParam(value = "reason", required = false) String reason,
                                              @AuthenticationPrincipal User admin) {
        String normalizedReason = normalizeReason(reason);
        validateReviewReason(approved, normalizedReason);
        verificationService.review(id, admin.getId(), approved, normalizedReason);
        return ApiResponse.success(approved ? "审核通过" : "已拒绝", null);
    }

    private void validateRejectReason(String reason) {
        if (!StringUtils.hasText(reason)) {
            throw new BusinessException("拒绝原因不能为空");
        }
    }

    private void validateReviewReason(boolean approved, String reason) {
        if (!approved && !StringUtils.hasText(reason)) {
            throw new BusinessException("拒绝原因不能为空");
        }
    }

    private String normalizeReason(String reason) {
        return StringUtils.hasText(reason) ? reason.trim() : null;
    }
}
