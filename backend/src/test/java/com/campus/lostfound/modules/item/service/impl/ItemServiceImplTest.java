package com.campus.lostfound.modules.item.service.impl;
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
import com.campus.lostfound.modules.system.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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
    @Mock private UserRepository userRepository;
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
                userRepository, jdbcTemplate, cacheService, objectMapper,
                notificationService, matchingService);
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
}
