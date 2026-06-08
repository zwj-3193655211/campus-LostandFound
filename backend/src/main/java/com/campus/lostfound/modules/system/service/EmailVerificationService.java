package com.campus.lostfound.modules.system.service;

public interface EmailVerificationService {

    /**
     * 发送 6 位邮箱验证码到目标邮箱,存入 Redis 有效期 5 分钟。
     * 同一邮箱在 60 秒冷却期内只允许发送一次,防止刷码。
     *
     * @param email   目标邮箱
     * @param purpose 用途 (REGISTER / RESET_PASSWORD 等)
     * @return 是否成功 (true=已发送,false=冷却中或邮件发送失败)
     */
    boolean sendCode(String email, String purpose);

    /**
     * 校验验证码:成功则消费掉(防止重复使用),失败抛出业务异常。
     */
    void verifyAndConsume(String email, String code, String purpose);

    /**
     * 当前是否启用了"注册必须邮箱验证"开关。供 AuthService 决定是否强制校验。
     */
    boolean isRegisterVerificationRequired();
}
