package com.campus.lostfound.modules.system.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.campus.lostfound.common.constant.UserConstants;
import com.campus.lostfound.common.dto.request.LoginRequest;
import com.campus.lostfound.common.dto.request.RegisterRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.util.DataMaskUtils;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.AuthService;
import com.campus.lostfound.modules.system.service.EmailVerificationService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证服务实现 - 纯 Sa-Token(不再用 JwtUtils)
 *
 * 流程:
 *   登录: StpUtil.login(userId)  → Sa-Token 自动签 JWT → 返回 tokenValue
 *   校验: Sa-Token 自带 SaServletFilter,从 Authorization 头读 token 并验证
 *   续期: 用 refresh token(loginType=refresh)再走一遍 login 即可
 *   登出: StpUtil.logout() 自动从 Sa-Token 会话中删除
 */
@Service
public class AuthServiceImpl implements AuthService {

    private static final String VERIFY_PURPOSE_REGISTER = "register";
    /** Sa-Token 的 loginType 区分 access/refresh */
    private static final String LOGIN_TYPE_ACCESS = "access";
    private static final String LOGIN_TYPE_REFRESH = "refresh";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailVerificationService emailVerificationService;

    public AuthServiceImpl(UserRepository userRepository,
                           PasswordEncoder passwordEncoder,
                           EmailVerificationService emailVerificationService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailVerificationService = emailVerificationService;
    }

    @Override
    @Transactional
    public String register(RegisterRequest request) {
        String normalizedEmail = request.getEmail() == null ? "" : request.getEmail().trim().toLowerCase();
        if (normalizedEmail.isEmpty()) {
            throw new BusinessException("邮箱不能为空");
        }

        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, request.getUsername());
        if (userRepository.selectOne(wrapper) != null) {
            throw new BusinessException("用户名已存在");
        }

        QueryWrapper<User> emailWrapper = new QueryWrapper<>();
        emailWrapper.apply("LOWER(email) = {0}", normalizedEmail);
        emailWrapper.eq("deleted", 0);
        if (userRepository.selectOne(emailWrapper) != null) {
            throw new BusinessException("邮箱已被注册");
        }

        if (emailVerificationService.isRegisterVerificationRequired()) {
            if (request.getCode() == null || request.getCode().isBlank()) {
                throw new BusinessException("请先发送并填写邮箱验证码");
            }
            emailVerificationService.verifyAndConsume(normalizedEmail, request.getCode(), VERIFY_PURPOSE_REGISTER);
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmail(normalizedEmail);
        user.setStudentId(request.getStudentId());
        user.setPhone(request.getPhone());
        user.setRole("USER");
        user.setStatus(1);
        user.setIdentityStatus(UserConstants.IdentityStatus.UNVERIFIED);
        user.setNotificationInApp(1);
        user.setNotificationEmail(1);
        user.setNotificationMatch(1);
        user.setNotificationVerification(1);
        LocalDateTime now = LocalDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        userRepository.insert(user);
        return "注册成功";
    }

    @Override
    public Map<String, Object> login(LoginRequest request) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, request.getUsername());
        User user = userRepository.selectOne(wrapper);

        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        if (user.getStatus() == 0) {
            throw new BusinessException("账户已被禁用");
        }

        user.setLastLoginTime(LocalDateTime.now());
        userRepository.updateById(user);

        // 签发 access token(Sa-Token JWT,loginType=access)
        StpUtil.login(user.getId(), LOGIN_TYPE_ACCESS);
        String accessToken = StpUtil.getTokenValue();

        // 签发 refresh token(loginType=refresh,不同 loginType 互不影响)
        StpUtil.login(user.getId(), LOGIN_TYPE_REFRESH);
        String refreshToken = StpUtil.getTokenValue();
        // 回到 access 会话用于后续业务请求
        StpUtil.switchTo(LOGIN_TYPE_ACCESS);

        Map<String, Object> result = new HashMap<>();
        result.put("token", accessToken);
        result.put("accessToken", accessToken);
        result.put("refreshToken", refreshToken);
        result.put("tokenName", StpUtil.getTokenName());
        result.put("tokenValue", accessToken);
        result.put("user", buildUserMap(user));
        return result;
    }

    @Override
    public Map<String, Object> refreshToken(String refreshToken) {
        // 切到 refresh loginType 校验这个 token 是否有效
        StpUtil.switchTo(LOGIN_TYPE_REFRESH);
        try {
            if (refreshToken == null || refreshToken.isBlank()) {
                throw new BusinessException("无效的刷新令牌");
            }
            // 通过 Sa-Token 解析 refresh token
            Object loginId = StpUtil.getLoginIdByToken(refreshToken);
            if (loginId == null) {
                throw new BusinessException("无效的刷新令牌");
            }
            User user = userRepository.selectById(Long.valueOf(loginId.toString()));
            if (user == null || user.getStatus() == 0) {
                throw new BusinessException("用户不存在或已被禁用");
            }

            // 重新签发两个 token
            StpUtil.login(user.getId(), LOGIN_TYPE_ACCESS);
            String newAccessToken = StpUtil.getTokenValue();
            StpUtil.login(user.getId(), LOGIN_TYPE_REFRESH);
            String newRefreshToken = StpUtil.getTokenValue();
            StpUtil.switchTo(LOGIN_TYPE_ACCESS);

            Map<String, Object> result = new HashMap<>();
            result.put("accessToken", newAccessToken);
            result.put("refreshToken", newRefreshToken);
            return result;
        } finally {
            StpUtil.switchTo(LOGIN_TYPE_ACCESS);
        }
    }

    private Map<String, Object> buildUserMap(User user) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", user.getId());
        m.put("username", user.getUsername());
        m.put("email", user.getEmail());
        m.put("role", user.getRole());
        m.put("studentId", user.getStudentId());
        m.put("phone", user.getPhone());
        m.put("realName", user.getRealName());
        m.put("idCard", DataMaskUtils.maskIdCard(user.getIdCard()));
        m.put("identityStatus", user.getIdentityStatus());
        m.put("identityVerifiedAt", user.getIdentityVerifiedAt());
        m.put("notificationInApp", user.getNotificationInApp());
        m.put("notificationEmail", user.getNotificationEmail());
        m.put("notificationMatch", user.getNotificationMatch());
        m.put("notificationVerification", user.getNotificationVerification());
        return m;
    }
}
