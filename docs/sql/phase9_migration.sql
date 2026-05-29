-- 第九轮显式迁移脚本
-- 用途：将旧版库结构升级到“高分匹配标签 + 完成申请审核流 + 新通知类型”版本
-- 说明：请在目标数据库已存在的前提下执行，例如：
-- mysql -u root -p campus_lostfound < docs/sql/phase9_migration.sql

-- 1. 先把旧状态 CLAIMED 迁移为 APPROVED，避免后续缩减枚举时报错
UPDATE `items`
SET `status` = 'APPROVED'
WHERE `status` = 'CLAIMED';

-- 2. 调整 items.status 枚举
ALTER TABLE `items`
MODIFY COLUMN `status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'FOUND_BACK', 'RETURNED', 'EXPIRED', 'CLOSED')
NOT NULL DEFAULT 'PENDING'
COMMENT '状态: PENDING待审核, APPROVED已发布, REJECTED审核未通过, FOUND_BACK寻物已找到, RETURNED招领已归还, EXPIRED已过期, CLOSED已关闭';

-- 3. 调整 notifications.type 枚举
ALTER TABLE `notifications`
MODIFY COLUMN `type` ENUM('MATCH_FOUND', 'VERIFICATION_RESULT', 'CLAIM_REVIEW_RESULT', 'COMPLETION_REVIEW_RESULT', 'SYSTEM')
NOT NULL
COMMENT '通知类型';

-- 4. 创建完成状态申请表
CREATE TABLE IF NOT EXISTS `item_completion_requests` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '申请ID',
    `item_id` BIGINT NOT NULL COMMENT '物品ID',
    `user_id` BIGINT NOT NULL COMMENT '申请人ID',
    `target_status` ENUM('FOUND_BACK', 'RETURNED') NOT NULL COMMENT '目标状态',
    `reason` VARCHAR(255) COMMENT '申请说明',
    `status` ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'PENDING' COMMENT '申请状态',
    `review_reason` VARCHAR(255) COMMENT '审核说明',
    `reviewed_by` BIGINT COMMENT '审核人ID',
    `reviewed_at` DATETIME COMMENT '审核时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_item_id` (`item_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`),
    CONSTRAINT `fk_item_completion_requests_item` FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_item_completion_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_item_completion_requests_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='物品完成状态申请表';

-- 5. 为旧库补齐通知开关列
SET @schema_name = DATABASE();

SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'users'
              AND COLUMN_NAME = 'notification_in_app'
        ),
        'SELECT 1',
        'ALTER TABLE `users` ADD COLUMN `notification_in_app` INT DEFAULT 1 COMMENT ''站内通知'''
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 7. 为旧库补齐实名认证状态字段
SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'users'
              AND COLUMN_NAME = 'identity_status'
        ),
        'SELECT 1',
        'ALTER TABLE `users` ADD COLUMN `identity_status` ENUM(''UNVERIFIED'',''PENDING'',''VERIFIED'',''REJECTED'') NOT NULL DEFAULT ''UNVERIFIED'' COMMENT ''实名认证状态'''
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'users'
              AND COLUMN_NAME = 'identity_verified_at'
        ),
        'SELECT 1',
        'ALTER TABLE `users` ADD COLUMN `identity_verified_at` DATETIME DEFAULT NULL COMMENT ''实名认证通过时间'''
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `users`
SET `identity_status` = CASE
    WHEN `id_card` IS NOT NULL AND `id_card` <> '' THEN 'VERIFIED'
    ELSE 'UNVERIFIED'
END
WHERE `identity_status` IS NULL OR `identity_status` = '';

-- 8. 创建实名认证申请表
CREATE TABLE IF NOT EXISTS `user_identity_verifications` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '申请ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `real_name` VARCHAR(50) NOT NULL COMMENT '申请姓名',
    `id_card` VARCHAR(18) NOT NULL COMMENT '申请身份证号',
    `status` ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING' COMMENT '审核状态',
    `review_reason` VARCHAR(255) COMMENT '审核原因',
    `reviewed_by` BIGINT COMMENT '审核人ID',
    `reviewed_at` DATETIME COMMENT '审核时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`),
    CONSTRAINT `fk_user_identity_verifications_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_user_identity_verifications_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实名认证申请记录表';

SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'users'
              AND COLUMN_NAME = 'notification_email'
        ),
        'SELECT 1',
        'ALTER TABLE `users` ADD COLUMN `notification_email` INT DEFAULT 1 COMMENT ''邮件通知'''
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'users'
              AND COLUMN_NAME = 'notification_match'
        ),
        'SELECT 1',
        'ALTER TABLE `users` ADD COLUMN `notification_match` INT DEFAULT 1 COMMENT ''匹配提醒'''
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'users'
              AND COLUMN_NAME = 'notification_verification'
        ),
        'SELECT 1',
        'ALTER TABLE `users` ADD COLUMN `notification_verification` INT DEFAULT 1 COMMENT ''审核提醒'''
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6. 为旧库补齐 items.location 字段
SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'items'
              AND COLUMN_NAME = 'location'
        ),
        'SELECT 1',
        'ALTER TABLE `items` ADD COLUMN `location` VARCHAR(100) DEFAULT NULL COMMENT ''详细位置'''
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
