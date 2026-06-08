package com.campus.lostfound.modules.system.service.impl;

import cn.dev33.satoken.stp.SaLoginModel;
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
 * 认证服务实现 - 纯 Sa-Token(JWT Stateless 模式)
 *
 * <p>Sa-Token 配置为 {@code StpLogicJwtForStateless},所有会话状态都封装在
 * JWT 自身的签名 + {@code eff} 过期戳里,后端不持有任何会话存储。
 * 因此:
 * <ul>
 *   <li>access token 过期时间由 {@code SaLoginModel.setTimeout(...)} 写进
 *       JWT 的 {@code eff} 字段;</li>
 *   <li>refresh token 同样由 {@code eff} 字段控制,与 access 互不干扰;</li>
 *   <li>{@code StpUtil.login(id, "access")} 里的字符串其实是 Sa-Token 的
 *       {@code device} 参数(device 写进 JWT 的 {@code device} claim,
 *       用来区分多端登录),与"loginType"无关 —— access/refresh 两个 token
 *       仍然在同一个 {@code loginType="login"} 命名空间下。</li>
 * </ul>
 * </p>
 */
@Service
public class AuthServiceImpl implements AuthService {

    private static final String VERIFY_PURPOSE_REGISTER = "register";
    /** 设备标识 —— 写进 JWT 的 device claim,不参与权限判断 */
    private static final String DEVICE_ACCESS = "access";
    private static final String DEVICE_REFRESH = "refresh";

    /** access token 有效期:7 天(秒) —— 7 天内不用重新登录 */
    private static final long ACCESS_TIMEOUT_SECONDS = 7L * 24 * 60 * 60;
    /** refresh token 有效期:30 天(秒) —— 用来续 access */
    private static final long REFRESH_TIMEOUT_SECONDS = 30L * 24 * 60 * 60;

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

        // 签发 access token(7 天) —— device="access" 写进 JWT 的 device claim
        // Sa-Token 的 StpUtil.login() 是 void,要拿 token 值用 getTokenValue()
        StpUtil.login(user.getId(), new SaLoginModel()
                .setDevice(DEVICE_ACCESS)
                .setTimeout(ACCESS_TIMEOUT_SECONDS));
        String accessToken = StpUtil.getTokenValue();

        // 签发 refresh token(30 天) —— device="refresh"
        StpUtil.login(user.getId(), new SaLoginModel()
                .setDevice(DEVICE_REFRESH)
                .setTimeout(REFRESH_TIMEOUT_SECONDS));
        String refreshToken = StpUtil.getTokenValue();

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
        if (refreshToken == null || refreshToken.isBlank()) {
            throw new BusinessException("无效的刷新令牌");
        }
        // Stateless 模式下,JWT 自带 loginId,直接用 SaJwtUtil 验签 + 取 loginId
        // (不再依赖 switchTo —— 那个对 JWT 无意义)
        Object loginId = StpUtil.getLoginIdByToken(refreshToken);
        if (loginId == null) {
            throw new BusinessException("无效的刷新令牌");
        }
        User user = userRepository.selectById(Long.valueOf(loginId.toString()));
        if (user == null || user.getStatus() == 0) {
            throw new BusinessException("用户不存在或已被禁用");
        }

        // 重新签发两个 token
        StpUtil.login(user.getId(), new SaLoginModel()
                .setDevice(DEVICE_ACCESS)
                .setTimeout(ACCESS_TIMEOUT_SECONDS));
        String newAccessToken = StpUtil.getTokenValue();
        StpUtil.login(user.getId(), new SaLoginModel()
                .setDevice(DEVICE_REFRESH)
                .setTimeout(REFRESH_TIMEOUT_SECONDS));
        String newRefreshToken = StpUtil.getTokenValue();

        Map<String, Object> result = new HashMap<>();
        result.put("accessToken", newAccessToken);
        result.put("refreshToken", newRefreshToken);
        return result;
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
