package com.campus.lostfound.security;

import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.common.util.JwtUtils;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.nullable;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class JwtSecurityIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtUtils jwtUtils;

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
    void accessTokenShouldAllowAuthenticatedProfileAccess() throws Exception {
        User currentUser = buildUser(1L, "USER", 1);
        when(userRepository.selectById(1L)).thenReturn(currentUser);
        when(userService.getById(1L)).thenReturn(currentUser);

        String accessToken = jwtUtils.generateAccessToken(1L, "student1", "USER");

        mockMvc.perform(get("/api/users/profile")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.role").value("USER"));
    }

    @Test
    void refreshTokenShouldNotAuthenticateProtectedEndpoint() throws Exception {
        String refreshToken = jwtUtils.generateRefreshToken(1L, "student1");

        mockMvc.perform(get("/api/users/profile")
                        .header("Authorization", "Bearer " + refreshToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void downgradedDatabaseRoleShouldBlockAdminAccess() throws Exception {
        User downgradedUser = buildUser(2L, "USER", 1);
        when(userRepository.selectById(2L)).thenReturn(downgradedUser);

        String staleAdminToken = jwtUtils.generateAccessToken(2L, "campusAdmin", "CAMPUS_ADMIN");

        mockMvc.perform(get("/api/admin/users")
                        .header("Authorization", "Bearer " + staleAdminToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void upgradedDatabaseRoleShouldAllowAdminAccess() throws Exception {
        User upgradedUser = buildUser(3L, "CAMPUS_ADMIN", 1);
        when(userRepository.selectById(3L)).thenReturn(upgradedUser);

        String staleUserToken = jwtUtils.generateAccessToken(3L, "campusAdmin", "USER");

        mockMvc.perform(get("/api/admin/users")
                        .header("Authorization", "Bearer " + staleUserToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void disabledUserShouldBeRejectedEvenWithValidAccessToken() throws Exception {
        User disabledUser = buildUser(4L, "USER", 0);
        when(userRepository.selectById(4L)).thenReturn(disabledUser);

        String accessToken = jwtUtils.generateAccessToken(4L, "disabledUser", "USER");

        mockMvc.perform(get("/api/users/profile")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isForbidden());
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
