package com.campus.lostfound.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.util.StringUtils;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

/**
 * 跨域配置
 *
 * <p>allowed-origins 通过配置项 {@code app.cors.allowed-origins} 注入,
 * 多个 origin 用英文逗号分隔。默认仅放行本地开发端口,
 * 严禁使用 {@code *} 配合 {@code setAllowCredentials(true)} 的危险组合。</p>
 */
@Configuration
public class CorsConfig {

    @Value("${app.cors.allowed-origins:http://localhost:3000,http://localhost:5173,http://127.0.0.1:3000,http://127.0.0.1:5173,http://localhost:8081}")
    private String allowedOrigins;

    @Bean
    @Order(0)
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();

        // 仅放行白名单来源,避免与 allowCredentials 组合造成 CSRF
        List<String> origins = Arrays.stream(StringUtils.commaDelimitedListToStringArray(allowedOrigins))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
        if (origins.isEmpty()) {
            // 兜底:禁止任何跨域,避免隐式 * 暴露
            config.setAllowedOrigins(List.of("http://localhost:3000"));
        } else {
            config.setAllowedOrigins(origins);
        }

        // 允许的方法
        config.addAllowedMethod("*");

        // 允许的头
        config.addAllowedHeader("*");

        // 允许凭证(Authorization 头)
        config.setAllowCredentials(true);

        // 暴露的头
        config.addExposedHeader("Authorization");

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return new CorsFilter(source);
    }
}
