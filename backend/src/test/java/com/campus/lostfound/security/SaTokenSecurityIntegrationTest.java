package com.campus.lostfound.security;

import cn.dev33.satoken.stp.StpUtil;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.nullable;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * 纯 Sa-Token 鉴权集成测试 - 覆盖:
 *  1. 有效 token 通过受保护接口
 *  2. 禁用用户被拒
 *  3. 数据库角色被降级后,旧 token 立即失效(实时权限)
 *  4. 数据库角色被升级后,旧 token 立即生效
 *  5. 无 token 401
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(SaTokenTestConfig.class)
class SaTokenSecurityIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private UserService userService;

    @BeforeEach
    void setUp() {
        when(userService.adminQueryUsers(
                nullable(String.class),
                nullable(String.class),
                nullable(Integer.class),
                nullable(Boolean.class),
                anyInt(),
                anyInt()))
                .thenReturn(PageResponse.of(List.<User>of(), 0, 1, 10));
    }

    @Test
    void validTokenShouldAllowProfileAccess() throws Exception {
        User user = buildUser(1L, "USER", 1);
        when(userRepository.selectById(1L)).thenReturn(user);
        when(userService.getById(1L)).thenReturn(user);

        StpUtil.login(1L);
        String token = StpUtil.getTokenValue();

        mockMvc.perform(get("/api/users/profile")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.role").value("USER"));
    }

    @Test
    void disabledUserShouldReturnUnauthorized() throws Exception {
        User disabled = buildUser(4L, "USER", 0);
        when(userRepository.selectById(4L)).thenReturn(disabled);
        when(userService.getById(4L)).thenReturn(disabled);

        StpUtil.login(4L);
        String token = StpUtil.getTokenValue();

        // 被禁用的用户不会写入 SecurityContext → 等价于未登录 → 401
        // (前端拦截器收到 401 会尝试 refresh，refresh 也失败则跳登录页)
        mockMvc.perform(get("/api/users/profile")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void downgradedDatabaseRoleShouldBlockAdminAccess() throws Exception {
        // token 签发时是 CAMPUS_ADMIN,数据库里被降级为 USER
        User downgraded = buildUser(2L, "USER", 1);
        when(userRepository.selectById(2L)).thenReturn(downgraded);
        when(userService.getById(2L)).thenReturn(downgraded);

        StpUtil.login(2L);
        String staleToken = StpUtil.getTokenValue();

        mockMvc.perform(get("/api/admin/users")
                        .header("Authorization", "Bearer " + staleToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void upgradedDatabaseRoleShouldAllowAdminAccess() throws Exception {
        User upgraded = buildUser(3L, "CAMPUS_ADMIN", 1);
        when(userRepository.selectById(3L)).thenReturn(upgraded);
        when(userService.getById(3L)).thenReturn(upgraded);

        StpUtil.login(3L);
        String staleToken = StpUtil.getTokenValue();

        mockMvc.perform(get("/api/admin/users")
                        .header("Authorization", "Bearer " + staleToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void noTokenShouldReturnUnauthorized() throws Exception {
        // 未登录 → 401 + JSON body(而不是 Spring 默认的 403),
        // 前端 axios 拦截器据此触发 refresh token 流程
        mockMvc.perform(get("/api/users/profile"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void invalidTokenShouldReturnUnauthorized() throws Exception {
        mockMvc.perform(get("/api/users/profile")
                        .header("Authorization", "Bearer not.a.valid.jwt"))
                .andExpect(status().isUnauthorized());
    }

    private User buildUser(Long id, String role, Integer status) {
        User user = new User();
        user.setId(id);
        user.setUsername("user" + id);
        user.setRole(role);
        user.setStatus(status);
        return user;
    }
}
