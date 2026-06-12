-- =====================================================
-- Phase Fix: 修复 notifications 表 type 字段长度不足问题
-- 日期: 2026-06-12
-- 问题: COMPLETION_REVIEW_REQUEST (27字符) 超出原 VARCHAR(20) 限制
-- 解决: 扩大 type 字段为 VARCHAR(50)
-- =====================================================

-- 修改 notifications 表的 type 字段长度
ALTER TABLE notifications MODIFY COLUMN type VARCHAR(50) NOT NULL COMMENT '通知类型';
