package com.campus.lostfound.security;

import cn.dev33.satoken.jwt.StpLogicJwtForSimple;
import cn.dev33.satoken.stp.StpLogic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Sa-Token 配置类
 * 
 * @author Campus LostFound
 */
@Configuration
public class SaTokenConfig {

    /**
     * Sa-Token 整合 JWT 模式（使用 Simple 模式）
     * 返回 StpLogic 对象用于 Sa-Token 的 JWT 集成
     */
    @Bean
    public StpLogic getStpLogicJwt() {
        return new StpLogicJwtForSimple();
    }
}
