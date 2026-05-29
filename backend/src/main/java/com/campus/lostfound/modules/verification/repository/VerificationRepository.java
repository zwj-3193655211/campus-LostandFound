package com.campus.lostfound.modules.verification.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.verification.entity.Verification;
import org.apache.ibatis.annotations.Mapper;

/**
 * 认领审核Repository
 */
@Mapper
public interface VerificationRepository extends BaseMapper<Verification> {
}