package com.campus.lostfound.modules.item.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.item.entity.Item;
import org.apache.ibatis.annotations.Mapper;

/**
 * 失物Repository
 */
@Mapper
public interface ItemRepository extends BaseMapper<Item> {
}