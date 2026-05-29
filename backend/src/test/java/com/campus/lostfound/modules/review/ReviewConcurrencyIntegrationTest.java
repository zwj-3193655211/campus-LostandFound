package com.campus.lostfound.modules.review;

import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.item.service.ItemCompletionRequestService;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.campus.lostfound.modules.verification.entity.Verification;
import com.campus.lostfound.modules.verification.repository.VerificationRepository;
import com.campus.lostfound.modules.verification.service.VerificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@ActiveProfiles("test")
class ReviewConcurrencyIntegrationTest {

    @Autowired
    private VerificationService verificationService;

    @Autowired
    private ItemCompletionRequestService itemCompletionRequestService;

    @Autowired
    private VerificationRepository verificationRepository;

    @Autowired
    private ItemCompletionRequestRepository completionRequestRepository;

    @Autowired
    private ItemRepository itemRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @MockBean
    private NotificationService notificationService;

    @BeforeEach
    void setUp() {
        ensureSchema();
        tearDown();
    }

    @AfterEach
    void tearDown() {
        jdbcTemplate.execute("DELETE FROM notifications");
        jdbcTemplate.execute("DELETE FROM item_completion_requests");
        jdbcTemplate.execute("DELETE FROM verifications");
        jdbcTemplate.execute("DELETE FROM item_images");
        jdbcTemplate.execute("DELETE FROM matches");
        jdbcTemplate.execute("DELETE FROM items");
        jdbcTemplate.execute("DELETE FROM user_identity_verifications");
        jdbcTemplate.execute("DELETE FROM users");
    }

