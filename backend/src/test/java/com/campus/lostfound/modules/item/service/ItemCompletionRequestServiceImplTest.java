package com.campus.lostfound.modules.item.service;

import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.item.service.impl.ItemCompletionRequestServiceImpl;
import com.campus.lostfound.modules.notification.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ItemCompletionRequestServiceImplTest {

    @Mock
    private ItemCompletionRequestRepository completionRequestRepository;

    @Mock
    private ItemRepository itemRepository;

    @Mock
    private NotificationService notificationService;

    private ItemCompletionRequestServiceImpl completionRequestService;

    @BeforeEach
    void setUp() {
        completionRequestService = new ItemCompletionRequestServiceImpl(
                completionRequestRepository,
                itemRepository,
                notificationService
        );
    }

    @Test
    void shouldApproveCompletionRequestAndUpdateItemStatus() {
        Item item = new Item();
        item.setId(100L);
        item.setUserId(200L);
        item.setType(ItemConstants.Type.LOST);
        item.setTitle("校园卡");
        item.setStatus(ItemConstants.Status.APPROVED);

        ItemCompletionRequest request = new ItemCompletionRequest();
        request.setId(10L);
        request.setItemId(100L);
        request.setUserId(200L);
        request.setTargetStatus(ItemConstants.Status.FOUND_BACK);
        request.setStatus(ItemConstants.CompletionStatus.PENDING);

        when(completionRequestRepository.selectById(10L)).thenReturn(request);
        when(itemRepository.selectById(100L)).thenReturn(item);
        when(completionRequestRepository.update(any(ItemCompletionRequest.class), any())).thenReturn(1);
        when(itemRepository.update(any(Item.class), any())).thenReturn(1);

        completionRequestService.review(10L, 1L, true, null);

        assertEquals(ItemConstants.CompletionStatus.APPROVED, request.getStatus());
        assertEquals(ItemConstants.Status.FOUND_BACK, item.getStatus());
        verify(itemRepository).update(any(Item.class), any());
        verify(completionRequestRepository).update(any(ItemCompletionRequest.class), any());
        verify(notificationService).create(
                eq(200L),
                eq(ItemConstants.NotificationType.COMPLETION_REVIEW_RESULT),
                eq("完成申请已通过"),
                contains("当前状态已更新为已找到"),
                eq(100L)
        );
    }

    @Test
    void shouldRejectReviewWhenCompletionRequestAlreadyProcessed() {
        ItemCompletionRequest request = new ItemCompletionRequest();
        request.setId(10L);
        request.setStatus(ItemConstants.CompletionStatus.REJECTED);
        when(completionRequestRepository.selectById(10L)).thenReturn(request);

        BusinessException exception = assertThrows(BusinessException.class,
                () -> completionRequestService.review(10L, 1L, true, null));

        assertEquals("该完成申请已处理", exception.getMessage());
        verify(itemRepository, never()).updateById(org.mockito.ArgumentMatchers.any());
        verify(notificationService, never()).create(
                org.mockito.ArgumentMatchers.anyLong(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyLong()
        );
    }

    @Test
    void shouldRejectCompletionRequestWithoutChangingItemStatus() {
        Item item = new Item();
        item.setId(100L);
        item.setUserId(200L);
        item.setType(ItemConstants.Type.FOUND);
        item.setTitle("钥匙");
        item.setStatus(ItemConstants.Status.APPROVED);

        ItemCompletionRequest request = new ItemCompletionRequest();
        request.setId(10L);
        request.setItemId(100L);
        request.setUserId(200L);
        request.setTargetStatus(ItemConstants.Status.RETURNED);
        request.setStatus(ItemConstants.CompletionStatus.PENDING);

        when(completionRequestRepository.selectById(10L)).thenReturn(request);
        when(itemRepository.selectById(100L)).thenReturn(item);
        when(completionRequestRepository.update(any(ItemCompletionRequest.class), any())).thenReturn(1);

        completionRequestService.review(10L, 1L, false, "证据不足");

        assertEquals(ItemConstants.CompletionStatus.REJECTED, request.getStatus());
        assertEquals(ItemConstants.Status.APPROVED, item.getStatus());
        verify(itemRepository, never()).update(any(Item.class), any());
        verify(completionRequestRepository).update(any(ItemCompletionRequest.class), any());
        verify(notificationService).create(
                eq(200L),
                eq(ItemConstants.NotificationType.COMPLETION_REVIEW_RESULT),
                eq("完成申请未通过"),
                contains("原因：证据不足"),
                eq(100L)
        );
    }

    @Test
    void shouldRejectReviewWhenConcurrentUpdateAlreadyProcessedCompletionRequest() {
        ItemCompletionRequest request = new ItemCompletionRequest();
        request.setId(10L);
        request.setItemId(100L);
        request.setStatus(ItemConstants.CompletionStatus.PENDING);

        Item item = new Item();
        item.setId(100L);
        item.setStatus(ItemConstants.Status.APPROVED);

        when(completionRequestRepository.selectById(10L)).thenReturn(request);
        when(itemRepository.selectById(100L)).thenReturn(item);
        when(completionRequestRepository.update(any(ItemCompletionRequest.class), any())).thenReturn(0);

        BusinessException exception = assertThrows(BusinessException.class,
                () -> completionRequestService.review(10L, 1L, true, null));

        assertEquals("该完成申请已处理", exception.getMessage());
        verify(itemRepository, never()).update(any(Item.class), any());
        verify(notificationService, never()).create(
                org.mockito.ArgumentMatchers.anyLong(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyLong()
        );
    }

    @Test
    void shouldRejectApprovalWhenItemStatusChangedBeforeCompletionReviewUpdate() {
        ItemCompletionRequest request = new ItemCompletionRequest();
        request.setId(10L);
        request.setItemId(100L);
        request.setUserId(200L);
        request.setTargetStatus(ItemConstants.Status.FOUND_BACK);
        request.setStatus(ItemConstants.CompletionStatus.PENDING);

        Item item = new Item();
        item.setId(100L);
        item.setTitle("校园卡");
        item.setStatus(ItemConstants.Status.APPROVED);

        when(completionRequestRepository.selectById(10L)).thenReturn(request);
        when(itemRepository.selectById(100L)).thenReturn(item);
        when(completionRequestRepository.update(any(ItemCompletionRequest.class), any())).thenReturn(1);
        when(itemRepository.update(any(Item.class), any())).thenReturn(0);

        BusinessException exception = assertThrows(BusinessException.class,
                () -> completionRequestService.review(10L, 1L, true, null));

        assertEquals("关联物品状态已变更，请刷新后重试", exception.getMessage());
        verify(notificationService, never()).create(
                org.mockito.ArgumentMatchers.anyLong(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyLong()
        );
    }
}
