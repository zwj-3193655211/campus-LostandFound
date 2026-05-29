package com.campus.lostfound.modules.statistics.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.statistics.entity.DailyStatistics;
import org.apache.ibatis.annotations.Mapper;

/**
 * 统计Repository
 */
@Mapper
public interface DailyStatisticsRepository extends BaseMapper<DailyStatistics> {
}