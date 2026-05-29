package com.campus.lostfound.modules.system.controller;

import com.campus.lostfound.common.result.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.env.Environment;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据库修复控制器
 */
@RestController
@ConditionalOnProperty(prefix = "app", name = "db-fix-enabled", havingValue = "true")
@RequestMapping("/api/db")
public class DbFixController {

    private static final Logger log = LoggerFactory.getLogger(DbFixController.class);

    private final JdbcTemplate jdbcTemplate;
    private final RestTemplate restTemplate;
    private final Environment environment;

    public DbFixController(JdbcTemplate jdbcTemplate, RestTemplate restTemplate, Environment environment) {
        this.jdbcTemplate = jdbcTemplate;
        this.restTemplate = restTemplate;
        this.environment = environment;
    }

    /**
     * 完整初始化数据库
     */
    @PostMapping("/init")
    public ApiResponse<String> fullInit() {
        boolean foreignKeyChecksDisabled = false;
        try {
            log.info("开始数据库初始化...");

            // 禁用外键检查
            jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 0");
            foreignKeyChecksDisabled = true;

            // 清空所有表
            String[] tables = {
                "notifications", "item_completion_requests", "matches", "item_images", "verifications", 
                "items", "locations", "users", "daily_statistics"
            };
            
            for (String table : tables) {
                jdbcTemplate.execute("DELETE FROM " + table);
                log.info("清空表: {}", table);
            }

            // 插入位置
            log.info("插入位置数据...");
            Object[][] locations = {
                {"A教学楼一层大厅", "A教学楼", 1, "主要入口和休息区"},
                {"A教学楼三层301教室", "A教学楼", 3, "301教室门口"},
                {"图书馆一楼自习室", "图书馆", 1, "自习区入口"},
                {"图书馆二楼阅览室", "图书馆", 2, "期刊阅览室"},
                {"食堂一楼入口", "食堂", 1, "食堂正门"},
                {"食堂二楼餐厅", "食堂", 2, "快餐区"},
                {"操场看台下方", "操场", 0, "体育器材室"},
                {"学生宿舍5号楼", "学生宿舍", 1, "宿舍楼大厅"},
                {"实验楼A座一层", "实验楼A座", 1, "实验室走廊"},
                {"行政楼一楼服务大厅", "行政楼", 1, "办事大厅"}
            };
            
            for (Object[] loc : locations) {
                jdbcTemplate.update(
                    "INSERT INTO locations (name, building, floor, description) VALUES (?, ?, ?, ?)",
                    loc[0], loc[1], loc[2], loc[3]
                );
            }

            // 插入用户
            log.info("插入用户数据...");
            Object[][] users = {
                {"superadmin", "123456", "superadmin@campus.edu", "2024001", "13800000001", "王管理员", "110101199001010001", "SUPER_ADMIN", 1},
                {"campusadmin", "123456", "campusadmin@campus.edu", "2024002", "13800000002", "张老师", "110101199001010002", "CAMPUS_ADMIN", 1},
                {"testuser", "123456", "testuser@campus.edu", "2024003", "13800000003", "赵同学", "110101200401010003", "USER", 1},
                {"zhangsan", "123456", "zhangsan@campus.edu", "2024004", "13800000004", "张三", "110101200401010004", "USER", 1},
                {"lisi", "123456", "lisi@campus.edu", "2024005", "13800000005", "李四", "110101200401010005", "USER", 1}
            };
            
            org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder encoder = new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder();
            for (Object[] user : users) {
                String encodedPw = encoder.encode((String)user[1]);
                jdbcTemplate.update(
                    "INSERT INTO users (username, password, email, student_id, phone, real_name, id_card, identity_status, role, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    user[0], encodedPw, user[2], user[3], user[4], user[5], user[6], "VERIFIED", user[7], user[8]
                );
            }

            // 获取用户和位置的ID用于插入items
            Map<String, Long> userIds = jdbcTemplate.queryForList("SELECT username, id FROM users")
                .stream()
                .collect(java.util.stream.Collectors.toMap(
                    m -> (String) m.get("username"),
                    m -> (Long) m.get("id")
                ));
                
            Map<String, Long> locationIds = jdbcTemplate.queryForList("SELECT name, id FROM locations")
                .stream()
                .collect(java.util.stream.Collectors.toMap(
                    m -> (String) m.get("name"),
                    m -> (Long) m.get("id")
                ));

            // 插入寻物启示
            log.info("插入寻物启示...");
            Object[][] lostItems = {
                {"zhangsan", "LOST", "电子产品", "丢失iPad Air 4代 灰色", 
                 "在A教学楼一楼自习室遗落一台平板电脑，机身灰色，背面有卡通贴纸，10.9英寸显示屏，带蓝色保护壳，屏幕完好无损。捡到请联系，必有重谢！",
                 "Apple iPad Air 4", "灰色", "A教学楼一层大厅", "2026-05-20 14:30:00", "", "微信: zhangsan2024", "APPROVED", "2026-05-20 15:00:00"},
                {"testuser", "LOST", "证件", "丢失校园卡",
                 "在图书馆自习室遗失校园卡，卡上姓名张三，卡号 2024004，拾到请联系，非常感谢！",
                 "", "", "图书馆一楼自习室", "2026-05-21 10:00:00", "2024004", "手机: 13800000004", "APPROVED", "2026-05-21 11:00:00"},
                {"lisi", "LOST", "书籍", "丢失《高等数学》教材",
                 "在实验楼A座一层做实验时遗失高等数学教材，绿色封面，扉页有\"李四\"字样。这本书对我很重要，拾到请联系！",
                 "", "绿色", "实验楼A座一层", "2026-05-22 16:00:00", "", "邮箱: lisi@campus.edu", "PENDING", "2026-05-22 17:00:00"}
            };
            
            for (Object[] item : lostItems) {
                Long userId = userIds.get(item[0]);
                Long locId = locationIds.get(item[7]);
                jdbcTemplate.update(
                    "INSERT INTO items (user_id, type, category, title, description, brand, color, location_id, lost_time, serial_number, contact_info, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    userId, item[1], item[2], item[3], item[4], item[5], item[6], locId, item[8], item[9], item[10], item[11], item[12]
                );
            }

            // 插入失物招领
            log.info("插入失物招领...");
            Object[][] foundItems = {
                {"campusadmin", "FOUND", "电子产品", "捡到iPad Air 灰色平板电脑",
                 "在A教学楼一楼大厅捡到一台10.9寸灰色iPad，背面有卡通贴纸，包着蓝色保护壳，已妥善保管等待失主认领。",
                 "Apple iPad Air", "灰色", "A教学楼一层大厅", "2026-05-20 16:00:00", "", "邮箱: campusadmin@campus.edu", "APPROVED", "2026-05-20 17:00:00"},
                {"superadmin", "FOUND", "证件", "拾取校园卡一张",
                 "在图书馆二楼阅览室拾取校园卡一张，卡号2024004，拾取时卡套内还有50元现金。已交到行政楼服务大厅失物招领处。",
                 "", "", "图书馆二楼阅览室", "2026-05-21 11:30:00", "2024004", "行政楼服务大厅: 010-12345678", "APPROVED", "2026-05-21 12:00:00"},
                {"testuser", "FOUND", "书籍", "捡到高等数学教材",
                 "在操场跑道旁捡到一本高等数学教材，绿色封面，书内有\"李四\"字样，已妥善保管。",
                 "", "绿色", "操场看台下方", "2026-05-22 18:00:00", "", "微信: testuser2024", "PENDING", "2026-05-22 18:30:00"}
            };
            
            for (Object[] item : foundItems) {
                Long userId = userIds.get(item[0]);
                Long locId = locationIds.get(item[7]);
                jdbcTemplate.update(
                    "INSERT INTO items (user_id, type, category, title, description, brand, color, location_id, found_time, serial_number, contact_info, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    userId, item[1], item[2], item[3], item[4], item[5], item[6], locId, item[8], item[9], item[10], item[11], item[12]
                );
            }

            // 统计结果
            int userCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM users", Integer.class);
            int locationCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM locations", Integer.class);
            int itemCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM items", Integer.class);

            String result = String.format(
                "数据库初始化完成!\n用户: %d, 位置: %d, 物品: %d\n\n测试账号密码都是: 123456",
                userCount, locationCount, itemCount
            );
            
            log.info(result);
            return ApiResponse.success(result, null);
            
        } catch (Exception e) {
            log.error("初始化失败", e);
            return ApiResponse.error("初始化失败: " + e.getMessage());
        } finally {
            restoreForeignKeyChecks(foreignKeyChecksDisabled);
        }
    }

