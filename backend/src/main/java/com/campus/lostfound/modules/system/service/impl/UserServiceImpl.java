package com.campus.lostfound.modules.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.constant.UserConstants;
import com.campus.lostfound.common.dto.request.UserUpdateRequest;
import com.campus.lostfound.common.dto.request.VerificationRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.common.util.DataMaskUtils;
import com.campus.lostfound.modules.match.service.DocumentOwnerMatchService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.entity.UserIdentityVerification;
import com.campus.lostfound.modules.system.repository.UserIdentityVerificationRepository;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * 用户服务实现
 */
@Service
public class UserServiceImpl implements UserService {

    private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);

    private final UserRepository userRepository;
    private final UserIdentityVerificationRepository identityVerificationRepository;
    private final PasswordEncoder passwordEncoder;
    private final NotificationService notificationService;
    private final DocumentOwnerMatchService documentOwnerMatchService;

    public UserServiceImpl(UserRepository userRepository,
                           UserIdentityVerificationRepository identityVerificationRepository,
                           PasswordEncoder passwordEncoder,
                           NotificationService notificationService,
                           DocumentOwnerMatchService documentOwnerMatchService) {
        this.userRepository = userRepository;
        this.identityVerificationRepository = identityVerificationRepository;
        this.passwordEncoder = passwordEncoder;
        this.notificationService = notificationService;
        this.documentOwnerMatchService = documentOwnerMatchService;
    }

    @Override
    public User getById(Long id) {
        return sanitize(userRepository.selectById(id));
    }

    @Override
    public User getByUsername(String username) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("username", username);
        return userRepository.selectOne(wrapper);
    }

    @Override
    public User getByEmail(String email) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("email", email);
        return userRepository.selectOne(wrapper);
    }

    @Override
    @Transactional
    public User updateProfile(Long userId, UserUpdateRequest request) {
        User user = userRepository.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        if (request.getEmail() != null) {
            user.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }
        if (request.getRealName() != null
                && !UserConstants.IdentityStatus.VERIFIED.equals(user.getIdentityStatus())) {
            user.setRealName(request.getRealName());
        }

        userRepository.updateById(user);
        return sanitize(user);
    }

    @Override
    @Transactional
    public User verifyIdentity(Long userId, VerificationRequest request) {
        User user = userRepository.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        if (UserConstants.IdentityStatus.PENDING.equals(user.getIdentityStatus())) {
            throw new BusinessException("您已有待审核的实名认证申请");
        }
        if (UserConstants.IdentityStatus.VERIFIED.equals(user.getIdentityStatus())) {
            throw new BusinessException("您已完成实名认证，无需重复提交");
        }

        String normalizedIdCard = normalizeIdCard(request.getIdCard());
        validateIdCardUniqueness(normalizedIdCard, userId);

        user.setRealName(request.getRealName());
        user.setIdCard(normalizedIdCard);
        user.setIdentityStatus(UserConstants.IdentityStatus.PENDING);
        user.setIdentityVerifiedAt(null);
        userRepository.updateById(user);

        UserIdentityVerification record = new UserIdentityVerification();
        record.setUserId(userId);
        record.setRealName(request.getRealName());
        record.setIdCard(normalizedIdCard);
        record.setStatus(UserConstants.IdentityStatus.PENDING);
        record.setCreatedAt(java.time.LocalDateTime.now());
        record.setUpdatedAt(java.time.LocalDateTime.now());
        identityVerificationRepository.insert(record);

        // 向所有管理员发送实名认证待审核通知
        try {
            notifyAdminsForPendingVerification(record);
        } catch (Exception e) {
            log.error("发送管理员实名认证审核提醒失败: requestId={}", record.getId(), e);
        }

        return sanitize(user);
    }

    @Override
    @Transactional
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userRepository.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BusinessException("原密码不正确");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.updateById(user);
    }

    @Override
    @Transactional
    public User updateNotificationSettings(Long userId, Map<String, Boolean> settings) {
        User user = userRepository.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        if (settings.containsKey("inApp")) {
            user.setNotificationInApp(settings.get("inApp") ? 1 : 0);
        }
        if (settings.containsKey("email")) {
            user.setNotificationEmail(settings.get("email") ? 1 : 0);
        }
        if (settings.containsKey("match")) {
            user.setNotificationMatch(settings.get("match") ? 1 : 0);
        }
        if (settings.containsKey("verification")) {
            user.setNotificationVerification(settings.get("verification") ? 1 : 0);
        }

        userRepository.updateById(user);
        return sanitize(user);
    }

    @Override
    public PageResponse<User> adminQueryUsers(String keyword, String role, Integer status, Boolean verified, int page, int pageSize) {
        Page<User> queryPage = new Page<>(page, pageSize);
        QueryWrapper<User> wrapper = new QueryWrapper<>();

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like("username", keyword)
                    .or().like("email", keyword)
                    .or().like("real_name", keyword)
                    .or().like("student_id", keyword));
        }
        if (role != null && !role.isBlank()) {
            wrapper.eq("role", role);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        if (verified != null) {
            if (verified) {
                wrapper.eq("identity_status", UserConstants.IdentityStatus.VERIFIED);
            } else {
                wrapper.and(w -> w.ne("identity_status", UserConstants.IdentityStatus.VERIFIED)
                        .or()
                        .isNull("identity_status"));
            }
        }

        wrapper.orderByDesc("created_at");

        Page<User> result = userRepository.selectPage(queryPage, wrapper);
        List<User> sanitizedUsers = result.getRecords().stream().map(this::sanitize).toList();
        return PageResponse.of(sanitizedUsers, result.getTotal(), page, pageSize);
    }

    @Override
    @Transactional
    public User adminUpdateUser(Long operatorId, String operatorRole, Long targetUserId, String email, String phone) {
        User targetUser = requireTargetUser(targetUserId);

        if (!"SUPER_ADMIN".equals(operatorRole)) {
            throw new BusinessException("仅超级管理员可编辑用户资料");
        }

        if (email != null) {
            targetUser.setEmail(email);
        }
        if (phone != null) {
            targetUser.setPhone(phone);
        }

        userRepository.updateById(targetUser);
        return sanitize(targetUser);
    }

    @Override
    @Transactional
    public User adminChangeRole(Long operatorId, String operatorRole, Long targetUserId, String role) {
        User targetUser = requireTargetUser(targetUserId);

        if (!"SUPER_ADMIN".equals(operatorRole)) {
            throw new BusinessException("仅超级管理员可修改用户角色");
        }
        if (operatorId.equals(targetUserId)) {
            throw new BusinessException("不能修改自己的角色");
        }
        if (!"USER".equals(role) && !"CAMPUS_ADMIN".equals(role) && !"SUPER_ADMIN".equals(role)) {
            throw new BusinessException("角色值不合法");
        }
        if ("SUPER_ADMIN".equals(targetUser.getRole())) {
            throw new BusinessException("不能修改超级管理员账号角色");
        }

        targetUser.setRole(role);
        userRepository.updateById(targetUser);
        return sanitize(targetUser);
    }

    @Override
    @Transactional
    public User adminChangeStatus(Long operatorId, String operatorRole, Long targetUserId, Integer status) {
        User targetUser = requireTargetUser(targetUserId);

        if ("CAMPUS_ADMIN".equals(operatorRole) && !"USER".equals(targetUser.getRole())) {
            throw new BusinessException("校园管理员只能启用或禁用普通用户");
        }
        if (status == null || (status != 0 && status != 1)) {
            throw new BusinessException("状态值不合法");
        }
        if (operatorId.equals(targetUserId) && status != null && status == 0) {
            throw new BusinessException("不能禁用自己的账号");
        }

        targetUser.setStatus(status);
        userRepository.updateById(targetUser);
        return sanitize(targetUser);
    }

    @Override
    @Transactional
    public void adminDeleteUser(Long operatorId, String operatorRole, Long targetUserId) {
        User targetUser = requireTargetUser(targetUserId);

        if (!"SUPER_ADMIN".equals(operatorRole)) {
            throw new BusinessException("仅超级管理员可删除用户");
        }
        if (operatorId.equals(targetUserId)) {
            throw new BusinessException("不能删除自己的账号");
        }
        if ("SUPER_ADMIN".equals(targetUser.getRole())) {
            throw new BusinessException("不能删除超级管理员账号");
        }

        userRepository.deleteById(targetUserId);
    }

    @Override
    public User updateById(User user) {
        userRepository.updateById(user);
        return user;
    }

    @Override
    public List<UserIdentityVerification> listPendingIdentityVerifications() {
        LambdaQueryWrapper<UserIdentityVerification> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserIdentityVerification::getStatus, UserConstants.IdentityStatus.PENDING)
                .orderByAsc(UserIdentityVerification::getCreatedAt);
        return enrichIdentityVerifications(identityVerificationRepository.selectList(wrapper));
    }

    @Override
    public List<UserIdentityVerification> listIdentityVerificationHistory() {
        LambdaQueryWrapper<UserIdentityVerification> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(UserIdentityVerification::getCreatedAt);
        return enrichIdentityVerifications(identityVerificationRepository.selectList(wrapper));
    }

    @Override
    @Transactional
    public void reviewIdentityVerification(Long requestId, Long adminId, boolean approved, String reason) {
        UserIdentityVerification record = identityVerificationRepository.selectById(requestId);
        if (record == null) {
            throw new BusinessException("实名认证申请不存在");
        }
        if (!UserConstants.IdentityStatus.PENDING.equals(record.getStatus())) {
            throw new BusinessException("该实名认证申请已处理");
        }

        User user = userRepository.selectById(record.getUserId());
        if (user == null) {
            throw new BusinessException("申请用户不存在");
        }

        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        record.setReviewedBy(adminId);
        record.setReviewedAt(now);
        record.setUpdatedAt(now);
        record.setReviewReason(reason);

        if (approved) {
            validateIdCardUniqueness(normalizeIdCard(record.getIdCard()), user.getId());
            record.setStatus(UserConstants.IdentityStatus.VERIFIED);
            user.setRealName(record.getRealName());
            user.setIdCard(normalizeIdCard(record.getIdCard()));
            user.setIdentityStatus(UserConstants.IdentityStatus.VERIFIED);
            user.setIdentityVerifiedAt(now);
        } else {
            record.setStatus(UserConstants.IdentityStatus.REJECTED);
            user.setIdentityStatus(UserConstants.IdentityStatus.REJECTED);
            user.setIdentityVerifiedAt(null);
        }

        identityVerificationRepository.updateById(record);
        userRepository.updateById(user);

        notificationService.create(
                user.getId(),
                ItemConstants.NotificationType.SYSTEM,
                approved ? "实名认证审核已通过" : "实名认证审核未通过",
                approved
                        ? "您提交的实名认证申请已通过，后续如有证件类招领信息命中，将优先通知您。"
                        : String.format("您提交的实名认证申请未通过，原因：%s", reason == null || reason.isBlank() ? "请完善信息后重新提交" : reason),
                record.getId()
        );

        if (approved) {
            documentOwnerMatchService.notifyPotentialOwnerForVerifiedUser(user);
        }
    }

    private User requireTargetUser(Long targetUserId) {
        User targetUser = userRepository.selectById(targetUserId);
        if (targetUser == null) {
            throw new BusinessException("用户不存在");
        }
        return targetUser;
    }

    private void validateIdCardUniqueness(String idCard, Long currentUserId) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getIdCard, idCard)
                .eq(User::getIdentityStatus, UserConstants.IdentityStatus.VERIFIED)
                .eq(User::getDeleted, 0);
        User existing = userRepository.selectOne(wrapper);
        if (existing != null && !existing.getId().equals(currentUserId)) {
            throw new BusinessException("该身份证号已绑定其他已实名账号");
        }
    }

    private String normalizeIdCard(String idCard) {
        return idCard == null ? null : idCard.trim().toUpperCase();
    }

    private List<UserIdentityVerification> enrichIdentityVerifications(List<UserIdentityVerification> records) {
        if (records == null || records.isEmpty()) {
            return List.of();
        }

        List<Long> userIds = records.stream()
                .map(UserIdentityVerification::getUserId)
                .filter(java.util.Objects::nonNull)
                .distinct()
                .toList();
        List<Long> reviewerIds = records.stream()
                .map(UserIdentityVerification::getReviewedBy)
                .filter(java.util.Objects::nonNull)
                .distinct()
                .toList();

        java.util.Map<Long, String> usernameMap = userIds.isEmpty()
                ? java.util.Map.of()
                : userRepository.selectBatchIds(userIds).stream()
                .collect(java.util.stream.Collectors.toMap(User::getId, User::getUsername));
        java.util.Map<Long, String> reviewerMap = reviewerIds.isEmpty()
                ? java.util.Map.of()
                : userRepository.selectBatchIds(reviewerIds).stream()
                .collect(java.util.stream.Collectors.toMap(User::getId, User::getUsername));

        records.forEach(record -> {
            record.setUsername(usernameMap.getOrDefault(record.getUserId(), "用户#" + record.getUserId()));
            if (record.getReviewedBy() != null) {
                record.setReviewerName(reviewerMap.getOrDefault(record.getReviewedBy(), "管理员#" + record.getReviewedBy()));
            }
        });
        return records;
    }

    /**
     * 向所有管理员发送实名认证待审核通知
     */
    private void notifyAdminsForPendingVerification(UserIdentityVerification record) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(User::getRole, UserConstants.ROLE_SUPER_ADMIN, UserConstants.ROLE_CAMPUS_ADMIN);
        List<User> admins = userRepository.selectList(wrapper);

        if (admins.isEmpty()) {
            log.warn("没有找到管理员，无法发送实名认证审核提醒通知");
            return;
        }

        String title = "新实名认证待审核";
        String content = String.format(
                "用户【%s】提交了实名认证申请，真实姓名：%s，请及时审核。",
                record.getUsername(),
                record.getRealName()
        );

        for (User admin : admins) {
            try {
                notificationService.create(
                        admin.getId(),
                        ItemConstants.NotificationType.VERIFICATION_PENDING,
                        title,
                        content,
                        record.getId()
                );
            } catch (Exception e) {
                log.error("发送实名认证审核提醒通知失败: adminId={}, requestId={}", admin.getId(), record.getId(), e);
            }
        }

        log.info("已向 {} 位管理员发送实名认证审核提醒通知: requestId={}", admins.size(), record.getId());
    }

    private User sanitize(User user) {
        if (user == null) {
            return null;
        }
        user.setPassword(null);
        user.setIdCard(DataMaskUtils.maskIdCard(user.getIdCard()));
        return user;
    }

    /**
     * 邮箱归一化:trim + 小写。空值返回 "" 表示无效。
     */
    private String normalizeEmail(String email) {
        if (email == null) return "";
        return email.trim().toLowerCase();
    }

    /**
     * 检查邮箱是否已被其他用户占用(忽略大小写,排除已逻辑删除用户与当前用户)。
     * 与 {@link #normalizeEmail} 配合使用,避免 Test@x.com / test@x.com 被视作不同邮箱。
     */
    private void ensureEmailAvailable(String normalizedEmail, Long excludeUserId) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.apply("LOWER(email) = {0}", normalizedEmail);
        wrapper.eq("deleted", 0);
        wrapper.ne("id", excludeUserId);
        Long count = userRepository.selectCount(wrapper);
        if (count != null && count > 0) {
            throw new BusinessException("邮箱已被其他用户使用");
        }
    }
}
