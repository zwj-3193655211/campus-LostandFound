package com.campus.lostfound.modules.item.service.impl;

import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemImageRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ItemServiceImplTest {

    @Mock
    private ItemRepository itemRepository;

    @Mock
    private ItemImageRepository itemImageRepository;

    @Mock
    private MatchRepository matchRepository;

    @Mock
    private ItemCompletionRequestRepository completionRequestRepository;

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private JdbcTemplate jdbcTemplate;

    @Test
    void incrementViewCount_setsZeroWhenNull() {
        ItemServiceImpl service = new ItemServiceImpl(
                itemRepository,
                itemImageRepository,
                matchRepository,
                completionRequestRepository,
                notificationRepository,
                jdbcTemplate
        );

        service.incrementViewCount(1L);

        verify(jdbcTemplate).update(
                eq("UPDATE items SET view_count = COALESCE(view_count, 0) + 1 WHERE id = ?"),
                eq(1L)
        );
    }
}
