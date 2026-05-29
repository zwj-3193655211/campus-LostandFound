package com.campus.lostfound.modules.item.service;

import com.campus.lostfound.common.dto.request.ItemCreateRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemImageRepository;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.item.service.impl.ItemServiceImpl;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ItemServiceImplTest {

    @Mock
    private ItemRepository itemRepository;

    @Mock
    private ItemImageRepository itemImageRepository;

    @Mock
    private MatchRepository matchRepository;

    @Mock
    private ItemCompletionRequestRepository itemCompletionRequestRepository;

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private JdbcTemplate jdbcTemplate;

    private ItemServiceImpl itemService;

    @BeforeEach
    void setUp() {
        itemService = new ItemServiceImpl(
                itemRepository,
                itemImageRepository,
                matchRepository,
                itemCompletionRequestRepository,
                notificationRepository,
                jdbcTemplate
        );
    }

    @Test
    void shouldRejectUpdateForApprovedItem() {
        Item item = buildItem(1L, 100L, "APPROVED");
        when(itemRepository.selectById(1L)).thenReturn(item);

        BusinessException exception = assertThrows(BusinessException.class,
                () -> itemService.update(1L, new ItemCreateRequest(), 100L));

        assertEquals("仅待审核物品允许修改", exception.getMessage());
        verify(itemRepository, never()).updateById(item);
    }

    @Test
    void shouldRejectDeleteForClaimedItem() {
        Item item = buildItem(1L, 100L, "CLAIMED");
        when(itemRepository.selectById(1L)).thenReturn(item);

        BusinessException exception = assertThrows(BusinessException.class,
                () -> itemService.delete(1L, 100L));

        assertEquals("仅待审核物品允许删除", exception.getMessage());
        verify(itemRepository, never()).deleteById(1L);
    }

    private Item buildItem(Long id, Long userId, String status) {
        Item item = new Item();
        item.setId(id);
        item.setUserId(userId);
        item.setStatus(status);
        return item;
    }
}
