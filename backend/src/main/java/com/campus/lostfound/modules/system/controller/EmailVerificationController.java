package com.campus.lostfound.modules.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.EmailVerificationService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 邮箱验证码相关公开接口。
 * 限流说明:同邮箱 60 秒冷却期由 {@link EmailVerificationService} 控制。
 */
@RestController
@RequestMapping("/api/auth")
public class EmailVerificationController {

    private static final String PURPOSE_REGISTER = "register";

    private final EmailVerificationService emailVerificationService;
    private final UserRepository userRepository;

    public EmailVerificationController(EmailVerificationService emailVerificationService,
                                       UserRepository userRepository) {
        this.emailVerificationService = emailVerificationService;
        this.userRepository = userRepository;
    }

    /**
     * 发送注册验证码到指定邮箱。
     * body: { "email": "user@example.com" }
     */
    @PostMapping("/send-register-code")
    public ApiResponse<String> sendRegisterCode(@RequestBody Map<String, String> body) {
        String email = body == null ? null : body.get("email");
        if (email == null || email.isBlank()) {
            throw new BusinessException("邮箱不能为空");
        }
        String trimmed = email.trim();
        int at = trimmed.indexOf('@');
        int lastDot = trimmed.lastIndexOf('.');
        if (at <= 0 || lastDot <= at + 1 || lastDot == trimmed.length() - 1) {
            throw new BusinessException("邮箱格式不正确");
        }

        // 提前检查邮箱是否已被注册，避免向已注册邮箱发送无效验证码
        String normalizedEmail = trimmed.toLowerCase();
        QueryWrapper<User> emailWrapper = new QueryWrapper<>();
        emailWrapper.apply("LOWER(email) = {0}", normalizedEmail);
        emailWrapper.eq("deleted", 0);
        if (userRepository.selectOne(emailWrapper) != null) {
            throw new BusinessException("该邮箱已被注册，请直接登录或使用其他邮箱");
        }

        boolean ok = emailVerificationService.sendCode(trimmed, PURPOSE_REGISTER);
        return ApiResponse.success(
                ok ? "验证码已发送,请查收邮箱" : "验证码发送过于频繁,请稍后再试",
                String.valueOf(ok));
    }
}
