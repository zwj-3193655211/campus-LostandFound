package com.campus.lostfound.security;

import cn.dev33.satoken.stp.StpUtil;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Sa-Token → Spring Security 桥接过滤器
 *
 * 流程:
 *   1. 从 Authorization 头拿 Sa-Token token
 *   2. 调 StpUtil 检查登录态
 *   3. 从 DB 查 user(实时,角色/禁用立即生效)
 *   4. 把 user + ROLE_xxx 塞进 SecurityContext
 *   5. 后续 .hasAnyRole("ADMIN") 等 URL 权限校验才能正常工作
 *
 * 注意:这里用 UserRepository(直接查表)而不是 UserService,避免 UserService ->
 * PasswordEncoder -> WebSecurityConfig -> 本 filter 的循环依赖。
 */
@Component
public class SaTokenAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(SaTokenAuthenticationFilter.class);

    private final UserRepository userRepository;

    public SaTokenAuthenticationFilter(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String token = getTokenFromRequest(request);
        if (StringUtils.hasText(token) && StpUtil.isLogin()) {
            try {
                Object loginId = StpUtil.getLoginId();
                if (loginId != null) {
                    User user = userRepository.selectById(Long.valueOf(loginId.toString()));
                    if (user != null && Integer.valueOf(1).equals(user.getStatus())) {
                        String role = user.getRole();
                        List<SimpleGrantedAuthority> authorities = role != null
                                ? List.of(new SimpleGrantedAuthority("ROLE_" + role))
                                : List.of();

                        UsernamePasswordAuthenticationToken authentication =
                                new UsernamePasswordAuthenticationToken(user, null, authorities);
                        authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                        SecurityContextHolder.getContext().setAuthentication(authentication);
                        log.debug("用户 {} 认证成功 (Sa-Token)", user.getUsername());
                    }
                }
            } catch (Exception e) {
                log.error("Sa-Token 解析失败: {}", e.getMessage());
                SecurityContextHolder.clearContext();
            }
        }

        filterChain.doFilter(request, response);
    }

    private String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