    /**
     * 修复角色字段并添加测试用户
     */
    @PostMapping("/fix-roles")
    public ApiResponse<String> fixRoles() {
        try {
            jdbcTemplate.execute("DELETE FROM users");
            log.info("删除用户成功");

            jdbcTemplate.execute("ALTER TABLE users DROP COLUMN role");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN role ENUM('SUPER_ADMIN','CAMPUS_ADMIN','USER') DEFAULT 'USER'");

            String pw = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5GHsJ4dI2dF7dL8d8jW/8Gq";

            jdbcTemplate.update(
                "INSERT INTO users (username, password, email, student_id, phone, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
                "admin", pw, "admin@test.com", "2024001", "13800000001", "SUPER_ADMIN", 1
            );
            jdbcTemplate.update(
                "INSERT INTO users (username, password, email, student_id, phone, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
                "campusadmin", pw, "campus@test.com", "2024002", "13800000002", "CAMPUS_ADMIN", 1
            );
            jdbcTemplate.update(
                "INSERT INTO users (username, password, email, student_id, phone, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
                "testuser", pw, "user@test.com", "2024003", "13800000003", "USER", 1
            );

            List<Map<String, Object>> users = jdbcTemplate.queryForList("SELECT id, username, role FROM users");

            return ApiResponse.success("修复完成! 密码: 123456", users.toString());
        } catch (Exception e) {
            log.error("修复失败", e);
            return ApiResponse.error("修复失败: " + e.getMessage());
        }
    }

