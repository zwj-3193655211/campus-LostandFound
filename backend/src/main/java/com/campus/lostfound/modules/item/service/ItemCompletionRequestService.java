package com.campus.lostfound.modules.item.service;

import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;

import java.util.List;
import java.util.Map;

public interface ItemCompletionRequestService {

    ItemCompletionRequest submit(Long itemId, Long userId, String targetStatus, String reason);

    void review(Long requestId, Long adminId, boolean approved, String reason);

    List<ItemCompletionRequest> listPending();

    Map<Long, ItemCompletionRequest> findLatestPendingByItemIds(List<Long> itemIds);
}
