-- =====================================================
-- 校园失物招领平台 - 阶段 17 数据库迁移
-- 目标:为 users.email 添加 UNIQUE 约束(与代码层校验形成双保险),
--       同时兼容 MyBatis-Plus 的逻辑删除(deleted=0/1)。
--       顺带清理历史脏数据(早期注册测试残留 / 自动生成的临时账号)。
-- 日期: 2026-06-07
-- 说明:可重复执行(每步都有防护判断)。
-- 设计:在 users 上加一个虚拟生成列 email_active,
--       仅当 deleted=0 时取 email 值,否则为 NULL。
--       MySQL 的 UNIQUE 允许多个 NULL 共存,因此已软删用户
--       不会因历史邮箱相同而阻塞新用户使用该邮箱。
-- =====================================================

USE campus_lostfound;

-- ===== 1. 清理历史脏数据 =====
-- 1.1 列出未删除用户中已有的重复邮箱(仅诊断,不阻塞)
SELECT MIN(email) AS email_sample, COUNT(*) AS dup_count, GROUP_CONCAT(id ORDER BY id) AS user_ids
FROM users
WHERE deleted = 0
GROUP BY LOWER(email)
HAVING COUNT(*) > 1;

-- 1.2 保留每个重复邮箱组中 id 最小的用户,其余物理删除
--     (项目里这些都是早期注册测试时自动生成、无业务价值的账号)
--     如果你的环境里有真实业务账号撞邮箱,请人工先迁移再执行此步。
DELETE u FROM users u
JOIN (
    SELECT LOWER(email) AS lemail, MIN(id) AS keep_id
    FROM users
    WHERE deleted = 0
    GROUP BY LOWER(email)
    HAVING COUNT(*) > 1
) keeper ON LOWER(u.email) = keeper.lemail
WHERE u.id <> keeper.keep_id;

-- 1.3 清理早期注册测试时自动生成的临时账号(无物品/通知关联的)
--     匹配模式:
--       - test- / login- 前缀的数字戳
--       - 包含真实身份信息(user_ncu / user_qq 等显式测试账号)被显式排除
--     仅在确认账号无业务数据(id 不在 items/notifications/matches/completion_requests 里)时硬删。
DELETE FROM users
WHERE deleted = 0
  AND (
        username REGEXP '^(test|login|e2e|u2|a[0-9]+|off|r|fT|u)_?[0-9]+$'
     OR username IN ('test-1779886113093','test-1779894398077','test-1779895075427',
                     'test-1779895391141','test-1779896423298','test-1779896540517')
  )
  AND id NOT IN (SELECT DISTINCT user_id FROM items WHERE user_id IS NOT NULL)
  AND id NOT IN (SELECT DISTINCT user_id FROM notifications WHERE user_id IS NOT NULL)
  AND id NOT IN (
        SELECT DISTINCT lost_item_id FROM matches WHERE lost_item_id IS NOT NULL
        UNION
        SELECT DISTINCT found_item_id FROM matches WHERE found_item_id IS NOT NULL
        UNION
        SELECT DISTINCT item_id FROM item_completion_requests WHERE item_id IS NOT NULL
  )
  AND email NOT IN (
        'superadmin@campus.edu','campusadmin@campus.edu','testuser@campus.edu',
        'zhangsan@campus.edu','lisi@campus.edu',
        'user_qq@qq.com','user_ncu@email.ncu.edu.cn'
  );

-- 1.4 顺手把历史遗留的 E2E/测试期间产生的"孤立物品"也清掉。
--     这里改用 LIKE + INSTR 而非 REGEXP,绕开 MySQL 字符类与转义混用的解析陷阱。
--     标题以 '[' 开头(几乎都是我们测试时手写的 [T18]/[OFF]/[E2E] 之类) 且串号
--     命中测试前缀(E2E-/QQ-TEST-/OFF-/T1 数字-)的物品,被认为是测试残留。
DELETE FROM items
WHERE (INSTR(title, '[') = 1)
   OR serial_number LIKE 'E2E-%'
   OR serial_number LIKE 'QQ-TEST-%'
   OR serial_number LIKE 'OFF-%'
   OR serial_number LIKE 'T1%-%';

-- ===== 2. 邮箱归一化 =====
UPDATE users SET email = LOWER(TRIM(email)) WHERE email <> LOWER(TRIM(email));

-- ===== 3. 添加 UNIQUE 约束(虚拟生成列 + UNIQUE) =====

-- 3.1 虚拟生成列 email_active(若已存在则跳过)
SET @cnt := (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'email_active');
SET @sql := IF(@cnt = 0,
    'ALTER TABLE users ADD COLUMN email_active VARCHAR(100) GENERATED ALWAYS AS (CASE WHEN deleted = 0 THEN email ELSE NULL END) VIRTUAL',
    'SELECT "email_active column already exists, skip" AS msg');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3.2 在 email_active 上加 UNIQUE(若已存在则跳过)
SET @cnt := (SELECT COUNT(*) FROM information_schema.statistics
             WHERE table_schema = DATABASE() AND table_name = 'users' AND index_name = 'uk_users_email_active');
SET @sql := IF(@cnt = 0,
    'ALTER TABLE users ADD UNIQUE KEY uk_users_email_active (email_active)',
    'SELECT "uk_users_email_active already exists, skip" AS msg');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ===== 4. 验证 =====
-- 4.1 未删除用户间不应再有重复邮箱(查询应为空)
SELECT MIN(email) AS email_sample, COUNT(*) AS c
FROM users
WHERE deleted = 0
GROUP BY LOWER(email)
HAVING COUNT(*) > 1;

-- 4.2 全表也确认无重复
SELECT email, COUNT(*) AS c
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
