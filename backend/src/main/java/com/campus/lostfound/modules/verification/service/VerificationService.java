package com.campus.lostfound.modules.verification.service;

import com.campus.lostfound.modules.verification.entity.Verification;

/**
 * 认领审核服务接口
 */
public interface VerificationService {

    /**
     * 提交认领申请
     */
    Verification claim(Long itemId, Long userId, String proof);

    /**
     * 审核认领申请
     */
    void review(Long verificationId, Long adminId, boolean approved, String reason);

    /**
     * 获取认领申请列表
     */
    java.util.List<Verification> getVerifications(Long itemId);

    /**
     * 获取用户的认领申请
     */
    Verification getUserClaim(Long itemId, Long userId);
}