package com.campus.lostfound.modules.system.service;

import com.campus.lostfound.common.dto.request.LoginRequest;
import com.campus.lostfound.common.dto.request.RegisterRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.util.JwtUtils;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.impl.AuthServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtUtils jwtUtils;

    private AuthService authService;
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        passwordEncoder = new BCryptPasswordEncoder();
        authService = new AuthServiceImpl(userRepository, passwordEncoder, jwtUtils);
    }

    @Test
    void testRegister() {
        when(userRepository.selectOne(any())).thenReturn(null);

        RegisterRequest request = new RegisterRequest();
        request.setUsername("test-user");
        request.setPassword("test123");
        request.setEmail("test@test.com");
        request.setStudentId("20240999");

        String result = authService.register(request);

        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).insert(captor.capture());
        User savedUser = captor.getValue();
        assertEquals("注册成功", result);
        assertEquals("test-user", savedUser.getUsername());
        assertEquals("USER", savedUser.getRole());
        assertNotNull(savedUser.getCreatedAt());
        assertNull(savedUser.getIdCard());
    }

    @Test
    void testLogin() {
        User user = new User();
        user.setId(1L);
        user.setUsername("login-user");
        user.setPassword(passwordEncoder.encode("test123"));
        user.setEmail("login@test.com");
        user.setStudentId("20240001");
        user.setRole("USER");
        user.setStatus(1);
        user.setIdCard("123456789012345678");
        user.setNotificationInApp(1);
        user.setNotificationEmail(1);
        user.setNotificationMatch(1);
        user.setNotificationVerification(1);

        when(userRepository.selectOne(any())).thenReturn(user);
        when(jwtUtils.generateAccessToken(1L, "login-user", "USER")).thenReturn("access-token");
        when(jwtUtils.generateRefreshToken(1L, "login-user")).thenReturn("refresh-token");

        LoginRequest request = new LoginRequest();
        request.setUsername("login-user");
        request.setPassword("test123");
        Map<String, Object> tokens = authService.login(request);

        assertEquals("access-token", tokens.get("token"));
        assertEquals("refresh-token", tokens.get("refreshToken"));
        Map<String, Object> userMap = (Map<String, Object>) tokens.get("user");
        assertEquals("1234**********5678", userMap.get("idCard"));
    }

    @Test
    void testLoginFailed() {
        when(userRepository.selectOne(any())).thenReturn(null);

        LoginRequest request = new LoginRequest();
        request.setUsername("nonexistent");
        request.setPassword("wrong");

        BusinessException exception = assertThrows(BusinessException.class, () -> authService.login(request));
        assertEquals("用户名或密码错误", exception.getMessage());
    }
}
