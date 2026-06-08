package com.campus.lostfound.security.config;

import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.security.SaTokenAuthenticationFilter;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security 配置
 *
 * <p>关键点:</p>
 * <ul>
 *   <li>用 {@link SaTokenAuthenticationFilter} 从 {@code Authorization: Bearer ...}
 *       头读 JWT,设置到 Spring Security 的 {@code SecurityContext};</li>
 *   <li>{@link AuthenticationEntryPoint} 用 {@link HttpStatusEntryPoint} 配
 *       {@code 401 UNAUTHORIZED} —— 之前默认的 {@code Http403ForbiddenEntryPoint}
 *       会让 token 过期时返回 403 + 空 body,前端 axios 拦截器只对 401 触发
 *       refresh,403 直接被丢掉,用户得手动重登。</li>
 *   <li>受保护路径要求 {@code .authenticated()},具体角色限制在更具体的
 *       matcher 上。</li>
 * </ul>
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class WebSecurityConfig {

    private final SaTokenAuthenticationFilter saTokenAuthenticationFilter;
    private final ObjectMapper objectMapper;

    public WebSecurityConfig(SaTokenAuthenticationFilter saTokenAuthenticationFilter,
                             ObjectMapper objectMapper) {
        this.saTokenAuthenticationFilter = saTokenAuthenticationFilter;
        this.objectMapper = objectMapper;
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
                .cors(cors -> {})
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
                        .requestMatchers("/api/uploads/**").authenticated()
                        .requestMatchers("/api/matches/**").hasAnyRole("SUPER_ADMIN", "CAMPUS_ADMIN", "USER")
                        .requestMatchers("/api/notifications/**").authenticated()
                        .anyRequest().authenticated()
                )
                // 关键改动:
                //  - AuthenticationException(未登录)→ 401 + JSON body,
                //    前端 axios 拦截器对 401 自动 refresh;
                //  - AccessDeniedException(已登录但无权限)→ 403 + JSON body,
                //    告诉前端"无权访问",不是"请重新登录"。
                .exceptionHandling(eh -> eh
                        .authenticationEntryPoint(unauthorizedJsonEntryPoint())
                        .accessDeniedHandler(forbiddenJsonHandler()))
                .addFilterBefore(saTokenAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    private AuthenticationEntryPoint unauthorizedJsonEntryPoint() {
        return (request, response, authException) -> {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");
            // 与项目 ApiResponse 包络一致(code=401, message="未登录或登录已过期")
            ApiResponse<Void> body = ApiResponse.error(401, "未登录或登录已过期");
            objectMapper.writeValue(response.getOutputStream(), body);
        };
    }

    /**
     * 已登录但权限不足 → 403 + JSON body。
     * 跟 {@link #unauthorizedJsonEntryPoint} 区分,前端可以分别提示
     * "请重新登录" vs "无权访问"。
     */
    private org.springframework.security.web.access.AccessDeniedHandler forbiddenJsonHandler() {
        return (request, response, accessDeniedException) -> {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");
            ApiResponse<Void> body = ApiResponse.error(403, "无权访问该资源");
            objectMapper.writeValue(response.getOutputStream(), body);
        };
    }
}
