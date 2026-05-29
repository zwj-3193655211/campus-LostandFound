package com.campus.lostfound.modules.system.service;

import com.campus.lostfound.common.dto.request.LoginRequest;
import com.campus.lostfound.common.dto.request.RegisterRequest;

import java.util.Map;

/**
 * 认证服务接口
 */
public interface AuthService {

    /**
     * 注册
     */
    String register(RegisterRequest request);

    /**
     * 登录
     */
    Map<String, Object> login(LoginRequest request);

    /**
     * 刷新Token
     */
    String refreshToken(String refreshToken);
}