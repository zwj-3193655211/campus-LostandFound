-- 第十轮显式迁移脚本
-- 用途：移除“悬赏金额 reward”字段（产品层弃用，鼓励在描述中自愿表达感谢/酬谢）
-- 执行示例：
-- mysql -u root -p campus_lostfound < docs/sql/phase10_remove_reward.sql

SET @schema_name = DATABASE();

SET @sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'items'
              AND COLUMN_NAME = 'reward'
        ),
        'ALTER TABLE `items` DROP COLUMN `reward`',
        'SELECT 1'
    )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

