package com.campus.lostfound.security.config;

import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.common.util.JwtUtils;
import com.campus.lostfound.modules.item.controller.AdminCompletionRequestController;
import com.campus.lostfound.modules.item.controller.ItemController;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.service.ItemCompletionRequestService;
import com.campus.lostfound.modules.item.repository.ItemImageRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.item.repository.LocationRepository;
import com.campus.lostfound.modules.item.service.ItemService;
import com.campus.lostfound.modules.match.service.DocumentOwnerMatchService;
import com.campus.lostfound.modules.match.service.MatchingService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import com.campus.lostfound.modules.statistics.repository.DailyStatisticsRepository;
import com.campus.lostfound.modules.system.controller.AdminUserController;
import com.campus.lostfound.modules.system.controller.DbFixController;
import com.campus.lostfound.modules.system.controller.UserController;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserIdentityVerificationRepository;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.system.service.UserService;
import com.campus.lostfound.modules.verification.controller.VerificationController;
import com.campus.lostfound.modules.verification.repository.VerificationRepository;
import com.campus.lostfound.modules.verification.service.VerificationService;
import com.campus.lostfound.security.JwtAuthenticationFilter;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.web.client.RestTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.nullable;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ActiveProfiles("test")
@AutoConfigureMockMvc(addFilters = true)
@WebMvcTest(controllers = {
        ItemController.class,
        UserController.class,
        AdminUserController.class,
        DbFixController.class,
        VerificationController.class,
        AdminCompletionRequestController.class
})
@Import({WebSecurityConfig.class, JwtAuthenticationFilter.class})
class WebSecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ItemService itemService;

    @MockBean
    private VerificationService verificationService;

    @MockBean
    private ItemCompletionRequestService itemCompletionRequestService;

    @MockBean
    private MatchingService matchingService;

    @MockBean
    private NotificationService notificationService;

    @MockBean
    private DocumentOwnerMatchService documentOwnerMatchService;

    @MockBean
    private UserService userService;

    @MockBean
    private JdbcTemplate jdbcTemplate;

    @MockBean
    private RestTemplate restTemplate;

    @MockBean
    private JwtUtils jwtUtils;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private UserIdentityVerificationRepository userIdentityVerificationRepository;

    @MockBean
    private ItemRepository itemRepository;

    @MockBean
    private ItemImageRepository itemImageRepository;

    @MockBean
    private ItemCompletionRequestRepository itemCompletionRequestRepository;

    @MockBean
    private LocationRepository locationRepository;

    @MockBean
    private MatchRepository matchRepository;

    @MockBean
    private NotificationRepository notificationRepository;

    @MockBean
    private VerificationRepository verificationRepository;

    @MockBean
    private DailyStatisticsRepository dailyStatisticsRepository;

    @BeforeEach
    void setUp() {
        when(itemService.query(any())).thenReturn(PageResponse.of(List.<Item>of(), 0, 1, 10));
        when(userService.adminQueryUsers(
                nullable(String.class),
                nullable(String.class),
                nullable(Integer.class),
                nullable(Boolean.class),
                anyInt(),
                anyInt()))
                .thenReturn(PageResponse.of(List.<User>of(), 0, 1, 10));
        when(userService.getById(anyLong())).thenAnswer(invocation -> buildUser(invocation.getArgument(0), "USER"));
        doNothing().when(jdbcTemplate).execute(anyString());
    }

    @Test
    void publicItemQueryShouldBeAccessibleWithoutAuthentication() throws Exception {
        mockMvc.perform(get("/api/items"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void protectedUserProfileShouldRejectAnonymousRequest() throws Exception {
        mockMvc.perform(get("/api/users/profile"))
                .andExpect(status().isForbidden());
    }

    @Test
    void userShouldNotAccessAdminEndpoints() throws Exception {
        mockMvc.perform(get("/api/admin/users").with(authenticatedUser("USER")))
                .andExpect(status().isForbidden());
    }

    @Test
    void campusAdminShouldAccessAdminEndpoints() throws Exception {
        mockMvc.perform(get("/api/admin/users").with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void campusAdminShouldNotAccessDbEndpoints() throws Exception {
        mockMvc.perform(post("/api/db/fix-match-table").with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isForbidden());
    }

    @Test
    void superAdminShouldAccessDbEndpoints() throws Exception {
        mockMvc.perform(post("/api/db/fix-match-table").with(authenticatedUser("SUPER_ADMIN")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void dbFixEndpointShouldReturnErrorPayloadWhenJdbcExecutionFails() throws Exception {
        doThrow(new RuntimeException("boom"))
                .when(jdbcTemplate)
                .execute("ALTER TABLE `matches` MODIFY COLUMN `match_type` ENUM('SERIAL_EXACT', 'WEIGHTED', 'NONE') NOT NULL");

        mockMvc.perform(post("/api/db/fix-match-table").with(authenticatedUser("SUPER_ADMIN")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("修复失败: boom"));
    }

    @Test
    void rejectItemShouldRequireReason() throws Exception {
        mockMvc.perform(put("/api/admin/items/1/reject")
                        .param("reason", "   ")
                        .with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("拒绝原因不能为空"));
    }

    @Test
    void verificationReviewShouldRequireReasonWhenRejected() throws Exception {
        mockMvc.perform(put("/api/admin/verifications/1/review")
                        .param("approved", "false")
                        .param("reason", " ")
                        .with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("拒绝原因不能为空"));
    }

    @Test
    void completionReviewShouldRequireReasonWhenRejected() throws Exception {
        mockMvc.perform(put("/api/admin/completion-requests/1/review")
                        .param("approved", "false")
                        .param("reason", "")
                        .with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("拒绝原因不能为空"));
    }

    @Test
    void verificationReviewShouldRejectInvalidApprovedParameter() throws Exception {
        mockMvc.perform(put("/api/admin/verifications/1/review")
                        .param("approved", "maybe")
                        .with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("参数 approved 格式不正确"));
    }

    @Test
    void verificationReviewShouldRequireApprovedParameter() throws Exception {
        mockMvc.perform(put("/api/admin/verifications/1/review")
                        .with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("参数 approved 不能为空"));
    }

    @Test
    void completionReviewShouldRequireApprovedParameter() throws Exception {
        mockMvc.perform(put("/api/admin/completion-requests/1/review")
                        .with(authenticatedUser("CAMPUS_ADMIN")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("参数 approved 不能为空"));
    }

    private RequestPostProcessor authenticatedUser(String role) {
        User user = buildUser(1L, role);
        UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(
                user,
                null,
                List.of(new SimpleGrantedAuthority("ROLE_" + role))
        );
        return authentication(token);
    }

    private User buildUser(Long id, String role) {
        User user = new User();
        user.setId(id);
        user.setUsername(role.toLowerCase());
        user.setRole(role);
        user.setStatus(1);
        return user;
    }
}
