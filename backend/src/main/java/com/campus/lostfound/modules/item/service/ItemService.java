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

    /**
     * 管理员审核物品。
     * 通过:状态置为 APPROVED,触发匹配,并向发布者发通知;
     * 拒绝:状态置为 REJECTED,带原因通知发布者。
     * 走"按 id + status=PENDING 条件原子更新"避免并发审核竞态。
     *
     * @return 审核后的物品
     */
    Item review(Long itemId, Long adminId, boolean approved, String reason);

    /**
     * 获取待审核物品列表(管理员用,按创建时间倒序)。
     */
    java.util.List<Item> listPending();

    /**
     * 按状态分页查物品(管理员仪表盘/审核中心用)。
     */
    com.campus.lostfound.common.result.PageResponse<Item> adminListByStatus(
            String status, int page, int pageSize);
}