package com.campus.lostfound.modules.notification.service;

import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.match.entity.Match;

/**
 * 邮件服务接口
 */
public interface MailService {

    /**
     * 发送匹配通知邮件
     * @param userEmail 收件人邮箱
     * @param userName 收件人用户名
     * @param item 用户发布的物品     * @param matchedItem 匹配到的物品
     * @param match 匹配记录
     */
    void sendMatchNotificationEmail(
            String userEmail,
            String userName,
            Item item,
            Item matchedItem,
            Match match
    );

    /**
     * 发送审核结果通知邮件
     * @param userEmail 收件人邮箱
     * @param userName 收件人用户名
     * @param item 物品信息
     * @param approved 是否通过
     * @param reason 原因（如果未通过）
     */
    void sendVerificationEmail(
            String userEmail,
            String userName,
            Item item,
            boolean approved,
            String reason
    );

    /**
     * 发送测试邮件（用于验证配置）
     * @param userEmail 收件人邮箱
     * @return 是否发送成功
     */
    boolean sendTestEmail(String userEmail);

    /**
     * 发送简单邮件通知
     */
    void sendSimpleEmail(String userEmail, String subject, String content);
}
