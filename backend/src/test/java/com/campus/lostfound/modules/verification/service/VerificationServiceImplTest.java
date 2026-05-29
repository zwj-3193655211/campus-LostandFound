package com.campus.lostfound.modules.verification.service;

import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.notification.service.NotificationService;
import com.campus.lostfound.modules.verification.entity.Verification;
import com.campus.lostfound.modules.verification.repository.VerificationRepository;
import com.campus.lostfound.modules.verification.service.impl.VerificationServiceImpl;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VerificationServiceImplTest {

    @Mock
    private VerificationRepository verificationRepository;

    @Mock
    private ItemRepository itemRepository;

    @Mock
    private NotificationService notificationService;

    private VerificationServiceImpl verificationService;

    @BeforeEach
    void setUp() {
        verificationService = new VerificationServiceImpl(verificationRepository, itemRepository, notificationService);
    }

    @Test
    void shouldNotifyClaimantWhenClaimReviewApproved() {
        Verification verification = new Verification();
        verification.setId(10L);
        verification.setItemId(100L);
        verification.setClaimantId(200L);
        verification.setStatus("PENDING");
        when(verificationRepository.selectById(10L)).thenReturn(verification);
        when(verificationRepository.update(any(Verification.class), any())).thenReturn(1);

        verificationService.review(10L, 1L, true, null);

        verify(notificationService).notifyClaimReviewResult(10L, "APPROVED", null);
    }

    @Test
    void shouldRejectReviewWhenVerificationAlreadyProcessed() {
        Verification verification = new Verification();
        verification.setId(10L);
        verification.setStatus("APPROVED");
        when(verificationRepository.selectById(10L)).thenReturn(verification);

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> verificationService.review(10L, 1L, false, "重复审核"));

        assertEquals("该申请已处理", exception.getMessage());
        verify(notificationService, never()).notifyClaimReviewResult(10L, "REJECTED", "重复审核");
    }

    @Test
    void shouldSwallowNotificationFailureAfterReviewSucceeded() {
        Verification verification = new Verification();
        verification.setId(10L);
        verification.setItemId(100L);
        verification.setClaimantId(200L);
        verification.setStatus("PENDING");
        when(verificationRepository.selectById(10L)).thenReturn(verification);
        when(verificationRepository.update(any(Verification.class), any())).thenReturn(1);
        doThrow(new RuntimeException("mail failed"))
                .when(notificationService)
                .notifyClaimReviewResult(10L, "REJECTED", "资料不足");

        Assertions.assertDoesNotThrow(() -> verificationService.review(10L, 1L, false, "资料不足"));

        assertEquals("REJECTED", verification.getStatus());
        assertEquals("资料不足", verification.getRejectReason());
        verify(verificationRepository).update(any(Verification.class), any());
    }

    @Test
    void shouldRejectReviewWhenConcurrentUpdateAlreadyProcessedRequest() {
        Verification verification = new Verification();
        verification.setId(10L);
        verification.setStatus("PENDING");
        when(verificationRepository.selectById(10L)).thenReturn(verification);
        when(verificationRepository.update(any(Verification.class), any())).thenReturn(0);

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> verificationService.review(10L, 1L, true, null));

        assertEquals("该申请已处理", exception.getMessage());
        verify(notificationService, never()).notifyClaimReviewResult(10L, "APPROVED", null);
    }
}
