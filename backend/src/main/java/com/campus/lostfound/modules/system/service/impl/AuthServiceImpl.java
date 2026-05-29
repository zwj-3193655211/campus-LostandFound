package com.campus.lostfound.modules.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.lostfound.common.constant.UserConstants;
import com.campus.lostfound.common.dto.request.LoginRequest;
import com.campus.lostfound.common.dto.request.RegisterRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.util.DataMaskUtils;
import com.campus.lostfound.common.util.JwtUtils;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.AuthService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证服务实现
 */
@Service
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    public AuthServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtils jwtUtils) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtils = jwtUtils;
    }

    @Override
    @Transactional
    public String register(RegisterRequest request) {
        // 检查用户名是否存在
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, request.getUsername());
        if (userRepository.selectOne(wrapper) != null) {
            throw new BusinessException("用户名已存在");
        }

        // 检查邮箱是否存在        wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getEmail, request.getEmail());
        if (userRepository.selectOne(wrapper) != null) {
            throw new BusinessException("邮箱已被注册");
        }

        // 创建用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
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

        // 更新最后登录时间
        user.setLastLoginTime(LocalDateTime.now());
        userRepository.updateById(user);

        // 生成Token
        String accessToken = jwtUtils.generateAccessToken(user.getId(), user.getUsername(), user.getRole());
        String refreshToken = jwtUtils.generateRefreshToken(user.getId(), user.getUsername());

        Map<String, Object> result = new HashMap<>();
        result.put("token", accessToken);
        result.put("accessToken", accessToken);
        result.put("refreshToken", refreshToken);
        
        Map<String, Object> userMap = new HashMap<>();
        userMap.put("id", user.getId());
        userMap.put("username", user.getUsername());
        userMap.put("email", user.getEmail());
        userMap.put("role", user.getRole());
        userMap.put("studentId", user.getStudentId());
        userMap.put("phone", user.getPhone());
        userMap.put("realName", user.getRealName());
        userMap.put("idCard", DataMaskUtils.maskIdCard(user.getIdCard()));
        userMap.put("identityStatus", user.getIdentityStatus());
        userMap.put("identityVerifiedAt", user.getIdentityVerifiedAt());
        userMap.put("notificationInApp", user.getNotificationInApp());
        userMap.put("notificationEmail", user.getNotificationEmail());
        userMap.put("notificationMatch", user.getNotificationMatch());
        userMap.put("notificationVerification", user.getNotificationVerification());
        result.put("user", userMap);
        
        return result;
    }

    @Override
    public String refreshToken(String refreshToken) {
        if (!jwtUtils.validateToken(refreshToken) || !jwtUtils.isRefreshToken(refreshToken)) {
            throw new BusinessException("无效的刷新令牌");
        }

        Long userId = jwtUtils.getUserIdFromToken(refreshToken);
        String username = jwtUtils.getUsernameFromToken(refreshToken);

        User user = userRepository.selectById(userId);
        if (user == null || user.getStatus() == 0) {
            throw new BusinessException("用户不存在或已被禁用");
        }

        return jwtUtils.generateAccessToken(user.getId(), user.getUsername(), user.getRole());
    }
}
