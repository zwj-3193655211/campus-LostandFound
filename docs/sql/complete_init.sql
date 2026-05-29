-- =====================================================
-- 校园失物招领智能匹配平台 - 完整数据库初始化脚本
-- 版本: 1.0.0
-- 日期: 2026-05-26
-- =====================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS campus_lostfound CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campus_lostfound;

-- =====================================================
-- 1. 用户表
-- =====================================================
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '加密后的密码',
    `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
    `student_id` VARCHAR(20) COMMENT '学号/工号',
    `phone` VARCHAR(20) COMMENT '手机号',
    `real_name` VARCHAR(50) COMMENT '真实姓名(实名认证)',
    `id_card` VARCHAR(18) UNIQUE COMMENT '身份证号(实名认证)',
    `identity_status` ENUM('UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'UNVERIFIED' COMMENT '实名认证状态',
    `identity_verified_at` DATETIME COMMENT '实名认证通过时间',
    `role` ENUM('SUPER_ADMIN', 'CAMPUS_ADMIN', 'USER') NOT NULL DEFAULT 'USER' COMMENT '角色: SUPER_ADMIN-超级管理员, CAMPUS_ADMIN-校园管理员, USER-普通用户',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0禁用 1正常',
    `notification_in_app` TINYINT NOT NULL DEFAULT 1 COMMENT '站内通知: 0关闭 1开启',
    `notification_email` TINYINT NOT NULL DEFAULT 1 COMMENT '邮件通知: 0关闭 1开启',
    `notification_match` TINYINT NOT NULL DEFAULT 1 COMMENT '匹配提醒: 0关闭 1开启',
    `notification_verification` TINYINT NOT NULL DEFAULT 1 COMMENT '审核提醒: 0关闭 1开启',
    `last_login_time` DATETIME COMMENT '最后登录时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0未删 1已删',
    INDEX `idx_username` (`username`),
    INDEX `idx_email` (`email`),
    INDEX `idx_student_id` (`student_id`),
    INDEX `idx_identity_status` (`identity_status`),
    INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

DROP TABLE IF EXISTS `user_identity_verifications`;
CREATE TABLE `user_identity_verifications` (
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

-- =====================================================
-- 2. 位置区域表
-- =====================================================
DROP TABLE IF EXISTS `locations`;
CREATE TABLE `locations` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '位置ID',
    `name` VARCHAR(100) NOT NULL COMMENT '位置名称(如:A教学楼)',
    `building` VARCHAR(50) COMMENT '所属建筑',
    `floor` INT COMMENT '楼层',
    `description` VARCHAR(255) COMMENT '位置描述',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    INDEX `idx_name` (`name`),
    INDEX `idx_building` (`building`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='位置区域表';

-- =====================================================
-- 3. 失物招领表(统一LOST/FOUND类型)
-- =====================================================
DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物品ID',
    `user_id` BIGINT NOT NULL COMMENT '发布者ID',
    `type` ENUM('LOST', 'FOUND') NOT NULL COMMENT '类型: LOST寻物/FOUND招领',
    `category` VARCHAR(50) NOT NULL COMMENT '物品类别(如:电子产品/证件/书籍等)',
    `title` VARCHAR(100) NOT NULL COMMENT '标题',
    `description` TEXT COMMENT '详细描述',
    `brand` VARCHAR(50) COMMENT '品牌/型号',
    `color` VARCHAR(20) COMMENT '颜色',
    `location_id` BIGINT COMMENT '丢失/拾取地点',
    `location` VARCHAR(100) COMMENT '详细位置文本',
    `lost_time` DATETIME COMMENT '丢失时间',
    `found_time` DATETIME COMMENT '拾取时间',
    `serial_number` VARCHAR(50) COMMENT '序列号/证件号(用于精确匹配)',
    `contact_info` VARCHAR(100) COMMENT '联系方式',
    `status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'FOUND_BACK', 'RETURNED', 'EXPIRED', 'CLOSED') NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING待审核, APPROVED已发布, REJECTED审核未通过, FOUND_BACK寻物已找到, RETURNED招领已归还, EXPIRED已过期, CLOSED已关闭',
    `view_count` INT NOT NULL DEFAULT 0 COMMENT '浏览次数',
    `match_score` DECIMAL(5,2) COMMENT '最高匹配分数',
    `match_item_id` BIGINT COMMENT '匹配成功的物品ID',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_category` (`category`),
    INDEX `idx_status` (`status`),
    INDEX `idx_location_id` (`location_id`),
    INDEX `idx_serial_number` (`serial_number`),
    INDEX `idx_created_at` (`created_at`),
    INDEX `idx_type_status` (`type`, `status`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`location_id`) REFERENCES `locations`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='失物招领表';

-- =====================================================
-- 4. 物品图片表
-- =====================================================
DROP TABLE IF EXISTS `item_images`;
CREATE TABLE `item_images` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '图片ID',
    `item_id` BIGINT NOT NULL COMMENT '物品ID',
    `image_url` VARCHAR(255) NOT NULL COMMENT '图片URL',
    `image_type` ENUM('MAIN', 'DETAIL') NOT NULL DEFAULT 'DETAIL' COMMENT '图片类型: MAIN主图, DETAIL详情图',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_item_id` (`item_id`),
    FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='物品图片表';

