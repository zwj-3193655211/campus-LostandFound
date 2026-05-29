package com.campus.lostfound.modules.notification.service;

import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.notification.entity.Notification;

/**
 * 通知服务接口
 */
public interface NotificationService {

    /**
     * 创建通知
     */
    void create(Long userId, String type, String title, String content, Long relatedId);

    /**
     * 发送匹配通知
     */
    void notifyMatchFound(Long itemId, Long matchId);

    /**
     * 发送审核结果通知
     */
    void notifyVerificationResult(Long itemId, String status, String reason);

    /**
     * 发送认领审核结果通知
     */
    void notifyClaimReviewResult(Long verificationId, String status, String reason);

    /**
     * 获取用户未读通知数量
     */
    long getUnreadCount(Long userId);

    /**
     * 获取用户通知列表
     */
    PageResponse<Notification> getUserNotifications(Long userId, int page, int pageSize);

    /**
     * 标记通知为已读
     */
    void markAsRead(Long notificationId, Long userId);

    /**
     * 标记所有通知为已�?     */
    void markAllAsRead(Long userId);
}
