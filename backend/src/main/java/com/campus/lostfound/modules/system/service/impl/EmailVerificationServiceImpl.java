package com.campus.lostfound.modules.system.service.impl;

import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.common.service.RedisCacheService;
import com.campus.lostfound.modules.notification.service.MailService;
import com.campus.lostfound.modules.system.service.EmailVerificationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.concurrent.TimeUnit;

/**
 * 邮箱验证码服务:
 * - 6 位数字验证码
 * - Redis 存码,有效期 5 分钟
 * - 同一邮箱 60 秒冷却期,避免刷码
 * - 用途 (purpose) 隔离:register / reset_password 互不干扰
 */
@Service
public class EmailVerificationServiceImpl implements EmailVerificationService {

    private static final Logger log = LoggerFactory.getLogger(EmailVerificationServiceImpl.class);
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final char CH_QUOTE = '"';

    private static final String KEY_PREFIX = "auth:email-code:";
    private static final String COOLDOWN_PREFIX = "auth:email-cooldown:";
    private static final long CODE_TTL_SECONDS = 5 * 60;        // 5 分钟
    private static final long COOLDOWN_TTL_SECONDS = 60;        // 60 秒

    private final RedisCacheService cacheService;
    private final MailService mailService;
    private final ObjectMapper objectMapper;
    private final boolean required;

    public EmailVerificationServiceImpl(RedisCacheService cacheService,
                                        MailService mailService,
                                        ObjectMapper objectMapper,
                                        @Value("${app.auth.email-verification-required:false}") boolean required) {
        this.cacheService = cacheService;
        this.mailService = mailService;
        this.objectMapper = objectMapper;
        this.required = required;
    }

    @Override
    public boolean isRegisterVerificationRequired() {
        return required;
    }

    @Override
    public boolean sendCode(String email, String purpose) {
        if (email == null || email.isBlank()) {
            throw new BusinessException("邮箱不能为空");
        }
        String normalized = email.trim().toLowerCase();
        String cooldownKey = COOLDOWN_PREFIX + purpose + ":" + normalized;
        if (Boolean.TRUE.equals(cacheService.hasKey(cooldownKey))) {
            log.warn("邮箱 {} 验证码冷却中(60s),purpose={}", normalized, purpose);
            return false;
        }

        String code = String.format("%06d", RANDOM.nextInt(1_000_000));
        String codeKey = KEY_PREFIX + purpose + ":" + normalized;
        cacheService.set(codeKey, code, CODE_TTL_SECONDS, TimeUnit.SECONDS);
        cacheService.set(cooldownKey, "1", COOLDOWN_TTL_SECONDS, TimeUnit.SECONDS);

        try {
            mailService.sendSimpleEmail(
                    normalized,
                    "【校园失物招领】邮箱验证码",
                    "您的验证码是: " + code + " ,5 分钟内有效,请勿泄露给他人。");
            log.info("邮箱验证码已发送: email={}, purpose={}", normalized, purpose);
            return true;
        } catch (Exception e) {
            // 邮件发送失败时回滚缓存,避免用户拿不到码但被锁住
            cacheService.delete(codeKey);
            cacheService.delete(cooldownKey);
            log.error("邮箱验证码发送失败: email={}, purpose={}", normalized, purpose, e);
            throw new BusinessException("验证码发送失败,请稍后再试");
        }
    }

    @Override
    public void verifyAndConsume(String email, String code, String purpose) {
        if (code == null || code.isBlank()) {
            throw new BusinessException("验证码不能为空");
        }
        String normalized = email == null ? "" : email.trim().toLowerCase();
        String key = KEY_PREFIX + purpose + ":" + normalized;
        Object stored = cacheService.get(key);
        if (stored == null) {
            throw new BusinessException("验证码已过期或未发送,请重新获取");
        }
        // 兼容 RedisCacheService + RedisTemplate 双重 JSON 编码:
        // 实际拿到的是 "410492" (带 JSON 引号),需要再 parseValue 一次剥掉外壳。
        String storedStr = String.valueOf(stored);
        if (storedStr.length() >= 2
                && storedStr.charAt(0) == CH_QUOTE
                && storedStr.charAt(storedStr.length() - 1) == CH_QUOTE) {
            try {
                storedStr = objectMapper.readValue(storedStr, String.class);
            } catch (Exception ignore) {
                // 不是合法 JSON 字符串,保持原样
            }
        }
        if (!storedStr.equals(code.trim())) {
            throw new BusinessException("验证码不正确");
        }
        cacheService.delete(key);
    }
}
