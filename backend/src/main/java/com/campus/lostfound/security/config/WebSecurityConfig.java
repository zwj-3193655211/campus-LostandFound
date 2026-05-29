package com.campus.lostfound.security.config;

import com.campus.lostfound.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security配置
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class WebSecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public WebSecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 公开接口
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/statistics/**").permitAll()
                        // 位置查询公开
                        .requestMatchers(HttpMethod.GET, "/api/locations/**").permitAll()
                        .requestMatchers("/api/locations/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        // 测试接口公开
                        .requestMatchers("/api/matches/test").permitAll()
                        // 前端静态资源
                        .requestMatchers("/").permitAll()
                        .requestMatchers("/index.html").permitAll()
                        .requestMatchers("/css/**").permitAll()
                        .requestMatchers("/js/**").permitAll()
                        .requestMatchers("/assets/**").permitAll()

                        // 超级管理员专属接口
                        .requestMatchers("/api/db/**").hasRole("SUPER_ADMIN")

                        // 管理后台：超级管理员和校园管理员均可访问
                        .requestMatchers("/api/admin/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")

                        // 管理操作：仅管理员可触发
                        .requestMatchers(HttpMethod.POST, "/api/matches/trigger", "/api/matches/batch")
                        .hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/notifications/send-test-email", "/api/notifications/send-match-email")
                        .hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")

                        // 自助用户接口：登录即可访问
                        .requestMatchers("/api/users/**").authenticated()

                        // 普通用户 - 基本功能（物品查询公开）
                        .requestMatchers(HttpMethod.GET, "/api/items/**").permitAll()
                        .requestMatchers("/api/items/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN", "USER")
                        .requestMatchers("/api/matches/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN", "USER")
                        .requestMatchers("/api/notifications/**").authenticated()

                        // 其他需要认证
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
