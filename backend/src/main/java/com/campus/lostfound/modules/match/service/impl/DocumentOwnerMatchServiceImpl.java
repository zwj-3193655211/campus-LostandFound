package com.campus.lostfound.modules.match.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.constant.UserConstants;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.service.DocumentOwnerMatchService;
import com.campus.lostfound.modules.notification.entity.Notification;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DocumentOwnerMatchServiceImpl implements DocumentOwnerMatchService {

    private final UserRepository userRepository;
    private final ItemRepository itemRepository;
    private final NotificationRepository notificationRepository;
    private final NotificationService notificationService;

    public DocumentOwnerMatchServiceImpl(UserRepository userRepository,
                                         ItemRepository itemRepository,
                                         NotificationRepository notificationRepository,
                                         NotificationService notificationService) {
        this.userRepository = userRepository;
        this.itemRepository = itemRepository;
        this.notificationRepository = notificationRepository;
        this.notificationService = notificationService;
    }

    @Override
    public void notifyPotentialOwnerForItem(Item item) {
        if (!isIdentityDocumentItem(item)) {
            return;
        }

        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getIdCard, normalizeIdCard(item.getSerialNumber()))
                .eq(User::getIdentityStatus, UserConstants.IdentityStatus.VERIFIED)
                .eq(User::getDeleted, 0);
        User user = userRepository.selectOne(wrapper);
        if (user == null) {
            return;
        }

        notifyUserIfNeeded(user.getId(), item);
    }

    @Override
    public void notifyPotentialOwnerForVerifiedUser(User user) {
        if (user == null || user.getIdCard() == null || user.getIdCard().isBlank()
                || !UserConstants.IdentityStatus.VERIFIED.equals(user.getIdentityStatus())) {
            return;
        }

        LambdaQueryWrapper<Item> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Item::getType, ItemConstants.Type.FOUND)
                .eq(Item::getCategory, ItemConstants.Category.DOCUMENTS)
                .eq(Item::getStatus, ItemConstants.Status.APPROVED)
                .eq(Item::getSerialNumber, normalizeIdCard(user.getIdCard()))
                .eq(Item::getDeleted, 0)
                .orderByDesc(Item::getCreatedAt);
        List<Item> items = itemRepository.selectList(wrapper);
        for (Item item : items) {
            notifyUserIfNeeded(user.getId(), item);
        }
    }

    private boolean isIdentityDocumentItem(Item item) {
        return item != null
                && ItemConstants.Type.FOUND.equals(item.getType())
                && ItemConstants.Category.DOCUMENTS.equals(item.getCategory())
                && ItemConstants.Status.APPROVED.equals(item.getStatus())
                && item.getSerialNumber() != null
                && !item.getSerialNumber().isBlank();
    }

    private void notifyUserIfNeeded(Long userId, Item item) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notification::getUserId, userId)
                .eq(Notification::getType, ItemConstants.NotificationType.SYSTEM)
                .eq(Notification::getTitle, ItemConstants.NotificationTitle.POTENTIAL_DOCUMENT_OWNER)
                .eq(Notification::getRelatedId, item.getId());
        if (notificationRepository.selectCount(wrapper) > 0) {
            return;
        }

        String content = String.format(
                "系统发现一条证件招领信息【%s】与您的实名认证证件号一致，请尽快登录平台核对并联系校园管理员处理。",
                item.getTitle()
        );
        notificationService.create(
                userId,
                ItemConstants.NotificationType.SYSTEM,
                ItemConstants.NotificationTitle.POTENTIAL_DOCUMENT_OWNER,
                content,
                item.getId()
        );
    }

    private String normalizeIdCard(String value) {
        return value == null ? null : value.trim().toUpperCase();
    }
}
