/*
 Navicat Premium Dump SQL

 Source Server         : MysSQL80
 Source Server Type    : MySQL
 Source Server Version : 80405 (8.4.5)
 Source Host           : localhost:3306
 Source Schema         : campus_lostfound

 Target Server Type    : MySQL
 Target Server Version : 80405 (8.4.5)
 File Encoding         : 65001

 Date: 10/06/2026 12:37:54
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for daily_statistics
-- ----------------------------
DROP TABLE IF EXISTS `daily_statistics`;
CREATE TABLE `daily_statistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stat_date` date NOT NULL,
  `lost_count` int NOT NULL DEFAULT 0,
  `found_count` int NOT NULL DEFAULT 0,
  `match_count` int NOT NULL DEFAULT 0,
  `claim_count` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `stat_date`(`stat_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of daily_statistics
-- ----------------------------

-- ----------------------------
-- Table structure for item_completion_requests
-- ----------------------------
DROP TABLE IF EXISTS `item_completion_requests`;
CREATE TABLE `item_completion_requests`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '申请ID',
  `item_id` bigint NOT NULL COMMENT '物品ID',
  `user_id` bigint NOT NULL COMMENT '申请人ID',
  `target_status` enum('FOUND_BACK','RETURNED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '目标状态',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '申请说明',
  `status` enum('PENDING','APPROVED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '申请状态',
  `review_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核说明',
  `reviewed_by` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `reviewed_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `fk_item_completion_requests_reviewed_by`(`reviewed_by` ASC) USING BTREE,
  CONSTRAINT `fk_item_completion_requests_item` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_completion_requests_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_completion_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '物品完成状态申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of item_completion_requests
-- ----------------------------

-- ----------------------------
-- Table structure for item_images
-- ----------------------------
DROP TABLE IF EXISTS `item_images`;
CREATE TABLE `item_images`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍥剧墖ID',
  `item_id` bigint NOT NULL COMMENT '鐗╁搧ID',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鍥剧墖URL',
  `image_type` enum('MAIN','DETAIL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DETAIL' COMMENT '鍥剧墖绫诲瀷',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '鎺掑簭',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  CONSTRAINT `item_images_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 69 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐗╁搧鍥剧墖琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of item_images
-- ----------------------------
INSERT INTO `item_images` VALUES (1, 29, 'https://img.cdn1.vip/i/6a184ef7a2ca5_1779977975.png', 'MAIN', 0, '2026-05-28 22:19:38');
INSERT INTO `item_images` VALUES (2, 26, 'https://img.cdn1.vip/i/6a184ef7a2ca5_1779977975.png', 'MAIN', 0, '2026-05-28 22:19:38');
INSERT INTO `item_images` VALUES (3, 28, 'https://img.cdn1.vip/i/6a184ef6ae8c2_1779977974.png', 'MAIN', 0, '2026-05-28 22:19:38');
INSERT INTO `item_images` VALUES (4, 25, 'https://img.cdn1.vip/i/6a184ef6ae8c2_1779977974.png', 'MAIN', 0, '2026-05-28 22:19:38');
INSERT INTO `item_images` VALUES (66, 325, '/api/uploads/images/2026/06/20260609230438-42cfd96c.png', 'MAIN', 0, '2026-06-09 23:04:39');
INSERT INTO `item_images` VALUES (68, 335, '/api/uploads/images/2026/06/20260610121934-a0754fd8.png', 'MAIN', 0, '2026-06-10 12:19:40');

-- ----------------------------
-- Table structure for items
-- ----------------------------
DROP TABLE IF EXISTS `items`;
CREATE TABLE `items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐗╁搧ID',
  `user_id` bigint NOT NULL COMMENT '鍙戝竷鑰匢D',
  `type` enum('LOST','FOUND') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '绫诲瀷: 瀵荤墿LOST/鎷涢?FOUND',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鐗╁搧绫诲埆(濡?鐢靛瓙浜у搧/璇佷欢/涔︾睄绛?',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鏍囬?',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '璇︾粏鎻忚堪',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍝佺墝/鍨嬪彿',
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '棰滆壊',
  `location_id` bigint NULL DEFAULT NULL COMMENT '涓㈠け/鎷惧彇鍦扮偣',
  `lost_time` datetime NULL DEFAULT NULL COMMENT '涓㈠け鏃堕棿',
  `found_time` datetime NULL DEFAULT NULL COMMENT '鎷惧彇鏃堕棿',
  `serial_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '搴忓垪鍙?璇佷欢鍙?鐢ㄤ簬绮剧‘鍖归厤)',
  `contact_info` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鑱旂郴鏂瑰紡',
  `status` enum('PENDING','APPROVED','REJECTED','FOUND_BACK','RETURNED','EXPIRED','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING待审核, APPROVED已发布, REJECTED审核未通过, FOUND_BACK寻物已找到, RETURNED招领已归还, EXPIRED已过期, CLOSED已关闭',
  `view_count` int NOT NULL DEFAULT 0 COMMENT '娴忚?娆℃暟',
  `match_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '鏈?珮鍖归厤鍒嗘暟',
  `match_item_id` bigint NULL DEFAULT NULL COMMENT '鍖归厤鎴愬姛鐨勭墿鍝両D',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '详细位置',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_location_id`(`location_id` ASC) USING BTREE,
  INDEX `idx_serial_number`(`serial_number` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 336 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '澶辩墿鎷涢?琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of items
-- ----------------------------
INSERT INTO `items` VALUES (25, 35, 'LOST', '电子产品', '丢失iPad Air 4代 灰色', '在A教学楼一楼自习室遗落一台平板电脑，机身灰色，背面有卡通贴纸，10.9英寸显示屏，带蓝色保护壳，屏幕完好无损。捡到请联系，必有重谢！', 'Apple iPad Air 4', '灰色', 41, '2026-05-20 14:30:00', NULL, '', '微信: zhangsan2024', 'APPROVED', 1, 1.00, 28, '2026-05-20 15:00:00', '2026-06-09 21:49:12', 1, NULL);
INSERT INTO `items` VALUES (26, 34, 'LOST', '证件', '丢失校园卡', '在图书馆自习室遗失校园卡，卡上姓名张三，卡号 2024004，拾到请联系，非常感谢！', '', '', 43, '2026-05-21 10:00:00', NULL, '2024004', '手机: 13800000004', 'APPROVED', 1, 1.00, 29, '2026-05-21 11:00:00', '2026-06-09 21:49:12', 1, NULL);
INSERT INTO `items` VALUES (27, 36, 'LOST', '书籍', '丢失《高等数学》教材', '在实验楼A座一层做实验时遗失高等数学教材，绿色封面，扉页有\"李四\"字样。这本书对我很重要，拾到请联系！', '', '绿色', 49, '2026-05-22 16:00:00', NULL, '', '邮箱: lisi@campus.edu', 'REJECTED', 0, NULL, NULL, '2026-05-22 17:00:00', '2026-06-09 21:49:12', 1, NULL);
INSERT INTO `items` VALUES (28, 33, 'FOUND', '电子产品', '捡到iPad Air 灰色平板电脑', '在A教学楼一楼大厅捡到一台10.9寸灰色iPad，背面有卡通贴纸，包着蓝色保护壳，已妥善保管等待失主认领。', 'Apple iPad Air', '灰色', 41, NULL, '2026-05-20 16:00:00', '', '邮箱: campusadmin@campus.edu', 'APPROVED', 0, 1.00, 25, '2026-05-20 17:00:00', '2026-06-09 21:49:12', 1, NULL);
INSERT INTO `items` VALUES (29, 32, 'FOUND', '证件', '拾取校园卡一张', '在图书馆二楼阅览室拾取校园卡一张，卡号2024004，拾取时卡套内还有50元现金。已交到行政楼服务大厅失物招领处。', '', '', 44, NULL, '2026-05-21 11:30:00', '2024004', '行政楼服务大厅: 010-12345678', 'APPROVED', 8, 1.00, 26, '2026-05-21 12:00:00', '2026-06-09 21:49:12', 1, NULL);
INSERT INTO `items` VALUES (30, 34, 'FOUND', '书籍', '捡到高等数学教材', '在操场跑道旁捡到一本高等数学教材，绿色封面，书内有\"李四\"字样，已妥善保管。', '', '绿色', 47, NULL, '2026-05-22 18:00:00', '', '微信: testuser2024', 'REJECTED', 1, NULL, NULL, '2026-05-22 18:30:00', '2026-06-09 21:49:12', 1, NULL);
INSERT INTO `items` VALUES (183, 50, 'LOST', '电子产品', '[审核E2E] lost 31962', 'E2E test for approve', 'Apple', 'black', NULL, NULL, NULL, 'REVIEW_SN_31962', 'QQ:test', 'APPROVED', 3, NULL, NULL, '2026-06-07 19:32:42', '2026-06-09 21:49:12', 1, '图书馆');
INSERT INTO `items` VALUES (184, 50, 'FOUND', '其他', '[E2E] campusadmin test 31962', 'campusadmin review test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'APPROVED', 2, NULL, NULL, '2026-06-07 19:32:44', '2026-06-09 21:49:12', 1, '宿舍');
INSERT INTO `items` VALUES (186, 32, 'LOST', '证件', '丢失校园卡', '在图书馆三楼自习室丢失校园卡，卡号CARD001', NULL, NULL, NULL, '2026-06-08 21:49:53', NULL, 'CARD001', NULL, 'APPROVED', 0, 1.00, 187, '2026-06-08 21:49:53', '2026-06-09 21:53:07', 1, '图书馆三楼自习室');
INSERT INTO `items` VALUES (187, 32, 'FOUND', '证件', '捡到校园卡', '在图书馆三楼自习室捡到校园卡，卡号CARD001', NULL, NULL, NULL, NULL, '2026-06-08 23:49:53', 'CARD001', NULL, 'APPROVED', 0, 1.00, 186, '2026-06-08 23:49:53', '2026-06-09 21:53:07', 1, '图书馆三楼自习室');
INSERT INTO `items` VALUES (188, 32, 'LOST', '证件', '丢失校园卡', '在食堂三楼丢失校园卡，卡号CARD002', NULL, NULL, NULL, '2026-06-07 21:49:53', NULL, 'CARD002', NULL, 'APPROVED', 0, 1.00, 189, '2026-06-07 21:49:53', '2026-06-09 21:53:07', 1, '食堂三楼');
INSERT INTO `items` VALUES (189, 32, 'FOUND', '证件', '捡到校园卡', '在食堂三楼捡到校园卡，卡号CARD002', NULL, NULL, NULL, NULL, '2026-06-07 23:49:53', 'CARD002', NULL, 'APPROVED', 0, 1.00, 188, '2026-06-07 23:49:53', '2026-06-09 21:53:07', 1, '食堂三楼');
INSERT INTO `items` VALUES (190, 32, 'LOST', '证件', '丢失校园卡', '在体育馆丢失校园卡，卡号CARD003', NULL, NULL, NULL, '2026-06-06 21:49:53', NULL, 'CARD003', NULL, 'APPROVED', 0, 1.00, 191, '2026-06-06 21:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (191, 32, 'FOUND', '证件', '捡到校园卡', '在体育馆捡到校园卡，卡号CARD003', NULL, NULL, NULL, NULL, '2026-06-06 23:49:53', 'CARD003', NULL, 'APPROVED', 0, 1.00, 190, '2026-06-06 23:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (192, 32, 'LOST', '证件', '丢失校园卡', '在教学楼B座丢失校园卡，卡号CARD004', NULL, NULL, NULL, '2026-06-05 21:49:53', NULL, 'CARD004', NULL, 'APPROVED', 0, 1.00, 193, '2026-06-05 21:49:53', '2026-06-09 21:53:07', 1, '教学楼B座');
INSERT INTO `items` VALUES (193, 32, 'FOUND', '证件', '捡到校园卡', '在教学楼B座捡到校园卡，卡号CARD004', NULL, NULL, NULL, NULL, '2026-06-05 23:49:53', 'CARD004', NULL, 'APPROVED', 0, 1.00, 192, '2026-06-05 23:49:53', '2026-06-09 21:53:07', 1, '教学楼B座');
INSERT INTO `items` VALUES (194, 32, 'LOST', '证件', '丢失校园卡', '在实验楼丢失校园卡，卡号CARD005', NULL, NULL, NULL, '2026-06-04 21:49:53', NULL, 'CARD005', NULL, 'APPROVED', 0, 1.00, 195, '2026-06-04 21:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (195, 32, 'FOUND', '证件', '捡到校园卡', '在实验楼捡到校园卡，卡号CARD005', NULL, NULL, NULL, NULL, '2026-06-04 23:49:53', 'CARD005', NULL, 'APPROVED', 0, 1.00, 194, '2026-06-04 23:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (196, 32, 'LOST', '证件', '丢失校园卡', '在行政楼丢失校园卡，卡号CARD006', NULL, NULL, NULL, '2026-06-03 21:49:53', NULL, 'CARD006', NULL, 'APPROVED', 0, 1.00, 197, '2026-06-03 21:49:53', '2026-06-09 21:53:07', 1, '行政楼');
INSERT INTO `items` VALUES (197, 32, 'FOUND', '证件', '捡到校园卡', '在行政楼捡到校园卡，卡号CARD006', NULL, NULL, NULL, NULL, '2026-06-03 23:49:53', 'CARD006', NULL, 'APPROVED', 0, 1.00, 196, '2026-06-03 23:49:53', '2026-06-09 21:53:07', 1, '行政楼');
INSERT INTO `items` VALUES (198, 32, 'LOST', '证件', '丢失校园卡', '在学生宿舍丢失校园卡，卡号CARD007', NULL, NULL, NULL, '2026-06-02 21:49:53', NULL, 'CARD007', NULL, 'APPROVED', 0, 1.00, 199, '2026-06-02 21:49:53', '2026-06-09 21:53:07', 1, '学生宿舍');
INSERT INTO `items` VALUES (199, 32, 'FOUND', '证件', '捡到校园卡', '在学生宿舍捡到校园卡，卡号CARD007', NULL, NULL, NULL, NULL, '2026-06-02 23:49:53', 'CARD007', NULL, 'APPROVED', 0, 1.00, 198, '2026-06-02 23:49:53', '2026-06-09 21:53:07', 1, '学生宿舍');
INSERT INTO `items` VALUES (200, 32, 'LOST', '证件', '丢失校园卡', '在操场丢失校园卡，卡号CARD008', NULL, NULL, NULL, '2026-06-01 21:49:53', NULL, 'CARD008', NULL, 'APPROVED', 0, 1.00, 201, '2026-06-01 21:49:53', '2026-06-09 21:53:07', 1, '操场');
INSERT INTO `items` VALUES (201, 32, 'FOUND', '证件', '捡到校园卡', '在操场捡到校园卡，卡号CARD008', NULL, NULL, NULL, NULL, '2026-06-01 23:49:53', 'CARD008', NULL, 'APPROVED', 0, 1.00, 200, '2026-06-01 23:49:53', '2026-06-09 21:53:07', 1, '操场');
INSERT INTO `items` VALUES (202, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-04 21:49:53', NULL, 'ID001', NULL, 'APPROVED', 0, 1.00, 203, '2026-06-04 21:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (203, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-05 00:49:53', 'ID001', NULL, 'APPROVED', 0, 1.00, 202, '2026-06-05 00:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (204, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-03 21:49:53', NULL, 'ID002', NULL, 'APPROVED', 0, 1.00, 205, '2026-06-03 21:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (205, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-04 00:49:53', 'ID002', NULL, 'APPROVED', 0, 1.00, 204, '2026-06-04 00:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (206, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-02 21:49:53', NULL, 'ID003', NULL, 'APPROVED', 0, 1.00, 207, '2026-06-02 21:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (207, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-03 00:49:53', 'ID003', NULL, 'APPROVED', 0, 1.00, 206, '2026-06-03 00:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (208, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-01 21:49:53', NULL, 'ID004', NULL, 'APPROVED', 0, 1.00, 209, '2026-06-01 21:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (209, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-02 00:49:53', 'ID004', NULL, 'APPROVED', 0, 1.00, 208, '2026-06-02 00:49:53', '2026-06-09 21:53:07', 1, '第二食堂');
INSERT INTO `items` VALUES (210, 34, 'LOST', '电子产品', '丢失iPhone 15', '在图书馆丢失iPhone 15，黑色', 'Apple', '黑色', NULL, '2026-06-08 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-08 21:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (211, 32, 'FOUND', '电子产品', '捡到iPhone 15', '在图书馆捡到iPhone 15，黑色', 'Apple', '黑色', NULL, NULL, '2026-06-09 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-09 01:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (212, 34, 'LOST', '电子产品', '丢失华为Mate 60', '在教学楼丢失华为Mate 60，白色', 'Huawei', '白色', NULL, '2026-06-07 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-07 21:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (213, 32, 'FOUND', '电子产品', '捡到华为Mate 60', '在教学楼捡到华为Mate 60，白色', 'Huawei', '白色', NULL, NULL, '2026-06-08 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-08 01:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (214, 34, 'LOST', '电子产品', '丢失小米14', '在食堂丢失小米14，蓝色', 'Xiaomi', '蓝色', NULL, '2026-06-06 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 21:49:53', '2026-06-09 21:53:07', 1, '食堂');
INSERT INTO `items` VALUES (215, 32, 'FOUND', '电子产品', '捡到小米14', '在食堂捡到小米14，蓝色', 'Xiaomi', '蓝色', NULL, NULL, '2026-06-07 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-07 01:49:53', '2026-06-09 21:53:07', 1, '食堂');
INSERT INTO `items` VALUES (216, 34, 'LOST', '电子产品', '丢失AirPods Pro 2', '在体育馆丢失AirPods Pro 2，白色', 'Apple', '白色', NULL, '2026-06-05 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 21:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (217, 32, 'FOUND', '电子产品', '捡到AirPods Pro 2', '在体育馆捡到AirPods Pro 2，白色', 'Apple', '白色', NULL, NULL, '2026-06-06 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 01:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (218, 34, 'LOST', '电子产品', '丢失iPad Pro', '在图书馆丢失iPad Pro，银色', 'Apple', '银色', NULL, '2026-06-04 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 21:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (219, 32, 'FOUND', '电子产品', '捡到iPad Pro', '在图书馆捡到iPad Pro，银色', 'Apple', '银色', NULL, NULL, '2026-06-05 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 01:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (220, 34, 'LOST', '电子产品', '丢失MacBook Pro', '在教学楼丢失MacBook Pro，深空灰', 'Apple', '深空灰', NULL, '2026-06-03 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 21:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (221, 32, 'FOUND', '电子产品', '捡到MacBook Pro', '在教学楼捡到MacBook Pro，深空灰', 'Apple', '深空灰', NULL, NULL, '2026-06-04 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 01:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (222, 34, 'LOST', '电子产品', '丢失Apple Watch', '在操场丢失Apple Watch，黑色', 'Apple', '黑色', NULL, '2026-06-02 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 21:49:53', '2026-06-09 21:53:07', 1, '操场');
INSERT INTO `items` VALUES (223, 32, 'FOUND', '电子产品', '捡到Apple Watch', '在操场捡到Apple Watch，黑色', 'Apple', '黑色', NULL, NULL, '2026-06-03 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 01:49:53', '2026-06-09 21:53:07', 1, '操场');
INSERT INTO `items` VALUES (224, 34, 'LOST', '电子产品', '丢失Anker充电宝', '在实验楼丢失Anker充电宝，白色', 'Anker', '白色', NULL, '2026-06-01 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-01 21:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (225, 32, 'FOUND', '电子产品', '捡到Anker充电宝', '在实验楼捡到Anker充电宝，白色', 'Anker', '白色', NULL, NULL, '2026-06-02 01:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 01:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (226, 33, 'LOST', '其他', '丢失雨伞', '在教学楼B座丢失雨伞', NULL, '黑色', NULL, '2026-06-06 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 21:49:53', '2026-06-09 21:53:07', 1, '教学楼B座');
INSERT INTO `items` VALUES (227, 33, 'LOST', '其他', '丢失保温杯', '在图书馆丢失保温杯', NULL, '银色', NULL, '2026-06-05 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 21:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (228, 33, 'LOST', '书籍', '丢失高等数学课本', '在实验楼丢失高等数学课本', NULL, '绿色', NULL, '2026-06-04 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 21:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (229, 33, 'LOST', '其他', '丢失钱包', '在食堂丢失钱包', NULL, '棕色', NULL, '2026-06-03 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 21:49:53', '2026-06-09 21:53:07', 1, '食堂');
INSERT INTO `items` VALUES (230, 33, 'LOST', '其他', '丢失钥匙串', '在宿舍丢失钥匙串', NULL, '', NULL, '2026-06-02 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 21:49:53', '2026-06-09 21:53:07', 1, '宿舍');
INSERT INTO `items` VALUES (231, 33, 'LOST', '其他', '丢失书包', '在操场丢失书包', NULL, '蓝色', NULL, '2026-06-01 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-01 21:49:53', '2026-06-09 21:53:07', 1, '操场');
INSERT INTO `items` VALUES (232, 33, 'LOST', '其他', '丢失眼镜', '在图书馆丢失眼镜', NULL, '黑色', NULL, '2026-05-31 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-31 21:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (233, 33, 'LOST', '其他', '丢失笔记本', '在教学楼丢失笔记本', NULL, '红色', NULL, '2026-05-30 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-30 21:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (234, 33, 'LOST', '其他', '丢失运动水杯', '在体育馆丢失运动水杯', NULL, '橙色', NULL, '2026-05-29 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-29 21:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (235, 33, 'LOST', '其他', '丢失有线耳机', '在食堂丢失有线耳机', NULL, '白色', NULL, '2026-05-28 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-28 21:49:53', '2026-06-09 21:53:07', 1, '食堂');
INSERT INTO `items` VALUES (236, 33, 'LOST', '书籍', '丢失英语四级真题', '在图书馆丢失英语四级真题', NULL, '蓝色', NULL, '2026-05-27 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-27 21:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (237, 33, 'LOST', '其他', '丢失U盘', '在实验楼丢失U盘', NULL, '银色', NULL, '2026-05-26 21:49:53', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-26 21:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (238, 32, 'FOUND', '其他', '捡到雨伞', '在教学楼捡到雨伞', NULL, '蓝色', NULL, NULL, '2026-06-06 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 23:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (239, 32, 'FOUND', '其他', '捡到保温杯', '在图书馆捡到保温杯', NULL, '红色', NULL, NULL, '2026-06-05 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 23:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (240, 32, 'FOUND', '书籍', '捡到线性代数', '在实验楼捡到线性代数', NULL, '蓝色', NULL, NULL, '2026-06-04 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 23:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (241, 32, 'FOUND', '其他', '捡到钱包', '在食堂捡到钱包', NULL, '黑色', NULL, NULL, '2026-06-03 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 23:49:53', '2026-06-09 21:53:07', 1, '食堂');
INSERT INTO `items` VALUES (242, 32, 'FOUND', '其他', '捡到钥匙串', '在宿舍捡到钥匙串', NULL, '', NULL, NULL, '2026-06-02 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 23:49:53', '2026-06-09 21:53:07', 1, '宿舍');
INSERT INTO `items` VALUES (243, 32, 'FOUND', '其他', '捡到书包', '在操场捡到书包', NULL, '黑色', NULL, NULL, '2026-06-01 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-01 23:49:53', '2026-06-09 21:53:07', 1, '操场');
INSERT INTO `items` VALUES (244, 32, 'FOUND', '其他', '捡到眼镜', '在图书馆捡到眼镜', NULL, '银色', NULL, NULL, '2026-05-31 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-31 23:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (245, 32, 'FOUND', '其他', '捡到笔记本', '在教学楼捡到笔记本', NULL, '蓝色', NULL, NULL, '2026-05-30 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-30 23:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (246, 32, 'FOUND', '其他', '捡到运动水杯', '在体育馆捡到运动水杯', NULL, '蓝色', NULL, NULL, '2026-05-29 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-29 23:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (247, 32, 'FOUND', '其他', '捡到耳机', '在食堂捡到耳机', NULL, '黑色', NULL, NULL, '2026-05-28 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-28 23:49:53', '2026-06-09 21:53:07', 1, '食堂');
INSERT INTO `items` VALUES (248, 32, 'FOUND', '书籍', '捡到计算机基础', '在图书馆捡到计算机基础', NULL, '绿色', NULL, NULL, '2026-05-27 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-27 23:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (249, 32, 'FOUND', '其他', '捡到U盘', '在实验楼捡到U盘', NULL, '黑色', NULL, NULL, '2026-05-26 23:49:53', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-26 23:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (250, 34, 'LOST', '电子产品', '丢失三星手机', '丢失三星手机，正在等待审核', NULL, '黑色', NULL, '2026-06-09 20:49:53', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 20:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (251, 32, 'FOUND', '证件', '捡到银行卡', '捡到银行卡，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 19:49:53', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 19:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (252, 34, 'LOST', '其他', '丢失计算器', '丢失计算器，正在等待审核', NULL, '', NULL, '2026-06-09 18:49:53', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 18:49:53', '2026-06-09 21:53:07', 1, '实验楼');
INSERT INTO `items` VALUES (253, 32, 'FOUND', '电子产品', '捡到蓝牙耳机', '捡到蓝牙耳机，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 17:49:53', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 17:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (254, 34, 'LOST', '书籍', '丢失数据结构', '丢失数据结构，正在等待审核', NULL, '', NULL, '2026-06-09 16:49:53', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 16:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (255, 32, 'FOUND', '其他', '捡到饭盒', '捡到饭盒，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 15:49:53', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 15:49:53', '2026-06-09 21:53:07', 1, '食堂');
INSERT INTO `items` VALUES (256, 34, 'LOST', '电子产品', '丢失OPPO手机', '丢失OPPO手机，正在等待审核', NULL, '绿色', NULL, '2026-06-09 14:49:53', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 14:49:53', '2026-06-09 21:53:07', 1, '教学楼');
INSERT INTO `items` VALUES (257, 32, 'FOUND', '证件', '捡到校园卡', '捡到校园卡，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 13:49:53', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 13:49:53', '2026-06-09 21:53:07', 1, '操场');
INSERT INTO `items` VALUES (258, 34, 'LOST', '其他', '丢失羽毛球拍', '丢失羽毛球拍，正在等待审核', NULL, '', NULL, '2026-06-09 12:49:53', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 12:49:53', '2026-06-09 21:53:07', 1, '体育馆');
INSERT INTO `items` VALUES (259, 32, 'FOUND', '电子产品', '捡到小米手环', '捡到小米手环，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 11:49:53', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 11:49:53', '2026-06-09 21:53:07', 1, '图书馆');
INSERT INTO `items` VALUES (260, 32, 'LOST', '证件', '丢失校园卡', '在图书馆三楼自习室丢失校园卡，卡号CARD001', NULL, NULL, NULL, '2026-06-08 21:53:07', NULL, 'CARD001', NULL, 'APPROVED', 1, 1.00, 261, '2026-06-08 21:53:07', '2026-06-09 21:55:02', 0, '图书馆三楼自习室');
INSERT INTO `items` VALUES (261, 32, 'FOUND', '证件', '捡到校园卡', '在图书馆三楼自习室捡到校园卡，卡号CARD001', NULL, NULL, NULL, NULL, '2026-06-08 23:53:07', 'CARD001', NULL, 'APPROVED', 1, 1.00, 260, '2026-06-08 23:53:07', '2026-06-09 21:53:34', 0, '图书馆三楼自习室');
INSERT INTO `items` VALUES (262, 32, 'LOST', '证件', '丢失校园卡', '在食堂三楼丢失校园卡，卡号CARD002', NULL, NULL, NULL, '2026-06-07 21:53:07', NULL, 'CARD002', NULL, 'APPROVED', 2, 1.00, 263, '2026-06-07 21:53:07', '2026-06-09 21:54:19', 0, '食堂三楼');
INSERT INTO `items` VALUES (263, 32, 'FOUND', '证件', '捡到校园卡', '在食堂三楼捡到校园卡，卡号CARD002', NULL, NULL, NULL, NULL, '2026-06-07 23:53:07', 'CARD002', NULL, 'APPROVED', 2, 1.00, 262, '2026-06-07 23:53:07', '2026-06-09 21:54:18', 0, '食堂三楼');
INSERT INTO `items` VALUES (264, 32, 'LOST', '证件', '丢失校园卡', '在体育馆丢失校园卡，卡号CARD003', NULL, NULL, NULL, '2026-06-06 21:53:07', NULL, 'CARD003', NULL, 'APPROVED', 0, 1.00, 265, '2026-06-06 21:53:07', '2026-06-09 21:53:12', 0, '体育馆');
INSERT INTO `items` VALUES (265, 32, 'FOUND', '证件', '捡到校园卡', '在体育馆捡到校园卡，卡号CARD003', NULL, NULL, NULL, NULL, '2026-06-06 23:53:07', 'CARD003', NULL, 'APPROVED', 1, 1.00, 264, '2026-06-06 23:53:07', '2026-06-09 21:54:40', 0, '体育馆');
INSERT INTO `items` VALUES (266, 32, 'LOST', '证件', '丢失校园卡', '在教学楼B座丢失校园卡，卡号CARD004', NULL, NULL, NULL, '2026-06-05 21:53:07', NULL, 'CARD004', NULL, 'APPROVED', 2, 1.00, 267, '2026-06-05 21:53:07', '2026-06-09 21:54:09', 0, '教学楼B座');
INSERT INTO `items` VALUES (267, 32, 'FOUND', '证件', '捡到校园卡', '在教学楼B座捡到校园卡，卡号CARD004', NULL, NULL, NULL, NULL, '2026-06-05 23:53:07', 'CARD004', NULL, 'APPROVED', 0, 1.00, 266, '2026-06-05 23:53:07', '2026-06-09 21:53:13', 0, '教学楼B座');
INSERT INTO `items` VALUES (268, 32, 'LOST', '证件', '丢失校园卡', '在实验楼丢失校园卡，卡号CARD005', NULL, NULL, NULL, '2026-06-04 21:53:07', NULL, 'CARD005', NULL, 'APPROVED', 0, 1.00, 269, '2026-06-04 21:53:07', '2026-06-09 21:53:14', 0, '实验楼');
INSERT INTO `items` VALUES (269, 32, 'FOUND', '证件', '捡到校园卡', '在实验楼捡到校园卡，卡号CARD005', NULL, NULL, NULL, NULL, '2026-06-04 23:53:07', 'CARD005', NULL, 'APPROVED', 0, 1.00, 268, '2026-06-04 23:53:07', '2026-06-09 21:53:14', 0, '实验楼');
INSERT INTO `items` VALUES (270, 32, 'LOST', '证件', '丢失校园卡', '在行政楼丢失校园卡，卡号CARD006', NULL, NULL, NULL, '2026-06-03 21:53:07', NULL, 'CARD006', NULL, 'APPROVED', 0, 1.00, 271, '2026-06-03 21:53:07', '2026-06-09 21:53:15', 0, '行政楼');
INSERT INTO `items` VALUES (271, 32, 'FOUND', '证件', '捡到校园卡', '在行政楼捡到校园卡，卡号CARD006', NULL, NULL, NULL, NULL, '2026-06-03 23:53:07', 'CARD006', NULL, 'APPROVED', 0, 1.00, 270, '2026-06-03 23:53:07', '2026-06-09 21:53:15', 0, '行政楼');
INSERT INTO `items` VALUES (272, 32, 'LOST', '证件', '丢失校园卡', '在学生宿舍丢失校园卡，卡号CARD007', NULL, NULL, NULL, '2026-06-02 21:53:07', NULL, 'CARD007', NULL, 'APPROVED', 0, 1.00, 273, '2026-06-02 21:53:07', '2026-06-09 21:53:16', 0, '学生宿舍');
INSERT INTO `items` VALUES (273, 32, 'FOUND', '证件', '捡到校园卡', '在学生宿舍捡到校园卡，卡号CARD007', NULL, NULL, NULL, NULL, '2026-06-02 23:53:07', 'CARD007', NULL, 'APPROVED', 0, 1.00, 272, '2026-06-02 23:53:07', '2026-06-09 21:53:16', 0, '学生宿舍');
INSERT INTO `items` VALUES (274, 32, 'LOST', '证件', '丢失校园卡', '在操场丢失校园卡，卡号CARD008', NULL, NULL, NULL, '2026-06-01 21:53:07', NULL, 'CARD008', NULL, 'APPROVED', 0, 1.00, 275, '2026-06-01 21:53:07', '2026-06-09 21:53:16', 0, '操场');
INSERT INTO `items` VALUES (275, 32, 'FOUND', '证件', '捡到校园卡', '在操场捡到校园卡，卡号CARD008', NULL, NULL, NULL, NULL, '2026-06-01 23:53:07', 'CARD008', NULL, 'APPROVED', 0, 1.00, 274, '2026-06-01 23:53:07', '2026-06-09 21:53:16', 0, '操场');
INSERT INTO `items` VALUES (276, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-04 21:53:07', NULL, 'ID001', NULL, 'APPROVED', 0, 1.00, 277, '2026-06-04 21:53:07', '2026-06-09 21:53:17', 0, '第二食堂');
INSERT INTO `items` VALUES (277, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-05 00:53:07', 'ID001', NULL, 'APPROVED', 0, 1.00, 276, '2026-06-05 00:53:07', '2026-06-09 21:53:17', 0, '第二食堂');
INSERT INTO `items` VALUES (278, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-03 21:53:07', NULL, 'ID002', NULL, 'APPROVED', 0, 1.00, 279, '2026-06-03 21:53:07', '2026-06-09 21:53:18', 0, '第二食堂');
INSERT INTO `items` VALUES (279, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-04 00:53:07', 'ID002', NULL, 'APPROVED', 0, 1.00, 278, '2026-06-04 00:53:07', '2026-06-09 21:53:18', 0, '第二食堂');
INSERT INTO `items` VALUES (280, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-02 21:53:07', NULL, 'ID003', NULL, 'APPROVED', 0, 1.00, 281, '2026-06-02 21:53:07', '2026-06-09 21:53:21', 0, '第二食堂');
INSERT INTO `items` VALUES (281, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-03 00:53:07', 'ID003', NULL, 'APPROVED', 0, 1.00, 280, '2026-06-03 00:53:07', '2026-06-09 21:53:21', 0, '第二食堂');
INSERT INTO `items` VALUES (282, 33, 'LOST', '证件', '丢失身份证', '在食堂丢失身份证', NULL, NULL, NULL, '2026-06-01 21:53:07', NULL, 'ID004', NULL, 'APPROVED', 0, 1.00, 283, '2026-06-01 21:53:07', '2026-06-09 21:53:22', 0, '第二食堂');
INSERT INTO `items` VALUES (283, 32, 'FOUND', '证件', '捡到身份证', '在食堂捡到身份证', NULL, NULL, NULL, NULL, '2026-06-02 00:53:07', 'ID004', NULL, 'APPROVED', 0, 1.00, 282, '2026-06-02 00:53:07', '2026-06-09 21:53:22', 0, '第二食堂');
INSERT INTO `items` VALUES (284, 34, 'LOST', '电子产品', '丢失iPhone 15', '在图书馆丢失iPhone 15，黑色', 'Apple', '黑色', NULL, '2026-06-08 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-08 21:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (285, 32, 'FOUND', '电子产品', '捡到iPhone 15', '在图书馆捡到iPhone 15，黑色', 'Apple', '黑色', NULL, NULL, '2026-06-09 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-09 01:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (286, 34, 'LOST', '电子产品', '丢失华为Mate 60', '在教学楼丢失华为Mate 60，白色', 'Huawei', '白色', NULL, '2026-06-07 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-07 21:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (287, 32, 'FOUND', '电子产品', '捡到华为Mate 60', '在教学楼捡到华为Mate 60，白色', 'Huawei', '白色', NULL, NULL, '2026-06-08 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-08 01:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (288, 34, 'LOST', '电子产品', '丢失小米14', '在食堂丢失小米14，蓝色', 'Xiaomi', '蓝色', NULL, '2026-06-06 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 21:53:07', '2026-06-09 21:53:07', 0, '食堂');
INSERT INTO `items` VALUES (289, 32, 'FOUND', '电子产品', '捡到小米14', '在食堂捡到小米14，蓝色', 'Xiaomi', '蓝色', NULL, NULL, '2026-06-07 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-07 01:53:07', '2026-06-09 21:53:07', 0, '食堂');
INSERT INTO `items` VALUES (290, 34, 'LOST', '电子产品', '丢失AirPods Pro 2', '在体育馆丢失AirPods Pro 2，白色', 'Apple', '白色', NULL, '2026-06-05 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 21:53:07', '2026-06-09 21:53:07', 0, '体育馆');
INSERT INTO `items` VALUES (291, 32, 'FOUND', '电子产品', '捡到AirPods Pro 2', '在体育馆捡到AirPods Pro 2，白色', 'Apple', '白色', NULL, NULL, '2026-06-06 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 01:53:07', '2026-06-09 21:53:07', 0, '体育馆');
INSERT INTO `items` VALUES (292, 34, 'LOST', '电子产品', '丢失iPad Pro', '在图书馆丢失iPad Pro，银色', 'Apple', '银色', NULL, '2026-06-04 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 21:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (293, 32, 'FOUND', '电子产品', '捡到iPad Pro', '在图书馆捡到iPad Pro，银色', 'Apple', '银色', NULL, NULL, '2026-06-05 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 01:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (294, 34, 'LOST', '电子产品', '丢失MacBook Pro', '在教学楼丢失MacBook Pro，深空灰', 'Apple', '深空灰', NULL, '2026-06-03 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 21:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (295, 32, 'FOUND', '电子产品', '捡到MacBook Pro', '在教学楼捡到MacBook Pro，深空灰', 'Apple', '深空灰', NULL, NULL, '2026-06-04 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 01:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (296, 34, 'LOST', '电子产品', '丢失Apple Watch', '在操场丢失Apple Watch，黑色', 'Apple', '黑色', NULL, '2026-06-02 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 21:53:07', '2026-06-09 21:53:07', 0, '操场');
INSERT INTO `items` VALUES (297, 32, 'FOUND', '电子产品', '捡到Apple Watch', '在操场捡到Apple Watch，黑色', 'Apple', '黑色', NULL, NULL, '2026-06-03 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 01:53:07', '2026-06-09 21:53:07', 0, '操场');
INSERT INTO `items` VALUES (298, 34, 'LOST', '电子产品', '丢失Anker充电宝', '在实验楼丢失Anker充电宝，白色', 'Anker', '白色', NULL, '2026-06-01 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-01 21:53:07', '2026-06-09 21:53:07', 0, '实验楼');
INSERT INTO `items` VALUES (299, 32, 'FOUND', '电子产品', '捡到Anker充电宝', '在实验楼捡到Anker充电宝，白色', 'Anker', '白色', NULL, NULL, '2026-06-02 01:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 01:53:07', '2026-06-09 21:53:07', 0, '实验楼');
INSERT INTO `items` VALUES (300, 33, 'LOST', '其他', '丢失雨伞', '在教学楼B座丢失雨伞', NULL, '黑色', NULL, '2026-06-06 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 21:53:07', '2026-06-09 21:53:07', 0, '教学楼B座');
INSERT INTO `items` VALUES (301, 33, 'LOST', '其他', '丢失保温杯', '在图书馆丢失保温杯', NULL, '银色', NULL, '2026-06-05 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 21:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (302, 33, 'LOST', '书籍', '丢失高等数学课本', '在实验楼丢失高等数学课本', NULL, '绿色', NULL, '2026-06-04 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 21:53:07', '2026-06-09 21:53:07', 0, '实验楼');
INSERT INTO `items` VALUES (303, 33, 'LOST', '其他', '丢失钱包', '在食堂丢失钱包', NULL, '棕色', NULL, '2026-06-03 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 21:53:07', '2026-06-09 21:53:07', 0, '食堂');
INSERT INTO `items` VALUES (304, 33, 'LOST', '其他', '丢失钥匙串', '在宿舍丢失钥匙串', NULL, '', NULL, '2026-06-02 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 21:53:07', '2026-06-09 21:53:07', 0, '宿舍');
INSERT INTO `items` VALUES (305, 33, 'LOST', '其他', '丢失书包', '在操场丢失书包', NULL, '蓝色', NULL, '2026-06-01 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-01 21:53:07', '2026-06-09 21:53:07', 0, '操场');
INSERT INTO `items` VALUES (306, 33, 'LOST', '其他', '丢失眼镜', '在图书馆丢失眼镜', NULL, '黑色', NULL, '2026-05-31 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-31 21:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (307, 33, 'LOST', '其他', '丢失笔记本', '在教学楼丢失笔记本', NULL, '红色', NULL, '2026-05-30 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-30 21:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (308, 33, 'LOST', '其他', '丢失运动水杯', '在体育馆丢失运动水杯', NULL, '橙色', NULL, '2026-05-29 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-29 21:53:07', '2026-06-09 21:53:07', 0, '体育馆');
INSERT INTO `items` VALUES (309, 33, 'LOST', '其他', '丢失有线耳机', '在食堂丢失有线耳机', NULL, '白色', NULL, '2026-05-28 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-28 21:53:07', '2026-06-09 21:53:07', 0, '食堂');
INSERT INTO `items` VALUES (310, 33, 'LOST', '书籍', '丢失英语四级真题', '在图书馆丢失英语四级真题', NULL, '蓝色', NULL, '2026-05-27 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-27 21:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (311, 33, 'LOST', '其他', '丢失U盘', '在实验楼丢失U盘', NULL, '银色', NULL, '2026-05-26 21:53:07', NULL, NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-26 21:53:07', '2026-06-09 21:53:07', 0, '实验楼');
INSERT INTO `items` VALUES (312, 32, 'FOUND', '其他', '捡到雨伞', '在教学楼捡到雨伞', NULL, '蓝色', NULL, NULL, '2026-06-06 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-06 23:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (313, 32, 'FOUND', '其他', '捡到保温杯', '在图书馆捡到保温杯', NULL, '红色', NULL, NULL, '2026-06-05 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-05 23:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (314, 32, 'FOUND', '书籍', '捡到线性代数', '在实验楼捡到线性代数', NULL, '蓝色', NULL, NULL, '2026-06-04 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-04 23:53:07', '2026-06-09 21:53:07', 0, '实验楼');
INSERT INTO `items` VALUES (315, 32, 'FOUND', '其他', '捡到钱包', '在食堂捡到钱包', NULL, '黑色', NULL, NULL, '2026-06-03 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-03 23:53:07', '2026-06-09 21:53:07', 0, '食堂');
INSERT INTO `items` VALUES (316, 32, 'FOUND', '其他', '捡到钥匙串', '在宿舍捡到钥匙串', NULL, '', NULL, NULL, '2026-06-02 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-02 23:53:07', '2026-06-09 21:53:07', 0, '宿舍');
INSERT INTO `items` VALUES (317, 32, 'FOUND', '其他', '捡到书包', '在操场捡到书包', NULL, '黑色', NULL, NULL, '2026-06-01 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-06-01 23:53:07', '2026-06-09 21:53:07', 0, '操场');
INSERT INTO `items` VALUES (318, 32, 'FOUND', '其他', '捡到眼镜', '在图书馆捡到眼镜', NULL, '银色', NULL, NULL, '2026-05-31 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-31 23:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (319, 32, 'FOUND', '其他', '捡到笔记本', '在教学楼捡到笔记本', NULL, '蓝色', NULL, NULL, '2026-05-30 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-30 23:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (320, 32, 'FOUND', '其他', '捡到运动水杯', '在体育馆捡到运动水杯', NULL, '蓝色', NULL, NULL, '2026-05-29 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-29 23:53:07', '2026-06-09 21:53:07', 0, '体育馆');
INSERT INTO `items` VALUES (321, 32, 'FOUND', '其他', '捡到耳机', '在食堂捡到耳机', NULL, '黑色', NULL, NULL, '2026-05-28 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-28 23:53:07', '2026-06-09 21:53:07', 0, '食堂');
INSERT INTO `items` VALUES (322, 32, 'FOUND', '书籍', '捡到计算机基础', '在图书馆捡到计算机基础', NULL, '绿色', NULL, NULL, '2026-05-27 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-27 23:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (323, 32, 'FOUND', '其他', '捡到U盘', '在实验楼捡到U盘', NULL, '黑色', NULL, NULL, '2026-05-26 23:53:07', NULL, NULL, 'APPROVED', 0, NULL, NULL, '2026-05-26 23:53:07', '2026-06-09 21:53:07', 0, '实验楼');
INSERT INTO `items` VALUES (324, 34, 'LOST', '电子产品', '丢失三星手机', '丢失三星手机，正在等待审核', NULL, '黑色', NULL, '2026-06-09 20:53:07', NULL, NULL, NULL, 'PENDING', 1, NULL, NULL, '2026-06-09 20:53:07', '2026-06-09 22:28:29', 0, '教学楼');
INSERT INTO `items` VALUES (325, 32, 'FOUND', '证件', '捡到银行卡', '捡到银行卡，正在等待审核', '', '', NULL, NULL, '2026-06-09 19:53:07', NULL, '1243433', 'PENDING', 16, NULL, NULL, '2026-06-09 19:53:07', '2026-06-09 23:04:51', 0, '图书馆');
INSERT INTO `items` VALUES (326, 34, 'LOST', '其他', '丢失计算器', '丢失计算器，正在等待审核', NULL, '', NULL, '2026-06-09 18:53:07', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 18:53:07', '2026-06-09 21:53:07', 0, '实验楼');
INSERT INTO `items` VALUES (327, 32, 'FOUND', '电子产品', '捡到蓝牙耳机', '捡到蓝牙耳机，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 17:53:07', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 17:53:07', '2026-06-09 21:53:07', 0, '体育馆');
INSERT INTO `items` VALUES (328, 34, 'LOST', '书籍', '丢失数据结构', '丢失数据结构，正在等待审核', NULL, '', NULL, '2026-06-09 16:53:07', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 16:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (329, 32, 'FOUND', '其他', '捡到饭盒', '捡到饭盒，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 15:53:07', NULL, NULL, 'PENDING', 1, NULL, NULL, '2026-06-09 15:53:07', '2026-06-09 22:14:08', 0, '食堂');
INSERT INTO `items` VALUES (330, 34, 'LOST', '电子产品', '丢失OPPO手机', '丢失OPPO手机，正在等待审核', NULL, '绿色', NULL, '2026-06-09 14:53:07', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 14:53:07', '2026-06-09 21:53:07', 0, '教学楼');
INSERT INTO `items` VALUES (331, 32, 'FOUND', '证件', '捡到校园卡', '捡到校园卡，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 13:53:07', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 13:53:07', '2026-06-09 21:53:07', 0, '操场');
INSERT INTO `items` VALUES (332, 34, 'LOST', '其他', '丢失羽毛球拍', '丢失羽毛球拍，正在等待审核', NULL, '', NULL, '2026-06-09 12:53:07', NULL, NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 12:53:07', '2026-06-09 21:53:07', 0, '体育馆');
INSERT INTO `items` VALUES (333, 32, 'FOUND', '电子产品', '捡到小米手环', '捡到小米手环，正在等待审核', NULL, '', NULL, NULL, '2026-06-09 11:53:07', NULL, NULL, 'PENDING', 0, NULL, NULL, '2026-06-09 11:53:07', '2026-06-09 21:53:07', 0, '图书馆');
INSERT INTO `items` VALUES (335, 32, 'LOST', '其他', '测试物品', '这是一个测试，用来验证功能是否正常', 'wj', '黑色', NULL, '2026-06-10 12:19:26', NULL, NULL, 'qq:3123213123', 'PENDING', 1, NULL, NULL, '2026-06-10 12:19:40', '2026-06-10 12:19:42', 0, '宿舍');

-- ----------------------------
-- Table structure for locations
-- ----------------------------
DROP TABLE IF EXISTS `locations`;
CREATE TABLE `locations`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '浣嶇疆ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '浣嶇疆鍚嶇О(濡?A鏁欏?妤?',
  `building` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鎵?睘寤虹瓚',
  `floor` int NULL DEFAULT NULL COMMENT '妤煎眰',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '浣嶇疆鎻忚堪',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '浣嶇疆鍖哄煙琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of locations
-- ----------------------------
INSERT INTO `locations` VALUES (41, 'A教学楼一层大厅', 'A教学楼', 1, '主要入口和休息区', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (42, 'A教学楼三层301教室', 'A教学楼', 3, '301教室门口', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (43, '图书馆一楼自习室', '图书馆', 1, '自习区入口', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (44, '图书馆二楼阅览室', '图书馆', 2, '期刊阅览室', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (45, '食堂一楼入口', '食堂', 1, '食堂正门', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (46, '食堂二楼餐厅', '食堂', 2, '快餐区', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (47, '操场看台下方', '操场', 0, '体育器材室', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (48, '学生宿舍5号楼', '学生宿舍', 1, '宿舍楼大厅', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (49, '实验楼A座一层', '实验楼A座', 1, '实验室走廊', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);
INSERT INTO `locations` VALUES (50, '行政楼一楼服务大厅', '行政楼', 1, '办事大厅', '2026-05-27 19:44:28', '2026-05-27 19:44:28', 0);

-- ----------------------------
-- Table structure for matches
-- ----------------------------
DROP TABLE IF EXISTS `matches`;
CREATE TABLE `matches`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `lost_item_id` bigint NOT NULL,
  `found_item_id` bigint NOT NULL,
  `score` decimal(5, 2) NOT NULL,
  `match_type` enum('SERIAL_EXACT','WEIGHTED','NONE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','CONFIRMED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `is_read` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_item_pair`(`lost_item_id` ASC, `found_item_id` ASC) USING BTREE,
  INDEX `idx_lost_item_id`(`lost_item_id` ASC) USING BTREE,
  INDEX `idx_found_item_id`(`found_item_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `matches_ibfk_1` FOREIGN KEY (`lost_item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `matches_ibfk_2` FOREIGN KEY (`found_item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 517 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of matches
-- ----------------------------
INSERT INTO `matches` VALUES (2, 25, 28, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-05 21:35:30', '2026-06-05 21:35:30');
INSERT INTO `matches` VALUES (3, 26, 29, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-05 21:35:31', '2026-06-05 21:35:31');
INSERT INTO `matches` VALUES (389, 186, 187, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:49:53', '2026-06-09 21:49:53');
INSERT INTO `matches` VALUES (390, 188, 189, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:49:55', '2026-06-09 21:49:55');
INSERT INTO `matches` VALUES (391, 190, 191, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:49:56', '2026-06-09 21:49:56');
INSERT INTO `matches` VALUES (392, 192, 193, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:49:56', '2026-06-09 21:49:56');
INSERT INTO `matches` VALUES (393, 194, 195, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:49:57', '2026-06-09 21:49:57');
INSERT INTO `matches` VALUES (394, 196, 197, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:49:58', '2026-06-09 21:49:58');
INSERT INTO `matches` VALUES (395, 198, 199, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:49:59', '2026-06-09 21:49:59');
INSERT INTO `matches` VALUES (396, 200, 201, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:50:00', '2026-06-09 21:50:00');
INSERT INTO `matches` VALUES (397, 202, 203, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:50:01', '2026-06-09 21:50:01');
INSERT INTO `matches` VALUES (398, 204, 205, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:50:03', '2026-06-09 21:50:03');
INSERT INTO `matches` VALUES (399, 206, 207, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:50:04', '2026-06-09 21:50:04');
INSERT INTO `matches` VALUES (400, 208, 209, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:50:05', '2026-06-09 21:50:05');
INSERT INTO `matches` VALUES (401, 210, 211, 0.84, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:09', '2026-06-09 21:50:09');
INSERT INTO `matches` VALUES (402, 210, 217, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:10', '2026-06-09 21:50:10');
INSERT INTO `matches` VALUES (403, 210, 219, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:11', '2026-06-09 21:50:11');
INSERT INTO `matches` VALUES (404, 210, 221, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:14', '2026-06-09 21:50:14');
INSERT INTO `matches` VALUES (405, 216, 211, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:15', '2026-06-09 21:50:15');
INSERT INTO `matches` VALUES (406, 218, 211, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:15', '2026-06-09 21:50:15');
INSERT INTO `matches` VALUES (407, 220, 211, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:16', '2026-06-09 21:50:16');
INSERT INTO `matches` VALUES (408, 212, 213, 0.89, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:17', '2026-06-09 21:50:17');
INSERT INTO `matches` VALUES (409, 214, 215, 0.88, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:18', '2026-06-09 21:50:18');
INSERT INTO `matches` VALUES (410, 216, 217, 0.84, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:19', '2026-06-09 21:50:19');
INSERT INTO `matches` VALUES (411, 216, 223, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:20', '2026-06-09 21:50:20');
INSERT INTO `matches` VALUES (412, 222, 217, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:21', '2026-06-09 21:50:21');
INSERT INTO `matches` VALUES (413, 218, 219, 0.84, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:22', '2026-06-09 21:50:22');
INSERT INTO `matches` VALUES (414, 218, 223, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:23', '2026-06-09 21:50:23');
INSERT INTO `matches` VALUES (415, 222, 219, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:24', '2026-06-09 21:50:24');
INSERT INTO `matches` VALUES (416, 220, 221, 0.85, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:24', '2026-06-09 21:50:24');
INSERT INTO `matches` VALUES (417, 220, 223, 0.70, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:27', '2026-06-09 21:50:27');
INSERT INTO `matches` VALUES (418, 222, 221, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:28', '2026-06-09 21:50:28');
INSERT INTO `matches` VALUES (419, 222, 223, 0.83, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:29', '2026-06-09 21:50:29');
INSERT INTO `matches` VALUES (420, 224, 225, 0.89, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:32', '2026-06-09 21:50:32');
INSERT INTO `matches` VALUES (421, 226, 238, 0.72, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:33', '2026-06-09 21:50:33');
INSERT INTO `matches` VALUES (422, 226, 241, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:34', '2026-06-09 21:50:34');
INSERT INTO `matches` VALUES (423, 226, 243, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:35', '2026-06-09 21:50:35');
INSERT INTO `matches` VALUES (424, 226, 239, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:35', '2026-06-09 21:50:35');
INSERT INTO `matches` VALUES (425, 226, 247, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:38', '2026-06-09 21:50:38');
INSERT INTO `matches` VALUES (426, 227, 239, 0.77, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:39', '2026-06-09 21:50:39');
INSERT INTO `matches` VALUES (427, 227, 244, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:40', '2026-06-09 21:50:40');
INSERT INTO `matches` VALUES (428, 228, 248, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:42', '2026-06-09 21:50:42');
INSERT INTO `matches` VALUES (429, 229, 241, 0.74, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:45', '2026-06-09 21:50:45');
INSERT INTO `matches` VALUES (430, 229, 242, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:45', '2026-06-09 21:50:45');
INSERT INTO `matches` VALUES (431, 230, 242, 0.80, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:46', '2026-06-09 21:50:46');
INSERT INTO `matches` VALUES (432, 230, 243, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:47', '2026-06-09 21:50:47');
INSERT INTO `matches` VALUES (433, 231, 243, 0.74, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:48', '2026-06-09 21:50:48');
INSERT INTO `matches` VALUES (434, 231, 245, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:49', '2026-06-09 21:50:49');
INSERT INTO `matches` VALUES (435, 231, 246, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:50', '2026-06-09 21:50:50');
INSERT INTO `matches` VALUES (436, 231, 238, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:51', '2026-06-09 21:50:51');
INSERT INTO `matches` VALUES (437, 231, 244, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:52', '2026-06-09 21:50:52');
INSERT INTO `matches` VALUES (438, 232, 244, 0.75, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:53', '2026-06-09 21:50:53');
INSERT INTO `matches` VALUES (439, 232, 243, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:54', '2026-06-09 21:50:54');
INSERT INTO `matches` VALUES (440, 232, 247, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:55', '2026-06-09 21:50:55');
INSERT INTO `matches` VALUES (441, 232, 241, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:56', '2026-06-09 21:50:56');
INSERT INTO `matches` VALUES (442, 232, 249, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:56', '2026-06-09 21:50:56');
INSERT INTO `matches` VALUES (443, 232, 245, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:57', '2026-06-09 21:50:57');
INSERT INTO `matches` VALUES (444, 233, 245, 0.77, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:58', '2026-06-09 21:50:58');
INSERT INTO `matches` VALUES (445, 233, 239, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:50:59', '2026-06-09 21:50:59');
INSERT INTO `matches` VALUES (446, 233, 246, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:51:00', '2026-06-09 21:51:00');
INSERT INTO `matches` VALUES (447, 234, 246, 0.78, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:51:01', '2026-06-09 21:51:01');
INSERT INTO `matches` VALUES (448, 234, 247, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:51:05', '2026-06-09 21:51:05');
INSERT INTO `matches` VALUES (449, 235, 247, 0.72, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:51:06', '2026-06-09 21:51:06');
INSERT INTO `matches` VALUES (450, 236, 240, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:51:07', '2026-06-09 21:51:07');
INSERT INTO `matches` VALUES (451, 237, 249, 0.74, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:51:08', '2026-06-09 21:51:08');
INSERT INTO `matches` VALUES (452, 237, 244, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:51:09', '2026-06-09 21:51:09');
INSERT INTO `matches` VALUES (453, 260, 261, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:07', '2026-06-09 21:53:07');
INSERT INTO `matches` VALUES (454, 262, 263, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:11', '2026-06-09 21:53:11');
INSERT INTO `matches` VALUES (455, 264, 265, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:12', '2026-06-09 21:53:12');
INSERT INTO `matches` VALUES (456, 266, 267, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:13', '2026-06-09 21:53:13');
INSERT INTO `matches` VALUES (457, 268, 269, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:14', '2026-06-09 21:53:14');
INSERT INTO `matches` VALUES (458, 270, 271, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:15', '2026-06-09 21:53:15');
INSERT INTO `matches` VALUES (459, 272, 273, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:16', '2026-06-09 21:53:16');
INSERT INTO `matches` VALUES (460, 274, 275, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:16', '2026-06-09 21:53:16');
INSERT INTO `matches` VALUES (461, 276, 277, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:17', '2026-06-09 21:53:17');
INSERT INTO `matches` VALUES (462, 278, 279, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:18', '2026-06-09 21:53:18');
INSERT INTO `matches` VALUES (463, 280, 281, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:21', '2026-06-09 21:53:21');
INSERT INTO `matches` VALUES (464, 282, 283, 1.00, 'SERIAL_EXACT', 'CONFIRMED', 0, '2026-06-09 21:53:22', '2026-06-09 21:53:22');
INSERT INTO `matches` VALUES (465, 284, 285, 0.84, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:23', '2026-06-09 21:53:23');
INSERT INTO `matches` VALUES (466, 284, 291, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:24', '2026-06-09 21:53:24');
INSERT INTO `matches` VALUES (467, 284, 293, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:25', '2026-06-09 21:53:25');
INSERT INTO `matches` VALUES (468, 284, 295, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:26', '2026-06-09 21:53:26');
INSERT INTO `matches` VALUES (469, 290, 285, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:27', '2026-06-09 21:53:27');
INSERT INTO `matches` VALUES (470, 292, 285, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:28', '2026-06-09 21:53:28');
INSERT INTO `matches` VALUES (471, 294, 285, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:29', '2026-06-09 21:53:29');
INSERT INTO `matches` VALUES (472, 286, 287, 0.89, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:30', '2026-06-09 21:53:30');
INSERT INTO `matches` VALUES (473, 288, 289, 0.88, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:31', '2026-06-09 21:53:31');
INSERT INTO `matches` VALUES (474, 290, 291, 0.84, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:31', '2026-06-09 21:53:31');
INSERT INTO `matches` VALUES (475, 290, 297, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:32', '2026-06-09 21:53:32');
INSERT INTO `matches` VALUES (476, 296, 291, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:37', '2026-06-09 21:53:37');
INSERT INTO `matches` VALUES (477, 292, 293, 0.84, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:38', '2026-06-09 21:53:38');
INSERT INTO `matches` VALUES (478, 292, 297, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:39', '2026-06-09 21:53:39');
INSERT INTO `matches` VALUES (479, 296, 293, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:39', '2026-06-09 21:53:39');
INSERT INTO `matches` VALUES (480, 294, 295, 0.85, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:42', '2026-06-09 21:53:42');
INSERT INTO `matches` VALUES (481, 294, 297, 0.70, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:42', '2026-06-09 21:53:42');
INSERT INTO `matches` VALUES (482, 296, 295, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:43', '2026-06-09 21:53:43');
INSERT INTO `matches` VALUES (483, 296, 297, 0.83, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:46', '2026-06-09 21:53:46');
INSERT INTO `matches` VALUES (484, 298, 299, 0.89, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:48', '2026-06-09 21:53:48');
INSERT INTO `matches` VALUES (485, 300, 312, 0.72, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:49', '2026-06-09 21:53:49');
INSERT INTO `matches` VALUES (486, 300, 315, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:50', '2026-06-09 21:53:50');
INSERT INTO `matches` VALUES (487, 300, 317, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:51', '2026-06-09 21:53:51');
INSERT INTO `matches` VALUES (488, 300, 313, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:51', '2026-06-09 21:53:51');
INSERT INTO `matches` VALUES (489, 300, 321, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:52', '2026-06-09 21:53:52');
INSERT INTO `matches` VALUES (490, 301, 313, 0.77, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:53', '2026-06-09 21:53:53');
INSERT INTO `matches` VALUES (491, 301, 318, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:54', '2026-06-09 21:53:54');
INSERT INTO `matches` VALUES (492, 302, 322, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:55', '2026-06-09 21:53:55');
INSERT INTO `matches` VALUES (493, 303, 315, 0.74, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:56', '2026-06-09 21:53:56');
INSERT INTO `matches` VALUES (494, 303, 316, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:58', '2026-06-09 21:53:58');
INSERT INTO `matches` VALUES (495, 304, 316, 0.80, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:53:59', '2026-06-09 21:53:59');
INSERT INTO `matches` VALUES (496, 304, 317, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:02', '2026-06-09 21:54:02');
INSERT INTO `matches` VALUES (497, 305, 317, 0.74, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:03', '2026-06-09 21:54:03');
INSERT INTO `matches` VALUES (498, 305, 319, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:04', '2026-06-09 21:54:04');
INSERT INTO `matches` VALUES (499, 305, 320, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:05', '2026-06-09 21:54:05');
INSERT INTO `matches` VALUES (500, 305, 312, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:06', '2026-06-09 21:54:06');
INSERT INTO `matches` VALUES (501, 305, 318, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:06', '2026-06-09 21:54:06');
INSERT INTO `matches` VALUES (502, 306, 318, 0.75, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:10', '2026-06-09 21:54:10');
INSERT INTO `matches` VALUES (503, 306, 317, 0.69, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:11', '2026-06-09 21:54:11');
INSERT INTO `matches` VALUES (504, 306, 321, 0.68, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:12', '2026-06-09 21:54:12');
INSERT INTO `matches` VALUES (505, 306, 315, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:13', '2026-06-09 21:54:13');
INSERT INTO `matches` VALUES (506, 306, 323, 0.67, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:14', '2026-06-09 21:54:14');
INSERT INTO `matches` VALUES (507, 306, 319, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:15', '2026-06-09 21:54:15');
INSERT INTO `matches` VALUES (508, 307, 319, 0.77, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:16', '2026-06-09 21:54:16');
INSERT INTO `matches` VALUES (509, 307, 313, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:16', '2026-06-09 21:54:16');
INSERT INTO `matches` VALUES (510, 307, 320, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:17', '2026-06-09 21:54:17');
INSERT INTO `matches` VALUES (511, 308, 320, 0.78, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:18', '2026-06-09 21:54:18');
INSERT INTO `matches` VALUES (512, 308, 321, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:19', '2026-06-09 21:54:19');
INSERT INTO `matches` VALUES (513, 309, 321, 0.72, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:20', '2026-06-09 21:54:20');
INSERT INTO `matches` VALUES (514, 310, 314, 0.65, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:21', '2026-06-09 21:54:21');
INSERT INTO `matches` VALUES (515, 311, 323, 0.74, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:22', '2026-06-09 21:54:22');
INSERT INTO `matches` VALUES (516, 311, 318, 0.66, 'WEIGHTED', 'PENDING', 0, '2026-06-09 21:54:23', '2026-06-09 21:54:23');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `type` enum('MATCH_FOUND','VERIFICATION_RESULT','COMPLETION_REVIEW_RESULT','SYSTEM','ITEM_PENDING','VERIFICATION_PENDING') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `related_id` bigint NULL DEFAULT NULL,
  `is_read` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1045 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (8, 35, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPad Air 4代 灰色\"找到了匹配的失物招领，请查看详情', 2, 1, '2026-06-05 21:35:30');
INSERT INTO `notifications` VALUES (9, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Air 灰色平板电脑\"找到了匹配的寻物启示，请查看详情', 2, 0, '2026-06-05 21:35:31');
INSERT INTO `notifications` VALUES (10, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 3, 0, '2026-06-05 21:35:31');
INSERT INTO `notifications` VALUES (11, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"拾取校园卡一张\"找到了匹配的寻物启示，请查看详情', 3, 1, '2026-06-05 21:35:31');
INSERT INTO `notifications` VALUES (12, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）28\"找到了匹配的失物招领，请查看详情', 4, 1, '2026-06-05 21:35:32');
INSERT INTO `notifications` VALUES (13, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Air 灰色平板电脑\"找到了匹配的寻物启示，请查看详情', 4, 0, '2026-06-05 21:35:32');
INSERT INTO `notifications` VALUES (14, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi 电子产品（黑色）#1\"找到了匹配的失物招领，请查看详情', 5, 0, '2026-06-05 21:35:33');
INSERT INTO `notifications` VALUES (15, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi 电子产品（黑色）#1\"找到了匹配的寻物启示，请查看详情', 5, 1, '2026-06-05 21:35:34');
INSERT INTO `notifications` VALUES (16, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi 电子产品（黑色）#1\"找到了匹配的失物招领，请查看详情', 6, 0, '2026-06-05 21:35:34');
INSERT INTO `notifications` VALUES (17, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi电子产品（黑色）#1\"找到了匹配的寻物启示，请查看详情', 6, 1, '2026-06-05 21:35:35');
INSERT INTO `notifications` VALUES (18, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi电子产品（黑色）#1\"找到了匹配的失物招领，请查看详情', 7, 0, '2026-06-05 21:35:35');
INSERT INTO `notifications` VALUES (19, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi 电子产品（黑色）#1\"找到了匹配的寻物启示，请查看详情', 7, 1, '2026-06-05 21:35:36');
INSERT INTO `notifications` VALUES (20, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple 证件（白色）#2\"找到了匹配的失物招领，请查看详情', 8, 0, '2026-06-05 21:35:36');
INSERT INTO `notifications` VALUES (21, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple 证件（白色）#2\"找到了匹配的寻物启示，请查看详情', 8, 1, '2026-06-05 21:35:37');
INSERT INTO `notifications` VALUES (22, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple 证件（白色）#2\"找到了匹配的失物招领，请查看详情', 9, 0, '2026-06-05 21:35:37');
INSERT INTO `notifications` VALUES (23, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple证件（白色）#2\"找到了匹配的寻物启示，请查看详情', 9, 1, '2026-06-05 21:35:38');
INSERT INTO `notifications` VALUES (24, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple证件（白色）#2\"找到了匹配的失物招领，请查看详情', 10, 0, '2026-06-05 21:35:38');
INSERT INTO `notifications` VALUES (25, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple 证件（白色）#2\"找到了匹配的寻物启示，请查看详情', 10, 1, '2026-06-05 21:35:39');
INSERT INTO `notifications` VALUES (26, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei 书籍（灰色）#3\"找到了匹配的失物招领，请查看详情', 11, 0, '2026-06-05 21:35:39');
INSERT INTO `notifications` VALUES (27, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei 书籍（灰色）#3\"找到了匹配的寻物启示，请查看详情', 11, 1, '2026-06-05 21:35:40');
INSERT INTO `notifications` VALUES (28, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei 书籍（灰色）#3\"找到了匹配的失物招领，请查看详情', 12, 0, '2026-06-05 21:35:40');
INSERT INTO `notifications` VALUES (29, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei书籍（灰色）#3\"找到了匹配的寻物启示，请查看详情', 12, 1, '2026-06-05 21:35:41');
INSERT INTO `notifications` VALUES (30, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei书籍（灰色）#3\"找到了匹配的失物招领，请查看详情', 13, 0, '2026-06-05 21:35:41');
INSERT INTO `notifications` VALUES (31, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei 书籍（灰色）#3\"找到了匹配的寻物启示，请查看详情', 13, 1, '2026-06-05 21:35:41');
INSERT INTO `notifications` VALUES (32, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO 衣物（蓝色）#4\"找到了匹配的失物招领，请查看详情', 14, 0, '2026-06-05 21:35:42');
INSERT INTO `notifications` VALUES (33, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO 衣物（蓝色）#4\"找到了匹配的寻物启示，请查看详情', 14, 1, '2026-06-05 21:35:42');
INSERT INTO `notifications` VALUES (34, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO 衣物（蓝色）#4\"找到了匹配的失物招领，请查看详情', 15, 0, '2026-06-05 21:35:43');
INSERT INTO `notifications` VALUES (35, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO衣物（蓝色）#4\"找到了匹配的寻物启示，请查看详情', 15, 1, '2026-06-05 21:35:44');
INSERT INTO `notifications` VALUES (36, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO衣物（蓝色）#4\"找到了匹配的失物招领，请查看详情', 16, 0, '2026-06-05 21:35:44');
INSERT INTO `notifications` VALUES (37, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO 衣物（蓝色）#4\"找到了匹配的寻物启示，请查看详情', 16, 1, '2026-06-05 21:35:44');
INSERT INTO `notifications` VALUES (38, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo 饰品（红色）#5\"找到了匹配的失物招领，请查看详情', 17, 0, '2026-06-05 21:35:45');
INSERT INTO `notifications` VALUES (39, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo 饰品（红色）#5\"找到了匹配的寻物启示，请查看详情', 17, 1, '2026-06-05 21:35:45');
INSERT INTO `notifications` VALUES (40, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo 饰品（红色）#5\"找到了匹配的失物招领，请查看详情', 18, 0, '2026-06-05 21:35:46');
INSERT INTO `notifications` VALUES (41, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo电子产品（黑色）#5\"找到了匹配的寻物启示，请查看详情', 18, 1, '2026-06-05 21:35:46');
INSERT INTO `notifications` VALUES (42, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo电子产品（黑色）#5\"找到了匹配的失物招领，请查看详情', 19, 0, '2026-06-05 21:35:47');
INSERT INTO `notifications` VALUES (43, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo 饰品（红色）#5\"找到了匹配的寻物启示，请查看详情', 19, 1, '2026-06-05 21:35:47');
INSERT INTO `notifications` VALUES (44, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo 文具（绿色）#6\"找到了匹配的失物招领，请查看详情', 20, 0, '2026-06-05 21:35:48');
INSERT INTO `notifications` VALUES (45, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo 文具（绿色）#6\"找到了匹配的寻物启示，请查看详情', 20, 1, '2026-06-05 21:35:48');
INSERT INTO `notifications` VALUES (46, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo 文具（绿色）#6\"找到了匹配的失物招领，请查看详情', 21, 0, '2026-06-05 21:35:49');
INSERT INTO `notifications` VALUES (47, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo证件（白色）#6\"找到了匹配的寻物启示，请查看详情', 21, 1, '2026-06-05 21:35:49');
INSERT INTO `notifications` VALUES (48, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo证件（白色）#6\"找到了匹配的失物招领，请查看详情', 22, 0, '2026-06-05 21:35:50');
INSERT INTO `notifications` VALUES (49, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo 文具（绿色）#6\"找到了匹配的寻物启示，请查看详情', 22, 1, '2026-06-05 21:35:50');
INSERT INTO `notifications` VALUES (50, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Nike 钥匙（黑色）#7\"找到了匹配的失物招领，请查看详情', 23, 0, '2026-06-05 21:35:51');
INSERT INTO `notifications` VALUES (51, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Nike 钥匙（黑色）#7\"找到了匹配的寻物启示，请查看详情', 23, 1, '2026-06-05 21:35:51');
INSERT INTO `notifications` VALUES (52, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Nike 钥匙（黑色）#7\"找到了匹配的失物招领，请查看详情', 24, 0, '2026-06-05 21:35:51');
INSERT INTO `notifications` VALUES (53, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi书籍（灰色）#7\"找到了匹配的寻物启示，请查看详情', 24, 1, '2026-06-05 21:35:52');
INSERT INTO `notifications` VALUES (54, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi书籍（灰色）#7\"找到了匹配的失物招领，请查看详情', 25, 0, '2026-06-05 21:35:52');
INSERT INTO `notifications` VALUES (55, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Nike 钥匙（黑色）#7\"找到了匹配的寻物启示，请查看详情', 25, 1, '2026-06-05 21:35:53');
INSERT INTO `notifications` VALUES (56, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Adidas 其他（白色）#8\"找到了匹配的失物招领，请查看详情', 26, 0, '2026-06-05 21:35:53');
INSERT INTO `notifications` VALUES (57, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Adidas 其他（白色）#8\"找到了匹配的寻物启示，请查看详情', 26, 1, '2026-06-05 21:35:54');
INSERT INTO `notifications` VALUES (58, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Adidas 其他（白色）#8\"找到了匹配的失物招领，请查看详情', 27, 0, '2026-06-05 21:35:54');
INSERT INTO `notifications` VALUES (59, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple衣物（蓝色）#8\"找到了匹配的寻物启示，请查看详情', 27, 1, '2026-06-05 21:35:55');
INSERT INTO `notifications` VALUES (60, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple衣物（蓝色）#8\"找到了匹配的失物招领，请查看详情', 28, 0, '2026-06-05 21:35:56');
INSERT INTO `notifications` VALUES (61, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Adidas 其他（白色）#8\"找到了匹配的寻物启示，请查看详情', 28, 1, '2026-06-05 21:35:56');
INSERT INTO `notifications` VALUES (62, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 29, 1, '2026-06-05 21:35:56');
INSERT INTO `notifications` VALUES (63, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 29, 1, '2026-06-05 21:35:57');
INSERT INTO `notifications` VALUES (64, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 30, 0, '2026-06-05 21:35:58');
INSERT INTO `notifications` VALUES (65, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 30, 1, '2026-06-05 21:35:58');
INSERT INTO `notifications` VALUES (66, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 31, 1, '2026-06-05 21:35:58');
INSERT INTO `notifications` VALUES (67, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 31, 1, '2026-06-05 21:35:59');
INSERT INTO `notifications` VALUES (68, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 32, 1, '2026-06-05 21:35:59');
INSERT INTO `notifications` VALUES (69, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 32, 1, '2026-06-05 21:36:00');
INSERT INTO `notifications` VALUES (70, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 33, 1, '2026-06-05 21:36:00');
INSERT INTO `notifications` VALUES (71, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 33, 1, '2026-06-05 21:36:01');
INSERT INTO `notifications` VALUES (72, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 34, 1, '2026-06-05 21:36:01');
INSERT INTO `notifications` VALUES (73, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 34, 1, '2026-06-05 21:36:02');
INSERT INTO `notifications` VALUES (74, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 35, 1, '2026-06-05 21:36:02');
INSERT INTO `notifications` VALUES (75, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 35, 1, '2026-06-05 21:36:03');
INSERT INTO `notifications` VALUES (76, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 36, 1, '2026-06-05 21:36:03');
INSERT INTO `notifications` VALUES (77, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 36, 0, '2026-06-05 21:36:04');
INSERT INTO `notifications` VALUES (78, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 37, 1, '2026-06-05 21:36:04');
INSERT INTO `notifications` VALUES (79, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 37, 1, '2026-06-05 21:36:04');
INSERT INTO `notifications` VALUES (80, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 38, 1, '2026-06-05 21:36:05');
INSERT INTO `notifications` VALUES (81, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 38, 0, '2026-06-05 21:36:05');
INSERT INTO `notifications` VALUES (82, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 39, 1, '2026-06-05 21:36:06');
INSERT INTO `notifications` VALUES (83, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 39, 1, '2026-06-05 21:36:06');
INSERT INTO `notifications` VALUES (84, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 40, 1, '2026-06-05 21:36:07');
INSERT INTO `notifications` VALUES (85, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 40, 0, '2026-06-05 21:36:07');
INSERT INTO `notifications` VALUES (86, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 41, 1, '2026-06-05 21:36:08');
INSERT INTO `notifications` VALUES (87, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 41, 0, '2026-06-05 21:36:08');
INSERT INTO `notifications` VALUES (88, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）10\"找到了匹配的失物招领，请查看详情', 42, 1, '2026-06-05 21:36:08');
INSERT INTO `notifications` VALUES (89, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 42, 0, '2026-06-05 21:36:09');
INSERT INTO `notifications` VALUES (90, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）24\"找到了匹配的失物招领，请查看详情', 43, 0, '2026-06-05 21:36:09');
INSERT INTO `notifications` VALUES (91, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 43, 0, '2026-06-05 21:36:10');
INSERT INTO `notifications` VALUES (92, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）10\"找到了匹配的失物招领，请查看详情', 44, 1, '2026-06-05 21:36:10');
INSERT INTO `notifications` VALUES (93, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 44, 0, '2026-06-05 21:36:11');
INSERT INTO `notifications` VALUES (94, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）24\"找到了匹配的失物招领，请查看详情', 45, 0, '2026-06-05 21:36:12');
INSERT INTO `notifications` VALUES (95, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 45, 0, '2026-06-05 21:36:12');
INSERT INTO `notifications` VALUES (96, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（灰色）52\"找到了匹配的失物招领，请查看详情', 46, 1, '2026-06-05 21:36:13');
INSERT INTO `notifications` VALUES (97, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 46, 0, '2026-06-05 21:36:13');
INSERT INTO `notifications` VALUES (98, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 47, 1, '2026-06-05 21:36:14');
INSERT INTO `notifications` VALUES (99, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 47, 0, '2026-06-05 21:36:14');
INSERT INTO `notifications` VALUES (100, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 48, 1, '2026-06-05 21:36:14');
INSERT INTO `notifications` VALUES (101, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（绿色）11\"找到了匹配的寻物启示，请查看详情', 48, 1, '2026-06-05 21:36:15');
INSERT INTO `notifications` VALUES (102, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 49, 1, '2026-06-05 21:36:15');
INSERT INTO `notifications` VALUES (103, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）25\"找到了匹配的寻物启示，请查看详情', 49, 1, '2026-06-05 21:36:16');
INSERT INTO `notifications` VALUES (104, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 50, 1, '2026-06-05 21:36:16');
INSERT INTO `notifications` VALUES (105, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）11\"找到了匹配的寻物启示，请查看详情', 50, 1, '2026-06-05 21:36:17');
INSERT INTO `notifications` VALUES (106, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 51, 1, '2026-06-05 21:36:17');
INSERT INTO `notifications` VALUES (107, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（黑色）25\"找到了匹配的寻物启示，请查看详情', 51, 1, '2026-06-05 21:36:18');
INSERT INTO `notifications` VALUES (108, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 52, 1, '2026-06-05 21:36:18');
INSERT INTO `notifications` VALUES (109, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（蓝色）53\"找到了匹配的寻物启示，请查看详情', 52, 1, '2026-06-05 21:36:18');
INSERT INTO `notifications` VALUES (110, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）12\"找到了匹配的失物招领，请查看详情', 53, 0, '2026-06-05 21:36:19');
INSERT INTO `notifications` VALUES (111, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（绿色）5\"找到了匹配的寻物启示，请查看详情', 53, 1, '2026-06-05 21:36:19');
INSERT INTO `notifications` VALUES (112, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）26\"找到了匹配的失物招领，请查看详情', 54, 1, '2026-06-05 21:36:20');
INSERT INTO `notifications` VALUES (113, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（绿色）5\"找到了匹配的寻物启示，请查看详情', 54, 1, '2026-06-05 21:36:20');
INSERT INTO `notifications` VALUES (114, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）12\"找到了匹配的失物招领，请查看详情', 55, 0, '2026-06-05 21:36:21');
INSERT INTO `notifications` VALUES (115, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（绿色）5\"找到了匹配的寻物启示，请查看详情', 55, 1, '2026-06-05 21:36:21');
INSERT INTO `notifications` VALUES (116, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（白色）26\"找到了匹配的失物招领，请查看详情', 56, 1, '2026-06-05 21:36:21');
INSERT INTO `notifications` VALUES (117, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（绿色）5\"找到了匹配的寻物启示，请查看详情', 56, 1, '2026-06-05 21:36:22');
INSERT INTO `notifications` VALUES (118, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）40\"找到了匹配的失物招领，请查看详情', 57, 1, '2026-06-05 21:36:22');
INSERT INTO `notifications` VALUES (119, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（绿色）5\"找到了匹配的寻物启示，请查看详情', 57, 1, '2026-06-05 21:36:23');
INSERT INTO `notifications` VALUES (120, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（红色）54\"找到了匹配的失物招领，请查看详情', 58, 0, '2026-06-05 21:36:23');
INSERT INTO `notifications` VALUES (121, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（绿色）5\"找到了匹配的寻物启示，请查看详情', 58, 1, '2026-06-05 21:36:24');
INSERT INTO `notifications` VALUES (122, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）6\"找到了匹配的失物招领，请查看详情', 59, 0, '2026-06-05 21:36:24');
INSERT INTO `notifications` VALUES (123, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（黑色）55\"找到了匹配的寻物启示，请查看详情', 59, 1, '2026-06-05 21:36:25');
INSERT INTO `notifications` VALUES (124, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）6\"找到了匹配的失物招领，请查看详情', 60, 0, '2026-06-05 21:36:25');
INSERT INTO `notifications` VALUES (125, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）13\"找到了匹配的寻物启示，请查看详情', 60, 1, '2026-06-05 21:36:26');
INSERT INTO `notifications` VALUES (126, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）6\"找到了匹配的失物招领，请查看详情', 61, 0, '2026-06-05 21:36:26');
INSERT INTO `notifications` VALUES (127, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（灰色）27\"找到了匹配的寻物启示，请查看详情', 61, 0, '2026-06-05 21:36:27');
INSERT INTO `notifications` VALUES (128, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）6\"找到了匹配的失物招领，请查看详情', 62, 0, '2026-06-05 21:36:27');
INSERT INTO `notifications` VALUES (129, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）41\"找到了匹配的寻物启示，请查看详情', 62, 1, '2026-06-05 21:36:28');
INSERT INTO `notifications` VALUES (130, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）6\"找到了匹配的失物招领，请查看详情', 63, 0, '2026-06-05 21:36:28');
INSERT INTO `notifications` VALUES (131, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）13\"找到了匹配的寻物启示，请查看详情', 63, 1, '2026-06-05 21:36:29');
INSERT INTO `notifications` VALUES (132, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）6\"找到了匹配的失物招领，请查看详情', 64, 0, '2026-06-05 21:36:29');
INSERT INTO `notifications` VALUES (133, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）27\"找到了匹配的寻物启示，请查看详情', 64, 0, '2026-06-05 21:36:30');
INSERT INTO `notifications` VALUES (134, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）14\"找到了匹配的失物招领，请查看详情', 65, 1, '2026-06-05 21:36:30');
INSERT INTO `notifications` VALUES (135, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）7\"找到了匹配的寻物启示，请查看详情', 65, 1, '2026-06-05 21:36:30');
INSERT INTO `notifications` VALUES (136, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（白色）56\"找到了匹配的失物招领，请查看详情', 66, 1, '2026-06-05 21:36:31');
INSERT INTO `notifications` VALUES (137, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）7\"找到了匹配的寻物启示，请查看详情', 66, 1, '2026-06-05 21:36:32');
INSERT INTO `notifications` VALUES (138, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）28\"找到了匹配的失物招领，请查看详情', 67, 1, '2026-06-05 21:36:33');
INSERT INTO `notifications` VALUES (139, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）7\"找到了匹配的寻物启示，请查看详情', 67, 1, '2026-06-05 21:36:34');
INSERT INTO `notifications` VALUES (140, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）14\"找到了匹配的失物招领，请查看详情', 68, 1, '2026-06-05 21:36:35');
INSERT INTO `notifications` VALUES (141, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）7\"找到了匹配的寻物启示，请查看详情', 68, 1, '2026-06-05 21:36:36');
INSERT INTO `notifications` VALUES (142, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（蓝色）28\"找到了匹配的失物招领，请查看详情', 69, 1, '2026-06-05 21:36:36');
INSERT INTO `notifications` VALUES (143, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）7\"找到了匹配的寻物启示，请查看详情', 69, 1, '2026-06-05 21:36:37');
INSERT INTO `notifications` VALUES (144, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）42\"找到了匹配的失物招领，请查看详情', 70, 0, '2026-06-05 21:36:37');
INSERT INTO `notifications` VALUES (145, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）7\"找到了匹配的寻物启示，请查看详情', 70, 1, '2026-06-05 21:36:38');
INSERT INTO `notifications` VALUES (146, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 71, 1, '2026-06-05 21:36:38');
INSERT INTO `notifications` VALUES (147, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（灰色）57\"找到了匹配的寻物启示，请查看详情', 71, 0, '2026-06-05 21:36:39');
INSERT INTO `notifications` VALUES (148, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 72, 1, '2026-06-05 21:36:39');
INSERT INTO `notifications` VALUES (149, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）15\"找到了匹配的寻物启示，请查看详情', 72, 0, '2026-06-05 21:36:40');
INSERT INTO `notifications` VALUES (150, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 73, 1, '2026-06-05 21:36:40');
INSERT INTO `notifications` VALUES (151, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（绿色）29\"找到了匹配的寻物启示，请查看详情', 73, 1, '2026-06-05 21:36:41');
INSERT INTO `notifications` VALUES (152, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 74, 1, '2026-06-05 21:36:41');
INSERT INTO `notifications` VALUES (153, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 74, 1, '2026-06-05 21:36:42');
INSERT INTO `notifications` VALUES (154, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 75, 1, '2026-06-05 21:36:42');
INSERT INTO `notifications` VALUES (155, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（黑色）15\"找到了匹配的寻物启示，请查看详情', 75, 0, '2026-06-05 21:36:43');
INSERT INTO `notifications` VALUES (156, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 76, 1, '2026-06-05 21:36:43');
INSERT INTO `notifications` VALUES (157, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（红色）29\"找到了匹配的寻物启示，请查看详情', 76, 1, '2026-06-05 21:36:44');
INSERT INTO `notifications` VALUES (158, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）8\"找到了匹配的失物招领，请查看详情', 77, 1, '2026-06-05 21:36:44');
INSERT INTO `notifications` VALUES (159, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）43\"找到了匹配的寻物启示，请查看详情', 77, 1, '2026-06-05 21:36:45');
INSERT INTO `notifications` VALUES (160, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（蓝色）58\"找到了匹配的失物招领，请查看详情', 78, 1, '2026-06-05 21:36:45');
INSERT INTO `notifications` VALUES (161, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 78, 0, '2026-06-05 21:36:46');
INSERT INTO `notifications` VALUES (162, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）16\"找到了匹配的失物招领，请查看详情', 79, 1, '2026-06-05 21:36:46');
INSERT INTO `notifications` VALUES (163, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 79, 0, '2026-06-05 21:36:47');
INSERT INTO `notifications` VALUES (164, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 80, 0, '2026-06-05 21:36:47');
INSERT INTO `notifications` VALUES (165, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 80, 0, '2026-06-05 21:36:48');
INSERT INTO `notifications` VALUES (166, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 81, 1, '2026-06-05 21:36:48');
INSERT INTO `notifications` VALUES (167, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 81, 0, '2026-06-05 21:36:49');
INSERT INTO `notifications` VALUES (168, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（白色）16\"找到了匹配的失物招领，请查看详情', 82, 1, '2026-06-05 21:36:49');
INSERT INTO `notifications` VALUES (169, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 82, 0, '2026-06-05 21:36:50');
INSERT INTO `notifications` VALUES (170, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 83, 0, '2026-06-05 21:36:50');
INSERT INTO `notifications` VALUES (171, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 83, 0, '2026-06-05 21:36:51');
INSERT INTO `notifications` VALUES (172, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）44\"找到了匹配的失物招领，请查看详情', 84, 1, '2026-06-05 21:36:51');
INSERT INTO `notifications` VALUES (173, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）9\"找到了匹配的寻物启示，请查看详情', 84, 0, '2026-06-05 21:36:52');
INSERT INTO `notifications` VALUES (176, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）10\"找到了匹配的失物招领，请查看详情', 86, 1, '2026-06-05 21:37:21');
INSERT INTO `notifications` VALUES (177, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（红色）59\"找到了匹配的寻物启示，请查看详情', 86, 1, '2026-06-05 21:37:22');
INSERT INTO `notifications` VALUES (178, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）10\"找到了匹配的失物招领，请查看详情', 87, 1, '2026-06-05 21:37:22');
INSERT INTO `notifications` VALUES (179, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（绿色）17\"找到了匹配的寻物启示，请查看详情', 87, 1, '2026-06-05 21:37:23');
INSERT INTO `notifications` VALUES (180, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）10\"找到了匹配的失物招领，请查看详情', 88, 1, '2026-06-05 21:37:24');
INSERT INTO `notifications` VALUES (181, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 88, 0, '2026-06-05 21:37:24');
INSERT INTO `notifications` VALUES (182, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）10\"找到了匹配的失物招领，请查看详情', 89, 1, '2026-06-05 21:37:25');
INSERT INTO `notifications` VALUES (183, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（灰色）17\"找到了匹配的寻物启示，请查看详情', 89, 1, '2026-06-05 21:37:25');
INSERT INTO `notifications` VALUES (184, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）10\"找到了匹配的失物招领，请查看详情', 90, 1, '2026-06-05 21:37:26');
INSERT INTO `notifications` VALUES (185, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（白色）31\"找到了匹配的寻物启示，请查看详情', 90, 1, '2026-06-05 21:37:27');
INSERT INTO `notifications` VALUES (186, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）10\"找到了匹配的失物招领，请查看详情', 91, 1, '2026-06-05 21:37:28');
INSERT INTO `notifications` VALUES (187, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（黑色）45\"找到了匹配的寻物启示，请查看详情', 91, 0, '2026-06-05 21:37:30');
INSERT INTO `notifications` VALUES (188, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）18\"找到了匹配的失物招领，请查看详情', 92, 0, '2026-06-05 21:37:30');
INSERT INTO `notifications` VALUES (189, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（绿色）11\"找到了匹配的寻物启示，请查看详情', 92, 1, '2026-06-05 21:37:32');
INSERT INTO `notifications` VALUES (190, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 93, 1, '2026-06-05 21:37:33');
INSERT INTO `notifications` VALUES (191, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（绿色）11\"找到了匹配的寻物启示，请查看详情', 93, 1, '2026-06-05 21:37:33');
INSERT INTO `notifications` VALUES (192, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（蓝色）18\"找到了匹配的失物招领，请查看详情', 94, 0, '2026-06-05 21:37:34');
INSERT INTO `notifications` VALUES (193, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（绿色）11\"找到了匹配的寻物启示，请查看详情', 94, 1, '2026-06-05 21:37:34');
INSERT INTO `notifications` VALUES (194, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（灰色）32\"找到了匹配的失物招领，请查看详情', 95, 1, '2026-06-05 21:37:34');
INSERT INTO `notifications` VALUES (195, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（绿色）11\"找到了匹配的寻物启示，请查看详情', 95, 1, '2026-06-05 21:37:35');
INSERT INTO `notifications` VALUES (196, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（白色）46\"找到了匹配的失物招领，请查看详情', 96, 1, '2026-06-05 21:37:35');
INSERT INTO `notifications` VALUES (197, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（绿色）11\"找到了匹配的寻物启示，请查看详情', 96, 1, '2026-06-05 21:37:36');
INSERT INTO `notifications` VALUES (198, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）60\"找到了匹配的失物招领，请查看详情', 97, 0, '2026-06-05 21:37:36');
INSERT INTO `notifications` VALUES (199, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（绿色）11\"找到了匹配的寻物启示，请查看详情', 97, 1, '2026-06-05 21:37:37');
INSERT INTO `notifications` VALUES (200, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）12\"找到了匹配的失物招领，请查看详情', 98, 0, '2026-06-05 21:37:37');
INSERT INTO `notifications` VALUES (201, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（黑色）5\"找到了匹配的寻物启示，请查看详情', 98, 1, '2026-06-05 21:37:38');
INSERT INTO `notifications` VALUES (202, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）12\"找到了匹配的失物招领，请查看详情', 99, 0, '2026-06-05 21:37:38');
INSERT INTO `notifications` VALUES (203, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（红色）19\"找到了匹配的寻物启示，请查看详情', 99, 1, '2026-06-05 21:37:39');
INSERT INTO `notifications` VALUES (204, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）12\"找到了匹配的失物招领，请查看详情', 100, 0, '2026-06-05 21:37:39');
INSERT INTO `notifications` VALUES (205, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（蓝色）33\"找到了匹配的寻物启示，请查看详情', 100, 0, '2026-06-05 21:37:39');
INSERT INTO `notifications` VALUES (206, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）12\"找到了匹配的失物招领，请查看详情', 101, 0, '2026-06-05 21:37:40');
INSERT INTO `notifications` VALUES (207, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（灰色）47\"找到了匹配的寻物启示，请查看详情', 101, 1, '2026-06-05 21:37:40');
INSERT INTO `notifications` VALUES (208, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）12\"找到了匹配的失物招领，请查看详情', 102, 0, '2026-06-05 21:37:41');
INSERT INTO `notifications` VALUES (209, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（白色）19\"找到了匹配的寻物启示，请查看详情', 102, 1, '2026-06-05 21:37:41');
INSERT INTO `notifications` VALUES (210, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（灰色）20\"找到了匹配的失物招领，请查看详情', 103, 1, '2026-06-05 21:37:42');
INSERT INTO `notifications` VALUES (211, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）13\"找到了匹配的寻物启示，请查看详情', 103, 1, '2026-06-05 21:37:42');
INSERT INTO `notifications` VALUES (212, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 104, 0, '2026-06-05 21:37:43');
INSERT INTO `notifications` VALUES (213, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）13\"找到了匹配的寻物启示，请查看详情', 104, 1, '2026-06-05 21:37:43');
INSERT INTO `notifications` VALUES (214, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）20\"找到了匹配的失物招领，请查看详情', 105, 1, '2026-06-05 21:37:44');
INSERT INTO `notifications` VALUES (215, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）13\"找到了匹配的寻物启示，请查看详情', 105, 1, '2026-06-05 21:37:44');
INSERT INTO `notifications` VALUES (216, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（红色）34\"找到了匹配的失物招领，请查看详情', 106, 1, '2026-06-05 21:37:45');
INSERT INTO `notifications` VALUES (217, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）13\"找到了匹配的寻物启示，请查看详情', 106, 1, '2026-06-05 21:37:46');
INSERT INTO `notifications` VALUES (218, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（蓝色）48\"找到了匹配的失物招领，请查看详情', 107, 0, '2026-06-05 21:37:46');
INSERT INTO `notifications` VALUES (219, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）13\"找到了匹配的寻物启示，请查看详情', 107, 1, '2026-06-05 21:37:47');
INSERT INTO `notifications` VALUES (220, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）14\"找到了匹配的失物招领，请查看详情', 108, 1, '2026-06-05 21:37:47');
INSERT INTO `notifications` VALUES (221, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（灰色）7\"找到了匹配的寻物启示，请查看详情', 108, 1, '2026-06-05 21:37:47');
INSERT INTO `notifications` VALUES (222, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）14\"找到了匹配的失物招领，请查看详情', 109, 1, '2026-06-05 21:37:49');
INSERT INTO `notifications` VALUES (223, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（蓝色）21\"找到了匹配的寻物启示，请查看详情', 109, 0, '2026-06-05 21:37:49');
INSERT INTO `notifications` VALUES (224, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）14\"找到了匹配的失物招领，请查看详情', 110, 1, '2026-06-05 21:37:50');
INSERT INTO `notifications` VALUES (225, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）21\"找到了匹配的寻物启示，请查看详情', 110, 0, '2026-06-05 21:37:50');
INSERT INTO `notifications` VALUES (226, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）14\"找到了匹配的失物招领，请查看详情', 111, 1, '2026-06-05 21:37:50');
INSERT INTO `notifications` VALUES (227, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 111, 1, '2026-06-05 21:37:51');
INSERT INTO `notifications` VALUES (228, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）14\"找到了匹配的失物招领，请查看详情', 112, 1, '2026-06-05 21:37:51');
INSERT INTO `notifications` VALUES (229, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（红色）49\"找到了匹配的寻物启示，请查看详情', 112, 1, '2026-06-05 21:37:52');
INSERT INTO `notifications` VALUES (230, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 113, 1, '2026-06-05 21:37:52');
INSERT INTO `notifications` VALUES (231, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）15\"找到了匹配的寻物启示，请查看详情', 113, 0, '2026-06-05 21:37:53');
INSERT INTO `notifications` VALUES (232, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 114, 1, '2026-06-05 21:37:53');
INSERT INTO `notifications` VALUES (233, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）15\"找到了匹配的寻物启示，请查看详情', 114, 0, '2026-06-05 21:37:54');
INSERT INTO `notifications` VALUES (234, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 115, 1, '2026-06-05 21:37:54');
INSERT INTO `notifications` VALUES (235, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）15\"找到了匹配的寻物启示，请查看详情', 115, 0, '2026-06-05 21:37:55');
INSERT INTO `notifications` VALUES (236, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 116, 0, '2026-06-05 21:37:55');
INSERT INTO `notifications` VALUES (237, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）15\"找到了匹配的寻物启示，请查看详情', 116, 0, '2026-06-05 21:37:56');
INSERT INTO `notifications` VALUES (238, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 117, 1, '2026-06-05 21:37:56');
INSERT INTO `notifications` VALUES (239, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）15\"找到了匹配的寻物启示，请查看详情', 117, 0, '2026-06-05 21:37:57');
INSERT INTO `notifications` VALUES (240, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）16\"找到了匹配的失物招领，请查看详情', 118, 1, '2026-06-05 21:37:57');
INSERT INTO `notifications` VALUES (241, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 118, 0, '2026-06-05 21:37:58');
INSERT INTO `notifications` VALUES (242, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）16\"找到了匹配的失物招领，请查看详情', 119, 1, '2026-06-05 21:37:58');
INSERT INTO `notifications` VALUES (243, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 119, 1, '2026-06-05 21:37:58');
INSERT INTO `notifications` VALUES (244, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）16\"找到了匹配的失物招领，请查看详情', 120, 1, '2026-06-05 21:37:59');
INSERT INTO `notifications` VALUES (245, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 120, 1, '2026-06-05 21:38:00');
INSERT INTO `notifications` VALUES (246, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）16\"找到了匹配的失物招领，请查看详情', 121, 1, '2026-06-05 21:38:00');
INSERT INTO `notifications` VALUES (247, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 121, 1, '2026-06-05 21:38:01');
INSERT INTO `notifications` VALUES (248, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）16\"找到了匹配的失物招领，请查看详情', 122, 1, '2026-06-05 21:38:01');
INSERT INTO `notifications` VALUES (249, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 122, 0, '2026-06-05 21:38:02');
INSERT INTO `notifications` VALUES (250, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）24\"找到了匹配的失物招领，请查看详情', 123, 0, '2026-06-05 21:38:02');
INSERT INTO `notifications` VALUES (251, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（绿色）17\"找到了匹配的寻物启示，请查看详情', 123, 1, '2026-06-05 21:38:03');
INSERT INTO `notifications` VALUES (252, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）10\"找到了匹配的失物招领，请查看详情', 124, 1, '2026-06-05 21:38:03');
INSERT INTO `notifications` VALUES (253, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（绿色）17\"找到了匹配的寻物启示，请查看详情', 124, 1, '2026-06-05 21:38:06');
INSERT INTO `notifications` VALUES (254, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）24\"找到了匹配的失物招领，请查看详情', 125, 0, '2026-06-05 21:38:06');
INSERT INTO `notifications` VALUES (255, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（绿色）17\"找到了匹配的寻物启示，请查看详情', 125, 1, '2026-06-05 21:38:06');
INSERT INTO `notifications` VALUES (256, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 126, 1, '2026-06-05 21:38:07');
INSERT INTO `notifications` VALUES (257, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（绿色）17\"找到了匹配的寻物启示，请查看详情', 126, 1, '2026-06-05 21:38:07');
INSERT INTO `notifications` VALUES (258, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（灰色）52\"找到了匹配的失物招领，请查看详情', 127, 1, '2026-06-05 21:38:08');
INSERT INTO `notifications` VALUES (259, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（绿色）17\"找到了匹配的寻物启示，请查看详情', 127, 1, '2026-06-05 21:38:08');
INSERT INTO `notifications` VALUES (260, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）18\"找到了匹配的失物招领，请查看详情', 128, 0, '2026-06-05 21:38:09');
INSERT INTO `notifications` VALUES (261, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（黑色）25\"找到了匹配的寻物启示，请查看详情', 128, 1, '2026-06-05 21:38:09');
INSERT INTO `notifications` VALUES (262, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）18\"找到了匹配的失物招领，请查看详情', 129, 0, '2026-06-05 21:38:10');
INSERT INTO `notifications` VALUES (263, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）11\"找到了匹配的寻物启示，请查看详情', 129, 1, '2026-06-05 21:38:10');
INSERT INTO `notifications` VALUES (264, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）18\"找到了匹配的失物招领，请查看详情', 130, 0, '2026-06-05 21:38:11');
INSERT INTO `notifications` VALUES (265, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 130, 0, '2026-06-05 21:38:11');
INSERT INTO `notifications` VALUES (266, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）18\"找到了匹配的失物招领，请查看详情', 131, 0, '2026-06-05 21:38:11');
INSERT INTO `notifications` VALUES (267, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（蓝色）53\"找到了匹配的寻物启示，请查看详情', 131, 1, '2026-06-05 21:38:12');
INSERT INTO `notifications` VALUES (268, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）18\"找到了匹配的失物招领，请查看详情', 132, 0, '2026-06-05 21:38:12');
INSERT INTO `notifications` VALUES (269, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）25\"找到了匹配的寻物启示，请查看详情', 132, 1, '2026-06-05 21:38:13');
INSERT INTO `notifications` VALUES (270, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）26\"找到了匹配的失物招领，请查看详情', 133, 1, '2026-06-05 21:38:13');
INSERT INTO `notifications` VALUES (271, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（白色）19\"找到了匹配的寻物启示，请查看详情', 133, 1, '2026-06-05 21:38:14');
INSERT INTO `notifications` VALUES (272, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（白色）26\"找到了匹配的失物招领，请查看详情', 134, 1, '2026-06-05 21:38:14');
INSERT INTO `notifications` VALUES (273, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（白色）19\"找到了匹配的寻物启示，请查看详情', 134, 1, '2026-06-05 21:38:15');
INSERT INTO `notifications` VALUES (274, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）12\"找到了匹配的失物招领，请查看详情', 135, 0, '2026-06-05 21:38:15');
INSERT INTO `notifications` VALUES (275, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（白色）19\"找到了匹配的寻物启示，请查看详情', 135, 1, '2026-06-05 21:38:16');
INSERT INTO `notifications` VALUES (276, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）40\"找到了匹配的失物招领，请查看详情', 136, 1, '2026-06-05 21:38:17');
INSERT INTO `notifications` VALUES (277, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（白色）19\"找到了匹配的寻物启示，请查看详情', 136, 1, '2026-06-05 21:38:17');
INSERT INTO `notifications` VALUES (278, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（红色）54\"找到了匹配的失物招领，请查看详情', 137, 0, '2026-06-05 21:38:18');
INSERT INTO `notifications` VALUES (279, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（白色）19\"找到了匹配的寻物启示，请查看详情', 137, 1, '2026-06-05 21:38:18');
INSERT INTO `notifications` VALUES (280, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（灰色）20\"找到了匹配的失物招领，请查看详情', 138, 1, '2026-06-05 21:38:19');
INSERT INTO `notifications` VALUES (281, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（灰色）27\"找到了匹配的寻物启示，请查看详情', 138, 0, '2026-06-05 21:38:19');
INSERT INTO `notifications` VALUES (282, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（灰色）20\"找到了匹配的失物招领，请查看详情', 139, 1, '2026-06-05 21:38:19');
INSERT INTO `notifications` VALUES (283, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）27\"找到了匹配的寻物启示，请查看详情', 139, 0, '2026-06-05 21:38:20');
INSERT INTO `notifications` VALUES (284, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（灰色）20\"找到了匹配的失物招领，请查看详情', 140, 1, '2026-06-05 21:38:20');
INSERT INTO `notifications` VALUES (285, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）13\"找到了匹配的寻物启示，请查看详情', 140, 1, '2026-06-05 21:38:21');
INSERT INTO `notifications` VALUES (286, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（灰色）20\"找到了匹配的失物招领，请查看详情', 141, 1, '2026-06-05 21:38:22');
INSERT INTO `notifications` VALUES (287, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）41\"找到了匹配的寻物启示，请查看详情', 141, 1, '2026-06-05 21:38:22');
INSERT INTO `notifications` VALUES (288, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（灰色）20\"找到了匹配的失物招领，请查看详情', 142, 1, '2026-06-05 21:38:23');
INSERT INTO `notifications` VALUES (289, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（黑色）55\"找到了匹配的寻物启示，请查看详情', 142, 1, '2026-06-05 21:38:23');
INSERT INTO `notifications` VALUES (290, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（蓝色）28\"找到了匹配的失物招领，请查看详情', 143, 1, '2026-06-05 21:38:24');
INSERT INTO `notifications` VALUES (291, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（蓝色）21\"找到了匹配的寻物启示，请查看详情', 143, 0, '2026-06-05 21:38:24');
INSERT INTO `notifications` VALUES (292, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）28\"找到了匹配的失物招领，请查看详情', 144, 1, '2026-06-05 21:38:25');
INSERT INTO `notifications` VALUES (293, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（蓝色）21\"找到了匹配的寻物启示，请查看详情', 144, 0, '2026-06-05 21:38:25');
INSERT INTO `notifications` VALUES (294, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）14\"找到了匹配的失物招领，请查看详情', 145, 1, '2026-06-05 21:38:26');
INSERT INTO `notifications` VALUES (295, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（蓝色）21\"找到了匹配的寻物启示，请查看详情', 145, 0, '2026-06-05 21:38:26');
INSERT INTO `notifications` VALUES (296, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）42\"找到了匹配的失物招领，请查看详情', 146, 0, '2026-06-05 21:38:27');
INSERT INTO `notifications` VALUES (297, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（蓝色）21\"找到了匹配的寻物启示，请查看详情', 146, 0, '2026-06-05 21:38:27');
INSERT INTO `notifications` VALUES (298, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（白色）56\"找到了匹配的失物招领，请查看详情', 147, 1, '2026-06-05 21:38:27');
INSERT INTO `notifications` VALUES (299, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（蓝色）21\"找到了匹配的寻物启示，请查看详情', 147, 0, '2026-06-05 21:38:28');
INSERT INTO `notifications` VALUES (300, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 148, 1, '2026-06-05 21:38:28');
INSERT INTO `notifications` VALUES (301, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（红色）29\"找到了匹配的寻物启示，请查看详情', 148, 1, '2026-06-05 21:38:29');
INSERT INTO `notifications` VALUES (302, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 149, 1, '2026-06-05 21:38:29');
INSERT INTO `notifications` VALUES (303, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（绿色）29\"找到了匹配的寻物启示，请查看详情', 149, 1, '2026-06-05 21:38:30');
INSERT INTO `notifications` VALUES (304, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 150, 1, '2026-06-05 21:38:30');
INSERT INTO `notifications` VALUES (305, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 150, 1, '2026-06-05 21:38:30');
INSERT INTO `notifications` VALUES (306, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 151, 1, '2026-06-05 21:38:31');
INSERT INTO `notifications` VALUES (307, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（黑色）15\"找到了匹配的寻物启示，请查看详情', 151, 0, '2026-06-05 21:38:31');
INSERT INTO `notifications` VALUES (308, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 152, 1, '2026-06-05 21:38:32');
INSERT INTO `notifications` VALUES (309, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）43\"找到了匹配的寻物启示，请查看详情', 152, 1, '2026-06-05 21:38:32');
INSERT INTO `notifications` VALUES (310, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（红色）22\"找到了匹配的失物招领，请查看详情', 153, 1, '2026-06-05 21:38:33');
INSERT INTO `notifications` VALUES (311, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（灰色）57\"找到了匹配的寻物启示，请查看详情', 153, 0, '2026-06-05 21:38:33');
INSERT INTO `notifications` VALUES (312, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 154, 0, '2026-06-05 21:38:34');
INSERT INTO `notifications` VALUES (313, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 154, 1, '2026-06-05 21:38:34');
INSERT INTO `notifications` VALUES (314, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 155, 1, '2026-06-05 21:38:35');
INSERT INTO `notifications` VALUES (315, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 155, 1, '2026-06-05 21:38:35');
INSERT INTO `notifications` VALUES (316, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（白色）16\"找到了匹配的失物招领，请查看详情', 156, 1, '2026-06-05 21:38:35');
INSERT INTO `notifications` VALUES (317, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 156, 1, '2026-06-05 21:38:36');
INSERT INTO `notifications` VALUES (318, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 157, 0, '2026-06-05 21:38:36');
INSERT INTO `notifications` VALUES (319, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 157, 1, '2026-06-05 21:38:37');
INSERT INTO `notifications` VALUES (320, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）44\"找到了匹配的失物招领，请查看详情', 158, 1, '2026-06-05 21:38:37');
INSERT INTO `notifications` VALUES (321, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 158, 1, '2026-06-05 21:38:38');
INSERT INTO `notifications` VALUES (322, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（蓝色）58\"找到了匹配的失物招领，请查看详情', 159, 1, '2026-06-05 21:38:38');
INSERT INTO `notifications` VALUES (323, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（绿色）23\"找到了匹配的寻物启示，请查看详情', 159, 1, '2026-06-05 21:38:39');
INSERT INTO `notifications` VALUES (324, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）24\"找到了匹配的失物招领，请查看详情', 160, 0, '2026-06-05 21:38:39');
INSERT INTO `notifications` VALUES (325, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（黑色）45\"找到了匹配的寻物启示，请查看详情', 160, 0, '2026-06-05 21:38:40');
INSERT INTO `notifications` VALUES (326, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）24\"找到了匹配的失物招领，请查看详情', 161, 0, '2026-06-05 21:39:01');
INSERT INTO `notifications` VALUES (327, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 161, 0, '2026-06-05 21:39:02');
INSERT INTO `notifications` VALUES (328, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）24\"找到了匹配的失物招领，请查看详情', 162, 0, '2026-06-05 21:39:02');
INSERT INTO `notifications` VALUES (329, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（灰色）17\"找到了匹配的寻物启示，请查看详情', 162, 1, '2026-06-05 21:39:03');
INSERT INTO `notifications` VALUES (330, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）24\"找到了匹配的失物招领，请查看详情', 163, 0, '2026-06-05 21:39:03');
INSERT INTO `notifications` VALUES (331, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（白色）31\"找到了匹配的寻物启示，请查看详情', 163, 1, '2026-06-05 21:39:04');
INSERT INTO `notifications` VALUES (332, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）24\"找到了匹配的失物招领，请查看详情', 164, 0, '2026-06-05 21:39:04');
INSERT INTO `notifications` VALUES (333, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（红色）59\"找到了匹配的寻物启示，请查看详情', 164, 1, '2026-06-05 21:39:06');
INSERT INTO `notifications` VALUES (334, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（白色）46\"找到了匹配的失物招领，请查看详情', 165, 1, '2026-06-05 21:39:07');
INSERT INTO `notifications` VALUES (335, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）25\"找到了匹配的寻物启示，请查看详情', 165, 1, '2026-06-05 21:39:07');
INSERT INTO `notifications` VALUES (336, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 166, 1, '2026-06-05 21:39:08');
INSERT INTO `notifications` VALUES (337, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）25\"找到了匹配的寻物启示，请查看详情', 166, 1, '2026-06-05 21:39:08');
INSERT INTO `notifications` VALUES (338, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（蓝色）18\"找到了匹配的失物招领，请查看详情', 167, 0, '2026-06-05 21:39:09');
INSERT INTO `notifications` VALUES (339, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）25\"找到了匹配的寻物启示，请查看详情', 167, 1, '2026-06-05 21:39:09');
INSERT INTO `notifications` VALUES (340, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（灰色）32\"找到了匹配的失物招领，请查看详情', 168, 1, '2026-06-05 21:39:10');
INSERT INTO `notifications` VALUES (341, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）25\"找到了匹配的寻物启示，请查看详情', 168, 1, '2026-06-05 21:39:10');
INSERT INTO `notifications` VALUES (342, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）60\"找到了匹配的失物招领，请查看详情', 169, 0, '2026-06-05 21:39:11');
INSERT INTO `notifications` VALUES (343, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）25\"找到了匹配的寻物启示，请查看详情', 169, 1, '2026-06-05 21:39:11');
INSERT INTO `notifications` VALUES (344, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）26\"找到了匹配的失物招领，请查看详情', 170, 1, '2026-06-05 21:39:11');
INSERT INTO `notifications` VALUES (345, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（灰色）47\"找到了匹配的寻物启示，请查看详情', 170, 1, '2026-06-05 21:39:12');
INSERT INTO `notifications` VALUES (346, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）26\"找到了匹配的失物招领，请查看详情', 171, 1, '2026-06-05 21:39:12');
INSERT INTO `notifications` VALUES (347, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（黑色）5\"找到了匹配的寻物启示，请查看详情', 171, 1, '2026-06-05 21:39:13');
INSERT INTO `notifications` VALUES (348, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）26\"找到了匹配的失物招领，请查看详情', 172, 1, '2026-06-05 21:39:13');
INSERT INTO `notifications` VALUES (349, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（红色）19\"找到了匹配的寻物启示，请查看详情', 172, 1, '2026-06-05 21:39:14');
INSERT INTO `notifications` VALUES (350, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）26\"找到了匹配的失物招领，请查看详情', 173, 1, '2026-06-05 21:39:14');
INSERT INTO `notifications` VALUES (351, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（蓝色）33\"找到了匹配的寻物启示，请查看详情', 173, 0, '2026-06-05 21:39:15');
INSERT INTO `notifications` VALUES (352, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（蓝色）48\"找到了匹配的失物招领，请查看详情', 174, 0, '2026-06-05 21:39:15');
INSERT INTO `notifications` VALUES (353, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）27\"找到了匹配的寻物启示，请查看详情', 174, 0, '2026-06-05 21:39:15');
INSERT INTO `notifications` VALUES (354, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 175, 0, '2026-06-05 21:39:16');
INSERT INTO `notifications` VALUES (355, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）27\"找到了匹配的寻物启示，请查看详情', 175, 0, '2026-06-05 21:39:16');
INSERT INTO `notifications` VALUES (356, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）20\"找到了匹配的失物招领，请查看详情', 176, 1, '2026-06-05 21:39:17');
INSERT INTO `notifications` VALUES (357, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）27\"找到了匹配的寻物启示，请查看详情', 176, 0, '2026-06-05 21:39:17');
INSERT INTO `notifications` VALUES (358, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（红色）34\"找到了匹配的失物招领，请查看详情', 177, 1, '2026-06-05 21:39:18');
INSERT INTO `notifications` VALUES (359, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）27\"找到了匹配的寻物启示，请查看详情', 177, 0, '2026-06-05 21:39:18');
INSERT INTO `notifications` VALUES (360, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）28\"找到了匹配的失物招领，请查看详情', 178, 1, '2026-06-05 21:39:19');
INSERT INTO `notifications` VALUES (361, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（红色）49\"找到了匹配的寻物启示，请查看详情', 178, 1, '2026-06-05 21:39:19');
INSERT INTO `notifications` VALUES (362, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）28\"找到了匹配的失物招领，请查看详情', 179, 1, '2026-06-05 21:39:20');
INSERT INTO `notifications` VALUES (363, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（灰色）7\"找到了匹配的寻物启示，请查看详情', 179, 1, '2026-06-05 21:39:21');
INSERT INTO `notifications` VALUES (364, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）28\"找到了匹配的失物招领，请查看详情', 180, 1, '2026-06-05 21:39:21');
INSERT INTO `notifications` VALUES (365, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）21\"找到了匹配的寻物启示，请查看详情', 180, 0, '2026-06-05 21:39:22');
INSERT INTO `notifications` VALUES (366, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）28\"找到了匹配的失物招领，请查看详情', 181, 1, '2026-06-05 21:39:22');
INSERT INTO `notifications` VALUES (367, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 181, 1, '2026-06-05 21:39:22');
INSERT INTO `notifications` VALUES (368, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 182, 1, '2026-06-05 21:39:23');
INSERT INTO `notifications` VALUES (369, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（绿色）29\"找到了匹配的寻物启示，请查看详情', 182, 1, '2026-06-05 21:39:23');
INSERT INTO `notifications` VALUES (370, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 183, 1, '2026-06-05 21:39:24');
INSERT INTO `notifications` VALUES (371, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（绿色）29\"找到了匹配的寻物启示，请查看详情', 183, 1, '2026-06-05 21:39:24');
INSERT INTO `notifications` VALUES (372, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 184, 0, '2026-06-05 21:39:25');
INSERT INTO `notifications` VALUES (373, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（绿色）29\"找到了匹配的寻物启示，请查看详情', 184, 1, '2026-06-05 21:39:25');
INSERT INTO `notifications` VALUES (374, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 185, 1, '2026-06-05 21:39:25');
INSERT INTO `notifications` VALUES (375, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（绿色）29\"找到了匹配的寻物启示，请查看详情', 185, 1, '2026-06-05 21:39:26');
INSERT INTO `notifications` VALUES (376, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 186, 0, '2026-06-05 21:39:26');
INSERT INTO `notifications` VALUES (377, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 186, 0, '2026-06-05 21:39:27');
INSERT INTO `notifications` VALUES (378, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 187, 0, '2026-06-05 21:39:27');
INSERT INTO `notifications` VALUES (379, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 187, 1, '2026-06-05 21:39:28');
INSERT INTO `notifications` VALUES (380, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 188, 0, '2026-06-05 21:39:28');
INSERT INTO `notifications` VALUES (381, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 188, 1, '2026-06-05 21:39:29');
INSERT INTO `notifications` VALUES (382, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 189, 0, '2026-06-05 21:39:29');
INSERT INTO `notifications` VALUES (383, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 189, 0, '2026-06-05 21:39:30');
INSERT INTO `notifications` VALUES (384, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi电子产品（黑色）#1\"找到了匹配的失物招领，请查看详情', 190, 0, '2026-06-05 21:39:30');
INSERT INTO `notifications` VALUES (385, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi电子产品（黑色）#1\"找到了匹配的寻物启示，请查看详情', 190, 1, '2026-06-05 21:39:30');
INSERT INTO `notifications` VALUES (386, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple证件（白色）#2\"找到了匹配的失物招领，请查看详情', 191, 0, '2026-06-05 21:39:31');
INSERT INTO `notifications` VALUES (387, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple证件（白色）#2\"找到了匹配的寻物启示，请查看详情', 191, 1, '2026-06-05 21:39:31');
INSERT INTO `notifications` VALUES (388, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei书籍（灰色）#3\"找到了匹配的失物招领，请查看详情', 192, 0, '2026-06-05 21:39:32');
INSERT INTO `notifications` VALUES (389, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei书籍（灰色）#3\"找到了匹配的寻物启示，请查看详情', 192, 1, '2026-06-05 21:39:32');
INSERT INTO `notifications` VALUES (390, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO衣物（蓝色）#4\"找到了匹配的失物招领，请查看详情', 193, 0, '2026-06-05 21:39:33');
INSERT INTO `notifications` VALUES (391, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO衣物（蓝色）#4\"找到了匹配的寻物启示，请查看详情', 193, 1, '2026-06-05 21:39:33');
INSERT INTO `notifications` VALUES (392, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo电子产品（黑色）#5\"找到了匹配的失物招领，请查看详情', 194, 0, '2026-06-05 21:39:34');
INSERT INTO `notifications` VALUES (393, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo电子产品（黑色）#5\"找到了匹配的寻物启示，请查看详情', 194, 1, '2026-06-05 21:39:34');
INSERT INTO `notifications` VALUES (394, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo证件（白色）#6\"找到了匹配的失物招领，请查看详情', 195, 0, '2026-06-05 21:39:34');
INSERT INTO `notifications` VALUES (395, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo证件（白色）#6\"找到了匹配的寻物启示，请查看详情', 195, 1, '2026-06-05 21:39:35');
INSERT INTO `notifications` VALUES (396, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi书籍（灰色）#7\"找到了匹配的失物招领，请查看详情', 196, 0, '2026-06-05 21:39:35');
INSERT INTO `notifications` VALUES (397, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi书籍（灰色）#7\"找到了匹配的寻物启示，请查看详情', 196, 1, '2026-06-05 21:39:36');
INSERT INTO `notifications` VALUES (398, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple衣物（蓝色）#8\"找到了匹配的失物招领，请查看详情', 197, 0, '2026-06-05 21:39:36');
INSERT INTO `notifications` VALUES (399, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple衣物（蓝色）#8\"找到了匹配的寻物启示，请查看详情', 197, 1, '2026-06-05 21:39:37');
INSERT INTO `notifications` VALUES (400, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei电子产品（黑色）#9\"找到了匹配的失物招领，请查看详情', 198, 0, '2026-06-05 21:39:37');
INSERT INTO `notifications` VALUES (401, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei电子产品（黑色）#9\"找到了匹配的寻物启示，请查看详情', 198, 1, '2026-06-05 21:39:38');
INSERT INTO `notifications` VALUES (402, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO证件（白色）#10\"找到了匹配的失物招领，请查看详情', 199, 0, '2026-06-05 21:39:38');
INSERT INTO `notifications` VALUES (403, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO证件（白色）#10\"找到了匹配的寻物启示，请查看详情', 199, 1, '2026-06-05 21:39:38');
INSERT INTO `notifications` VALUES (404, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo书籍（灰色）#11\"找到了匹配的失物招领，请查看详情', 200, 0, '2026-06-05 21:39:39');
INSERT INTO `notifications` VALUES (405, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo书籍（灰色）#11\"找到了匹配的寻物启示，请查看详情', 200, 1, '2026-06-05 21:39:39');
INSERT INTO `notifications` VALUES (406, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo衣物（蓝色）#12\"找到了匹配的失物招领，请查看详情', 201, 0, '2026-06-05 21:39:40');
INSERT INTO `notifications` VALUES (407, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo衣物（蓝色）#12\"找到了匹配的寻物启示，请查看详情', 201, 1, '2026-06-05 21:39:40');
INSERT INTO `notifications` VALUES (408, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi电子产品（黑色）#13\"找到了匹配的失物招领，请查看详情', 202, 0, '2026-06-05 21:39:41');
INSERT INTO `notifications` VALUES (409, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi电子产品（黑色）#13\"找到了匹配的寻物启示，请查看详情', 202, 1, '2026-06-05 21:39:41');
INSERT INTO `notifications` VALUES (410, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple证件（白色）#14\"找到了匹配的失物招领，请查看详情', 203, 0, '2026-06-05 21:39:42');
INSERT INTO `notifications` VALUES (411, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple证件（白色）#14\"找到了匹配的寻物启示，请查看详情', 203, 1, '2026-06-05 21:39:42');
INSERT INTO `notifications` VALUES (412, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei书籍（灰色）#15\"找到了匹配的失物招领，请查看详情', 204, 0, '2026-06-05 21:39:43');
INSERT INTO `notifications` VALUES (413, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei书籍（灰色）#15\"找到了匹配的寻物启示，请查看详情', 204, 1, '2026-06-05 21:39:43');
INSERT INTO `notifications` VALUES (414, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO衣物（蓝色）#16\"找到了匹配的失物招领，请查看详情', 205, 0, '2026-06-05 21:39:44');
INSERT INTO `notifications` VALUES (415, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO衣物（蓝色）#16\"找到了匹配的寻物启示，请查看详情', 205, 1, '2026-06-05 21:39:44');
INSERT INTO `notifications` VALUES (416, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo电子产品（黑色）#17\"找到了匹配的失物招领，请查看详情', 206, 0, '2026-06-05 21:39:45');
INSERT INTO `notifications` VALUES (417, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo电子产品（黑色）#17\"找到了匹配的寻物启示，请查看详情', 206, 1, '2026-06-05 21:39:45');
INSERT INTO `notifications` VALUES (418, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo证件（白色）#18\"找到了匹配的失物招领，请查看详情', 207, 0, '2026-06-05 21:39:46');
INSERT INTO `notifications` VALUES (419, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo证件（白色）#18\"找到了匹配的寻物启示，请查看详情', 207, 1, '2026-06-05 21:39:46');
INSERT INTO `notifications` VALUES (420, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi书籍（灰色）#19\"找到了匹配的失物招领，请查看详情', 208, 0, '2026-06-05 21:39:47');
INSERT INTO `notifications` VALUES (421, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi书籍（灰色）#19\"找到了匹配的寻物启示，请查看详情', 208, 1, '2026-06-05 21:39:47');
INSERT INTO `notifications` VALUES (422, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple衣物（蓝色）#20\"找到了匹配的失物招领，请查看详情', 209, 0, '2026-06-05 21:39:48');
INSERT INTO `notifications` VALUES (423, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple衣物（蓝色）#20\"找到了匹配的寻物启示，请查看详情', 209, 1, '2026-06-05 21:39:48');
INSERT INTO `notifications` VALUES (424, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 210, 0, '2026-06-05 21:39:48');
INSERT INTO `notifications` VALUES (425, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 210, 1, '2026-06-05 21:39:49');
INSERT INTO `notifications` VALUES (426, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 211, 1, '2026-06-05 21:39:49');
INSERT INTO `notifications` VALUES (427, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 211, 1, '2026-06-05 21:39:50');
INSERT INTO `notifications` VALUES (428, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 212, 1, '2026-06-05 21:39:50');
INSERT INTO `notifications` VALUES (429, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 212, 1, '2026-06-05 21:39:51');
INSERT INTO `notifications` VALUES (430, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 213, 1, '2026-06-05 21:39:51');
INSERT INTO `notifications` VALUES (431, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 213, 1, '2026-06-05 21:39:52');
INSERT INTO `notifications` VALUES (432, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple证件（白色）#2\"找到了匹配的失物招领，请查看详情', 214, 0, '2026-06-05 21:39:52');
INSERT INTO `notifications` VALUES (433, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 214, 1, '2026-06-05 21:39:53');
INSERT INTO `notifications` VALUES (434, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo证件（白色）#6\"找到了匹配的失物招领，请查看详情', 215, 0, '2026-06-05 21:39:53');
INSERT INTO `notifications` VALUES (435, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 215, 1, '2026-06-05 21:39:53');
INSERT INTO `notifications` VALUES (436, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO证件（白色）#10\"找到了匹配的失物招领，请查看详情', 216, 0, '2026-06-05 21:39:54');
INSERT INTO `notifications` VALUES (437, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 216, 1, '2026-06-05 21:39:55');
INSERT INTO `notifications` VALUES (438, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple证件（白色）#14\"找到了匹配的失物招领，请查看详情', 217, 0, '2026-06-05 21:39:55');
INSERT INTO `notifications` VALUES (439, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 217, 1, '2026-06-05 21:39:55');
INSERT INTO `notifications` VALUES (440, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo证件（白色）#18\"找到了匹配的失物招领，请查看详情', 218, 0, '2026-06-05 21:39:56');
INSERT INTO `notifications` VALUES (441, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 218, 1, '2026-06-05 21:39:56');
INSERT INTO `notifications` VALUES (442, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple 证件（白色）#2\"找到了匹配的失物招领，请查看详情', 219, 0, '2026-06-05 21:39:57');
INSERT INTO `notifications` VALUES (443, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 219, 1, '2026-06-05 21:39:58');
INSERT INTO `notifications` VALUES (444, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 220, 1, '2026-06-05 21:39:58');
INSERT INTO `notifications` VALUES (445, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 220, 1, '2026-06-05 21:39:58');
INSERT INTO `notifications` VALUES (446, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 221, 1, '2026-06-05 21:39:59');
INSERT INTO `notifications` VALUES (447, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 221, 0, '2026-06-05 21:39:59');
INSERT INTO `notifications` VALUES (448, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 222, 1, '2026-06-05 21:40:00');
INSERT INTO `notifications` VALUES (449, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 222, 1, '2026-06-05 21:40:00');
INSERT INTO `notifications` VALUES (450, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 223, 1, '2026-06-05 21:40:01');
INSERT INTO `notifications` VALUES (451, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 223, 0, '2026-06-05 21:40:01');
INSERT INTO `notifications` VALUES (452, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 224, 1, '2026-06-05 21:40:02');
INSERT INTO `notifications` VALUES (453, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei书籍（灰色）#3\"找到了匹配的寻物启示，请查看详情', 224, 1, '2026-06-05 21:40:03');
INSERT INTO `notifications` VALUES (454, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 225, 1, '2026-06-05 21:40:03');
INSERT INTO `notifications` VALUES (455, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi书籍（灰色）#7\"找到了匹配的寻物启示，请查看详情', 225, 1, '2026-06-05 21:40:04');
INSERT INTO `notifications` VALUES (456, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 226, 1, '2026-06-05 21:40:04');
INSERT INTO `notifications` VALUES (457, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo书籍（灰色）#11\"找到了匹配的寻物启示，请查看详情', 226, 1, '2026-06-05 21:40:05');
INSERT INTO `notifications` VALUES (458, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 227, 1, '2026-06-05 21:40:05');
INSERT INTO `notifications` VALUES (459, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei书籍（灰色）#15\"找到了匹配的寻物启示，请查看详情', 227, 1, '2026-06-05 21:40:05');
INSERT INTO `notifications` VALUES (460, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 228, 1, '2026-06-05 21:40:08');
INSERT INTO `notifications` VALUES (461, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Xiaomi书籍（灰色）#19\"找到了匹配的寻物启示，请查看详情', 228, 1, '2026-06-05 21:40:09');
INSERT INTO `notifications` VALUES (462, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（灰色）2\"找到了匹配的失物招领，请查看详情', 229, 1, '2026-06-05 21:40:09');
INSERT INTO `notifications` VALUES (463, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Huawei 书籍（灰色）#3\"找到了匹配的寻物启示，请查看详情', 229, 1, '2026-06-05 21:40:10');
INSERT INTO `notifications` VALUES (464, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 230, 1, '2026-06-05 21:40:10');
INSERT INTO `notifications` VALUES (465, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 230, 0, '2026-06-05 21:40:13');
INSERT INTO `notifications` VALUES (466, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）10\"找到了匹配的失物招领，请查看详情', 231, 1, '2026-06-05 21:40:13');
INSERT INTO `notifications` VALUES (467, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 231, 0, '2026-06-05 21:40:14');
INSERT INTO `notifications` VALUES (468, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）24\"找到了匹配的失物招领，请查看详情', 232, 0, '2026-06-05 21:40:14');
INSERT INTO `notifications` VALUES (469, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 232, 0, '2026-06-05 21:40:14');
INSERT INTO `notifications` VALUES (470, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（灰色）52\"找到了匹配的失物招领，请查看详情', 233, 1, '2026-06-05 21:40:15');
INSERT INTO `notifications` VALUES (471, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 233, 0, '2026-06-05 21:40:15');
INSERT INTO `notifications` VALUES (472, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO衣物（蓝色）#4\"找到了匹配的失物招领，请查看详情', 234, 0, '2026-06-05 21:40:16');
INSERT INTO `notifications` VALUES (473, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 234, 0, '2026-06-05 21:40:16');
INSERT INTO `notifications` VALUES (474, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple衣物（蓝色）#8\"找到了匹配的失物招领，请查看详情', 235, 0, '2026-06-05 21:40:17');
INSERT INTO `notifications` VALUES (475, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 235, 0, '2026-06-05 21:40:17');
INSERT INTO `notifications` VALUES (476, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Lenovo衣物（蓝色）#12\"找到了匹配的失物招领，请查看详情', 236, 0, '2026-06-05 21:40:19');
INSERT INTO `notifications` VALUES (477, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 236, 0, '2026-06-05 21:40:20');
INSERT INTO `notifications` VALUES (478, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO衣物（蓝色）#16\"找到了匹配的失物招领，请查看详情', 237, 0, '2026-06-05 21:40:21');
INSERT INTO `notifications` VALUES (479, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 237, 0, '2026-06-05 21:40:21');
INSERT INTO `notifications` VALUES (480, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Apple衣物（蓝色）#20\"找到了匹配的失物招领，请查看详情', 238, 0, '2026-06-05 21:40:22');
INSERT INTO `notifications` VALUES (481, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 238, 0, '2026-06-05 21:40:22');
INSERT INTO `notifications` VALUES (482, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失OPPO 衣物（蓝色）#4\"找到了匹配的失物招领，请查看详情', 239, 0, '2026-06-05 21:40:23');
INSERT INTO `notifications` VALUES (483, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 239, 0, '2026-06-05 21:40:23');
INSERT INTO `notifications` VALUES (484, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 240, 1, '2026-06-05 21:40:24');
INSERT INTO `notifications` VALUES (485, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 240, 0, '2026-06-05 21:40:24');
INSERT INTO `notifications` VALUES (486, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 241, 1, '2026-06-05 21:40:24');
INSERT INTO `notifications` VALUES (487, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）11\"找到了匹配的寻物启示，请查看详情', 241, 1, '2026-06-05 21:40:25');
INSERT INTO `notifications` VALUES (488, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 242, 1, '2026-06-05 21:40:25');
INSERT INTO `notifications` VALUES (489, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（黑色）25\"找到了匹配的寻物启示，请查看详情', 242, 1, '2026-06-05 21:40:26');
INSERT INTO `notifications` VALUES (490, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 243, 1, '2026-06-05 21:40:26');
INSERT INTO `notifications` VALUES (491, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（蓝色）53\"找到了匹配的寻物启示，请查看详情', 243, 1, '2026-06-05 21:40:27');
INSERT INTO `notifications` VALUES (492, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 244, 1, '2026-06-05 21:40:27');
INSERT INTO `notifications` VALUES (493, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到vivo 饰品（红色）#5\"找到了匹配的寻物启示，请查看详情', 244, 1, '2026-06-05 21:40:28');
INSERT INTO `notifications` VALUES (494, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）40\"找到了匹配的失物招领，请查看详情', 245, 1, '2026-06-05 21:40:28');
INSERT INTO `notifications` VALUES (495, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（黑色）5\"找到了匹配的寻物启示，请查看详情', 245, 1, '2026-06-05 21:40:28');
INSERT INTO `notifications` VALUES (496, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）12\"找到了匹配的失物招领，请查看详情', 246, 0, '2026-06-05 21:40:29');
INSERT INTO `notifications` VALUES (497, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（黑色）5\"找到了匹配的寻物启示，请查看详情', 246, 1, '2026-06-05 21:40:30');
INSERT INTO `notifications` VALUES (498, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（白色）26\"找到了匹配的失物招领，请查看详情', 247, 1, '2026-06-05 21:40:30');
INSERT INTO `notifications` VALUES (499, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（黑色）5\"找到了匹配的寻物启示，请查看详情', 247, 1, '2026-06-05 21:40:31');
INSERT INTO `notifications` VALUES (500, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（红色）54\"找到了匹配的失物招领，请查看详情', 248, 0, '2026-06-05 21:40:31');
INSERT INTO `notifications` VALUES (501, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（黑色）5\"找到了匹配的寻物启示，请查看详情', 248, 1, '2026-06-05 21:40:32');
INSERT INTO `notifications` VALUES (502, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 249, 0, '2026-06-05 21:40:32');
INSERT INTO `notifications` VALUES (503, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）41\"找到了匹配的寻物启示，请查看详情', 249, 1, '2026-06-05 21:40:32');
INSERT INTO `notifications` VALUES (504, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 250, 0, '2026-06-05 21:40:33');
INSERT INTO `notifications` VALUES (505, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）13\"找到了匹配的寻物启示，请查看详情', 250, 1, '2026-06-05 21:40:33');
INSERT INTO `notifications` VALUES (506, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 251, 0, '2026-06-05 21:40:34');
INSERT INTO `notifications` VALUES (507, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（灰色）27\"找到了匹配的寻物启示，请查看详情', 251, 0, '2026-06-05 21:40:34');
INSERT INTO `notifications` VALUES (508, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 252, 0, '2026-06-05 21:40:35');
INSERT INTO `notifications` VALUES (509, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（黑色）55\"找到了匹配的寻物启示，请查看详情', 252, 1, '2026-06-05 21:40:36');
INSERT INTO `notifications` VALUES (510, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 253, 0, '2026-06-05 21:40:36');
INSERT INTO `notifications` VALUES (511, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Adidas 其他（白色）#8\"找到了匹配的寻物启示，请查看详情', 253, 1, '2026-06-05 21:40:37');
INSERT INTO `notifications` VALUES (512, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）42\"找到了匹配的失物招领，请查看详情', 254, 0, '2026-06-05 21:40:37');
INSERT INTO `notifications` VALUES (513, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（灰色）7\"找到了匹配的寻物启示，请查看详情', 254, 1, '2026-06-05 21:40:38');
INSERT INTO `notifications` VALUES (514, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）14\"找到了匹配的失物招领，请查看详情', 255, 1, '2026-06-05 21:40:38');
INSERT INTO `notifications` VALUES (515, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（灰色）7\"找到了匹配的寻物启示，请查看详情', 255, 1, '2026-06-05 21:40:39');
INSERT INTO `notifications` VALUES (516, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（蓝色）28\"找到了匹配的失物招领，请查看详情', 256, 1, '2026-06-05 21:40:39');
INSERT INTO `notifications` VALUES (517, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（灰色）7\"找到了匹配的寻物启示，请查看详情', 256, 1, '2026-06-05 21:40:40');
INSERT INTO `notifications` VALUES (518, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（白色）56\"找到了匹配的失物招领，请查看详情', 257, 1, '2026-06-05 21:40:41');
INSERT INTO `notifications` VALUES (519, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（灰色）7\"找到了匹配的寻物启示，请查看详情', 257, 1, '2026-06-05 21:40:41');
INSERT INTO `notifications` VALUES (520, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 258, 1, '2026-06-05 21:40:42');
INSERT INTO `notifications` VALUES (521, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）43\"找到了匹配的寻物启示，请查看详情', 258, 1, '2026-06-05 21:40:42');
INSERT INTO `notifications` VALUES (522, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 259, 1, '2026-06-05 21:40:43');
INSERT INTO `notifications` VALUES (523, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（黑色）15\"找到了匹配的寻物启示，请查看详情', 259, 0, '2026-06-05 21:40:43');
INSERT INTO `notifications` VALUES (524, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 260, 1, '2026-06-05 21:40:43');
INSERT INTO `notifications` VALUES (525, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（红色）29\"找到了匹配的寻物启示，请查看详情', 260, 1, '2026-06-05 21:40:44');
INSERT INTO `notifications` VALUES (526, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 261, 1, '2026-06-05 21:40:44');
INSERT INTO `notifications` VALUES (527, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（灰色）57\"找到了匹配的寻物启示，请查看详情', 261, 0, '2026-06-05 21:40:45');
INSERT INTO `notifications` VALUES (528, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）44\"找到了匹配的失物招领，请查看详情', 262, 1, '2026-06-05 21:40:45');
INSERT INTO `notifications` VALUES (529, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 262, 0, '2026-06-05 21:40:46');
INSERT INTO `notifications` VALUES (530, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（白色）16\"找到了匹配的失物招领，请查看详情', 263, 1, '2026-06-05 21:40:46');
INSERT INTO `notifications` VALUES (531, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 263, 0, '2026-06-05 21:40:47');
INSERT INTO `notifications` VALUES (532, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 264, 0, '2026-06-05 21:40:47');
INSERT INTO `notifications` VALUES (533, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 264, 0, '2026-06-05 21:40:48');
INSERT INTO `notifications` VALUES (534, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（蓝色）58\"找到了匹配的失物招领，请查看详情', 265, 1, '2026-06-05 21:40:48');
INSERT INTO `notifications` VALUES (535, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 265, 0, '2026-06-05 21:40:49');
INSERT INTO `notifications` VALUES (536, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）10\"找到了匹配的失物招领，请查看详情', 266, 1, '2026-06-05 21:40:49');
INSERT INTO `notifications` VALUES (537, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（黑色）45\"找到了匹配的寻物启示，请查看详情', 266, 0, '2026-06-05 21:40:49');
INSERT INTO `notifications` VALUES (538, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）10\"找到了匹配的失物招领，请查看详情', 267, 1, '2026-06-05 21:40:50');
INSERT INTO `notifications` VALUES (539, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（灰色）17\"找到了匹配的寻物启示，请查看详情', 267, 1, '2026-06-05 21:40:50');
INSERT INTO `notifications` VALUES (540, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）10\"找到了匹配的失物招领，请查看详情', 268, 1, '2026-06-05 21:40:51');
INSERT INTO `notifications` VALUES (541, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（白色）31\"找到了匹配的寻物启示，请查看详情', 268, 1, '2026-06-05 21:40:51');
INSERT INTO `notifications` VALUES (542, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（黑色）10\"找到了匹配的失物招领，请查看详情', 269, 1, '2026-06-05 21:40:52');
INSERT INTO `notifications` VALUES (543, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（红色）59\"找到了匹配的寻物启示，请查看详情', 269, 1, '2026-06-05 21:40:52');
INSERT INTO `notifications` VALUES (544, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（白色）46\"找到了匹配的失物招领，请查看详情', 270, 1, '2026-06-05 21:40:53');
INSERT INTO `notifications` VALUES (545, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）11\"找到了匹配的寻物启示，请查看详情', 270, 1, '2026-06-05 21:40:53');
INSERT INTO `notifications` VALUES (546, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（蓝色）18\"找到了匹配的失物招领，请查看详情', 271, 0, '2026-06-05 21:40:54');
INSERT INTO `notifications` VALUES (547, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）11\"找到了匹配的寻物启示，请查看详情', 271, 1, '2026-06-05 21:40:54');
INSERT INTO `notifications` VALUES (548, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（灰色）32\"找到了匹配的失物招领，请查看详情', 272, 1, '2026-06-05 21:40:55');
INSERT INTO `notifications` VALUES (549, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）11\"找到了匹配的寻物启示，请查看详情', 272, 1, '2026-06-05 21:40:55');
INSERT INTO `notifications` VALUES (550, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）60\"找到了匹配的失物招领，请查看详情', 273, 0, '2026-06-05 21:40:55');
INSERT INTO `notifications` VALUES (551, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（白色）11\"找到了匹配的寻物启示，请查看详情', 273, 1, '2026-06-05 21:40:56');
INSERT INTO `notifications` VALUES (552, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）12\"找到了匹配的失物招领，请查看详情', 274, 0, '2026-06-05 21:40:56');
INSERT INTO `notifications` VALUES (553, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（灰色）47\"找到了匹配的寻物启示，请查看详情', 274, 1, '2026-06-05 21:40:57');
INSERT INTO `notifications` VALUES (554, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）12\"找到了匹配的失物招领，请查看详情', 275, 0, '2026-06-05 21:40:57');
INSERT INTO `notifications` VALUES (555, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（红色）19\"找到了匹配的寻物启示，请查看详情', 275, 1, '2026-06-05 21:40:58');
INSERT INTO `notifications` VALUES (556, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（灰色）12\"找到了匹配的失物招领，请查看详情', 276, 0, '2026-06-05 21:40:58');
INSERT INTO `notifications` VALUES (557, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（蓝色）33\"找到了匹配的寻物启示，请查看详情', 276, 0, '2026-06-05 21:40:59');
INSERT INTO `notifications` VALUES (558, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（蓝色）48\"找到了匹配的失物招领，请查看详情', 277, 0, '2026-06-05 21:40:59');
INSERT INTO `notifications` VALUES (559, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）13\"找到了匹配的寻物启示，请查看详情', 277, 1, '2026-06-05 21:40:59');
INSERT INTO `notifications` VALUES (560, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）20\"找到了匹配的失物招领，请查看详情', 278, 1, '2026-06-05 21:41:00');
INSERT INTO `notifications` VALUES (561, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）13\"找到了匹配的寻物启示，请查看详情', 278, 1, '2026-06-05 21:41:02');
INSERT INTO `notifications` VALUES (562, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（红色）34\"找到了匹配的失物招领，请查看详情', 279, 1, '2026-06-05 21:41:03');
INSERT INTO `notifications` VALUES (563, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（蓝色）13\"找到了匹配的寻物启示，请查看详情', 279, 1, '2026-06-05 21:41:03');
INSERT INTO `notifications` VALUES (564, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）14\"找到了匹配的失物招领，请查看详情', 280, 1, '2026-06-05 21:41:04');
INSERT INTO `notifications` VALUES (565, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（红色）49\"找到了匹配的寻物启示，请查看详情', 280, 1, '2026-06-05 21:41:04');
INSERT INTO `notifications` VALUES (566, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）14\"找到了匹配的失物招领，请查看详情', 281, 1, '2026-06-05 21:41:04');
INSERT INTO `notifications` VALUES (567, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）21\"找到了匹配的寻物启示，请查看详情', 281, 0, '2026-06-05 21:41:05');
INSERT INTO `notifications` VALUES (568, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（红色）14\"找到了匹配的失物招领，请查看详情', 282, 1, '2026-06-05 21:41:05');
INSERT INTO `notifications` VALUES (569, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 282, 1, '2026-06-05 21:41:06');
INSERT INTO `notifications` VALUES (572, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 284, 1, '2026-06-05 21:41:24');
INSERT INTO `notifications` VALUES (573, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（黑色）15\"找到了匹配的寻物启示，请查看详情', 284, 0, '2026-06-05 21:41:25');
INSERT INTO `notifications` VALUES (574, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 285, 1, '2026-06-05 21:41:25');
INSERT INTO `notifications` VALUES (575, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（黑色）15\"找到了匹配的寻物启示，请查看详情', 285, 0, '2026-06-05 21:41:26');
INSERT INTO `notifications` VALUES (576, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 286, 0, '2026-06-05 21:41:26');
INSERT INTO `notifications` VALUES (577, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（黑色）15\"找到了匹配的寻物启示，请查看详情', 286, 0, '2026-06-05 21:41:27');
INSERT INTO `notifications` VALUES (578, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（白色）16\"找到了匹配的失物招领，请查看详情', 287, 1, '2026-06-05 21:41:27');
INSERT INTO `notifications` VALUES (579, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 287, 0, '2026-06-05 21:41:27');
INSERT INTO `notifications` VALUES (580, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（白色）16\"找到了匹配的失物招领，请查看详情', 288, 1, '2026-06-05 21:41:28');
INSERT INTO `notifications` VALUES (581, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 288, 1, '2026-06-05 21:41:28');
INSERT INTO `notifications` VALUES (582, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（白色）16\"找到了匹配的失物招领，请查看详情', 289, 1, '2026-06-05 21:41:29');
INSERT INTO `notifications` VALUES (583, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 289, 1, '2026-06-05 21:41:29');
INSERT INTO `notifications` VALUES (584, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（灰色）52\"找到了匹配的失物招领，请查看详情', 290, 1, '2026-06-05 21:41:30');
INSERT INTO `notifications` VALUES (585, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（灰色）17\"找到了匹配的寻物启示，请查看详情', 290, 1, '2026-06-05 21:41:30');
INSERT INTO `notifications` VALUES (586, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）24\"找到了匹配的失物招领，请查看详情', 291, 0, '2026-06-05 21:41:30');
INSERT INTO `notifications` VALUES (587, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（灰色）17\"找到了匹配的寻物启示，请查看详情', 291, 1, '2026-06-05 21:41:31');
INSERT INTO `notifications` VALUES (588, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 292, 1, '2026-06-05 21:41:31');
INSERT INTO `notifications` VALUES (589, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（灰色）17\"找到了匹配的寻物启示，请查看详情', 292, 1, '2026-06-05 21:41:32');
INSERT INTO `notifications` VALUES (590, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（蓝色）18\"找到了匹配的失物招领，请查看详情', 293, 0, '2026-06-05 21:41:32');
INSERT INTO `notifications` VALUES (591, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（蓝色）53\"找到了匹配的寻物启示，请查看详情', 293, 1, '2026-06-05 21:41:33');
INSERT INTO `notifications` VALUES (592, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（蓝色）18\"找到了匹配的失物招领，请查看详情', 294, 0, '2026-06-05 21:41:33');
INSERT INTO `notifications` VALUES (593, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（黑色）25\"找到了匹配的寻物启示，请查看详情', 294, 1, '2026-06-05 21:41:34');
INSERT INTO `notifications` VALUES (594, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（蓝色）18\"找到了匹配的失物招领，请查看详情', 295, 0, '2026-06-05 21:41:34');
INSERT INTO `notifications` VALUES (595, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 295, 0, '2026-06-05 21:41:34');
INSERT INTO `notifications` VALUES (596, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（红色）54\"找到了匹配的失物招领，请查看详情', 296, 0, '2026-06-05 21:41:35');
INSERT INTO `notifications` VALUES (597, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（红色）19\"找到了匹配的寻物启示，请查看详情', 296, 1, '2026-06-05 21:41:35');
INSERT INTO `notifications` VALUES (598, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（白色）26\"找到了匹配的失物招领，请查看详情', 297, 1, '2026-06-05 21:41:36');
INSERT INTO `notifications` VALUES (599, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（红色）19\"找到了匹配的寻物启示，请查看详情', 297, 1, '2026-06-05 21:41:36');
INSERT INTO `notifications` VALUES (600, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）40\"找到了匹配的失物招领，请查看详情', 298, 1, '2026-06-05 21:41:37');
INSERT INTO `notifications` VALUES (601, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（红色）19\"找到了匹配的寻物启示，请查看详情', 298, 1, '2026-06-05 21:41:37');
INSERT INTO `notifications` VALUES (602, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）20\"找到了匹配的失物招领，请查看详情', 299, 1, '2026-06-05 21:41:37');
INSERT INTO `notifications` VALUES (603, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（黑色）55\"找到了匹配的寻物启示，请查看详情', 299, 1, '2026-06-05 21:41:38');
INSERT INTO `notifications` VALUES (604, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）20\"找到了匹配的失物招领，请查看详情', 300, 1, '2026-06-05 21:41:38');
INSERT INTO `notifications` VALUES (605, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（灰色）27\"找到了匹配的寻物启示，请查看详情', 300, 0, '2026-06-05 21:41:39');
INSERT INTO `notifications` VALUES (606, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（黑色）20\"找到了匹配的失物招领，请查看详情', 301, 1, '2026-06-05 21:41:39');
INSERT INTO `notifications` VALUES (607, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）41\"找到了匹配的寻物启示，请查看详情', 301, 1, '2026-06-05 21:41:40');
INSERT INTO `notifications` VALUES (608, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（白色）56\"找到了匹配的失物招领，请查看详情', 302, 1, '2026-06-05 21:41:40');
INSERT INTO `notifications` VALUES (609, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）21\"找到了匹配的寻物启示，请查看详情', 302, 0, '2026-06-05 21:41:41');
INSERT INTO `notifications` VALUES (610, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（蓝色）28\"找到了匹配的失物招领，请查看详情', 303, 1, '2026-06-05 21:41:41');
INSERT INTO `notifications` VALUES (611, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）21\"找到了匹配的寻物启示，请查看详情', 303, 0, '2026-06-05 21:41:41');
INSERT INTO `notifications` VALUES (612, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）42\"找到了匹配的失物招领，请查看详情', 304, 0, '2026-06-05 21:41:42');
INSERT INTO `notifications` VALUES (613, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（白色）21\"找到了匹配的寻物启示，请查看详情', 304, 0, '2026-06-05 21:41:42');
INSERT INTO `notifications` VALUES (614, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 305, 1, '2026-06-05 21:41:42');
INSERT INTO `notifications` VALUES (615, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（灰色）57\"找到了匹配的寻物启示，请查看详情', 305, 0, '2026-06-05 21:41:43');
INSERT INTO `notifications` VALUES (616, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 306, 1, '2026-06-05 21:41:43');
INSERT INTO `notifications` VALUES (617, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（红色）29\"找到了匹配的寻物启示，请查看详情', 306, 1, '2026-06-05 21:41:43');
INSERT INTO `notifications` VALUES (618, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（灰色）22\"找到了匹配的失物招领，请查看详情', 307, 1, '2026-06-05 21:41:43');
INSERT INTO `notifications` VALUES (619, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）43\"找到了匹配的寻物启示，请查看详情', 307, 1, '2026-06-05 21:41:44');
INSERT INTO `notifications` VALUES (620, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（蓝色）58\"找到了匹配的失物招领，请查看详情', 308, 1, '2026-06-05 21:41:44');
INSERT INTO `notifications` VALUES (621, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 308, 1, '2026-06-05 21:41:44');
INSERT INTO `notifications` VALUES (622, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 309, 0, '2026-06-05 21:41:45');
INSERT INTO `notifications` VALUES (623, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 309, 1, '2026-06-05 21:41:45');
INSERT INTO `notifications` VALUES (624, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）44\"找到了匹配的失物招领，请查看详情', 310, 1, '2026-06-05 21:41:45');
INSERT INTO `notifications` VALUES (625, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（蓝色）23\"找到了匹配的寻物启示，请查看详情', 310, 1, '2026-06-05 21:41:45');
INSERT INTO `notifications` VALUES (626, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）24\"找到了匹配的失物招领，请查看详情', 311, 0, '2026-06-05 21:41:46');
INSERT INTO `notifications` VALUES (627, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（红色）59\"找到了匹配的寻物启示，请查看详情', 311, 1, '2026-06-05 21:41:46');
INSERT INTO `notifications` VALUES (628, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）24\"找到了匹配的失物招领，请查看详情', 312, 0, '2026-06-05 21:41:46');
INSERT INTO `notifications` VALUES (629, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（白色）31\"找到了匹配的寻物启示，请查看详情', 312, 1, '2026-06-05 21:41:47');
INSERT INTO `notifications` VALUES (630, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（红色）24\"找到了匹配的失物招领，请查看详情', 313, 0, '2026-06-05 21:41:47');
INSERT INTO `notifications` VALUES (631, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（黑色）45\"找到了匹配的寻物启示，请查看详情', 313, 0, '2026-06-05 21:41:47');
INSERT INTO `notifications` VALUES (632, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）60\"找到了匹配的失物招领，请查看详情', 314, 0, '2026-06-05 21:41:48');
INSERT INTO `notifications` VALUES (633, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（黑色）25\"找到了匹配的寻物启示，请查看详情', 314, 1, '2026-06-05 21:41:48');
INSERT INTO `notifications` VALUES (634, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（灰色）32\"找到了匹配的失物招领，请查看详情', 315, 1, '2026-06-05 21:41:48');
INSERT INTO `notifications` VALUES (635, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（黑色）25\"找到了匹配的寻物启示，请查看详情', 315, 1, '2026-06-05 21:41:48');
INSERT INTO `notifications` VALUES (636, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（白色）46\"找到了匹配的失物招领，请查看详情', 316, 1, '2026-06-05 21:41:50');
INSERT INTO `notifications` VALUES (637, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（黑色）25\"找到了匹配的寻物启示，请查看详情', 316, 1, '2026-06-05 21:41:51');
INSERT INTO `notifications` VALUES (638, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（白色）26\"找到了匹配的失物招领，请查看详情', 317, 1, '2026-06-05 21:41:51');
INSERT INTO `notifications` VALUES (639, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（蓝色）33\"找到了匹配的寻物启示，请查看详情', 317, 0, '2026-06-05 21:41:51');
INSERT INTO `notifications` VALUES (640, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（白色）26\"找到了匹配的失物招领，请查看详情', 318, 1, '2026-06-05 21:41:52');
INSERT INTO `notifications` VALUES (641, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（灰色）47\"找到了匹配的寻物启示，请查看详情', 318, 1, '2026-06-05 21:41:52');
INSERT INTO `notifications` VALUES (642, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（红色）34\"找到了匹配的失物招领，请查看详情', 319, 1, '2026-06-05 21:41:52');
INSERT INTO `notifications` VALUES (643, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（灰色）27\"找到了匹配的寻物启示，请查看详情', 319, 0, '2026-06-05 21:41:53');
INSERT INTO `notifications` VALUES (644, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（蓝色）48\"找到了匹配的失物招领，请查看详情', 320, 0, '2026-06-05 21:41:54');
INSERT INTO `notifications` VALUES (645, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（灰色）27\"找到了匹配的寻物启示，请查看详情', 320, 0, '2026-06-05 21:41:55');
INSERT INTO `notifications` VALUES (646, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（蓝色）28\"找到了匹配的失物招领，请查看详情', 321, 1, '2026-06-05 21:41:55');
INSERT INTO `notifications` VALUES (647, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 321, 1, '2026-06-05 21:41:55');
INSERT INTO `notifications` VALUES (648, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（蓝色）28\"找到了匹配的失物招领，请查看详情', 322, 1, '2026-06-05 21:41:55');
INSERT INTO `notifications` VALUES (649, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（红色）49\"找到了匹配的寻物启示，请查看详情', 322, 1, '2026-06-05 21:41:56');
INSERT INTO `notifications` VALUES (650, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 323, 0, '2026-06-05 21:41:56');
INSERT INTO `notifications` VALUES (651, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（红色）29\"找到了匹配的寻物启示，请查看详情', 323, 1, '2026-06-05 21:41:56');
INSERT INTO `notifications` VALUES (652, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 324, 1, '2026-06-05 21:41:57');
INSERT INTO `notifications` VALUES (653, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（红色）29\"找到了匹配的寻物启示，请查看详情', 324, 1, '2026-06-05 21:41:57');
INSERT INTO `notifications` VALUES (654, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 325, 0, '2026-06-05 21:41:57');
INSERT INTO `notifications` VALUES (655, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 325, 1, '2026-06-05 21:41:57');
INSERT INTO `notifications` VALUES (656, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（黑色）30\"找到了匹配的失物招领，请查看详情', 326, 0, '2026-06-05 21:41:58');
INSERT INTO `notifications` VALUES (657, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 326, 0, '2026-06-05 21:41:58');
INSERT INTO `notifications` VALUES (658, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 327, 1, '2026-06-05 21:41:58');
INSERT INTO `notifications` VALUES (659, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（白色）31\"找到了匹配的寻物启示，请查看详情', 327, 1, '2026-06-05 21:41:59');
INSERT INTO `notifications` VALUES (660, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（灰色）52\"找到了匹配的失物招领，请查看详情', 328, 1, '2026-06-05 21:41:59');
INSERT INTO `notifications` VALUES (661, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（白色）31\"找到了匹配的寻物启示，请查看详情', 328, 1, '2026-06-05 21:41:59');
INSERT INTO `notifications` VALUES (662, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（灰色）32\"找到了匹配的失物招领，请查看详情', 329, 1, '2026-06-05 21:41:59');
INSERT INTO `notifications` VALUES (663, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 329, 0, '2026-06-05 21:42:00');
INSERT INTO `notifications` VALUES (664, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（灰色）32\"找到了匹配的失物招领，请查看详情', 330, 1, '2026-06-05 21:42:00');
INSERT INTO `notifications` VALUES (665, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（蓝色）53\"找到了匹配的寻物启示，请查看详情', 330, 1, '2026-06-05 21:42:00');
INSERT INTO `notifications` VALUES (666, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）40\"找到了匹配的失物招领，请查看详情', 331, 1, '2026-06-05 21:42:01');
INSERT INTO `notifications` VALUES (667, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（蓝色）33\"找到了匹配的寻物启示，请查看详情', 331, 0, '2026-06-05 21:42:01');
INSERT INTO `notifications` VALUES (668, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（红色）54\"找到了匹配的失物招领，请查看详情', 332, 0, '2026-06-05 21:42:01');
INSERT INTO `notifications` VALUES (669, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（蓝色）33\"找到了匹配的寻物启示，请查看详情', 332, 0, '2026-06-05 21:42:02');
INSERT INTO `notifications` VALUES (670, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（红色）34\"找到了匹配的失物招领，请查看详情', 333, 1, '2026-06-05 21:42:02');
INSERT INTO `notifications` VALUES (671, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）41\"找到了匹配的寻物启示，请查看详情', 333, 1, '2026-06-05 21:42:02');
INSERT INTO `notifications` VALUES (672, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（红色）34\"找到了匹配的失物招领，请查看详情', 334, 1, '2026-06-05 21:42:03');
INSERT INTO `notifications` VALUES (673, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（黑色）55\"找到了匹配的寻物启示，请查看详情', 334, 1, '2026-06-05 21:42:03');
INSERT INTO `notifications` VALUES (674, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）42\"找到了匹配的失物招领，请查看详情', 335, 0, '2026-06-05 21:42:03');
INSERT INTO `notifications` VALUES (675, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 335, 1, '2026-06-05 21:42:04');
INSERT INTO `notifications` VALUES (676, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（白色）56\"找到了匹配的失物招领，请查看详情', 336, 1, '2026-06-05 21:42:04');
INSERT INTO `notifications` VALUES (677, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 336, 1, '2026-06-05 21:42:04');
INSERT INTO `notifications` VALUES (678, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi电子产品（黑色）#1\"找到了匹配的失物招领，请查看详情', 337, 0, '2026-06-05 21:42:04');
INSERT INTO `notifications` VALUES (679, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 337, 1, '2026-06-05 21:42:05');
INSERT INTO `notifications` VALUES (680, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo电子产品（黑色）#5\"找到了匹配的失物招领，请查看详情', 338, 0, '2026-06-05 21:42:05');
INSERT INTO `notifications` VALUES (681, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 338, 1, '2026-06-05 21:42:05');
INSERT INTO `notifications` VALUES (682, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei电子产品（黑色）#9\"找到了匹配的失物招领，请查看详情', 339, 0, '2026-06-05 21:42:05');
INSERT INTO `notifications` VALUES (683, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 339, 1, '2026-06-05 21:42:08');
INSERT INTO `notifications` VALUES (684, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi电子产品（黑色）#13\"找到了匹配的失物招领，请查看详情', 340, 0, '2026-06-05 21:42:08');
INSERT INTO `notifications` VALUES (685, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 340, 1, '2026-06-05 21:42:08');
INSERT INTO `notifications` VALUES (686, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo电子产品（黑色）#17\"找到了匹配的失物招领，请查看详情', 341, 0, '2026-06-05 21:42:09');
INSERT INTO `notifications` VALUES (687, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 341, 1, '2026-06-05 21:42:09');
INSERT INTO `notifications` VALUES (688, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi 电子产品（黑色）#1\"找到了匹配的失物招领，请查看详情', 342, 0, '2026-06-05 21:42:09');
INSERT INTO `notifications` VALUES (689, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（黑色）35\"找到了匹配的寻物启示，请查看详情', 342, 1, '2026-06-05 21:42:09');
INSERT INTO `notifications` VALUES (690, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 343, 0, '2026-06-05 21:42:10');
INSERT INTO `notifications` VALUES (691, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）43\"找到了匹配的寻物启示，请查看详情', 343, 1, '2026-06-05 21:42:10');
INSERT INTO `notifications` VALUES (692, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 344, 0, '2026-06-05 21:42:10');
INSERT INTO `notifications` VALUES (693, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（灰色）57\"找到了匹配的寻物启示，请查看详情', 344, 0, '2026-06-05 21:42:11');
INSERT INTO `notifications` VALUES (694, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 345, 0, '2026-06-05 21:42:11');
INSERT INTO `notifications` VALUES (695, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple证件（白色）#2\"找到了匹配的寻物启示，请查看详情', 345, 1, '2026-06-05 21:42:11');
INSERT INTO `notifications` VALUES (696, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 346, 0, '2026-06-05 21:42:12');
INSERT INTO `notifications` VALUES (697, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo证件（白色）#6\"找到了匹配的寻物启示，请查看详情', 346, 1, '2026-06-05 21:42:12');
INSERT INTO `notifications` VALUES (698, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 347, 0, '2026-06-05 21:42:12');
INSERT INTO `notifications` VALUES (699, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO证件（白色）#10\"找到了匹配的寻物启示，请查看详情', 347, 1, '2026-06-05 21:42:12');
INSERT INTO `notifications` VALUES (700, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 348, 0, '2026-06-05 21:42:13');
INSERT INTO `notifications` VALUES (701, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple证件（白色）#14\"找到了匹配的寻物启示，请查看详情', 348, 1, '2026-06-05 21:42:13');
INSERT INTO `notifications` VALUES (702, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 349, 0, '2026-06-05 21:42:13');
INSERT INTO `notifications` VALUES (703, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo证件（白色）#18\"找到了匹配的寻物启示，请查看详情', 349, 1, '2026-06-05 21:42:14');
INSERT INTO `notifications` VALUES (704, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（白色）36\"找到了匹配的失物招领，请查看详情', 350, 0, '2026-06-05 21:42:14');
INSERT INTO `notifications` VALUES (705, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple 证件（白色）#2\"找到了匹配的寻物启示，请查看详情', 350, 1, '2026-06-05 21:42:14');
INSERT INTO `notifications` VALUES (706, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）44\"找到了匹配的失物招领，请查看详情', 351, 1, '2026-06-05 21:42:15');
INSERT INTO `notifications` VALUES (707, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 351, 1, '2026-06-05 21:42:15');
INSERT INTO `notifications` VALUES (708, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（蓝色）58\"找到了匹配的失物招领，请查看详情', 352, 1, '2026-06-05 21:42:15');
INSERT INTO `notifications` VALUES (709, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 352, 1, '2026-06-05 21:42:15');
INSERT INTO `notifications` VALUES (710, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei书籍（灰色）#3\"找到了匹配的失物招领，请查看详情', 353, 0, '2026-06-05 21:42:16');
INSERT INTO `notifications` VALUES (711, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 353, 1, '2026-06-05 21:42:16');
INSERT INTO `notifications` VALUES (712, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi书籍（灰色）#7\"找到了匹配的失物招领，请查看详情', 354, 0, '2026-06-05 21:42:16');
INSERT INTO `notifications` VALUES (713, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 354, 1, '2026-06-05 21:42:17');
INSERT INTO `notifications` VALUES (714, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo书籍（灰色）#11\"找到了匹配的失物招领，请查看详情', 355, 0, '2026-06-05 21:42:17');
INSERT INTO `notifications` VALUES (715, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 355, 1, '2026-06-05 21:42:18');
INSERT INTO `notifications` VALUES (716, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei书籍（灰色）#15\"找到了匹配的失物招领，请查看详情', 356, 0, '2026-06-05 21:42:18');
INSERT INTO `notifications` VALUES (717, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 356, 1, '2026-06-05 21:42:18');
INSERT INTO `notifications` VALUES (718, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Xiaomi书籍（灰色）#19\"找到了匹配的失物招领，请查看详情', 357, 0, '2026-06-05 21:42:19');
INSERT INTO `notifications` VALUES (719, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 357, 1, '2026-06-05 21:42:19');
INSERT INTO `notifications` VALUES (720, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Huawei 书籍（灰色）#3\"找到了匹配的失物招领，请查看详情', 358, 0, '2026-06-05 21:42:20');
INSERT INTO `notifications` VALUES (721, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（灰色）37\"找到了匹配的寻物启示，请查看详情', 358, 1, '2026-06-05 21:42:20');
INSERT INTO `notifications` VALUES (722, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 359, 1, '2026-06-05 21:42:21');
INSERT INTO `notifications` VALUES (723, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（黑色）45\"找到了匹配的寻物启示，请查看详情', 359, 0, '2026-06-05 21:42:21');
INSERT INTO `notifications` VALUES (724, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 360, 1, '2026-06-05 21:42:21');
INSERT INTO `notifications` VALUES (725, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（红色）59\"找到了匹配的寻物启示，请查看详情', 360, 1, '2026-06-05 21:42:22');
INSERT INTO `notifications` VALUES (726, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 361, 1, '2026-06-05 21:42:22');
INSERT INTO `notifications` VALUES (727, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO衣物（蓝色）#4\"找到了匹配的寻物启示，请查看详情', 361, 1, '2026-06-05 21:42:22');
INSERT INTO `notifications` VALUES (728, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 362, 1, '2026-06-05 21:42:23');
INSERT INTO `notifications` VALUES (729, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple衣物（蓝色）#8\"找到了匹配的寻物启示，请查看详情', 362, 1, '2026-06-05 21:42:23');
INSERT INTO `notifications` VALUES (730, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 363, 1, '2026-06-05 21:42:23');
INSERT INTO `notifications` VALUES (731, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Lenovo衣物（蓝色）#12\"找到了匹配的寻物启示，请查看详情', 363, 1, '2026-06-05 21:42:24');
INSERT INTO `notifications` VALUES (732, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 364, 1, '2026-06-05 21:42:25');
INSERT INTO `notifications` VALUES (733, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO衣物（蓝色）#16\"找到了匹配的寻物启示，请查看详情', 364, 1, '2026-06-05 21:42:25');
INSERT INTO `notifications` VALUES (734, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 365, 1, '2026-06-05 21:42:25');
INSERT INTO `notifications` VALUES (735, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到Apple衣物（蓝色）#20\"找到了匹配的寻物启示，请查看详情', 365, 1, '2026-06-05 21:42:25');
INSERT INTO `notifications` VALUES (736, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（蓝色）38\"找到了匹配的失物招领，请查看详情', 366, 1, '2026-06-05 21:42:26');
INSERT INTO `notifications` VALUES (737, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 捡到OPPO 衣物（蓝色）#4\"找到了匹配的寻物启示，请查看详情', 366, 1, '2026-06-05 21:42:26');
INSERT INTO `notifications` VALUES (738, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（白色）46\"找到了匹配的失物招领，请查看详情', 367, 1, '2026-06-05 21:42:26');
INSERT INTO `notifications` VALUES (739, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 367, 0, '2026-06-05 21:42:27');
INSERT INTO `notifications` VALUES (740, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）60\"找到了匹配的失物招领，请查看详情', 368, 0, '2026-06-05 21:42:27');
INSERT INTO `notifications` VALUES (741, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 368, 0, '2026-06-05 21:42:27');
INSERT INTO `notifications` VALUES (742, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失vivo 饰品（红色）#5\"找到了匹配的失物招领，请查看详情', 369, 0, '2026-06-05 21:42:27');
INSERT INTO `notifications` VALUES (743, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（红色）39\"找到了匹配的寻物启示，请查看详情', 369, 0, '2026-06-05 21:42:28');
INSERT INTO `notifications` VALUES (744, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（黑色）40\"找到了匹配的失物招领，请查看详情', 370, 1, '2026-06-05 21:42:28');
INSERT INTO `notifications` VALUES (745, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（灰色）47\"找到了匹配的寻物启示，请查看详情', 370, 1, '2026-06-05 21:42:28');
INSERT INTO `notifications` VALUES (746, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（蓝色）48\"找到了匹配的失物招领，请查看详情', 371, 0, '2026-06-05 21:42:29');
INSERT INTO `notifications` VALUES (747, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）41\"找到了匹配的寻物启示，请查看详情', 371, 1, '2026-06-05 21:42:29');
INSERT INTO `notifications` VALUES (748, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失Adidas 其他（白色）#8\"找到了匹配的失物招领，请查看详情', 372, 0, '2026-06-05 21:42:29');
INSERT INTO `notifications` VALUES (749, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（白色）41\"找到了匹配的寻物启示，请查看详情', 372, 1, '2026-06-05 21:42:30');
INSERT INTO `notifications` VALUES (750, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（灰色）42\"找到了匹配的失物招领，请查看详情', 373, 0, '2026-06-05 21:42:30');
INSERT INTO `notifications` VALUES (751, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（红色）49\"找到了匹配的寻物启示，请查看详情', 373, 1, '2026-06-05 21:42:30');
INSERT INTO `notifications` VALUES (752, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 374, 1, '2026-06-05 21:42:31');
INSERT INTO `notifications` VALUES (753, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（蓝色）43\"找到了匹配的寻物启示，请查看详情', 374, 1, '2026-06-05 21:42:31');
INSERT INTO `notifications` VALUES (754, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（红色）44\"找到了匹配的失物招领，请查看详情', 375, 1, '2026-06-05 21:42:31');
INSERT INTO `notifications` VALUES (755, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 375, 0, '2026-06-05 21:42:32');
INSERT INTO `notifications` VALUES (756, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（灰色）52\"找到了匹配的失物招领，请查看详情', 376, 1, '2026-06-05 21:42:32');
INSERT INTO `notifications` VALUES (757, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（黑色）45\"找到了匹配的寻物启示，请查看详情', 376, 0, '2026-06-05 21:42:32');
INSERT INTO `notifications` VALUES (758, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（白色）46\"找到了匹配的失物招领，请查看详情', 377, 1, '2026-06-05 21:42:33');
INSERT INTO `notifications` VALUES (759, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（蓝色）53\"找到了匹配的寻物启示，请查看详情', 377, 1, '2026-06-05 21:42:33');
INSERT INTO `notifications` VALUES (760, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失文具（红色）54\"找到了匹配的失物招领，请查看详情', 378, 0, '2026-06-05 21:42:33');
INSERT INTO `notifications` VALUES (761, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到文具（灰色）47\"找到了匹配的寻物启示，请查看详情', 378, 1, '2026-06-05 21:42:33');
INSERT INTO `notifications` VALUES (762, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（蓝色）48\"找到了匹配的失物招领，请查看详情', 379, 0, '2026-06-05 21:42:34');
INSERT INTO `notifications` VALUES (763, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到其他（黑色）55\"找到了匹配的寻物启示，请查看详情', 379, 1, '2026-06-05 21:42:34');
INSERT INTO `notifications` VALUES (764, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失电子产品（白色）56\"找到了匹配的失物招领，请查看详情', 380, 1, '2026-06-05 21:42:34');
INSERT INTO `notifications` VALUES (765, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到电子产品（红色）49\"找到了匹配的寻物启示，请查看详情', 380, 1, '2026-06-05 21:42:35');
INSERT INTO `notifications` VALUES (766, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（黑色）50\"找到了匹配的失物招领，请查看详情', 381, 1, '2026-06-05 21:42:35');
INSERT INTO `notifications` VALUES (767, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（灰色）57\"找到了匹配的寻物启示，请查看详情', 381, 0, '2026-06-05 21:42:35');
INSERT INTO `notifications` VALUES (768, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失书籍（蓝色）58\"找到了匹配的失物招领，请查看详情', 382, 1, '2026-06-05 21:42:36');
INSERT INTO `notifications` VALUES (769, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（白色）51\"找到了匹配的寻物启示，请查看详情', 382, 0, '2026-06-05 21:42:36');
INSERT INTO `notifications` VALUES (770, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失衣物（灰色）52\"找到了匹配的失物招领，请查看详情', 383, 1, '2026-06-05 21:42:36');
INSERT INTO `notifications` VALUES (771, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（红色）59\"找到了匹配的寻物启示，请查看详情', 383, 1, '2026-06-05 21:42:36');
INSERT INTO `notifications` VALUES (772, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（黑色）60\"找到了匹配的失物招领，请查看详情', 384, 0, '2026-06-05 21:42:37');
INSERT INTO `notifications` VALUES (773, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到饰品（蓝色）53\"找到了匹配的寻物启示，请查看详情', 384, 1, '2026-06-05 21:42:37');
INSERT INTO `notifications` VALUES (774, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失其他（白色）6\"找到了匹配的失物招领，请查看详情', 385, 0, '2026-06-07 12:38:38');
INSERT INTO `notifications` VALUES (775, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到证件（白色）1\"找到了匹配的寻物启示，请查看详情', 385, 1, '2026-06-07 12:38:39');
INSERT INTO `notifications` VALUES (776, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失证件（蓝色）8\"找到了匹配的失物招领，请查看详情', 386, 1, '2026-06-07 12:38:40');
INSERT INTO `notifications` VALUES (777, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到衣物（蓝色）3\"找到了匹配的寻物启示，请查看详情', 386, 0, '2026-06-07 12:38:41');
INSERT INTO `notifications` VALUES (778, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[MOCK] 丢失饰品（红色）4\"找到了匹配的失物招领，请查看详情', 387, 1, '2026-06-07 12:38:42');
INSERT INTO `notifications` VALUES (779, 49, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[MOCK] 拾到书籍（红色）9\"找到了匹配的寻物启示，请查看详情', 387, 0, '2026-06-07 12:38:43');
INSERT INTO `notifications` VALUES (780, 50, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"[E2E] user_qq 丢失iPhone 16 Pro\"找到了匹配的失物招领，请查看详情', 388, 1, '2026-06-07 18:41:02');
INSERT INTO `notifications` VALUES (781, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"[E2E] testuser 捡到iPhone 16 Pro\"找到了匹配的寻物启示，请查看详情', 388, 0, '2026-06-07 18:41:03');
INSERT INTO `notifications` VALUES (782, 34, 'VERIFICATION_RESULT', '物品审核未通过', '您发布的\"捡到高等数学教材\"未通过审核，原因：信息不够详细', 30, 0, '2026-06-07 19:32:41');
INSERT INTO `notifications` VALUES (783, 50, 'VERIFICATION_RESULT', '物品审核通过', '您发布的\"[审核E2E] lost 31962\"已审核通过，现在可以开始匹配了', 183, 1, '2026-06-07 19:32:42');
INSERT INTO `notifications` VALUES (784, 50, 'VERIFICATION_RESULT', '物品审核通过', '您发布的\"[E2E] campusadmin test 31962\"已审核通过，现在可以开始匹配了', 184, 1, '2026-06-07 19:32:44');
INSERT INTO `notifications` VALUES (785, 50, 'VERIFICATION_RESULT', '物品审核未通过', '您发布的\"[AdminUI-E2E] 模拟 AdminDashboard 审核\"未通过审核，原因：管理员审核未通过', 185, 1, '2026-06-07 19:46:35');
INSERT INTO `notifications` VALUES (786, 36, 'VERIFICATION_RESULT', '物品审核未通过', '您发布的\"丢失《高等数学》教材\"未通过审核，原因：管理员审核未通过', 27, 0, '2026-06-09 21:11:06');
INSERT INTO `notifications` VALUES (787, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 389, 0, '2026-06-09 21:49:53');
INSERT INTO `notifications` VALUES (788, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 389, 0, '2026-06-09 21:49:54');
INSERT INTO `notifications` VALUES (789, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 390, 0, '2026-06-09 21:49:55');
INSERT INTO `notifications` VALUES (790, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 390, 0, '2026-06-09 21:49:55');
INSERT INTO `notifications` VALUES (791, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 391, 0, '2026-06-09 21:49:56');
INSERT INTO `notifications` VALUES (792, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 391, 0, '2026-06-09 21:49:56');
INSERT INTO `notifications` VALUES (793, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 392, 0, '2026-06-09 21:49:56');
INSERT INTO `notifications` VALUES (794, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 392, 0, '2026-06-09 21:49:57');
INSERT INTO `notifications` VALUES (795, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 393, 0, '2026-06-09 21:49:57');
INSERT INTO `notifications` VALUES (796, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 393, 0, '2026-06-09 21:49:58');
INSERT INTO `notifications` VALUES (797, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 394, 0, '2026-06-09 21:49:58');
INSERT INTO `notifications` VALUES (798, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 394, 0, '2026-06-09 21:49:59');
INSERT INTO `notifications` VALUES (799, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 395, 0, '2026-06-09 21:49:59');
INSERT INTO `notifications` VALUES (800, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 395, 0, '2026-06-09 21:50:00');
INSERT INTO `notifications` VALUES (801, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 396, 0, '2026-06-09 21:50:00');
INSERT INTO `notifications` VALUES (802, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 396, 0, '2026-06-09 21:50:01');
INSERT INTO `notifications` VALUES (803, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 397, 0, '2026-06-09 21:50:01');
INSERT INTO `notifications` VALUES (804, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 397, 0, '2026-06-09 21:50:02');
INSERT INTO `notifications` VALUES (805, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 398, 0, '2026-06-09 21:50:03');
INSERT INTO `notifications` VALUES (806, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 398, 0, '2026-06-09 21:50:03');
INSERT INTO `notifications` VALUES (807, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 399, 0, '2026-06-09 21:50:04');
INSERT INTO `notifications` VALUES (808, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 399, 0, '2026-06-09 21:50:04');
INSERT INTO `notifications` VALUES (809, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 400, 0, '2026-06-09 21:50:05');
INSERT INTO `notifications` VALUES (810, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 400, 0, '2026-06-09 21:50:05');
INSERT INTO `notifications` VALUES (811, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 401, 0, '2026-06-09 21:50:09');
INSERT INTO `notifications` VALUES (812, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 401, 0, '2026-06-09 21:50:09');
INSERT INTO `notifications` VALUES (813, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 402, 0, '2026-06-09 21:50:10');
INSERT INTO `notifications` VALUES (814, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到AirPods Pro 2\"找到了匹配的寻物启示，请查看详情', 402, 0, '2026-06-09 21:50:10');
INSERT INTO `notifications` VALUES (815, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 403, 0, '2026-06-09 21:50:11');
INSERT INTO `notifications` VALUES (816, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Pro\"找到了匹配的寻物启示，请查看详情', 403, 0, '2026-06-09 21:50:11');
INSERT INTO `notifications` VALUES (817, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 404, 0, '2026-06-09 21:50:14');
INSERT INTO `notifications` VALUES (818, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到MacBook Pro\"找到了匹配的寻物启示，请查看详情', 404, 0, '2026-06-09 21:50:14');
INSERT INTO `notifications` VALUES (819, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失AirPods Pro 2\"找到了匹配的失物招领，请查看详情', 405, 0, '2026-06-09 21:50:15');
INSERT INTO `notifications` VALUES (820, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 405, 0, '2026-06-09 21:50:15');
INSERT INTO `notifications` VALUES (821, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPad Pro\"找到了匹配的失物招领，请查看详情', 406, 0, '2026-06-09 21:50:15');
INSERT INTO `notifications` VALUES (822, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 406, 0, '2026-06-09 21:50:16');
INSERT INTO `notifications` VALUES (823, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失MacBook Pro\"找到了匹配的失物招领，请查看详情', 407, 0, '2026-06-09 21:50:16');
INSERT INTO `notifications` VALUES (824, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 407, 0, '2026-06-09 21:50:17');
INSERT INTO `notifications` VALUES (825, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失华为Mate 60\"找到了匹配的失物招领，请查看详情', 408, 0, '2026-06-09 21:50:17');
INSERT INTO `notifications` VALUES (826, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到华为Mate 60\"找到了匹配的寻物启示，请查看详情', 408, 0, '2026-06-09 21:50:18');
INSERT INTO `notifications` VALUES (827, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失小米14\"找到了匹配的失物招领，请查看详情', 409, 0, '2026-06-09 21:50:18');
INSERT INTO `notifications` VALUES (828, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到小米14\"找到了匹配的寻物启示，请查看详情', 409, 0, '2026-06-09 21:50:19');
INSERT INTO `notifications` VALUES (829, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失AirPods Pro 2\"找到了匹配的失物招领，请查看详情', 410, 0, '2026-06-09 21:50:19');
INSERT INTO `notifications` VALUES (830, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到AirPods Pro 2\"找到了匹配的寻物启示，请查看详情', 410, 0, '2026-06-09 21:50:19');
INSERT INTO `notifications` VALUES (831, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失AirPods Pro 2\"找到了匹配的失物招领，请查看详情', 411, 0, '2026-06-09 21:50:20');
INSERT INTO `notifications` VALUES (832, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 411, 0, '2026-06-09 21:50:20');
INSERT INTO `notifications` VALUES (833, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 412, 0, '2026-06-09 21:50:21');
INSERT INTO `notifications` VALUES (834, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到AirPods Pro 2\"找到了匹配的寻物启示，请查看详情', 412, 0, '2026-06-09 21:50:21');
INSERT INTO `notifications` VALUES (835, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPad Pro\"找到了匹配的失物招领，请查看详情', 413, 0, '2026-06-09 21:50:22');
INSERT INTO `notifications` VALUES (836, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Pro\"找到了匹配的寻物启示，请查看详情', 413, 0, '2026-06-09 21:50:22');
INSERT INTO `notifications` VALUES (837, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPad Pro\"找到了匹配的失物招领，请查看详情', 414, 0, '2026-06-09 21:50:23');
INSERT INTO `notifications` VALUES (838, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 414, 0, '2026-06-09 21:50:23');
INSERT INTO `notifications` VALUES (839, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 415, 0, '2026-06-09 21:50:24');
INSERT INTO `notifications` VALUES (840, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Pro\"找到了匹配的寻物启示，请查看详情', 415, 0, '2026-06-09 21:50:24');
INSERT INTO `notifications` VALUES (841, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失MacBook Pro\"找到了匹配的失物招领，请查看详情', 416, 0, '2026-06-09 21:50:24');
INSERT INTO `notifications` VALUES (842, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到MacBook Pro\"找到了匹配的寻物启示，请查看详情', 416, 0, '2026-06-09 21:50:26');
INSERT INTO `notifications` VALUES (843, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失MacBook Pro\"找到了匹配的失物招领，请查看详情', 417, 0, '2026-06-09 21:50:27');
INSERT INTO `notifications` VALUES (844, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 417, 0, '2026-06-09 21:50:27');
INSERT INTO `notifications` VALUES (845, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 418, 0, '2026-06-09 21:50:28');
INSERT INTO `notifications` VALUES (846, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到MacBook Pro\"找到了匹配的寻物启示，请查看详情', 418, 0, '2026-06-09 21:50:29');
INSERT INTO `notifications` VALUES (847, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 419, 0, '2026-06-09 21:50:29');
INSERT INTO `notifications` VALUES (848, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 419, 0, '2026-06-09 21:50:32');
INSERT INTO `notifications` VALUES (849, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Anker充电宝\"找到了匹配的失物招领，请查看详情', 420, 0, '2026-06-09 21:50:32');
INSERT INTO `notifications` VALUES (850, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Anker充电宝\"找到了匹配的寻物启示，请查看详情', 420, 0, '2026-06-09 21:50:32');
INSERT INTO `notifications` VALUES (851, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 421, 0, '2026-06-09 21:50:33');
INSERT INTO `notifications` VALUES (852, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到雨伞\"找到了匹配的寻物启示，请查看详情', 421, 0, '2026-06-09 21:50:33');
INSERT INTO `notifications` VALUES (853, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 422, 0, '2026-06-09 21:50:34');
INSERT INTO `notifications` VALUES (854, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钱包\"找到了匹配的寻物启示，请查看详情', 422, 0, '2026-06-09 21:50:34');
INSERT INTO `notifications` VALUES (855, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 423, 0, '2026-06-09 21:50:35');
INSERT INTO `notifications` VALUES (856, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 423, 0, '2026-06-09 21:50:35');
INSERT INTO `notifications` VALUES (857, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 424, 0, '2026-06-09 21:50:35');
INSERT INTO `notifications` VALUES (858, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到保温杯\"找到了匹配的寻物启示，请查看详情', 424, 0, '2026-06-09 21:50:36');
INSERT INTO `notifications` VALUES (859, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 425, 0, '2026-06-09 21:50:38');
INSERT INTO `notifications` VALUES (860, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 425, 0, '2026-06-09 21:50:39');
INSERT INTO `notifications` VALUES (861, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失保温杯\"找到了匹配的失物招领，请查看详情', 426, 0, '2026-06-09 21:50:39');
INSERT INTO `notifications` VALUES (862, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到保温杯\"找到了匹配的寻物启示，请查看详情', 426, 0, '2026-06-09 21:50:39');
INSERT INTO `notifications` VALUES (863, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失保温杯\"找到了匹配的失物招领，请查看详情', 427, 0, '2026-06-09 21:50:40');
INSERT INTO `notifications` VALUES (864, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 427, 0, '2026-06-09 21:50:42');
INSERT INTO `notifications` VALUES (865, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失高等数学课本\"找到了匹配的失物招领，请查看详情', 428, 0, '2026-06-09 21:50:42');
INSERT INTO `notifications` VALUES (866, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到计算机基础\"找到了匹配的寻物启示，请查看详情', 428, 0, '2026-06-09 21:50:43');
INSERT INTO `notifications` VALUES (867, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钱包\"找到了匹配的失物招领，请查看详情', 429, 0, '2026-06-09 21:50:45');
INSERT INTO `notifications` VALUES (868, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钱包\"找到了匹配的寻物启示，请查看详情', 429, 0, '2026-06-09 21:50:45');
INSERT INTO `notifications` VALUES (869, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钱包\"找到了匹配的失物招领，请查看详情', 430, 0, '2026-06-09 21:50:45');
INSERT INTO `notifications` VALUES (870, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钥匙串\"找到了匹配的寻物启示，请查看详情', 430, 0, '2026-06-09 21:50:46');
INSERT INTO `notifications` VALUES (871, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钥匙串\"找到了匹配的失物招领，请查看详情', 431, 0, '2026-06-09 21:50:46');
INSERT INTO `notifications` VALUES (872, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钥匙串\"找到了匹配的寻物启示，请查看详情', 431, 0, '2026-06-09 21:50:47');
INSERT INTO `notifications` VALUES (873, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钥匙串\"找到了匹配的失物招领，请查看详情', 432, 0, '2026-06-09 21:50:47');
INSERT INTO `notifications` VALUES (874, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 432, 0, '2026-06-09 21:50:48');
INSERT INTO `notifications` VALUES (875, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 433, 0, '2026-06-09 21:50:48');
INSERT INTO `notifications` VALUES (876, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 433, 0, '2026-06-09 21:50:49');
INSERT INTO `notifications` VALUES (877, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 434, 0, '2026-06-09 21:50:49');
INSERT INTO `notifications` VALUES (878, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到笔记本\"找到了匹配的寻物启示，请查看详情', 434, 0, '2026-06-09 21:50:49');
INSERT INTO `notifications` VALUES (879, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 435, 0, '2026-06-09 21:50:50');
INSERT INTO `notifications` VALUES (880, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到运动水杯\"找到了匹配的寻物启示，请查看详情', 435, 0, '2026-06-09 21:50:50');
INSERT INTO `notifications` VALUES (881, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 436, 0, '2026-06-09 21:50:51');
INSERT INTO `notifications` VALUES (882, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到雨伞\"找到了匹配的寻物启示，请查看详情', 436, 0, '2026-06-09 21:50:51');
INSERT INTO `notifications` VALUES (883, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 437, 0, '2026-06-09 21:50:52');
INSERT INTO `notifications` VALUES (884, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 437, 0, '2026-06-09 21:50:52');
INSERT INTO `notifications` VALUES (885, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 438, 0, '2026-06-09 21:50:53');
INSERT INTO `notifications` VALUES (886, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 438, 0, '2026-06-09 21:50:53');
INSERT INTO `notifications` VALUES (887, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 439, 0, '2026-06-09 21:50:54');
INSERT INTO `notifications` VALUES (888, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 439, 0, '2026-06-09 21:50:54');
INSERT INTO `notifications` VALUES (889, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 440, 0, '2026-06-09 21:50:55');
INSERT INTO `notifications` VALUES (890, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 440, 0, '2026-06-09 21:50:55');
INSERT INTO `notifications` VALUES (891, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 441, 0, '2026-06-09 21:50:56');
INSERT INTO `notifications` VALUES (892, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钱包\"找到了匹配的寻物启示，请查看详情', 441, 0, '2026-06-09 21:50:56');
INSERT INTO `notifications` VALUES (893, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 442, 0, '2026-06-09 21:50:56');
INSERT INTO `notifications` VALUES (894, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到U盘\"找到了匹配的寻物启示，请查看详情', 442, 0, '2026-06-09 21:50:57');
INSERT INTO `notifications` VALUES (895, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 443, 0, '2026-06-09 21:50:57');
INSERT INTO `notifications` VALUES (896, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到笔记本\"找到了匹配的寻物启示，请查看详情', 443, 0, '2026-06-09 21:50:58');
INSERT INTO `notifications` VALUES (897, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失笔记本\"找到了匹配的失物招领，请查看详情', 444, 0, '2026-06-09 21:50:58');
INSERT INTO `notifications` VALUES (898, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到笔记本\"找到了匹配的寻物启示，请查看详情', 444, 0, '2026-06-09 21:50:59');
INSERT INTO `notifications` VALUES (899, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失笔记本\"找到了匹配的失物招领，请查看详情', 445, 0, '2026-06-09 21:50:59');
INSERT INTO `notifications` VALUES (900, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到保温杯\"找到了匹配的寻物启示，请查看详情', 445, 0, '2026-06-09 21:51:00');
INSERT INTO `notifications` VALUES (901, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失笔记本\"找到了匹配的失物招领，请查看详情', 446, 0, '2026-06-09 21:51:00');
INSERT INTO `notifications` VALUES (902, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到运动水杯\"找到了匹配的寻物启示，请查看详情', 446, 0, '2026-06-09 21:51:00');
INSERT INTO `notifications` VALUES (903, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失运动水杯\"找到了匹配的失物招领，请查看详情', 447, 0, '2026-06-09 21:51:01');
INSERT INTO `notifications` VALUES (904, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到运动水杯\"找到了匹配的寻物启示，请查看详情', 447, 0, '2026-06-09 21:51:01');
INSERT INTO `notifications` VALUES (905, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失运动水杯\"找到了匹配的失物招领，请查看详情', 448, 0, '2026-06-09 21:51:05');
INSERT INTO `notifications` VALUES (906, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 448, 0, '2026-06-09 21:51:05');
INSERT INTO `notifications` VALUES (907, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失有线耳机\"找到了匹配的失物招领，请查看详情', 449, 0, '2026-06-09 21:51:06');
INSERT INTO `notifications` VALUES (908, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 449, 0, '2026-06-09 21:51:06');
INSERT INTO `notifications` VALUES (909, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失英语四级真题\"找到了匹配的失物招领，请查看详情', 450, 0, '2026-06-09 21:51:07');
INSERT INTO `notifications` VALUES (910, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到线性代数\"找到了匹配的寻物启示，请查看详情', 450, 0, '2026-06-09 21:51:07');
INSERT INTO `notifications` VALUES (911, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失U盘\"找到了匹配的失物招领，请查看详情', 451, 0, '2026-06-09 21:51:08');
INSERT INTO `notifications` VALUES (912, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到U盘\"找到了匹配的寻物启示，请查看详情', 451, 0, '2026-06-09 21:51:08');
INSERT INTO `notifications` VALUES (913, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失U盘\"找到了匹配的失物招领，请查看详情', 452, 0, '2026-06-09 21:51:09');
INSERT INTO `notifications` VALUES (914, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 452, 0, '2026-06-09 21:51:09');
INSERT INTO `notifications` VALUES (915, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 453, 0, '2026-06-09 21:53:07');
INSERT INTO `notifications` VALUES (916, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 453, 0, '2026-06-09 21:53:08');
INSERT INTO `notifications` VALUES (917, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 454, 0, '2026-06-09 21:53:11');
INSERT INTO `notifications` VALUES (918, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 454, 0, '2026-06-09 21:53:11');
INSERT INTO `notifications` VALUES (919, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 455, 0, '2026-06-09 21:53:12');
INSERT INTO `notifications` VALUES (920, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 455, 0, '2026-06-09 21:53:12');
INSERT INTO `notifications` VALUES (921, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 456, 0, '2026-06-09 21:53:13');
INSERT INTO `notifications` VALUES (922, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 456, 0, '2026-06-09 21:53:13');
INSERT INTO `notifications` VALUES (923, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 457, 0, '2026-06-09 21:53:14');
INSERT INTO `notifications` VALUES (924, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 457, 0, '2026-06-09 21:53:14');
INSERT INTO `notifications` VALUES (925, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 458, 0, '2026-06-09 21:53:15');
INSERT INTO `notifications` VALUES (926, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 458, 0, '2026-06-09 21:53:15');
INSERT INTO `notifications` VALUES (927, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 459, 0, '2026-06-09 21:53:16');
INSERT INTO `notifications` VALUES (928, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 459, 0, '2026-06-09 21:53:16');
INSERT INTO `notifications` VALUES (929, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失校园卡\"找到了匹配的失物招领，请查看详情', 460, 0, '2026-06-09 21:53:16');
INSERT INTO `notifications` VALUES (930, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到校园卡\"找到了匹配的寻物启示，请查看详情', 460, 0, '2026-06-09 21:53:17');
INSERT INTO `notifications` VALUES (931, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 461, 0, '2026-06-09 21:53:17');
INSERT INTO `notifications` VALUES (932, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 461, 0, '2026-06-09 21:53:18');
INSERT INTO `notifications` VALUES (933, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 462, 0, '2026-06-09 21:53:18');
INSERT INTO `notifications` VALUES (934, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 462, 0, '2026-06-09 21:53:21');
INSERT INTO `notifications` VALUES (935, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 463, 0, '2026-06-09 21:53:21');
INSERT INTO `notifications` VALUES (936, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 463, 0, '2026-06-09 21:53:22');
INSERT INTO `notifications` VALUES (937, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失身份证\"找到了匹配的失物招领，请查看详情', 464, 0, '2026-06-09 21:53:22');
INSERT INTO `notifications` VALUES (938, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到身份证\"找到了匹配的寻物启示，请查看详情', 464, 0, '2026-06-09 21:53:23');
INSERT INTO `notifications` VALUES (939, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 465, 0, '2026-06-09 21:53:23');
INSERT INTO `notifications` VALUES (940, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 465, 0, '2026-06-09 21:53:24');
INSERT INTO `notifications` VALUES (941, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 466, 0, '2026-06-09 21:53:24');
INSERT INTO `notifications` VALUES (942, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到AirPods Pro 2\"找到了匹配的寻物启示，请查看详情', 466, 0, '2026-06-09 21:53:25');
INSERT INTO `notifications` VALUES (943, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 467, 0, '2026-06-09 21:53:25');
INSERT INTO `notifications` VALUES (944, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Pro\"找到了匹配的寻物启示，请查看详情', 467, 0, '2026-06-09 21:53:26');
INSERT INTO `notifications` VALUES (945, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPhone 15\"找到了匹配的失物招领，请查看详情', 468, 0, '2026-06-09 21:53:26');
INSERT INTO `notifications` VALUES (946, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到MacBook Pro\"找到了匹配的寻物启示，请查看详情', 468, 0, '2026-06-09 21:53:26');
INSERT INTO `notifications` VALUES (947, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失AirPods Pro 2\"找到了匹配的失物招领，请查看详情', 469, 0, '2026-06-09 21:53:27');
INSERT INTO `notifications` VALUES (948, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 469, 0, '2026-06-09 21:53:27');
INSERT INTO `notifications` VALUES (949, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPad Pro\"找到了匹配的失物招领，请查看详情', 470, 0, '2026-06-09 21:53:28');
INSERT INTO `notifications` VALUES (950, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 470, 0, '2026-06-09 21:53:28');
INSERT INTO `notifications` VALUES (951, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失MacBook Pro\"找到了匹配的失物招领，请查看详情', 471, 0, '2026-06-09 21:53:29');
INSERT INTO `notifications` VALUES (952, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPhone 15\"找到了匹配的寻物启示，请查看详情', 471, 0, '2026-06-09 21:53:29');
INSERT INTO `notifications` VALUES (953, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失华为Mate 60\"找到了匹配的失物招领，请查看详情', 472, 0, '2026-06-09 21:53:30');
INSERT INTO `notifications` VALUES (954, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到华为Mate 60\"找到了匹配的寻物启示，请查看详情', 472, 0, '2026-06-09 21:53:30');
INSERT INTO `notifications` VALUES (955, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失小米14\"找到了匹配的失物招领，请查看详情', 473, 0, '2026-06-09 21:53:31');
INSERT INTO `notifications` VALUES (956, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到小米14\"找到了匹配的寻物启示，请查看详情', 473, 0, '2026-06-09 21:53:31');
INSERT INTO `notifications` VALUES (957, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失AirPods Pro 2\"找到了匹配的失物招领，请查看详情', 474, 0, '2026-06-09 21:53:31');
INSERT INTO `notifications` VALUES (958, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到AirPods Pro 2\"找到了匹配的寻物启示，请查看详情', 474, 0, '2026-06-09 21:53:32');
INSERT INTO `notifications` VALUES (959, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失AirPods Pro 2\"找到了匹配的失物招领，请查看详情', 475, 0, '2026-06-09 21:53:32');
INSERT INTO `notifications` VALUES (960, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 475, 0, '2026-06-09 21:53:35');
INSERT INTO `notifications` VALUES (961, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 476, 0, '2026-06-09 21:53:37');
INSERT INTO `notifications` VALUES (962, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到AirPods Pro 2\"找到了匹配的寻物启示，请查看详情', 476, 0, '2026-06-09 21:53:37');
INSERT INTO `notifications` VALUES (963, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPad Pro\"找到了匹配的失物招领，请查看详情', 477, 0, '2026-06-09 21:53:38');
INSERT INTO `notifications` VALUES (964, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Pro\"找到了匹配的寻物启示，请查看详情', 477, 0, '2026-06-09 21:53:38');
INSERT INTO `notifications` VALUES (965, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失iPad Pro\"找到了匹配的失物招领，请查看详情', 478, 0, '2026-06-09 21:53:39');
INSERT INTO `notifications` VALUES (966, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 478, 0, '2026-06-09 21:53:39');
INSERT INTO `notifications` VALUES (967, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 479, 0, '2026-06-09 21:53:39');
INSERT INTO `notifications` VALUES (968, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到iPad Pro\"找到了匹配的寻物启示，请查看详情', 479, 0, '2026-06-09 21:53:40');
INSERT INTO `notifications` VALUES (969, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失MacBook Pro\"找到了匹配的失物招领，请查看详情', 480, 0, '2026-06-09 21:53:42');
INSERT INTO `notifications` VALUES (970, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到MacBook Pro\"找到了匹配的寻物启示，请查看详情', 480, 0, '2026-06-09 21:53:42');
INSERT INTO `notifications` VALUES (971, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失MacBook Pro\"找到了匹配的失物招领，请查看详情', 481, 0, '2026-06-09 21:53:42');
INSERT INTO `notifications` VALUES (972, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 481, 0, '2026-06-09 21:53:43');
INSERT INTO `notifications` VALUES (973, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 482, 0, '2026-06-09 21:53:43');
INSERT INTO `notifications` VALUES (974, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到MacBook Pro\"找到了匹配的寻物启示，请查看详情', 482, 0, '2026-06-09 21:53:44');
INSERT INTO `notifications` VALUES (975, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Apple Watch\"找到了匹配的失物招领，请查看详情', 483, 0, '2026-06-09 21:53:46');
INSERT INTO `notifications` VALUES (976, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Apple Watch\"找到了匹配的寻物启示，请查看详情', 483, 0, '2026-06-09 21:53:47');
INSERT INTO `notifications` VALUES (977, 34, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失Anker充电宝\"找到了匹配的失物招领，请查看详情', 484, 0, '2026-06-09 21:53:48');
INSERT INTO `notifications` VALUES (978, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到Anker充电宝\"找到了匹配的寻物启示，请查看详情', 484, 0, '2026-06-09 21:53:48');
INSERT INTO `notifications` VALUES (979, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 485, 0, '2026-06-09 21:53:49');
INSERT INTO `notifications` VALUES (980, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到雨伞\"找到了匹配的寻物启示，请查看详情', 485, 0, '2026-06-09 21:53:49');
INSERT INTO `notifications` VALUES (981, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 486, 0, '2026-06-09 21:53:50');
INSERT INTO `notifications` VALUES (982, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钱包\"找到了匹配的寻物启示，请查看详情', 486, 0, '2026-06-09 21:53:50');
INSERT INTO `notifications` VALUES (983, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 487, 0, '2026-06-09 21:53:51');
INSERT INTO `notifications` VALUES (984, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 487, 0, '2026-06-09 21:53:51');
INSERT INTO `notifications` VALUES (985, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 488, 0, '2026-06-09 21:53:51');
INSERT INTO `notifications` VALUES (986, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到保温杯\"找到了匹配的寻物启示，请查看详情', 488, 0, '2026-06-09 21:53:52');
INSERT INTO `notifications` VALUES (987, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失雨伞\"找到了匹配的失物招领，请查看详情', 489, 0, '2026-06-09 21:53:52');
INSERT INTO `notifications` VALUES (988, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 489, 0, '2026-06-09 21:53:53');
INSERT INTO `notifications` VALUES (989, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失保温杯\"找到了匹配的失物招领，请查看详情', 490, 0, '2026-06-09 21:53:53');
INSERT INTO `notifications` VALUES (990, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到保温杯\"找到了匹配的寻物启示，请查看详情', 490, 0, '2026-06-09 21:53:54');
INSERT INTO `notifications` VALUES (991, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失保温杯\"找到了匹配的失物招领，请查看详情', 491, 0, '2026-06-09 21:53:54');
INSERT INTO `notifications` VALUES (992, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 491, 0, '2026-06-09 21:53:55');
INSERT INTO `notifications` VALUES (993, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失高等数学课本\"找到了匹配的失物招领，请查看详情', 492, 0, '2026-06-09 21:53:55');
INSERT INTO `notifications` VALUES (994, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到计算机基础\"找到了匹配的寻物启示，请查看详情', 492, 0, '2026-06-09 21:53:55');
INSERT INTO `notifications` VALUES (995, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钱包\"找到了匹配的失物招领，请查看详情', 493, 0, '2026-06-09 21:53:56');
INSERT INTO `notifications` VALUES (996, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钱包\"找到了匹配的寻物启示，请查看详情', 493, 0, '2026-06-09 21:53:56');
INSERT INTO `notifications` VALUES (997, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钱包\"找到了匹配的失物招领，请查看详情', 494, 0, '2026-06-09 21:53:58');
INSERT INTO `notifications` VALUES (998, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钥匙串\"找到了匹配的寻物启示，请查看详情', 494, 0, '2026-06-09 21:53:59');
INSERT INTO `notifications` VALUES (999, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钥匙串\"找到了匹配的失物招领，请查看详情', 495, 0, '2026-06-09 21:53:59');
INSERT INTO `notifications` VALUES (1000, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钥匙串\"找到了匹配的寻物启示，请查看详情', 495, 0, '2026-06-09 21:54:00');
INSERT INTO `notifications` VALUES (1001, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失钥匙串\"找到了匹配的失物招领，请查看详情', 496, 0, '2026-06-09 21:54:02');
INSERT INTO `notifications` VALUES (1002, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 496, 0, '2026-06-09 21:54:02');
INSERT INTO `notifications` VALUES (1003, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 497, 0, '2026-06-09 21:54:03');
INSERT INTO `notifications` VALUES (1004, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 497, 0, '2026-06-09 21:54:03');
INSERT INTO `notifications` VALUES (1005, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 498, 0, '2026-06-09 21:54:04');
INSERT INTO `notifications` VALUES (1006, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到笔记本\"找到了匹配的寻物启示，请查看详情', 498, 0, '2026-06-09 21:54:04');
INSERT INTO `notifications` VALUES (1007, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 499, 0, '2026-06-09 21:54:05');
INSERT INTO `notifications` VALUES (1008, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到运动水杯\"找到了匹配的寻物启示，请查看详情', 499, 0, '2026-06-09 21:54:05');
INSERT INTO `notifications` VALUES (1009, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 500, 0, '2026-06-09 21:54:06');
INSERT INTO `notifications` VALUES (1010, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到雨伞\"找到了匹配的寻物启示，请查看详情', 500, 0, '2026-06-09 21:54:06');
INSERT INTO `notifications` VALUES (1011, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失书包\"找到了匹配的失物招领，请查看详情', 501, 0, '2026-06-09 21:54:06');
INSERT INTO `notifications` VALUES (1012, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 501, 0, '2026-06-09 21:54:07');
INSERT INTO `notifications` VALUES (1013, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 502, 0, '2026-06-09 21:54:10');
INSERT INTO `notifications` VALUES (1014, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 502, 0, '2026-06-09 21:54:11');
INSERT INTO `notifications` VALUES (1015, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 503, 0, '2026-06-09 21:54:11');
INSERT INTO `notifications` VALUES (1016, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到书包\"找到了匹配的寻物启示，请查看详情', 503, 0, '2026-06-09 21:54:12');
INSERT INTO `notifications` VALUES (1017, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 504, 0, '2026-06-09 21:54:12');
INSERT INTO `notifications` VALUES (1018, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 504, 0, '2026-06-09 21:54:13');
INSERT INTO `notifications` VALUES (1019, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 505, 0, '2026-06-09 21:54:13');
INSERT INTO `notifications` VALUES (1020, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到钱包\"找到了匹配的寻物启示，请查看详情', 505, 0, '2026-06-09 21:54:13');
INSERT INTO `notifications` VALUES (1021, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 506, 0, '2026-06-09 21:54:14');
INSERT INTO `notifications` VALUES (1022, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到U盘\"找到了匹配的寻物启示，请查看详情', 506, 0, '2026-06-09 21:54:14');
INSERT INTO `notifications` VALUES (1023, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失眼镜\"找到了匹配的失物招领，请查看详情', 507, 0, '2026-06-09 21:54:15');
INSERT INTO `notifications` VALUES (1024, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到笔记本\"找到了匹配的寻物启示，请查看详情', 507, 0, '2026-06-09 21:54:15');
INSERT INTO `notifications` VALUES (1025, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失笔记本\"找到了匹配的失物招领，请查看详情', 508, 0, '2026-06-09 21:54:16');
INSERT INTO `notifications` VALUES (1026, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到笔记本\"找到了匹配的寻物启示，请查看详情', 508, 0, '2026-06-09 21:54:16');
INSERT INTO `notifications` VALUES (1027, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失笔记本\"找到了匹配的失物招领，请查看详情', 509, 0, '2026-06-09 21:54:16');
INSERT INTO `notifications` VALUES (1028, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到保温杯\"找到了匹配的寻物启示，请查看详情', 509, 0, '2026-06-09 21:54:17');
INSERT INTO `notifications` VALUES (1029, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失笔记本\"找到了匹配的失物招领，请查看详情', 510, 0, '2026-06-09 21:54:17');
INSERT INTO `notifications` VALUES (1030, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到运动水杯\"找到了匹配的寻物启示，请查看详情', 510, 0, '2026-06-09 21:54:18');
INSERT INTO `notifications` VALUES (1031, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失运动水杯\"找到了匹配的失物招领，请查看详情', 511, 0, '2026-06-09 21:54:18');
INSERT INTO `notifications` VALUES (1032, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到运动水杯\"找到了匹配的寻物启示，请查看详情', 511, 0, '2026-06-09 21:54:19');
INSERT INTO `notifications` VALUES (1033, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失运动水杯\"找到了匹配的失物招领，请查看详情', 512, 0, '2026-06-09 21:54:19');
INSERT INTO `notifications` VALUES (1034, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 512, 0, '2026-06-09 21:54:20');
INSERT INTO `notifications` VALUES (1035, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失有线耳机\"找到了匹配的失物招领，请查看详情', 513, 0, '2026-06-09 21:54:20');
INSERT INTO `notifications` VALUES (1036, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到耳机\"找到了匹配的寻物启示，请查看详情', 513, 0, '2026-06-09 21:54:21');
INSERT INTO `notifications` VALUES (1037, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失英语四级真题\"找到了匹配的失物招领，请查看详情', 514, 0, '2026-06-09 21:54:21');
INSERT INTO `notifications` VALUES (1038, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到线性代数\"找到了匹配的寻物启示，请查看详情', 514, 0, '2026-06-09 21:54:21');
INSERT INTO `notifications` VALUES (1039, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失U盘\"找到了匹配的失物招领，请查看详情', 515, 0, '2026-06-09 21:54:22');
INSERT INTO `notifications` VALUES (1040, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到U盘\"找到了匹配的寻物启示，请查看详情', 515, 1, '2026-06-09 21:54:22');
INSERT INTO `notifications` VALUES (1041, 33, 'MATCH_FOUND', '发现匹配物品', '您发布的【寻物启示】\"丢失U盘\"找到了匹配的失物招领，请查看详情', 516, 0, '2026-06-09 21:54:23');
INSERT INTO `notifications` VALUES (1042, 32, 'MATCH_FOUND', '发现匹配物品', '您发布的【失物招领】\"捡到眼镜\"找到了匹配的寻物启示，请查看详情', 516, 1, '2026-06-09 21:54:23');
INSERT INTO `notifications` VALUES (1043, 32, 'ITEM_PENDING', '新物品待审核', '用户发布了一条新的寻物信息【测试物品】，请及时审核。', 335, 0, '2026-06-10 12:19:40');
INSERT INTO `notifications` VALUES (1044, 33, 'ITEM_PENDING', '新物品待审核', '用户发布了一条新的寻物信息【测试物品】，请及时审核。', 335, 0, '2026-06-10 12:19:40');

-- ----------------------------
-- Table structure for user_identity_verifications
-- ----------------------------
DROP TABLE IF EXISTS `user_identity_verifications`;
CREATE TABLE `user_identity_verifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','VERIFIED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `review_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `reviewed_by` bigint NULL DEFAULT NULL,
  `reviewed_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_identity_verifications
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢ㄦ埛ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鍔犲瘑鍚庣殑瀵嗙爜',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閭??',
  `student_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瀛﹀彿/宸ュ彿',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鎵嬫満鍙',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '身份证号',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0绂佺敤 1姝ｅ父',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '鏈?悗鐧诲綍鏃堕棿',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎: 0鏈?垹 1宸插垹',
  `role` enum('SUPER_ADMIN','CAMPUS_ADMIN','USER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'USER',
  `notification_in_app` int NULL DEFAULT 1 COMMENT '站内通知',
  `notification_email` int NULL DEFAULT 1 COMMENT '邮件通知',
  `notification_match` int NULL DEFAULT 1 COMMENT '匹配提醒',
  `notification_verification` int NULL DEFAULT 1 COMMENT '审核提醒',
  `identity_status` enum('UNVERIFIED','PENDING','VERIFIED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNVERIFIED' COMMENT '实名认证状态',
  `identity_verified_at` datetime NULL DEFAULT NULL COMMENT '实名认证通过时间',
  `email_active` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci GENERATED ALWAYS AS ((case when (`deleted` = 0) then `email` else NULL end)) VIRTUAL NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `id_card`(`id_card` ASC) USING BTREE,
  UNIQUE INDEX `uk_users_email_active`(`email_active` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_email`(`email` ASC) USING BTREE,
  INDEX `idx_student_id`(`student_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 79 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢ㄦ埛琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (32, 'superadmin', '$2a$10$sM1jL.NZAW3gst68P9eRfee/78agzkaCnoVA3sJd2JRrswzuQLrcm', 'superadmin@campus.edu', '2024001', '13800000001', '王管理员', '110101199001010001', 1, '2026-06-09 22:04:49', '2026-05-27 19:44:28', '2026-05-28 13:20:04', 0, 'SUPER_ADMIN', 1, 1, 1, 1, 'VERIFIED', NULL, DEFAULT);
INSERT INTO `users` VALUES (33, 'campusadmin', '$2a$10$9EM4Ee9DuupsndG36uRNDuVOA7uHi0W7f.CSpWuRc3W8b1CfcmU.O', 'campusadmin@campus.edu', '2024002', '13800000002', '张老师', '110101199001010002', 1, '2026-06-07 19:32:44', '2026-05-27 19:44:28', '2026-05-28 13:20:04', 0, 'CAMPUS_ADMIN', 1, 1, 1, 1, 'VERIFIED', NULL, DEFAULT);
INSERT INTO `users` VALUES (34, 'testuser', '$2a$10$43e/xoDyOoYjdH.9m1z1HevbqDHUQmJ1zhi5UIozAyFc4FOkQh16a', 'testuser@campus.edu', '2024003', '13800000003', '赵同学', '110101200401010003', 1, '2026-06-07 19:32:41', '2026-05-27 19:44:28', '2026-05-28 13:20:04', 0, 'USER', 1, 1, 1, 1, 'VERIFIED', NULL, DEFAULT);
INSERT INTO `users` VALUES (35, 'zhangsan', '$2a$10$9nUGFwfjWkH.EL3AvPeeWeFb2oMlPOOMzvqRaQDitPe0xpBbfn8I6', 'zhangsan@campus.edu', '2024004', '13800000004', '张三', '110101200401010004', 1, '2026-06-07 23:07:35', '2026-05-27 19:44:28', '2026-05-28 13:20:04', 0, 'USER', 1, 1, 1, 1, 'VERIFIED', NULL, DEFAULT);
INSERT INTO `users` VALUES (36, 'lisi', '$2a$10$CX3pj7hYVQs13hY18SHtpOegXEljmTVK9fPaFcshRPqvNqUFHfdNG', 'lisi@campus.edu', '2024005', '13800000005', '李四', '110101200401010005', 1, NULL, '2026-05-27 19:44:28', '2026-05-28 13:20:04', 0, 'USER', 1, 1, 1, 1, 'VERIFIED', NULL, DEFAULT);
INSERT INTO `users` VALUES (49, 'user_ncu', '$2a$10$MMqewUPyweuXYAYdoxePs.1wYwsOAKzvyGVn1SI/Gw4woHHfyvzdW', '8008123240@email.ncu.edu.cn', '20240001', '13800000001', NULL, NULL, 1, '2026-05-29 10:13:37', '2026-05-29 10:12:46', '2026-05-29 10:12:46', 0, 'USER', 1, 1, 1, 1, 'UNVERIFIED', NULL, DEFAULT);
INSERT INTO `users` VALUES (50, 'user_qq', '$2a$10$43e/xoDyOoYjdH.9m1z1HevbqDHUQmJ1zhi5UIozAyFc4FOkQh16a', '3193655211@qq.com', '20240002', '13800000002', NULL, NULL, 1, '2026-06-09 21:14:58', '2026-05-29 10:13:12', '2026-06-09 16:55:17', 0, 'USER', 1, 1, 1, 1, 'UNVERIFIED', NULL, DEFAULT);
INSERT INTO `users` VALUES (78, 'test', '$2a$10$hmrRWRX/9koQEJnG8xb0VO7hJQjzk5qOteLeXJVG6Z.Nsp9GzryOa', '3193r655211@qq.com', '123456', '', NULL, NULL, 1, '2026-06-09 16:54:53', '2026-06-09 16:54:46', '2026-06-09 16:55:12', 0, 'USER', 1, 1, 1, 1, 'UNVERIFIED', NULL, DEFAULT);

-- ----------------------------
-- Table structure for verifications
-- ----------------------------
DROP TABLE IF EXISTS `verifications`;
CREATE TABLE `verifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item_id` bigint NOT NULL,
  `claimant_id` bigint NOT NULL,
  `claim_proof` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `reviewed_by` bigint NULL DEFAULT NULL,
  `reviewed_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_item_id`(`item_id` ASC) USING BTREE,
  INDEX `idx_claimant_id`(`claimant_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `verifications_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `verifications_ibfk_2` FOREIGN KEY (`claimant_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of verifications
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
