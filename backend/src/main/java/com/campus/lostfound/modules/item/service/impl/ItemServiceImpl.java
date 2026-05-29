package com.campus.lostfound.modules.item.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.dto.request.ItemCreateRequest;
import com.campus.lostfound.common.dto.request.ItemQueryRequest;
import com.campus.lostfound.common.exception.BusinessException;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;
import com.campus.lostfound.modules.item.entity.ItemImage;
import com.campus.lostfound.modules.item.repository.ItemCompletionRequestRepository;
import com.campus.lostfound.modules.item.repository.ItemImageRepository;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.match.repository.MatchRepository;
import com.campus.lostfound.modules.notification.entity.Notification;
import com.campus.lostfound.modules.notification.repository.NotificationRepository;
import com.campus.lostfound.modules.item.service.ItemService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 失物服务实现
 */
@Service
public class ItemServiceImpl implements ItemService {

    private final ItemRepository itemRepository;
    private final ItemImageRepository itemImageRepository;
    private final MatchRepository matchRepository;
    private final ItemCompletionRequestRepository completionRequestRepository;
    private final NotificationRepository notificationRepository;
    private final JdbcTemplate jdbcTemplate;

    public ItemServiceImpl(ItemRepository itemRepository,
                           ItemImageRepository itemImageRepository,
                           MatchRepository matchRepository,
                           ItemCompletionRequestRepository completionRequestRepository,
                           NotificationRepository notificationRepository,
                           JdbcTemplate jdbcTemplate) {
        this.itemRepository = itemRepository;
        this.itemImageRepository = itemImageRepository;
        this.matchRepository = matchRepository;
        this.completionRequestRepository = completionRequestRepository;
        this.notificationRepository = notificationRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    @Transactional
    public Item create(ItemCreateRequest request, Long userId) {
        Item item = new Item();
        item.setTitle(request.getTitle());
        item.setDescription(request.getDescription());
        item.setType(request.getType());
        item.setCategory(request.getCategory());
        item.setLocation(request.getLocation());
        item.setLocationId(request.getLocationId());
        item.setLostTime(request.getLostTime());
        item.setFoundTime(request.getFoundTime());
        item.setBrand(request.getBrand());
        item.setColor(request.getColor());
        item.setSerialNumber(normalizeSerialNumber(request.getSerialNumber()));
        item.setContactInfo(request.getContactInfo());
        item.setStatus(ItemConstants.Status.PENDING);
        item.setUserId(userId);
        item.setViewCount(0);
        item.setCreatedAt(LocalDateTime.now());
        item.setUpdatedAt(LocalDateTime.now());

        itemRepository.insert(item);
        saveImages(item.getId(), request.getImages());
        item.setImages(normalizeImageUrls(request.getImages()));
        return item;
    }

    @Override
    @Transactional
    public Item update(Long id, ItemCreateRequest request, Long userId) {
        Item item = getById(id);
        if (item == null) {
            throw new BusinessException("物品不存在");
        }

        if (!item.getUserId().equals(userId)) {
            throw new BusinessException("无权修改此物品");
        }
        if (!ItemConstants.Status.PENDING.equals(item.getStatus())) {
            throw new BusinessException("仅待审核物品允许修改");
        }

        item.setTitle(request.getTitle());
        item.setDescription(request.getDescription());
        item.setCategory(request.getCategory());
        item.setLocation(request.getLocation());
        item.setLocationId(request.getLocationId());
        item.setLostTime(request.getLostTime());
        item.setFoundTime(request.getFoundTime());
        item.setBrand(request.getBrand());
        item.setColor(request.getColor());
        item.setSerialNumber(normalizeSerialNumber(request.getSerialNumber()));
        item.setContactInfo(request.getContactInfo());
        item.setUpdatedAt(LocalDateTime.now());

        itemRepository.updateById(item);
        saveImages(item.getId(), request.getImages());
        item.setImages(normalizeImageUrls(request.getImages()));
        return item;
    }

    @Override
    @Transactional
    public void delete(Long id, Long userId) {
        Item item = getById(id);
        if (item == null) {
            throw new BusinessException("物品不存在");
        }

        if (!item.getUserId().equals(userId)) {
            throw new BusinessException("无权删除此物品");
        }
        if (!ItemConstants.Status.PENDING.equals(item.getStatus())) {
            throw new BusinessException("仅待审核物品允许删除");
        }

        itemRepository.deleteById(id);
    }

    @Override
    public Item getById(Long id) {
        Item item = itemRepository.selectById(id);
        if (item == null) {
            return null;
        }
        enrichItems(List.of(item));
        return item;
    }

    @Override
    public PageResponse<Item> query(ItemQueryRequest request) {
        Page<Item> page = new Page<>(request.getPage(), request.getPageSize());

        QueryWrapper<Item> wrapper = new QueryWrapper<>();

        if (request.getType() != null) {
            wrapper.eq("type", request.getType());
        }
        if (request.getCategory() != null) {
            wrapper.eq("category", request.getCategory());
        }
        if (request.getLocationId() != null) {
            wrapper.eq("location_id", request.getLocationId());
        }
        if (request.getUserId() != null) {
            wrapper.eq("user_id", request.getUserId());
        }
        if (request.getStatus() != null) {
            wrapper.eq("status", request.getStatus());
        }
        if (request.getStatuses() != null && !request.getStatuses().isEmpty()) {
            wrapper.in("status", request.getStatuses());
        }
        if (request.getKeyword() != null && !request.getKeyword().isBlank()) {
            wrapper.and(w -> w.like("title", request.getKeyword())
                    .or().like("description", request.getKeyword())
                    .or().like("brand", request.getKeyword())
                    .or().like("color", request.getKeyword())
                    .or().like("serial_number", request.getKeyword())
                    .or().like("location", request.getKeyword()));
        }
        if (request.getStartTime() != null) {
            wrapper.and(w -> w.ge("lost_time", request.getStartTime()).or().ge("found_time", request.getStartTime()));
        }
        if (request.getEndTime() != null) {
            wrapper.and(w -> w.le("lost_time", request.getEndTime()).or().le("found_time", request.getEndTime()));
        }

        wrapper.orderByDesc("created_at");

        IPage<Item> result = itemRepository.selectPage(page, wrapper);
        enrichItems(result.getRecords());

        return PageResponse.of(result.getRecords(), result.getTotal(), 
                (int) result.getCurrent(), (int) result.getSize());
    }

    @Override
    @Transactional
    public void incrementViewCount(Long id) {
        jdbcTemplate.update("UPDATE items SET view_count = COALESCE(view_count, 0) + 1 WHERE id = ?", id);
    }

    public List<Item> findByIds(List<Long> ids) {
        return itemRepository.selectBatchIds(ids);
    }

    public List<Item> list(QueryWrapper<Item> wrapper) {
        return itemRepository.selectList(wrapper);
    }

    public Item updateById(Item item) {
        itemRepository.updateById(item);
        return item;
    }

    public Map<Long, Item> findByIdsAsMap(List<Long> ids) {
        return findByIds(ids).stream()
                .collect(Collectors.toMap(Item::getId, Function.identity()));
    }

    private void saveImages(Long itemId, List<String> imageUrls) {
        LambdaQueryWrapper<ItemImage> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(ItemImage::getItemId, itemId);
        itemImageRepository.delete(deleteWrapper);

        List<String> normalized = normalizeImageUrls(imageUrls);
        for (int i = 0; i < normalized.size(); i++) {
            ItemImage image = new ItemImage();
            image.setItemId(itemId);
            image.setImageUrl(normalized.get(i));
            image.setImageType(i == 0 ? "MAIN" : "DETAIL");
            image.setSortOrder(i);
            itemImageRepository.insert(image);
        }
    }

    private List<String> normalizeImageUrls(List<String> imageUrls) {
        if (imageUrls == null) {
            return List.of();
        }
        return imageUrls.stream()
                .filter(url -> url != null && !url.isBlank())
                .distinct()
                .limit(6)
                .toList();
    }

    private String normalizeSerialNumber(String serialNumber) {
        if (serialNumber == null) {
            return null;
        }
        String trimmed = serialNumber.trim();
        return trimmed.isEmpty() ? null : trimmed.toUpperCase();
    }

    private void enrichItems(List<Item> items) {
        if (items == null || items.isEmpty()) {
            return;
        }

        List<Long> itemIds = items.stream().map(Item::getId).toList();

        LambdaQueryWrapper<ItemImage> imageWrapper = new LambdaQueryWrapper<>();
        imageWrapper.in(ItemImage::getItemId, itemIds).orderByAsc(ItemImage::getSortOrder);
        Map<Long, List<String>> imageMap = itemImageRepository.selectList(imageWrapper).stream()
                .collect(Collectors.groupingBy(
                        ItemImage::getItemId,
                        Collectors.mapping(ItemImage::getImageUrl, Collectors.toList())
                ));

        LambdaQueryWrapper<Match> matchWrapper = new LambdaQueryWrapper<>();
        matchWrapper.and(w -> w.in(Match::getLostItemId, itemIds).or().in(Match::getFoundItemId, itemIds));
        Map<Long, Boolean> matchedMap = new HashMap<>();
        for (Match match : matchRepository.selectList(matchWrapper)) {
            boolean highConfidence = match.getScore() != null
                    && match.getScore().compareTo(ItemConstants.HIGH_CONFIDENCE_MATCH_THRESHOLD) >= 0;
            if (!highConfidence) {
                continue;
            }
            matchedMap.put(match.getLostItemId(), true);
            matchedMap.put(match.getFoundItemId(), true);
        }

        LambdaQueryWrapper<ItemCompletionRequest> completionWrapper = new LambdaQueryWrapper<>();
        completionWrapper.in(ItemCompletionRequest::getItemId, itemIds)
                .eq(ItemCompletionRequest::getStatus, ItemConstants.CompletionStatus.PENDING)
                .orderByDesc(ItemCompletionRequest::getCreatedAt);
        Map<Long, ItemCompletionRequest> completionMap = new HashMap<>();
        for (ItemCompletionRequest request : completionRequestRepository.selectList(completionWrapper)) {
            completionMap.putIfAbsent(request.getItemId(), request);
        }

        LambdaQueryWrapper<Notification> notificationWrapper = new LambdaQueryWrapper<>();
        notificationWrapper.in(Notification::getRelatedId, itemIds)
                .eq(Notification::getType, ItemConstants.NotificationType.SYSTEM)
                .eq(Notification::getTitle, ItemConstants.NotificationTitle.POTENTIAL_DOCUMENT_OWNER);
        Map<Long, Boolean> potentialOwnerNotifiedMap = new HashMap<>();
        for (Notification notification : notificationRepository.selectList(notificationWrapper)) {
            potentialOwnerNotifiedMap.put(notification.getRelatedId(), true);
        }

        for (Item item : items) {
            item.setImages(new ArrayList<>(imageMap.getOrDefault(item.getId(), List.of())));
            item.setHighConfidenceMatched(Boolean.TRUE.equals(matchedMap.get(item.getId())));
            item.setPotentialOwnerNotified(Boolean.TRUE.equals(potentialOwnerNotifiedMap.get(item.getId())));
            ItemCompletionRequest request = completionMap.get(item.getId());
            if (request != null) {
                item.setPendingCompletionStatus(request.getStatus());
                item.setPendingCompletionTargetStatus(request.getTargetStatus());
            } else {
                item.setPendingCompletionStatus(null);
                item.setPendingCompletionTargetStatus(null);
            }
        }
    }
}
