package com.campus.lostfound.modules.notification.controller;

import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.notification.entity.Notification;
import com.campus.lostfound.modules.notification.service.MailService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

/**
 * 通知控制器
 */
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final MailService mailService;
    private final ItemRepository itemRepository;
    private final MatchRepository matchRepository;
    private final UserRepository userRepository;

    public NotificationController(NotificationService notificationService, MailService mailService,
                                  ItemRepository itemRepository, MatchRepository matchRepository,
                                  UserRepository userRepository) {
        this.notificationService = notificationService;
        this.mailService = mailService;
        this.itemRepository = itemRepository;
        this.matchRepository = matchRepository;
        this.userRepository = userRepository;
    }

    @GetMapping
    public ApiResponse<PageResponse<Notification>> listNotifications(
            @AuthenticationPrincipal User user,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "pageSize", defaultValue = "20") int pageSize) {
        return ApiResponse.success(notificationService.getUserNotifications(user.getId(), page, pageSize));
    }

    @GetMapping("/unread-count")
    public ApiResponse<Long> unreadCount(@AuthenticationPrincipal User user) {
        return ApiResponse.success(notificationService.getUnreadCount(user.getId()));
    }

    @PostMapping("/{id}/read")
    public ApiResponse<Void> markAsRead(@PathVariable Long id, @AuthenticationPrincipal User user) {
        notificationService.markAsRead(id, user.getId());
        return ApiResponse.success("已标记为已读", null);
    }

    @PostMapping("/read-all")
    public ApiResponse<Void> markAllAsRead(@AuthenticationPrincipal User user) {
        notificationService.markAllAsRead(user.getId());
        return ApiResponse.success("已全部标记为已读", null);
    }

    @PostMapping("/send-test-email")
    public ApiResponse<String> sendTestEmail(@RequestParam("email") String email) {
        boolean result = mailService.sendTestEmail(email);
        return ApiResponse.success(result ? "邮件发送成功" : "邮件发送失败", String.valueOf(result));
    }

    /**
     * 直接发送匹配邮件 - 测试用
     */
    @PostMapping("/send-match-email")
    public ApiResponse<String> sendMatchEmailDirect(
            @RequestParam("lostItemId") Long lostItemId,
            @RequestParam("foundItemId") Long foundItemId) {

        Item lostItem = itemRepository.selectById(lostItemId);
        Item foundItem = itemRepository.selectById(foundItemId);

        if (lostItem == null || foundItem == null) {
            return ApiResponse.success("物品不存在", "fail");
        }

        // 创建模拟的匹配记录
        Match match = new Match();
        match.setId(System.currentTimeMillis());
        match.setLostItemId(lostItemId);
        match.setFoundItemId(foundItemId);
        match.setScore(new BigDecimal("0.85"));
        match.setMatchType("WEIGHTED");
        match.setStatus("PENDING");

        // 发送给丢失物品的用户
        User lostUser = userRepository.selectById(lostItem.getUserId());
        if (lostUser != null && lostUser.getEmail() != null) {
            mailService.sendMatchNotificationEmail(
                    lostUser.getEmail(),
                    lostUser.getUsername(),
                    lostItem,
                    foundItem,
                    match
            );
        }

        // 也发送给拾取物品的用户
        User foundUser = userRepository.selectById(foundItem.getUserId());
        if (foundUser != null && foundUser.getEmail() != null) {
            mailService.sendMatchNotificationEmail(
                    foundUser.getEmail(),
                    foundUser.getUsername(),
                    foundItem,
                    lostItem,
                    match
            );
        }

        return ApiResponse.success("匹配邮件已发送", "ok");
    }
}
