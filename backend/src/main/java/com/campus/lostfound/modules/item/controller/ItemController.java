package com.campus.lostfound.modules.item.controller;

import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.common.dto.request.ItemCompletionRequestCreateRequest;
import com.campus.lostfound.common.dto.request.ItemCreateRequest;
import com.campus.lostfound.common.dto.request.ItemQueryRequest;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.common.util.DataMaskUtils;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.ItemCompletionRequest;
import com.campus.lostfound.modules.item.service.ItemCompletionRequestService;
import com.campus.lostfound.modules.item.service.ItemService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.verification.entity.Verification;
import com.campus.lostfound.modules.verification.service.VerificationService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 失物控制器
 */
@RestController
@RequestMapping("/api/items")
public class ItemController {

    private static final Logger log = LoggerFactory.getLogger(ItemController.class);

    private final ItemService itemService;
    private final VerificationService verificationService;
    private final ItemCompletionRequestService completionRequestService;

    public ItemController(ItemService itemService,
                          VerificationService verificationService,
                          ItemCompletionRequestService completionRequestService) {
        this.itemService = itemService;
        this.verificationService = verificationService;
        this.completionRequestService = completionRequestService;
    }

    /**
     * 创建失物
     */
    @PostMapping
    public ApiResponse<Item> create(@Valid @RequestBody ItemCreateRequest request,
                                    @AuthenticationPrincipal User user) {
        return ApiResponse.success(itemService.create(request, user.getId()));
    }

    /**
     * 更新失物
     */
    @PutMapping("/{id}")
    public ApiResponse<Item> update(@PathVariable Long id,
                                    @Valid @RequestBody ItemCreateRequest request,
                                    @AuthenticationPrincipal User user) {
        return ApiResponse.success(itemService.update(id, request, user.getId()));
    }

    /**
     * 删除失物
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id,
                                   @AuthenticationPrincipal User user) {
        itemService.delete(id, user.getId());
        return ApiResponse.success("删除成功", null);
    }

    /**
     * 获取失物详情
     */
    @GetMapping("/{id}")
    public ApiResponse<Item> getById(@PathVariable Long id,
                                     @AuthenticationPrincipal User user) {
        try {
            itemService.incrementViewCount(id);
        } catch (Exception e) {
            log.warn("Failed to increment view count for itemId={}", id, e);
        }
        Item item = itemService.getById(id);
        if (item == null) {
            return ApiResponse.error("物品不存在");
        }
        boolean canViewSensitive = canViewSensitive(item, user);
        if (!canViewSensitive && !isPublicStatus(item.getStatus())) {
            return ApiResponse.error("物品不存在或未公开");
        }
        return ApiResponse.success(toPublicItem(item, user));
    }

    /**
     * 分页查询失物
     */
    @GetMapping
    public ApiResponse<PageResponse<Item>> query(ItemQueryRequest request,
                                                 @AuthenticationPrincipal User user) {
        if (!isAdmin(user)) {
            List<String> publicStatuses = List.of(
                    ItemConstants.Status.APPROVED,
                    ItemConstants.Status.FOUND_BACK,
                    ItemConstants.Status.RETURNED
            );
            if (request.getStatus() != null && !publicStatuses.contains(request.getStatus())) {
                return ApiResponse.success(PageResponse.of(List.of(), 0, request.getPage(), request.getPageSize()));
            }
            if (request.getStatus() == null && (request.getStatuses() == null || request.getStatuses().isEmpty())) {
                request.setStatuses(publicStatuses);
            }
        }
        PageResponse<Item> page = itemService.query(request);
        return ApiResponse.success(PageResponse.of(toPublicItems(page.getRecords(), user), page.getTotal(), page.getCurrent(), page.getPageSize()));
    }

    /**
     * 获取我的失物列表
     */
    @GetMapping("/my")
    public ApiResponse<PageResponse<Item>> getMyItems(@AuthenticationPrincipal User user,
                                                  @RequestParam(value = "page", defaultValue = "1") Integer page,
                                                  @RequestParam(value = "pageSize", defaultValue = "10") Integer pageSize) {
        ItemQueryRequest queryRequest = new ItemQueryRequest();
        queryRequest.setPage(page);
        queryRequest.setPageSize(pageSize);
        queryRequest.setUserId(user.getId());
        return ApiResponse.success(itemService.query(queryRequest));
    }

    @PostMapping("/{id}/claim")
    public ApiResponse<Verification> claim(@PathVariable Long id,
                                           @RequestParam(value = "proof", required = false) String proof,
                                           @AuthenticationPrincipal User user) {
        return ApiResponse.success(verificationService.claim(id, user.getId(), proof));
    }

    @PostMapping("/{id}/completion-request")
    public ApiResponse<ItemCompletionRequest> submitCompletionRequest(@PathVariable Long id,
                                                                      @Valid @RequestBody ItemCompletionRequestCreateRequest request,
                                                                      @AuthenticationPrincipal User user) {
        return ApiResponse.success(completionRequestService.submit(id, user.getId(), request.getTargetStatus(), request.getReason()));
    }

    private List<Item> toPublicItems(List<Item> items, User currentUser) {
        return items.stream().map(item -> toPublicItem(item, currentUser)).toList();
    }

    private Item toPublicItem(Item item, User currentUser) {
        if (item == null) {
            return null;
        }

        boolean canViewSensitive = canViewSensitive(item, currentUser);

        if (canViewSensitive) {
            return item;
        }

        Item view = new Item();
        view.setId(item.getId());
        view.setUserId(item.getUserId());
        view.setType(item.getType());
        view.setCategory(item.getCategory());
        view.setTitle(item.getTitle());
        view.setDescription(item.getDescription());
        view.setBrand(item.getBrand());
        view.setColor(item.getColor());
        view.setLocation(item.getLocation());
        view.setLocationId(item.getLocationId());
        view.setLostTime(item.getLostTime());
        view.setFoundTime(item.getFoundTime());
        view.setSerialNumber(DataMaskUtils.maskSerialNumber(item.getSerialNumber()));
        view.setContactInfo(DataMaskUtils.maskContact(item.getContactInfo()));
        view.setStatus(item.getStatus());
        view.setImages(item.getImages());
        view.setHighConfidenceMatched(item.getHighConfidenceMatched());
        view.setPendingCompletionStatus(item.getPendingCompletionStatus());
        view.setPendingCompletionTargetStatus(item.getPendingCompletionTargetStatus());
        view.setPotentialOwnerNotified(item.getPotentialOwnerNotified());
        view.setViewCount(item.getViewCount());
        view.setCreatedAt(item.getCreatedAt());
        view.setUpdatedAt(item.getUpdatedAt());
        return view;
    }

    private boolean canViewSensitive(Item item, User currentUser) {
        return currentUser != null
                && (currentUser.getId().equals(item.getUserId())
                || "SUPER_ADMIN".equals(currentUser.getRole())
                || "CAMPUS_ADMIN".equals(currentUser.getRole()));
    }

    private boolean isAdmin(User currentUser) {
        return currentUser != null
                && ("SUPER_ADMIN".equals(currentUser.getRole()) || "CAMPUS_ADMIN".equals(currentUser.getRole()));
    }

    private boolean isPublicStatus(String status) {
        return ItemConstants.Status.APPROVED.equals(status)
                || ItemConstants.Status.FOUND_BACK.equals(status)
                || ItemConstants.Status.RETURNED.equals(status);
    }
}
