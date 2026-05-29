package com.campus.lostfound.modules.system.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.system.entity.UserIdentityVerification;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserIdentityVerificationRepository extends BaseMapper<UserIdentityVerification> {
}
