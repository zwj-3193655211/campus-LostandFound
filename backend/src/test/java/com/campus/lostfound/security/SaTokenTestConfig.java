package com.campus.lostfound.security;

import cn.dev33.satoken.dao.SaTokenDao;
import cn.dev33.satoken.dao.SaTokenDaoDefaultImpl;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

/**
 * 测试用 Sa-Token 配置:用内存 DAO 代替 Redis,避免测试环境依赖外部 Redis。
 */
@TestConfiguration
public class SaTokenTestConfig {

    @Bean
    @Primary
    public SaTokenDao saTokenDao() {
        return new SaTokenDaoDefaultImpl();  // ConcurrentHashMap 内存实现
    }
}
