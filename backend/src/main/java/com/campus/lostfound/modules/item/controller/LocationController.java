package com.campus.lostfound.modules.item.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.lostfound.common.result.ApiResponse;
import com.campus.lostfound.modules.common.service.RedisCacheService;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.Location;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.item.repository.LocationRepository;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 位置控制器
 */
@RestController
@RequestMapping("/api/locations")
public class LocationController {

    private final LocationRepository locationRepository;
    private final ItemRepository itemRepository;
    private final RedisCacheService cacheService;

    public LocationController(LocationRepository locationRepository,
                               ItemRepository itemRepository,
                               RedisCacheService cacheService) {
        this.locationRepository = locationRepository;
        this.itemRepository = itemRepository;
        this.cacheService = cacheService;
    }

    /**
     * 获取所有位置（带缓存）
     */
    @GetMapping
    public ApiResponse<List<Location>> list() {
        @SuppressWarnings("unchecked")
        List<Location> cached = (List<Location>) cacheService.get(RedisCacheService.PREFIX_LOCATION + "all");
        if (cached != null) {
            return ApiResponse.success(cached);
        }

        List<Location> locations = locationRepository.selectList(null);
        cacheService.set(RedisCacheService.PREFIX_LOCATION + "all", locations, Duration.ofHours(RedisCacheService.LONG_TTL));
        return ApiResponse.success(locations);
    }

    /**
     * 获取位置详情
     */
    @GetMapping("/{id}")
    public ApiResponse<Location> getById(@PathVariable Long id) {
        return ApiResponse.success(locationRepository.selectById(id));
    }

    /**
     * 创建位置
     */
    @PostMapping
    public ApiResponse<Location> create(@RequestBody Location location) {
        location.setId(null);
        location.setCreatedAt(LocalDateTime.now());
        location.setUpdatedAt(LocalDateTime.now());
        locationRepository.insert(location);
        // 清除地点缓存
        cacheService.clearLocationCache();
        return ApiResponse.success("创建成功", location);
    }

    /**
     * 更新位置
     */
    @PutMapping("/{id}")
    public ApiResponse<Location> update(@PathVariable Long id, @RequestBody Location request) {
        Location location = locationRepository.selectById(id);
        if (location == null) {
            return ApiResponse.error(404, "位置不存在");
        }

        location.setName(request.getName());
        location.setBuilding(request.getBuilding());
        location.setFloor(request.getFloor());
        location.setDescription(request.getDescription());
        location.setUpdatedAt(LocalDateTime.now());
        locationRepository.updateById(location);
        return ApiResponse.success("更新成功", location);
    }

    /**
     * 删除位置
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        LambdaQueryWrapper<Item> itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(Item::getLocationId, id).eq(Item::getDeleted, 0);
        if (itemRepository.selectCount(itemWrapper) > 0) {
            return ApiResponse.error(400, "该位置仍有关联物品，不能删除");
        }

        locationRepository.deleteById(id);
        // 清除地点缓存
        cacheService.clearLocationCache();
        return ApiResponse.success("删除成功", null);
    }
}
