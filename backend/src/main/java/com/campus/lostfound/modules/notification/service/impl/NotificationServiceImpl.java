package com.campus.lostfound.modules.notification.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.notification.entity.Notification;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import com.campus.lostfound.modules.notification.service.MailService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.verification.entity.Verification;
import com.campus.lostfound.modules.verification.repository.VerificationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 通知服务实现
 */
@Service
public class NotificationServiceImpl implements NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationServiceImpl.class);

    private final NotificationRepository notificationRepository;
    private final ItemRepository itemRepository;
    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    private final VerificationRepository verificationRepository;
    private final MailService mailService;

    public NotificationServiceImpl(NotificationRepository notificationRepository, ItemRepository itemRepository,
                                   MatchRepository matchRepository, UserRepository userRepository,
                                   VerificationRepository verificationRepository, MailService mailService) {
        this.notificationRepository = notificationRepository;
        this.itemRepository = itemRepository;
        this.matchRepository = matchRepository;
        this.userRepository = userRepository;
        this.verificationRepository = verificationRepository;
        this.mailService = mailService;
    }

    @Override
    @Transactional
    public void create(Long userId, String type, String title, String content, Long relatedId) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setType(type);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setRelatedId(relatedId);
        notification.setIsRead(0);
        notification.setCreatedAt(LocalDateTime.now());

        notificationRepository.insert(notification);
    }

    @Override
    @Transactional
    public void notifyMatchFound(Long itemId, Long matchId) {
        Item item = itemRepository.selectById(itemId);
        if (item == null) {
            return;
        }

        String typeLabel = "LOST".equals(item.getType()) ? "寻物启示" : "失物招领";
        String title = "发现匹配物品";
        String content = String.format("您发布的【%s】\"%s\"找到了匹配的%s，请查看详情",
                typeLabel, item.getTitle(), "LOST".equals(item.getType()) ? "失物招领" : "寻物启示");

        create(item.getUserId(), ItemConstants.NotificationType.MATCH_FOUND, title, content, matchId);

        User user = userRepository.selectById(item.getUserId());
        if (user != null && Integer.valueOf(1).equals(user.getNotificationMatch())) {
            sendMatchEmail(item, matchId);
        }

        log.info("发送匹配通知: itemId={}, matchId={}", itemId, matchId);
    }

    /**
     * 发送匹配邮件通知
     */
    private void sendMatchEmail(Item item, Long matchId) {
        try {
            Match match = matchRepository.selectById(matchId);
            if (match == null) {
                return;
            }

            // 获取用户信息
            User user = userRepository.selectById(item.getUserId());
            if (user == null || user.getEmail() == null || user.getEmail().isBlank()) {
                log.warn("User email is empty, skip sending email. userId={}", item.getUserId());
                return;
            }

            // 判断是哪一方找另一方（发布的是LOST则找FOUND，反之亦然）
            Item matchedItem;
            if ("LOST".equals(item.getType())) {
                matchedItem = itemRepository.selectById(match.getFoundItemId());
            } else {
                matchedItem = itemRepository.selectById(match.getLostItemId());
            }

            if (matchedItem == null) {
                return;
            }

            // 发送邮件
            mailService.sendMatchNotificationEmail(
                    user.getEmail(),
                    user.getUsername(),
                    item,
                    matchedItem,
                    match
            );

            log.info("匹配邮件已发送: matchId={}, to={}", matchId, user.getEmail());
        } catch (Exception e) {
            log.error("发送匹配邮件失败: matchId={}, error={}", matchId, e.getMessage());
        }
    }

    @Override
    @Transactional
    public void notifyVerificationResult(Long itemId, String status, String reason) {
        Item item = itemRepository.selectById(itemId);
        if (item == null) {
            return;
        }

        String title;
        String content;

        if ("APPROVED".equals(status)) {
            title = "物品审核通过";
            content = String.format("您发布的\"%s\"已审核通过，现在可以开始匹配了", item.getTitle());
        } else {
            title = "物品审核未通过";
            content = String.format("您发布的\"%s\"未通过审核，原因：%s", item.getTitle(), reason);
        }

        create(item.getUserId(), ItemConstants.NotificationType.VERIFICATION_RESULT, title, content, itemId);

        User user = userRepository.selectById(item.getUserId());
        if (user != null && Integer.valueOf(1).equals(user.getNotificationVerification())) {
            sendVerificationEmail(item, status, reason);
        }

        log.info("发送审核通知: itemId={}, status={}", itemId, status);
    }

    @Override
    @Transactional
    public void notifyClaimReviewResult(Long verificationId, String status, String reason) {
        Verification verification = verificationRepository.selectById(verificationId);
        if (verification == null) {
            return;
        }

        Item item = itemRepository.selectById(verification.getItemId());
        User claimant = userRepository.selectById(verification.getClaimantId());
        if (item == null || claimant == null) {
            return;
        }

        boolean approved = "APPROVED".equals(status);
        String title = approved ? "认领申请已通过" : "认领申请未通过";
        String content = approved
                ? String.format("您对物品\"%s\"提交的认领申请已通过，请尽快联系对方完成认领", item.getTitle())
                : String.format("您对物品\"%s\"提交的认领申请未通过，原因：%s", item.getTitle(), reason);

        create(claimant.getId(), ItemConstants.NotificationType.CLAIM_REVIEW_RESULT, title, content, item.getId());

        if (Integer.valueOf(1).equals(claimant.getNotificationVerification())
                && claimant.getEmail() != null && !claimant.getEmail().isBlank()) {
            mailService.sendSimpleEmail(
                    claimant.getEmail(),
                    title,
                    content
            );
        }

        log.info("发送认领审核结果通知: verificationId={}, claimantId={}, status={}",
                verificationId, claimant.getId(), status);
    }

    /**
     * 发送审核邮件通知
     */
    private void sendVerificationEmail(Item item, String status, String reason) {
        try {
            User user = userRepository.selectById(item.getUserId());
            if (user == null || user.getEmail() == null || user.getEmail().isBlank()) {
                log.warn("User email is empty, skip sending email. userId={}", item.getUserId());
                return;
            }

            boolean approved = "APPROVED".equals(status);
            mailService.sendVerificationEmail(
                    user.getEmail(),
                    user.getUsername(),
                    item,
                    approved,
                    approved ? null : reason
            );

            log.info("审核邮件已发送: itemId={}, to={}, approved={}", item.getId(), user.getEmail(), approved);
        } catch (Exception e) {
            log.error("发送审核邮件失败: itemId={}, error={}", item.getId(), e.getMessage());
        }
    }

    @Override
    public long getUnreadCount(Long userId) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId);
        wrapper.eq(Notification::getIsRead, 0);
        return notificationRepository.selectCount(wrapper);
    }

    @Override
    public PageResponse<Notification> getUserNotifications(Long userId, int page, int pageSize) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId);
        wrapper.orderByDesc(Notification::getCreatedAt);

        Page<Notification> result = notificationRepository.selectPage(new Page<>(page, pageSize), wrapper);
        return PageResponse.of(result.getRecords(), result.getTotal(), page, pageSize);
    }

    @Override
    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.selectById(notificationId);
        if (notification != null && notification.getUserId().equals(userId)) {
            notification.setIsRead(1);
            notificationRepository.updateById(notification);
        }
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId);
        wrapper.eq(Notification::getIsRead, 0);

        List<Notification> notifications = notificationRepository.selectList(wrapper);
        for (Notification notification : notifications) {
            notification.setIsRead(1);
            notificationRepository.updateById(notification);
        }
    }
}
