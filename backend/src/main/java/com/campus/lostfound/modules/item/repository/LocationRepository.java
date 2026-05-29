package com.campus.lostfound.modules.item.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.item.entity.Location;
import org.apache.ibatis.annotations.Mapper;

/**
 * 位置Repository
 */
@Mapper
public interface LocationRepository extends BaseMapper<Location> {
}