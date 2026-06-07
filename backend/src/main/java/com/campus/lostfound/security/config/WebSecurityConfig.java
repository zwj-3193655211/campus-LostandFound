package com.campus.lostfound.security.config;

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
import com.campus.lostfound.security.SaTokenAuthenticationFilter;

/**
 * Spring Security 配置(纯 Sa-Token)
 *
 * Sa-Token 自带 SaServletFilter(自动注册),负责从 Authorization 头读 token 并验证。
 * 这里只需配置 Spring Security 的 URL 权限矩阵,Sa-Token 会自动给已登录的请求设置角色。
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class WebSecurityConfig {

    private final SaTokenAuthenticationFilter saTokenAuthenticationFilter;

    public WebSecurityConfig(SaTokenAuthenticationFilter saTokenAuthenticationFilter) {
        this.saTokenAuthenticationFilter = saTokenAuthenticationFilter;
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
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/statistics/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/locations/**").permitAll()
                        .requestMatchers("/api/locations/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        .requestMatchers("/api/matches/test").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        .requestMatchers("/api/notifications/send-test-email").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        .requestMatchers("/api/notifications/send-match-email").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        .requestMatchers("/").permitAll()
                        .requestMatchers("/index.html").permitAll()
                        .requestMatchers("/css/**").permitAll()
                        .requestMatchers("/js/**").permitAll()
                        .requestMatchers("/assets/**").permitAll()
                        .requestMatchers("/api/db/**").hasRole("SUPER_ADMIN")
                        .requestMatchers("/api/admin/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/matches/trigger", "/api/matches/batch")
                        .hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN")
                        .requestMatchers("/api/users/**").authenticated()
                        .requestMatchers(HttpMethod.GET, "/api/items/**").permitAll()
                        .requestMatchers("/api/items/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN", "USER")
                        .requestMatchers("/api/matches/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN", "USER")
                        .requestMatchers("/api/notifications/**").authenticated()
                        .anyRequest().authenticated()
                )
                .addFilterBefore(saTokenAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