    private void ensureSchema() {
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    username VARCHAR(50) NOT NULL,
                    password VARCHAR(255) NOT NULL,
                    email VARCHAR(100) NOT NULL,
                    student_id VARCHAR(20),
                    phone VARCHAR(20),
                    real_name VARCHAR(50),
                    id_card VARCHAR(18),
                    identity_status VARCHAR(20) NOT NULL DEFAULT 'UNVERIFIED',
                    identity_verified_at TIMESTAMP NULL,
                    role VARCHAR(20) NOT NULL DEFAULT 'USER',
                    status TINYINT NOT NULL DEFAULT 1,
                    notification_in_app TINYINT NOT NULL DEFAULT 1,
                    notification_email TINYINT NOT NULL DEFAULT 1,
                    notification_match TINYINT NOT NULL DEFAULT 1,
                    notification_verification TINYINT NOT NULL DEFAULT 1,
                    last_login_time TIMESTAMP NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    deleted TINYINT NOT NULL DEFAULT 0
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS items (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    user_id BIGINT NOT NULL,
                    type VARCHAR(20) NOT NULL,
                    category VARCHAR(50) NOT NULL,
                    title VARCHAR(100) NOT NULL,
                    description CLOB,
                    brand VARCHAR(50),
                    color VARCHAR(20),
                    location_id BIGINT NULL,
                    location VARCHAR(100),
                    lost_time TIMESTAMP NULL,
                    found_time TIMESTAMP NULL,
                    serial_number VARCHAR(50),
                    contact_info VARCHAR(100),
                    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                    view_count INT NOT NULL DEFAULT 0,
                    match_score DECIMAL(5, 2),
                    match_item_id BIGINT NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    deleted TINYINT NOT NULL DEFAULT 0
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS verifications (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    item_id BIGINT NOT NULL,
                    claimant_id BIGINT NOT NULL,
                    claim_proof CLOB NOT NULL,
                    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                    reject_reason VARCHAR(255),
                    reviewed_by BIGINT NULL,
                    reviewed_at TIMESTAMP NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS item_completion_requests (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    item_id BIGINT NOT NULL,
                    user_id BIGINT NOT NULL,
                    target_status VARCHAR(20) NOT NULL,
                    reason VARCHAR(255),
                    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                    review_reason VARCHAR(255),
                    reviewed_by BIGINT NULL,
                    reviewed_at TIMESTAMP NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS notifications (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    user_id BIGINT NOT NULL,
                    type VARCHAR(50) NOT NULL,
                    title VARCHAR(100) NOT NULL,
                    content CLOB NOT NULL,
                    related_id BIGINT NULL,
                    is_read TINYINT NOT NULL DEFAULT 0,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS item_images (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    item_id BIGINT NOT NULL,
                    image_url VARCHAR(255) NOT NULL,
                    image_type VARCHAR(20) NOT NULL DEFAULT 'DETAIL',
                    sort_order INT NOT NULL DEFAULT 0,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS matches (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    lost_item_id BIGINT NOT NULL,
                    found_item_id BIGINT NOT NULL,
                    score DECIMAL(5, 2) NOT NULL,
                    match_type VARCHAR(20) NOT NULL,
                    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                    is_read TINYINT NOT NULL DEFAULT 0,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """);
        jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS user_identity_verifications (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    user_id BIGINT NOT NULL,
                    real_name VARCHAR(50) NOT NULL,
                    id_card VARCHAR(18) NOT NULL,
                    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                    review_reason VARCHAR(255),
                    reviewed_by BIGINT NULL,
                    reviewed_at TIMESTAMP NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """);
    }

    @Test
    void onlyOneVerificationReviewShouldSucceedUnderConcurrentRequests() throws Exception {
        User owner = insertUser("owner");
        User claimant = insertUser("claimant");
        User admin = insertUser("admin");
        Item item = insertApprovedItem(owner.getId(), ItemConstants.Type.FOUND, "失物招领-校园卡");
        Verification verification = insertPendingVerification(item.getId(), claimant.getId());

        List<Throwable> failures = new ArrayList<>();
        AtomicInteger successCount = new AtomicInteger();

        runConcurrently(
                () -> verificationService.review(verification.getId(), admin.getId(), true, null),
                failures,
                successCount
        );

        Verification latest = verificationRepository.selectById(verification.getId());
        assertNotNull(latest);
        assertEquals(1, successCount.get());
        assertEquals(1, failures.size());
        assertTrue(failures.get(0) instanceof BusinessException);
        assertEquals("该申请已处理", failures.get(0).getMessage());
        assertEquals("APPROVED", latest.getStatus());
        assertEquals(admin.getId(), latest.getReviewedBy());
        assertNotNull(latest.getReviewedAt());
    }

    @Test
    void onlyOneCompletionReviewShouldSucceedUnderConcurrentRequests() throws Exception {
        User owner = insertUser("owner");
        User admin = insertUser("admin");
        Item item = insertApprovedItem(owner.getId(), ItemConstants.Type.LOST, "寻物启事-平板电脑");
        ItemCompletionRequest request = insertPendingCompletionRequest(item.getId(), owner.getId(), ItemConstants.Status.FOUND_BACK);

        List<Throwable> failures = new ArrayList<>();
        AtomicInteger successCount = new AtomicInteger();

        runConcurrently(
                () -> itemCompletionRequestService.review(request.getId(), admin.getId(), true, null),
                failures,
                successCount
        );

        ItemCompletionRequest latestRequest = completionRequestRepository.selectById(request.getId());
        Item latestItem = itemRepository.selectById(item.getId());
        assertNotNull(latestRequest);
        assertNotNull(latestItem);
        assertEquals(1, successCount.get());
        assertEquals(1, failures.size());
        assertTrue(failures.get(0) instanceof BusinessException);
        assertEquals("该完成申请已处理", failures.get(0).getMessage());
        assertEquals(ItemConstants.CompletionStatus.APPROVED, latestRequest.getStatus());
        assertEquals(admin.getId(), latestRequest.getReviewedBy());
        assertEquals(ItemConstants.Status.FOUND_BACK, latestItem.getStatus());
    }

    private void runConcurrently(ThrowingRunnable action, List<Throwable> failures, AtomicInteger successCount)
            throws InterruptedException, ExecutionException {
        CountDownLatch ready = new CountDownLatch(2);
        CountDownLatch start = new CountDownLatch(1);
        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            Callable<Void> task = () -> {
                ready.countDown();
                if (!start.await(5, TimeUnit.SECONDS)) {
                    throw new IllegalStateException("并发测试启动超时");
                }
                try {
                    action.run();
                    successCount.incrementAndGet();
                } catch (Throwable throwable) {
                    synchronized (failures) {
                        failures.add(throwable);
                    }
                }
                return null;
            };

            Future<Void> first = executor.submit(task);
            Future<Void> second = executor.submit(task);
            assertTrue(ready.await(5, TimeUnit.SECONDS), "并发线程未能及时就绪");
            start.countDown();
            first.get();
            second.get();
        } finally {
            executor.shutdownNow();
        }
    }

    private User insertUser(String prefix) {
        String suffix = UUID.randomUUID().toString().substring(0, 8);
        User user = new User();
        user.setUsername(prefix + "_" + suffix);
        user.setPassword("$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq");
        user.setEmail(prefix + "_" + suffix + "@campus.test");
        user.setIdentityStatus("UNVERIFIED");
        user.setRole("USER");
        user.setStatus(1);
        user.setNotificationInApp(1);
        user.setNotificationEmail(1);
        user.setNotificationMatch(1);
        user.setNotificationVerification(1);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.insert(user);
        return user;
    }

    private Item insertApprovedItem(Long userId, String type, String title) {
        Item item = new Item();
        item.setUserId(userId);
        item.setType(type);
        item.setCategory("电子产品");
        item.setTitle(title);
        item.setDescription("并发测试数据");
        item.setLocation("测试地点");
        item.setStatus(ItemConstants.Status.APPROVED);
        item.setViewCount(0);
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());
        itemRepository.insert(item);
        return item;
    }

    private Verification insertPendingVerification(Long itemId, Long claimantId) {
        Verification verification = new Verification();
        verification.setItemId(itemId);
        verification.setClaimantId(claimantId);
        verification.setClaimProof("并发认领证明");
        verification.setStatus("PENDING");
        verification.setCreatedAt(LocalDateTime.now());
        verification.setUpdatedAt(LocalDateTime.now());
        verificationRepository.insert(verification);
        return verification;
    }

    private ItemCompletionRequest insertPendingCompletionRequest(Long itemId, Long userId, String targetStatus) {
        ItemCompletionRequest request = new ItemCompletionRequest();
        request.setItemId(itemId);
        request.setUserId(userId);
        request.setTargetStatus(targetStatus);
        request.setReason("并发完成申请");
        request.setStatus(ItemConstants.CompletionStatus.PENDING);
        request.setCreatedAt(LocalDateTime.now());
        request.setUpdatedAt(LocalDateTime.now());
        completionRequestRepository.insert(request);
        return request;
    }

    @FunctionalInterface
    interface ThrowingRunnable {
        void run() throws Exception;
    }
}