-- =====================================================
-- 5. 智能匹配记录表
-- =====================================================
DROP TABLE IF EXISTS `matches`;
CREATE TABLE `matches` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '匹配ID',
    `lost_item_id` BIGINT NOT NULL COMMENT '寻物启示ID',
    `found_item_id` BIGINT NOT NULL COMMENT '失物招领ID',
    `score` DECIMAL(5,2) NOT NULL COMMENT '匹配分数',
    `match_type` ENUM('SERIAL_EXACT', 'WEIGHTED', 'NONE') NOT NULL COMMENT '匹配类型: SERIAL_EXACT串号精确匹配, WEIGHTED加权相似度匹配, NONE无匹配',
    `status` ENUM('PENDING', 'CONFIRMED', 'REJECTED') NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING待确认, CONFIRMED已确认, REJECTED已拒绝',
    `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读: 0未读 1已读',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_lost_item_id` (`lost_item_id`),
    INDEX `idx_found_item_id` (`found_item_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_score` (`score`),
    INDEX `idx_created_at` (`created_at`),
    UNIQUE KEY `uk_item_pair` (`lost_item_id`, `found_item_id`),
    FOREIGN KEY (`lost_item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`found_item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='智能匹配记录表';

-- =====================================================
-- 6. 认领审核表
-- =====================================================
DROP TABLE IF EXISTS `verifications`;
CREATE TABLE `verifications` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '审核ID',
    `item_id` BIGINT NOT NULL COMMENT '物品ID',
    `claimant_id` BIGINT NOT NULL COMMENT '认领人ID',
    `claim_proof` TEXT NOT NULL COMMENT '认领证明',
    `status` ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING待审核, APPROVED已通过, REJECTED已拒绝',
    `reject_reason` VARCHAR(255) COMMENT '拒绝原因',
    `reviewed_by` BIGINT COMMENT '审核人ID',
    `reviewed_at` DATETIME COMMENT '审核时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_item_id` (`item_id`),
    INDEX `idx_claimant_id` (`claimant_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_reviewed_by` (`reviewed_by`),
    FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`claimant_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='认领审核表';

-- =====================================================
-- 7. 完成状态申请表
-- =====================================================
DROP TABLE IF EXISTS `item_completion_requests`;
CREATE TABLE `item_completion_requests` (
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
    FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='物品完成状态申请表';

-- =====================================================
-- 8. 通知表
-- =====================================================
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '通知ID',
    `user_id` BIGINT NOT NULL COMMENT '接收用户ID',
    `type` ENUM('MATCH_FOUND', 'VERIFICATION_RESULT', 'CLAIM_REVIEW_RESULT', 'COMPLETION_REVIEW_RESULT', 'SYSTEM') NOT NULL COMMENT '通知类型',
    `title` VARCHAR(100) NOT NULL COMMENT '标题',
    `content` TEXT NOT NULL COMMENT '内容',
    `related_id` BIGINT COMMENT '关联ID(如:match_id)',
    `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读: 0未读 1已读',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_is_read` (`is_read`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created_at` (`created_at`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';

-- =====================================================
-- 9. 每日统计表
-- =====================================================
DROP TABLE IF EXISTS `daily_statistics`;
CREATE TABLE `daily_statistics` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '统计ID',
    `stat_date` DATE NOT NULL UNIQUE COMMENT '统计日期',
    `lost_count` INT NOT NULL DEFAULT 0 COMMENT '新增寻物启示数',
    `found_count` INT NOT NULL DEFAULT 0 COMMENT '新增失物招领数',
    `match_count` INT NOT NULL DEFAULT 0 COMMENT '匹配成功数',
    `claim_count` INT NOT NULL DEFAULT 0 COMMENT '认领成功数',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='每日统计表';

-- =====================================================
-- 初始化测试数据
-- =====================================================

-- 插入测试位置
INSERT INTO `locations` (`name`, `building`, `floor`, `description`) VALUES
('A教学楼一层大厅', 'A教学楼', 1, '主要入口和休息区'),
('A教学楼三层301教室', 'A教学楼', 3, '301教室门口'),
('图书馆一楼自习室', '图书馆', 1, '自习区入口'),
('图书馆二楼阅览室', '图书馆', 2, '期刊阅览室'),
('食堂一楼入口', '食堂', 1, '食堂正门'),
('食堂二楼餐厅', '食堂', 2, '快餐区'),
('操场看台下方', '操场', 0, '体育器材室'),
('学生宿舍5号楼', '学生宿舍', 1, '宿舍楼大厅'),
('实验楼A座一层', '实验楼A座', 1, '实验室走廊'),
('行政楼一楼服务大厅', '行政楼', 1, '办事大厅');

-- 插入测试用户 (密码都是: 123456)
-- BCrypt hash for "123456": $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq
INSERT INTO `users` (`username`, `password`, `email`, `student_id`, `phone`, `real_name`, `id_card`, `identity_status`, `role`, `status`) VALUES
('superadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq', 'superadmin@campus.edu', '2024001', '13800000001', '王管理员', '110101199001010001', 'VERIFIED', 'SUPER_ADMIN', 1),
('campusadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq', 'campusadmin@campus.edu', '2024002', '13800000002', '张老师', '110101199001010002', 'VERIFIED', 'CAMPUS_ADMIN', 1),
('testuser', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq', 'testuser@campus.edu', '2024003', '13800000003', '赵同学', '110101200401010003', 'VERIFIED', 'USER', 1),
('zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq', 'zhangsan@campus.edu', '2024004', '13800000004', '张三', '110101200401010004', 'VERIFIED', 'USER', 1),
('lisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq', 'lisi@campus.edu', '2024005', '13800000005', '李四', '110101200401010005', 'VERIFIED', 'USER', 1);

-- 插入测试寻物启示
INSERT INTO `items` (`user_id`, `type`, `category`, `title`, `description`, `brand`, `color`, `location_id`, `lost_time`, `serial_number`, `contact_info`, `status`, `created_at`) VALUES
(
    (SELECT id FROM users WHERE username = 'zhangsan'),
    'LOST',
    '电子产品',
    '丢失iPad Air 4代 灰色',
    '在A教学楼一楼自习室遗落一台平板电脑，机身灰色，背面有卡通贴纸，10.9英寸显示屏，带蓝色保护壳，屏幕完好无损。捡到请联系，必有重谢！',
    'Apple iPad Air 4',
    '灰色',
    (SELECT id FROM locations WHERE name = 'A教学楼一层大厅'),
    '2026-05-20 14:30:00',
    '',
    '微信: zhangsan2024',
    'APPROVED',
    '2026-05-20 15:00:00'
),
(
    (SELECT id FROM users WHERE username = 'testuser'),
    'LOST',
    '证件',
    '丢失校园卡',
    '在图书馆自习室遗失校园卡，卡上姓名张三，卡号 2024004，拾到请联系，非常感谢！',
    '',
    '',
    (SELECT id FROM locations WHERE name = '图书馆一楼自习室'),
    '2026-05-21 10:00:00',
    '2024004',
    '手机: 13800000004',
    'APPROVED',
    '2026-05-21 11:00:00'
),
(
    (SELECT id FROM users WHERE username = 'lisi'),
    'LOST',
    '书籍',
    '丢失《高等数学》教材',
    '在实验楼A座一层做实验时遗失高等数学教材，绿色封面，扉页有"李四"字样。这本书对我很重要，拾到请联系！',
    '',
    '绿色',
    (SELECT id FROM locations WHERE name = '实验楼A座一层'),
    '2026-05-22 16:00:00',
    '',
    '邮箱: lisi@campus.edu',
    'PENDING',
    '2026-05-22 17:00:00'
);

-- 插入测试失物招领
INSERT INTO `items` (`user_id`, `type`, `category`, `title`, `description`, `brand`, `color`, `location_id`, `found_time`, `serial_number`, `contact_info`, `status`, `created_at`) VALUES
(
    (SELECT id FROM users WHERE username = 'campusadmin'),
    'FOUND',
    '电子产品',
    '捡到iPad Air 灰色平板电脑',
    '在A教学楼一楼大厅捡到一台10.9寸灰色iPad，背面有卡通贴纸，包着蓝色保护壳，已妥善保管等待失主认领。物品特征与描述完全吻合，请失主带身份证明来认领。',
    'Apple iPad Air',
    '灰色',
    (SELECT id FROM locations WHERE name = 'A教学楼一层大厅'),
    '2026-05-20 16:00:00',
    '',
    '邮箱: campusadmin@campus.edu',
    'APPROVED',
    '2026-05-20 17:00:00'
),
(
    (SELECT id FROM users WHERE username = 'superadmin'),
    'FOUND',
    '证件',
    '拾取校园卡一张',
    '在图书馆二楼阅览室拾取校园卡一张，卡号2024004，拾取时卡套内还有50元现金。已交到行政楼服务大厅失物招领处。',
    '',
    '',
    (SELECT id FROM locations WHERE name = '图书馆二楼阅览室'),
    '2026-05-21 11:30:00',
    '2024004',
    '行政楼服务大厅: 010-12345678',
    'APPROVED',
    '2026-05-21 12:00:00'
),
(
    (SELECT id FROM users WHERE username = 'testuser'),
    'FOUND',
    '书籍',
    '捡到高等数学教材',
    '在操场跑道旁捡到一本高等数学教材，绿色封面，书内有"李四"字样，已妥善保管。',
    '',
    '绿色',
    (SELECT id FROM locations WHERE name = '操场看台下方'),
    '2026-05-22 18:00:00',
    '',
    '微信: testuser2024',
    'PENDING',
    '2026-05-22 18:30:00'
);

-- 插入物品图片
INSERT INTO `item_images` (`item_id`, `image_url`, `image_type`, `sort_order`) VALUES
((SELECT id FROM items WHERE title = '丢失iPad Air 4代 灰色'), 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipad-air-select-gallery-1-202009_AV2?resized=w:470-h:470-q:75', 'MAIN', 0),
((SELECT id FROM items WHERE title = '捡到iPad Air 灰色平板电脑'), 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipad-air-select-gallery-1-202009_AV2?resized=w:470-h:470-q:75', 'MAIN', 0);

-- =====================================================
-- 查看初始化结果
-- =====================================================
SELECT '========================================' AS '';
SELECT '         数据库初始化完成!' AS '';
SELECT '========================================' AS '';

SELECT '-------- 用户列表 --------' AS '';
SELECT id, username, email, student_id, role, status FROM users;

SELECT '-------- 位置列表 --------' AS '';
SELECT id, name, building, floor FROM locations;

SELECT '-------- 物品列表 --------' AS '';
SELECT i.id, i.type, i.title, i.category, u.username AS owner, i.status
FROM items i
JOIN users u ON i.user_id = u.id
WHERE i.deleted = 0;

SELECT '========================================' AS '';
SELECT '         测试账号信息' AS '';
SELECT '========================================' AS '';
SELECT '| 用户名      | 密码   | 角色          |' AS '';
SELECT '|------------|--------|---------------|' AS '';
SELECT '| superadmin  | 123456 | SUPER_ADMIN   |' AS '';
SELECT '| campusadmin | 123456 | CAMPUS_ADMIN  |' AS '';
SELECT '| testuser    | 123456 | USER          |' AS '';
SELECT '| zhangsan    | 123456 | USER          |' AS '';
SELECT '| lisi        | 123456 | USER          |' AS '';
SELECT '========================================' AS '';
