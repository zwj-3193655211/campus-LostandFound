package com.campus.lostfound.modules.item.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.campus.lostfound.common.dto.request.ItemCreateRequest;
import com.campus.lostfound.common.dto.request.ItemQueryRequest;
import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.item.entity.Item;

import java.util.List;

/**
 * 失物服务接口
 */
public interface ItemService {

    /**
     * 创建失物
     */
    Item create(ItemCreateRequest request, Long userId);

    /**
     * 更新失物
     */
    Item update(Long id, ItemCreateRequest request, Long userId);

    /**
     * 删除失物
     */
    void delete(Long id, Long userId);

    /**
     * 获取失物详情
     */
    Item getById(Long id);

    /**
     * 分页查询失物
     */
    PageResponse<Item> query(ItemQueryRequest request);

    /**
     * 增加浏览次数
     */
    void incrementViewCount(Long id);

    /**
     * 列表查询
     */
    List<Item> list(QueryWrapper<Item> wrapper);

    /**
     * 更新物品
     */
    Item updateById(Item item);
}