package com.campus.lostfound.modules.item.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.item.service.ItemCompletionRequestService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ItemCompletionRequestServiceImpl implements ItemCompletionRequestService {

    private static final Logger log = LoggerFactory.getLogger(ItemCompletionRequestServiceImpl.class);
    
    private final ItemCompletionRequestRepository completionRequestRepository;
    private final ItemRepository itemRepository;
    private final NotificationService notificationService;

    public ItemCompletionRequestServiceImpl(ItemCompletionRequestRepository completionRequestRepository,
                                            ItemRepository itemRepository,
                                            NotificationService notificationService) {
        this.completionRequestRepository = completionRequestRepository;
        this.itemRepository = itemRepository;
        this.notificationService = notificationService;
    }

    @Override
    @Transactional
    public ItemCompletionRequest submit(Long itemId, Long userId, String targetStatus, String reason) {
        Item item = itemRepository.selectById(itemId);
        if (item == null) {
            throw new BusinessException("物品不存在");
        }
        if (!userId.equals(item.getUserId())) {
            throw new BusinessException("无权提交该物品的完成申请");
        }
        if (!ItemConstants.Status.APPROVED.equals(item.getStatus())) {
            throw new BusinessException("仅已审核发布且未完成的物品允许提交完成申请");
        }

        String expectedStatus = ItemConstants.Type.LOST.equals(item.getType())
                ? ItemConstants.Status.FOUND_BACK
                : ItemConstants.Status.RETURNED;
        if (!expectedStatus.equals(targetStatus)) {
            throw new BusinessException("当前物品类型不支持该目标状态");
        }

        LambdaQueryWrapper<ItemCompletionRequest> existingWrapper = new LambdaQueryWrapper<>();
        existingWrapper.eq(ItemCompletionRequest::getItemId, itemId)
                .eq(ItemCompletionRequest::getStatus, ItemConstants.CompletionStatus.PENDING)
                .orderByDesc(ItemCompletionRequest::getCreatedAt)
                .last("LIMIT 1");
        ItemCompletionRequest existing = completionRequestRepository.selectOne(existingWrapper);
        if (existing != null) {
            throw new BusinessException("该物品已有待审核的完成申请");
        }

        ItemCompletionRequest request = new ItemCompletionRequest();
        request.setItemId(itemId);
        request.setUserId(userId);
        request.setTargetStatus(targetStatus);
        request.setReason(reason);
        request.setStatus(ItemConstants.CompletionStatus.PENDING);
        request.setCreatedAt(LocalDateTime.now());
        request.setUpdatedAt(LocalDateTime.now());
        completionRequestRepository.insert(request);

        // 通知管理员有新的完成申请待审核
        try {
            notificationService.notifyAdminForCompletionRequest(itemId, item.getTitle(), targetStatus);
        } catch (Exception e) {
            // 通知失败不影响主流程
            log.error("通知管理员完成申请失败: itemId={}", itemId, e);
        }

        return request;
    }

    @Override
    @Transactional
    public void review(Long requestId, Long adminId, boolean approved, String reason) {
        ItemCompletionRequest request = completionRequestRepository.selectById(requestId);
        if (request == null) {
            throw new BusinessException("完成申请不存在");
        }
        if (!ItemConstants.CompletionStatus.PENDING.equals(request.getStatus())) {
            throw new BusinessException("该完成申请已处理");
        }

        Item item = itemRepository.selectById(request.getItemId());
        if (item == null) {
            throw new BusinessException("关联物品不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        request.setReviewedBy(adminId);
        request.setReviewedAt(now);
        request.setUpdatedAt(now);
        request.setReviewReason(reason);

        if (approved) {
            request.setStatus(ItemConstants.CompletionStatus.APPROVED);
        } else {
            request.setStatus(ItemConstants.CompletionStatus.REJECTED);
        }

        ItemCompletionRequest requestUpdate = new ItemCompletionRequest();
        requestUpdate.setReviewedBy(adminId);
        requestUpdate.setReviewedAt(now);
        requestUpdate.setUpdatedAt(now);
        requestUpdate.setReviewReason(reason);
        requestUpdate.setStatus(request.getStatus());

        int updatedRows = completionRequestRepository.update(
                requestUpdate,
                new LambdaUpdateWrapper<ItemCompletionRequest>()
                        .eq(ItemCompletionRequest::getId, requestId)
                        .eq(ItemCompletionRequest::getStatus, ItemConstants.CompletionStatus.PENDING)
        );
        if (updatedRows == 0) {
            throw new BusinessException("该完成申请已处理");
        }

        if (approved) {
            Item itemUpdate = new Item();
            itemUpdate.setStatus(request.getTargetStatus());
            itemUpdate.setUpdatedAt(now);
            int itemUpdatedRows = itemRepository.update(
                    itemUpdate,
                    new LambdaUpdateWrapper<Item>()
                            .eq(Item::getId, item.getId())
                            .eq(Item::getStatus, ItemConstants.Status.APPROVED)
            );
            if (itemUpdatedRows == 0) {
                throw new BusinessException("关联物品状态已变更，请刷新后重试");
            }
            item.setStatus(request.getTargetStatus());
            item.setUpdatedAt(now);
        }

        try {
            notificationService.create(
                    request.getUserId(),
                    ItemConstants.NotificationType.COMPLETION_REVIEW_RESULT,
                    approved ? "完成申请已通过" : "完成申请未通过",
                    buildReviewContent(item, request, approved, reason),
                    item.getId()
            );
        } catch (Exception ignored) {
            // 站内通知失败不影响主流程
        }
    }

    @Override
    public List<ItemCompletionRequest> listPending() {
        LambdaQueryWrapper<ItemCompletionRequest> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ItemCompletionRequest::getStatus, ItemConstants.CompletionStatus.PENDING)
                .orderByAsc(ItemCompletionRequest::getCreatedAt);
        return completionRequestRepository.selectList(wrapper);
    }

    @Override
    public Map<Long, ItemCompletionRequest> findLatestPendingByItemIds(List<Long> itemIds) {
        Map<Long, ItemCompletionRequest> latestMap = new LinkedHashMap<>();
        if (itemIds == null || itemIds.isEmpty()) {
            return latestMap;
        }

        LambdaQueryWrapper<ItemCompletionRequest> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(ItemCompletionRequest::getItemId, itemIds)
                .eq(ItemCompletionRequest::getStatus, ItemConstants.CompletionStatus.PENDING)
                .orderByDesc(ItemCompletionRequest::getCreatedAt);

        for (ItemCompletionRequest request : completionRequestRepository.selectList(wrapper)) {
            latestMap.putIfAbsent(request.getItemId(), request);
        }
        return latestMap;
    }

    private String buildReviewContent(Item item, ItemCompletionRequest request, boolean approved, String reason) {
        String targetText = ItemConstants.Status.FOUND_BACK.equals(request.getTargetStatus()) ? "已找到" : "已归还";
        if (approved) {
            return String.format("您提交的物品\"%s\"状态变更申请已通过，当前状态已更新为%s", item.getTitle(), targetText);
        }
        return String.format("您提交的物品\"%s\"状态变更申请未通过，原因：%s", item.getTitle(), reason);
    }
}
