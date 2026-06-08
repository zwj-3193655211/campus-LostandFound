package com.campus.lostfound.modules.system.service;

import com.campus.lostfound.common.dto.request.LoginRequest;
import com.campus.lostfound.common.dto.request.RegisterRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.impl.AuthServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 认证服务单元测试(纯 Sa-Token,不再 mock JwtUtils)
 * 完整登录链路(Web 层 + JWT 签发)由 SaTokenSecurityIntegrationTest 覆盖。
 */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailVerificationService emailVerificationService;

    private AuthService authService;
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        passwordEncoder = new BCryptPasswordEncoder();
        when(emailVerificationService.isRegisterVerificationRequired()).thenReturn(false);
        authService = new AuthServiceImpl(userRepository, passwordEncoder, emailVerificationService);
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
    void testLoginFailed() {
        when(userRepository.selectOne(any())).thenReturn(null);

        LoginRequest request = new LoginRequest();
        request.setUsername("nonexistent");
        request.setPassword("wrong");

        BusinessException exception = assertThrows(BusinessException.class, () -> authService.login(request));
        assertEquals("用户名或密码错误", exception.getMessage());
    }
}
