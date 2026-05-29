package com.campus.lostfound.modules.system.service;

import com.campus.lostfound.common.dto.request.UserUpdateRequest;
import com.campus.lostfound.common.dto.request.VerificationRequest;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.entity.UserIdentityVerification;

import java.util.List;
import java.util.Map;

/**
 * 用户服务接口
 */
public interface UserService {

    /**
     * 根据ID获取用户
     */
    User getById(Long id);

    /**
     * 根据用户名获取用户
     */
    User getByUsername(String username);

    /**
     * 根据邮箱获取用户
     */
    User getByEmail(String email);

    /**
     * 更新用户信息
     */
    User updateProfile(Long userId, UserUpdateRequest request);

    /**
     * 实名认证
     */
    User verifyIdentity(Long userId, VerificationRequest request);

    /**
     * 修改密码
     */
    void changePassword(Long userId, String oldPassword, String newPassword);

    /**
     * 更新通知设置
     */
    User updateNotificationSettings(Long userId, Map<String, Boolean> settings);

    /**
     * 管理员分页查询用户
     */
    PageResponse<User> adminQueryUsers(String keyword, String role, Integer status, Boolean verified, int page, int pageSize);

    /**
     * 管理员更新用户资料
     */
    User adminUpdateUser(Long operatorId, String operatorRole, Long targetUserId, String email, String phone);

    /**
     * 管理员修改用户角色
     */
    User adminChangeRole(Long operatorId, String operatorRole, Long targetUserId, String role);

    /**
     * 管理员修改用户状态
     */
    User adminChangeStatus(Long operatorId, String operatorRole, Long targetUserId, Integer status);

    /**
     * 管理员删除用户
     */
    void adminDeleteUser(Long operatorId, String operatorRole, Long targetUserId);

    /**
     * 更新用户
     */
    User updateById(User user);

    /**
     * 查询待审核实名认证申请
     */
    List<UserIdentityVerification> listPendingIdentityVerifications();

    /**
     * 查询实名认证申请历史
     */
    List<UserIdentityVerification> listIdentityVerificationHistory();

    /**
     * 审核实名认证申请
     */
    void reviewIdentityVerification(Long requestId, Long adminId, boolean approved, String reason);
}
