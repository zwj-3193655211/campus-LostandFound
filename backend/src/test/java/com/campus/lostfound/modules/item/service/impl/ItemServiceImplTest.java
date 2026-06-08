package com.campus.lostfound.modules.item.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.common.service.RedisCacheService;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemImageRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.match.service.MatchingService;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 覆盖管理员物品审核的关键状态机分支。
 */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class ItemServiceImplTest {

    @Mock private ItemRepository itemRepository;
    @Mock private ItemImageRepository itemImageRepository;
    @Mock private MatchRepository matchRepository;
    @Mock private ItemCompletionRequestRepository completionRequestRepository;
    @Mock private NotificationRepository notificationRepository;
    @Mock private JdbcTemplate jdbcTemplate;
    @Mock private RedisCacheService cacheService;
    @Mock private ObjectMapper objectMapper;
    @Mock private NotificationService notificationService;
    @Mock private MatchingService matchingService;

    private ItemServiceImpl itemService;

    @BeforeEach
    void setUp() {
        itemService = new ItemServiceImpl(
                itemRepository, itemImageRepository, matchRepository,
                completionRequestRepository, notificationRepository,
                jdbcTemplate, cacheService, objectMapper,
                notificationService, matchingService);
    }

    @Test
    void review_approvedTriggersMatchAndNotifies() {
        Item pending = new Item();
        pending.setId(123L);
        pending.setStatus(ItemConstants.Status.PENDING);
        pending.setUserId(50L);
        when(itemRepository.selectById(123L)).thenReturn(pending);
        when(itemRepository.update(any(), any(LambdaUpdateWrapper.class))).thenReturn(1);
        when(itemRepository.selectById(123L))
                .thenReturn(pending)   // first call (pre-check)
                .thenReturn(withStatus(pending, ItemConstants.Status.APPROVED)); // second call (after update)

        Item result = itemService.review(123L, 1L, true, null);

        assertEquals(ItemConstants.Status.APPROVED, result.getStatus());
        // 关键副作用:通知 + 匹配
        verify(notificationService).notifyVerificationResult(123L, ItemConstants.Status.APPROVED, null);
        verify(matchingService).match(123L);
        verify(cacheService).clearItemCache(123L);
        verify(cacheService).clearStatisticsCache();
    }

    @Test
    void review_rejectedSkipsMatchButNotifies() {
        Item pending = new Item();
        pending.setId(456L);
        pending.setStatus(ItemConstants.Status.PENDING);
        pending.setUserId(50L);
        when(itemRepository.selectById(456L)).thenReturn(pending);
        when(itemRepository.update(any(), any(LambdaUpdateWrapper.class))).thenReturn(1);
        when(itemRepository.selectById(456L))
                .thenReturn(pending)
                .thenReturn(withStatus(pending, ItemConstants.Status.REJECTED));

        Item result = itemService.review(456L, 1L, false, "信息不全");

        assertEquals(ItemConstants.Status.REJECTED, result.getStatus());
        verify(notificationService).notifyVerificationResult(456L, ItemConstants.Status.REJECTED, "信息不全");
        verify(matchingService, never()).match(anyLong());
    }

    @Test
    void review_nonPendingItemRejected() {
        Item approved = new Item();
        approved.setId(789L);
        approved.setStatus(ItemConstants.Status.APPROVED);
        when(itemRepository.selectById(789L)).thenReturn(approved);

        BusinessException ex = assertThrows(BusinessException.class,
                () -> itemService.review(789L, 1L, true, null));
        assertEquals("仅待审核物品可被审核,当前状态: APPROVED", ex.getMessage());
        // 关键:没有发出通知,没有触发匹配
        verify(notificationService, never()).notifyVerificationResult(anyLong(), any(), any());
        verify(matchingService, never()).match(anyLong());
    }

    @Test
    void review_concurrentUpdateLosesRace() {
        Item pending = new Item();
        pending.setId(999L);
        pending.setStatus(ItemConstants.Status.PENDING);
        when(itemRepository.selectById(999L)).thenReturn(pending);
        when(itemRepository.update(any(), any(LambdaUpdateWrapper.class))).thenReturn(0);

        BusinessException ex = assertThrows(BusinessException.class,
                () -> itemService.review(999L, 1L, true, null));
        assertEquals("该物品已被其他管理员审核", ex.getMessage());
        verify(notificationService, never()).notifyVerificationResult(anyLong(), any(), any());
        verify(matchingService, never()).match(anyLong());
    }

    @Test
    void review_missingItemRejected() {
        when(itemRepository.selectById(404L)).thenReturn(null);
        BusinessException ex = assertThrows(BusinessException.class,
                () -> itemService.review(404L, 1L, true, null));
        assertEquals("物品不存在", ex.getMessage());
    }

    @Test
    void review_notificationFailureDoesNotRollback() {
        // 通知异常应当被吞掉,不影响审核结果返回
        Item pending = new Item();
        pending.setId(111L);
        pending.setStatus(ItemConstants.Status.PENDING);
        pending.setUserId(50L);
        when(itemRepository.selectById(111L)).thenReturn(pending);
        when(itemRepository.update(any(), any(LambdaUpdateWrapper.class))).thenReturn(1);
        when(itemRepository.selectById(111L))
                .thenReturn(pending)
                .thenReturn(withStatus(pending, ItemConstants.Status.APPROVED));
        // 让 notifyVerificationResult 抛异常
        org.mockito.Mockito.doThrow(new RuntimeException("SMTP down"))
                .when(notificationService).notifyVerificationResult(anyLong(), any(), any());

        Item result = itemService.review(111L, 1L, true, null);
        assertEquals(ItemConstants.Status.APPROVED, result.getStatus());
        // 匹配仍然触发
        verify(matchingService).match(111L);
    }

    private static Item withStatus(Item base, String status) {
        Item copy = new Item();
        copy.setId(base.getId());
        copy.setStatus(status);
        copy.setUserId(base.getUserId());
        return copy;
    }
}