    @PostMapping("/fix-match-table")
    public ApiResponse<String> fixMatchTable() {
        try {
            jdbcTemplate.execute("ALTER TABLE `matches` MODIFY COLUMN `match_type` ENUM('SERIAL_EXACT', 'WEIGHTED', 'NONE') NOT NULL");
            return ApiResponse.success("匹配类型修复完成", null);
        } catch (Exception e) {
            log.error("修复失败", e);
            return ApiResponse.error("修复失败: " + e.getMessage());
        }
    }

    @PostMapping("/seed-images")
    public ApiResponse<Map<String, Object>> seedImages(@RequestBody(required = false) Map<String, Object> body) {
        try {
            int limit = 12;
            if (body != null && body.get("limit") instanceof Number n) {
                limit = Math.max(1, Math.min(50, n.intValue()));
            }

            Map<String, String> sourceByKey = new HashMap<>();
            sourceByKey.put("card", "https://dummyimage.com/900x600/0ea5e9/ffffff.png&text=Campus+Card");
            sourceByKey.put("ipad", "https://dummyimage.com/900x600/111827/ffffff.png&text=iPad");
            sourceByKey.put("book", "https://dummyimage.com/900x600/22c55e/ffffff.png&text=Textbook");
            sourceByKey.put("keys", "https://dummyimage.com/900x600/f59e0b/ffffff.png&text=Keys");
            sourceByKey.put("umbrella", "https://placehold.co/900x600/png?text=Umbrella");

            Map<String, String> uploadedUrlByKey = new HashMap<>();
            for (Map.Entry<String, String> entry : sourceByKey.entrySet()) {
                try {
                    uploadedUrlByKey.put(entry.getKey(), uploadToImageBedFromUrl(entry.getValue(), entry.getKey() + ".jpg"));
                } catch (Exception uploadException) {
                    log.warn("上传示例图片失败: key={}, source={}", entry.getKey(), entry.getValue(), uploadException);
                }
            }

            List<Map<String, Object>> items = jdbcTemplate.queryForList(
                "SELECT i.id, i.title, i.category, i.type " +
                    "FROM items i " +
                    "WHERE i.status = 'APPROVED' " +
                    "AND NOT EXISTS (SELECT 1 FROM item_images im WHERE im.item_id = i.id) " +
                    "ORDER BY i.created_at DESC " +
                    "LIMIT ?",
                limit
            );

            int inserted = 0;
            List<Long> itemIds = new ArrayList<>();
            for (Map<String, Object> item : items) {
                Long itemId = ((Number) item.get("id")).longValue();
                String category = (String) item.get("category");
                String type = (String) item.get("type");
                String key = pickImageKey(category, type);
                String imageUrl = uploadedUrlByKey.get(key);
                if (imageUrl == null || imageUrl.isBlank()) {
                    continue;
                }

                jdbcTemplate.update(
                    "INSERT INTO item_images (item_id, image_url, image_type, sort_order, created_at) VALUES (?, ?, ?, ?, NOW())",
                    itemId, imageUrl, "MAIN", 0
                );
                inserted++;
                itemIds.add(itemId);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("inserted", inserted);
            result.put("itemIds", itemIds);
            result.put("imageKeys", uploadedUrlByKey);
            return ApiResponse.success("已为物品补齐示例图片（图床）", result);
        } catch (Exception e) {
            log.error("补齐示例图片失败", e);
            return ApiResponse.error("补齐示例图片失败: " + e.getMessage());
        }
    }

    private String pickImageKey(String category, String type) {
        String cat = category == null ? "" : category;
        if (cat.contains("证件")) {
            return "card";
        }
        if (cat.contains("电子") || cat.contains("手机") || cat.contains("平板") || cat.contains("电脑")) {
            return "ipad";
        }
        if (cat.contains("书")) {
            return "book";
        }
        if ("FOUND".equals(type)) {
            return "keys";
        }
        return "umbrella";
    }

    private String uploadToImageBedFromUrl(String sourceUrl, String filename) {
        ResponseEntity<byte[]> downloaded = restTemplate.exchange(sourceUrl, HttpMethod.GET, new HttpEntity<>(new HttpHeaders()), byte[].class);
        if (downloaded.getBody() == null || downloaded.getBody().length == 0) {
            throw new IllegalStateException("下载图片失败");
        }

        String uploadUrl = environment.getProperty("image-bed.upload-url");
        String storageDestination = environment.getProperty("image-bed.storage-destination", "r2");
        String outputFormat = environment.getProperty("image-bed.output-format", "auto");
        String cdnDomain = environment.getProperty("image-bed.cdn-domain");

        if (uploadUrl == null || uploadUrl.isBlank()) {
            throw new IllegalStateException("未配置 image-bed.upload-url");
        }

        ByteArrayResource fileResource = new ByteArrayResource(downloaded.getBody()) {
            @Override
            public String getFilename() {
                return filename;
            }
        };

        HttpHeaders fileHeaders = new HttpHeaders();
        MediaType mediaType = downloaded.getHeaders().getContentType();
        fileHeaders.setContentType(mediaType != null ? mediaType : MediaType.APPLICATION_OCTET_STREAM);
        HttpEntity<ByteArrayResource> fileEntity = new HttpEntity<>(fileResource, fileHeaders);

        MultiValueMap<String, Object> form = new LinkedMultiValueMap<>();
        form.add("image", fileEntity);
        form.add("storage_destination", storageDestination);
        form.add("outputFormat", outputFormat);
        if (cdnDomain != null && !cdnDomain.isBlank()) {
            form.add("cdn_domain", cdnDomain);
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        HttpEntity<MultiValueMap<String, Object>> request = new HttpEntity<>(form, headers);

        ResponseEntity<Map> response = restTemplate.exchange(uploadUrl, HttpMethod.POST, request, Map.class);
        Map<?, ?> payload = response.getBody();
        if (payload == null) {
            throw new IllegalStateException("图床响应为空");
        }

        Object success = payload.get("success");
        if (!(success instanceof Boolean) || !((Boolean) success)) {
            throw new IllegalStateException("图床上传失败");
        }

        Object dataObj = payload.get("data");
        if (!(dataObj instanceof Map)) {
            throw new IllegalStateException("图床未返回 data");
        }

        Object urlObj = ((Map<?, ?>) dataObj).get("url");
        if (!(urlObj instanceof String url) || url.isBlank()) {
            throw new IllegalStateException("图床未返回可用图片地址");
        }
        return url;
    }

    private void restoreForeignKeyChecks(boolean foreignKeyChecksDisabled) {
        if (!foreignKeyChecksDisabled) {
            return;
        }
        try {
            jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 1");
        } catch (Exception restoreException) {
            log.error("恢复外键检查失败", restoreException);
        }
    }
}
