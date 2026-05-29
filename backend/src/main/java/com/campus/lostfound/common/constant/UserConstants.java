package com.campus.lostfound.common.constant;

/**
 * 用户角色常量
 */
public class UserConstants {

    /**
     * 系统管理员 - 最高权限
     */
    public static final String ROLE_SUPER_ADMIN = "SUPER_ADMIN";

    /**
     * 校园管理员 - 管理本校
     */
    public static final String ROLE_CAMPUS_ADMIN = "CAMPUS_ADMIN";

    /**
     * 普通用�?     */
    public static final String ROLE_USER = "USER";

    /**
     * 实名认证状态
     */
    public static class IdentityStatus {
        public static final String UNVERIFIED = "UNVERIFIED";
        public static final String PENDING = "PENDING";
        public static final String VERIFIED = "VERIFIED";
        public static final String REJECTED = "REJECTED";
    }

    private UserConstants() {}
}
