package com.campus.lostfound.modules.match.service;

import com.campus.lostfound.common.result.PageResponse;
import com.campus.lostfound.modules.match.entity.Match;

import java.util.List;

/**
 * 匹配服务接口
 */
public interface MatchingService {

    /**
     * 执行匹配 - 当新物品发布时触发
     */
    void match(Long itemId);

    /**
     * 批量匹配所有待匹配的物品
     */
    void matchAll();

    /**
     * 获取匹配列表
     */
    PageResponse<Match> getMatches(Long itemId, int page, int pageSize);

    /**
     * 获取所有匹配列表（不分item）
     */
    PageResponse<Match> getAllMatches(int page, int pageSize);

    /**
     * 获取用户可见的匹配列表
     */
    PageResponse<Match> getUserMatches(Long userId, int page, int pageSize);

    /**
     * 确认匹配
     */
    void confirmMatch(Long matchId, Long userId);

    /**
     * 拒绝匹配
     */
    void rejectMatch(Long matchId, Long userId, String reason);

    /**
     * 获取我的匹配通知
     */
    List<Match> getMyMatchNotifications(Long userId);
}
