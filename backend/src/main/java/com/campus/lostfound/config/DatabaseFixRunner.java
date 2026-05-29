package com.campus.lostfound.config;

import com.campus.lostfound.modules.item.repository.ItemRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;

@Component
public class DatabaseFixRunner implements CommandLineRunner {

    private final DataSource dataSource;
    private final ItemRepository itemRepository;
    private final boolean enabled;

    public DatabaseFixRunner(DataSource dataSource, ItemRepository itemRepository,
                             @Value("${app.auto-fix-schema:false}") boolean enabled) {
        this.dataSource = dataSource;
        this.itemRepository = itemRepository;
        this.enabled = enabled;
    }

    @Override
    public void run(String... args) throws Exception {
        if (!enabled) {
            return;
        }

        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {

            // 检查 location 列是否存在
            try {
                stmt.execute("SELECT location FROM items WHERE 1=0");
            } catch (Exception e) {
                // 列不存在，添加它
                stmt.execute("ALTER TABLE items ADD COLUMN location VARCHAR(100) DEFAULT NULL COMMENT '详细位置'");
                System.out.println("Added 'location' column to items table");
            }

            // 检查 notificationInApp 列是否存在
            try {
                stmt.execute("SELECT notification_in_app FROM users WHERE 1=0");
            } catch (Exception e) {
                stmt.execute("ALTER TABLE users ADD COLUMN notification_in_app INT DEFAULT 1 COMMENT '站内通知'");
                stmt.execute("ALTER TABLE users ADD COLUMN notification_email INT DEFAULT 1 COMMENT '邮件通知'");
                stmt.execute("ALTER TABLE users ADD COLUMN notification_match INT DEFAULT 1 COMMENT '匹配提醒'");
                stmt.execute("ALTER TABLE users ADD COLUMN notification_verification INT DEFAULT 1 COMMENT '审核提醒'");
                System.out.println("Added notification columns to users table");
            }

            try {
                stmt.execute("SELECT identity_status FROM users WHERE 1=0");
            } catch (Exception e) {
                stmt.execute("ALTER TABLE users ADD COLUMN identity_status ENUM('UNVERIFIED','PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'UNVERIFIED' COMMENT '实名认证状态'");
                stmt.execute("ALTER TABLE users ADD COLUMN identity_verified_at DATETIME DEFAULT NULL COMMENT '实名认证通过时间'");
                stmt.execute("UPDATE users SET identity_status = CASE WHEN id_card IS NOT NULL AND id_card <> '' THEN 'VERIFIED' ELSE 'UNVERIFIED' END");
                System.out.println("Added identity verification columns to users table");
            }

            try {
                stmt.execute("ALTER TABLE items MODIFY COLUMN status ENUM('PENDING','APPROVED','REJECTED','FOUND_BACK','RETURNED','EXPIRED','CLOSED') NOT NULL DEFAULT 'PENDING'");
            } catch (Exception e) {
                System.err.println("Failed to update items.status enum: " + e.getMessage());
            }

            try {
                stmt.execute("ALTER TABLE notifications MODIFY COLUMN type ENUM('MATCH_FOUND','VERIFICATION_RESULT','CLAIM_REVIEW_RESULT','COMPLETION_REVIEW_RESULT','SYSTEM') NOT NULL");
            } catch (Exception e) {
                System.err.println("Failed to update notifications.type enum: " + e.getMessage());
            }

            try {
                stmt.execute("SELECT id FROM item_completion_requests WHERE 1=0");
            } catch (Exception e) {
                stmt.execute("""
                        CREATE TABLE item_completion_requests (
                            id BIGINT PRIMARY KEY AUTO_INCREMENT,
                            item_id BIGINT NOT NULL,
                            user_id BIGINT NOT NULL,
                            target_status ENUM('FOUND_BACK','RETURNED') NOT NULL,
                            reason VARCHAR(255),
                            status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
                            review_reason VARCHAR(255),
                            reviewed_by BIGINT,
                            reviewed_at DATETIME,
                            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                            INDEX idx_item_id (item_id),
                            INDEX idx_user_id (user_id),
                            INDEX idx_status (status)
                        )
                        """);
                System.out.println("Created item_completion_requests table");
            }

            try {
                stmt.execute("SELECT id FROM user_identity_verifications WHERE 1=0");
            } catch (Exception e) {
                stmt.execute("""
                        CREATE TABLE user_identity_verifications (
                            id BIGINT PRIMARY KEY AUTO_INCREMENT,
                            user_id BIGINT NOT NULL,
                            real_name VARCHAR(50) NOT NULL,
                            id_card VARCHAR(18) NOT NULL,
                            status ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING',
                            review_reason VARCHAR(255),
                            reviewed_by BIGINT,
                            reviewed_at DATETIME,
                            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                            INDEX idx_user_id (user_id),
                            INDEX idx_status (status)
                        )
                        """);
                System.out.println("Created user_identity_verifications table");
            }

        } catch (Exception e) {
            System.err.println("Database fix failed: " + e.getMessage());
        }
    }
}
