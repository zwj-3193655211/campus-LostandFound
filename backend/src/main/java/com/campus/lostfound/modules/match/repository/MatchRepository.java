package com.campus.lostfound.modules.match.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.match.entity.Match;
import org.apache.ibatis.annotations.Mapper;

/**
 * 匹配记录Repository
 */
@Mapper
public interface MatchRepository extends BaseMapper<Match> {
}