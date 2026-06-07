-- =====================================================
-- 校园失物招领智能匹配平台 - 初始化数据脚本
-- 版本: 1.0.0
-- 日期: 2026-05-26
-- 说明: 请先执行 schema.sql 建表后再执行此脚本
-- =====================================================

USE campus_lostfound;

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
