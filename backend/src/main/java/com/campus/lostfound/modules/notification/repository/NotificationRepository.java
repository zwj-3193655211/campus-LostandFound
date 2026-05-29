package com.campus.lostfound.modules.notification.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.lostfound.modules.notification.entity.Notification;
import org.apache.ibatis.annotations.Mapper;

/**
 * 通知Repository
 */
@Mapper
public interface NotificationRepository extends BaseMapper<Notification> {
}