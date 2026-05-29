package com.campus.lostfound.modules.item.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.item.entity.ItemImage;
import org.apache.ibatis.annotations.Mapper;

/**
 * 物品图片Repository
 */
@Mapper
public interface ItemImageRepository extends BaseMapper<ItemImage> {
}