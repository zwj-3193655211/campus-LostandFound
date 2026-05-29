package com.campus.lostfound.modules.verification.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.verification.entity.Verification;
import com.campus.lostfound.modules.verification.repository.VerificationRepository;
import com.campus.lostfound.modules.verification.service.VerificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 认领审核服务实现
 */
@Service
public class VerificationServiceImpl implements VerificationService {

    private static final Logger log = LoggerFactory.getLogger(VerificationServiceImpl.class);

    private final VerificationRepository verificationRepository;
    private final ItemRepository itemRepository;
    private final NotificationService notificationService;

    public VerificationServiceImpl(VerificationRepository verificationRepository, ItemRepository itemRepository,
                                   NotificationService notificationService) {
        this.verificationRepository = verificationRepository;
        this.itemRepository = itemRepository;
        this.notificationService = notificationService;
    }

    @Override
    @Transactional
    public Verification claim(Long itemId, Long userId, String proof) {
        Item item = itemRepository.selectById(itemId);
        if (item == null) {
            throw new BusinessException("物品不存在");
        }
        if (userId.equals(item.getUserId())) {
            throw new BusinessException("不能认领自己发布的物品");
        }
        if (!ItemConstants.Status.APPROVED.equals(item.getStatus())) {
            throw new BusinessException("仅已审核发布的物品允许认领");
        }

        // 检查是否已经提交过认领申请
        LambdaQueryWrapper<Verification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Verification::getItemId, itemId);
        wrapper.eq(Verification::getClaimantId, userId);
        wrapper.eq(Verification::getStatus, "PENDING");
        Verification existing = verificationRepository.selectOne(wrapper);

        if (existing != null) {
            throw new BusinessException("您已提交过认领申请，请勿重复提交");
        }

        // 创建认领申请
        Verification verification = new Verification();
        verification.setItemId(itemId);
        verification.setClaimantId(userId);
        verification.setClaimProof(proof);
        verification.setStatus("PENDING");
        verification.setCreatedAt(LocalDateTime.now());

        verificationRepository.insert(verification);
        log.info("用户{} 提交认领申请: itemId={}", userId, itemId);

        return verification;
    }

    @Override
    @Transactional
    public void review(Long verificationId, Long adminId, boolean approved, String reason) {
        Verification verification = verificationRepository.selectById(verificationId);
        if (verification == null) {
            throw new BusinessException("认领申请不存在");
        }

        if (!"PENDING".equals(verification.getStatus())) {
            throw new BusinessException("该申请已处理");
        }

        LocalDateTime now = LocalDateTime.now();
        verification.setReviewedBy(adminId);
        verification.setReviewedAt(now);

        if (approved) {
            verification.setStatus("APPROVED");
        } else {
            verification.setStatus("REJECTED");
            verification.setRejectReason(reason);
        }

        verification.setUpdatedAt(now);

        Verification reviewUpdate = new Verification();
        reviewUpdate.setReviewedBy(adminId);
        reviewUpdate.setReviewedAt(now);
        reviewUpdate.setUpdatedAt(now);
        reviewUpdate.setStatus(verification.getStatus());
        reviewUpdate.setRejectReason(verification.getRejectReason());

        int updatedRows = verificationRepository.update(
                reviewUpdate,
                new LambdaUpdateWrapper<Verification>()
                        .eq(Verification::getId, verificationId)
                        .eq(Verification::getStatus, "PENDING")
        );
        if (updatedRows == 0) {
            throw new BusinessException("该申请已处理");
        }

        // 发送通知
        try {
            notificationService.notifyClaimReviewResult(verification.getId(),
                    verification.getStatus(),
                    reason);
        } catch (Exception e) {
            log.error("发送审核通知失败", e);
        }

        log.info("管理员{} 审核认领申请: verificationId={}, result={}", adminId, verificationId, approved ? "通过" : "拒绝");
    }

    @Override
    public List<Verification> getVerifications(Long itemId) {
        LambdaQueryWrapper<Verification> wrapper = new LambdaQueryWrapper<>();
        if (itemId != null) {
            wrapper.eq(Verification::getItemId, itemId);
        }
        wrapper.orderByDesc(Verification::getCreatedAt);
        return verificationRepository.selectList(wrapper);
    }

    @Override
    public Verification getUserClaim(Long itemId, Long userId) {
        LambdaQueryWrapper<Verification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Verification::getItemId, itemId);
        wrapper.eq(Verification::getClaimantId, userId);
        wrapper.last("LIMIT 1");
        return verificationRepository.selectOne(wrapper);
    }
}
