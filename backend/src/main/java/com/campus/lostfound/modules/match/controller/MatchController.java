package com.campus.lostfound.modules.match.controller;

import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.match.service.MatchingService;
import com.campus.lostfound.modules.system.entity.User;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * 匹配控制器
 */
@RestController
@RequestMapping("/api/matches")
public class MatchController {

    private final MatchingService matchingService;
    private final ItemRepository itemRepository;

    public MatchController(MatchingService matchingService, ItemRepository itemRepository) {
        this.matchingService = matchingService;
        this.itemRepository = itemRepository;
    }

    /**
     * 获取匹配列表（需要itemId参数）
     */
    @GetMapping
    public ApiResponse<PageResponse<Match>> list(
            @RequestParam(name = "itemId", required = false) Long itemId,
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "pageSize", defaultValue = "10") int pageSize,
            @AuthenticationPrincipal User user) {
        if (itemId == null) {
            // 所有用户（包括管理员）都只能看到自己相关的匹配
            return ApiResponse.success(matchingService.getUserMatches(user.getId(), page, pageSize));
        }

        // 验证用户是否有权查看该物品的匹配
        Item item = itemRepository.selectById(itemId);
        if (item == null || !user.getId().equals(item.getUserId())) {
            return ApiResponse.error(403, "无权查看该物品的匹配记录");
        }

        return ApiResponse.success(matchingService.getMatches(itemId, page, pageSize));
    }

    /**
     * 获取最近的匹配列表（无需itemId）
     */
    @GetMapping("/recent")
    public ApiResponse<PageResponse<Match>> recentList(
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "pageSize", defaultValue = "10") int pageSize,
            @AuthenticationPrincipal User user) {
        // 所有用户（包括管理员）都只能看到自己相关的匹配
        return ApiResponse.success(matchingService.getUserMatches(user.getId(), page, pageSize));
    }

    /**
     * 确认匹配
     */
    @PutMapping("/{id}/confirm")
    public ApiResponse<Void> confirm(@PathVariable Long id, @AuthenticationPrincipal User user) {
        matchingService.confirmMatch(id, user.getId());
        return ApiResponse.success("确认成功", null);
    }

    /**
     * 拒绝匹配（待确认状态）
     */
    @PutMapping("/{id}/reject")
    public ApiResponse<Void> reject(@PathVariable Long id,
                                   @RequestParam String reason,
                                   @AuthenticationPrincipal User user) {
        matchingService.rejectMatch(id, user.getId(), reason);
        return ApiResponse.success("已拒绝", null);
    }

    /**
     * 取消匹配（已确认状态，恢复物品可被其他匹配）
     */
    @PutMapping("/{id}/cancel")
    public ApiResponse<Void> cancel(@PathVariable Long id,
                                   @AuthenticationPrincipal User user) {
        matchingService.cancelMatch(id, user.getId());
        return ApiResponse.success("匹配已取消，物品已恢复可匹配状态", null);
    }

    /**
     * 触发匹配（调试用）
     */
    @PostMapping("/trigger")
    public ApiResponse<Void> trigger(@RequestParam Long itemId) {
        matchingService.match(itemId);
        return ApiResponse.success("匹配完成", null);
    }

    /**
     * 批量匹配（管理员）
     */
    @PostMapping("/batch")
    public ApiResponse<Void> batchMatch() {
        matchingService.matchAll();
        return ApiResponse.success("批量匹配完成", null);
    }

    /**
     * 测试端点 - 无需认证
     */
    @GetMapping("/test")
    public ApiResponse<String> test() {
        return ApiResponse.success("系统正常运行", "OK");
    }

    private boolean isAdmin(User user) {
        return user != null && ("SUPER_ADMIN".equals(user.getRole()) || "CAMPUS_ADMIN".equals(user.getRole()));
    }
}
