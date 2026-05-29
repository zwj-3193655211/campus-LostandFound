package com.campus.lostfound.modules.system.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.system.entity.User;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户Repository
 */
@Mapper
public interface UserRepository extends BaseMapper<User> {
}