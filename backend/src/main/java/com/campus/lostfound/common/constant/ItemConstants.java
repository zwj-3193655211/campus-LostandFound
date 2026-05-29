package com.campus.lostfound.common.constant;

import java.math.BigDecimal;

/**
 * 物品常量
 */
public class ItemConstants {

    public static final BigDecimal HIGH_CONFIDENCE_MATCH_THRESHOLD = new BigDecimal("0.80");

    /**
     * 物品类型
     */
    public static class Type {
        public static final String LOST = "LOST";    // 寻物启示
        public static final String FOUND = "FOUND";  // 失物招领
    }

    /**
     * 物品状态
     */
    public static class Status {
        public static final String PENDING = "PENDING";  // 待审核
        public static final String APPROVED = "APPROVED";  // 已审核
        public static final String REJECTED = "REJECTED"; // 审核未通过
        public static final String FOUND_BACK = "FOUND_BACK"; // 寻物已找到
        public static final String RETURNED = "RETURNED"; // 招领已归还
        public static final String EXPIRED = "EXPIRED"; // 已过期
        public static final String CLOSED = "CLOSED";  // 已关闭
    }

    /**
     * 完成申请状态
     */
    public static class CompletionStatus {
        public static final String PENDING = "PENDING";
        public static final String APPROVED = "APPROVED";
        public static final String REJECTED = "REJECTED";
    }

    /**
     * 通知类型
     */
    public static class NotificationType {
        public static final String MATCH_FOUND = "MATCH_FOUND";
        public static final String VERIFICATION_RESULT = "VERIFICATION_RESULT";
        public static final String CLAIM_REVIEW_RESULT = "CLAIM_REVIEW_RESULT";
        public static final String COMPLETION_REVIEW_RESULT = "COMPLETION_REVIEW_RESULT";
        public static final String SYSTEM = "SYSTEM";
    }

    public static class NotificationTitle {
        public static final String POTENTIAL_DOCUMENT_OWNER = "发现疑似证件失主";
    }

    /**
     * 物品类别
     */
    public static class Category {
        public static final String ELECTRONICS = "电子产品";
        public static final String DOCUMENTS = "证件";
        public static final String BOOKS = "书籍";
        public static final String CLOTHES = "衣物";
        public static final String ACCESSORIES = "饰品";
        public static final String KEYS = "钥匙";
        public static final String WALLETS = "钱包";
        public static final String PHONES = "手机";
        public static final String LAPTOPS = "笔记本";
        public static final String OTHER = "其他";
    }
}
