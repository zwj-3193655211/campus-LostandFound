package com.campus.lostfound.config;

import java.time.LocalDateTime;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.modules.common.service.RedisCacheService;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.match.service.MatchingService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final UserRepository userRepository;
    private final ItemRepository itemRepository;
    private final PasswordEncoder passwordEncoder;
    private final MatchingService matchingService;
    private final RedisCacheService cacheService;
    private final boolean enabled;

    public DataInitializer(UserRepository userRepository, 
                          ItemRepository itemRepository, PasswordEncoder passwordEncoder,
                          MatchingService matchingService,
                          RedisCacheService cacheService,
                          @Value("${app.init-demo-data:false}") boolean enabled) {
        this.userRepository = userRepository;
        this.itemRepository = itemRepository;
        this.passwordEncoder = passwordEncoder;
        this.matchingService = matchingService;
        this.cacheService = cacheService;
        this.enabled = enabled;
    }

    @Override
    public void run(String... args) throws Exception {
        if (!enabled) {
            log.info("Demo data initialization skipped. Use docs/sql/complete_init.sql as the baseline dataset.");
        } else {
            log.info("Starting data initialization...");
            initUsers();
            initItems();
            log.info("Data initialization completed.");
        }

        // 总是执行匹配（无论是否初始化演示数据）
        triggerMatching();
    }

    private void triggerMatching() {
        try {
            log.info("Triggering automatic matching for initialized items...");
            // 获取所有已审核通过的物品
            List<Item> approvedItems = itemRepository.selectList(null).stream()
                    .filter(item -> ItemConstants.Status.APPROVED.equals(item.getStatus()))
                    .toList();

            log.info("Found {} approved items for matching", approvedItems.size());

            // 对每个已审核物品触发匹配
            for (Item item : approvedItems) {
                try {
                    matchingService.match(item.getId());
                    log.info("Matching triggered for item: {}", item.getTitle());
                } catch (Exception e) {
                    log.error("Failed to trigger matching for item {}: {}", item.getId(), e.getMessage());
                }
            }

            // 匹配完成后清除统计缓存
            cacheService.clearStatisticsCache();
            log.info("Statistics cache cleared after matching");

            log.info("Automatic matching completed");
        } catch (Exception e) {
            log.error("Error during automatic matching: {}", e.getMessage());
        }
    }

    private void initUsers() {
        if (userRepository.selectCount(null) == 0) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setEmail("admin@campus.edu");
            admin.setPhone("13800138000");
            admin.setRealName("管理员");
            admin.setIdCard("110101199001011234");
            admin.setStatus(1);
            admin.setRole("SUPER_ADMIN");
            admin.setNotificationInApp(1);
            admin.setNotificationEmail(1);
            admin.setNotificationMatch(1);
            admin.setNotificationVerification(1);
            userRepository.insert(admin);

            User user1 = new User();
            user1.setUsername("student1");
            user1.setPassword(passwordEncoder.encode("123456"));
            user1.setEmail("student1@campus.edu");
            user1.setPhone("13800138001");
            user1.setRealName("张三");
            user1.setIdCard("110101199901011234");
            user1.setStatus(1);
            user1.setRole("USER");
            user1.setNotificationInApp(1);
            user1.setNotificationEmail(1);
            user1.setNotificationMatch(1);
            user1.setNotificationVerification(1);
            userRepository.insert(user1);

            User user2 = new User();
            user2.setUsername("student2");
            user2.setPassword(passwordEncoder.encode("123456"));
            user2.setEmail("student2@campus.edu");
            user2.setPhone("13800138002");
            user2.setRealName("李四");
            user2.setIdCard("110101199902022345");
            user2.setStatus(1);
            user2.setRole("USER");
            user2.setNotificationInApp(1);
            user2.setNotificationEmail(1);
            user2.setNotificationMatch(1);
            user2.setNotificationVerification(1);
            userRepository.insert(user2);

            User user3 = new User();
            user3.setUsername("student3");
            user3.setPassword(passwordEncoder.encode("123456"));
            user3.setEmail("student3@campus.edu");
            user3.setPhone("13800138003");
            user3.setRealName("王五");
            user3.setIdCard("110101199903033456");
            user3.setStatus(1);
            user3.setRole("USER");
            user3.setNotificationInApp(1);
            user3.setNotificationEmail(1);
            user3.setNotificationMatch(1);
            user3.setNotificationVerification(1);
            userRepository.insert(user3);

            log.info("Initialized {} users", 4);
        }
    }

    private void initItems() {
        if (itemRepository.selectCount(null) == 0) {
            User student1 = userRepository.selectList(null).stream()
                .filter(u -> "student1".equals(u.getUsername()))
                .findFirst().orElse(null);
            User student2 = userRepository.selectList(null).stream()
                .filter(u -> "student2".equals(u.getUsername()))
                .findFirst().orElse(null);
            User admin = userRepository.selectList(null).stream()
                .filter(u -> "admin".equals(u.getUsername()))
                .findFirst().orElse(null);

            if (student1 != null) {
                Item item1 = new Item();
                item1.setUserId(student1.getId());
                item1.setType("LOST");
                item1.setCategory("电子产品");
                item1.setTitle("丢失iPhone手机");
                item1.setDescription("在图书馆丢失一部iPhone手机，黑色外壳");
                item1.setBrand("Apple");
                item1.setColor("黑色");
                item1.setLocation("图书馆一楼");
                item1.setLostTime(LocalDateTime.now().minusDays(1));
                item1.setStatus("APPROVED");
                item1.setCreatedAt(LocalDateTime.now());
                itemRepository.insert(item1);
            }

            if (admin != null) {
                Item item2 = new Item();
                item2.setUserId(admin.getId());
                item2.setType("FOUND");
                item2.setCategory("电子产品");
                item2.setTitle("捡到iPhone手机");
                item2.setDescription("在图书馆捡到一部iPhone手机，已交到失物招领处");
                item2.setBrand("Apple");
                item2.setColor("黑色");
                item2.setLocation("图书馆一楼大厅");
                item2.setFoundTime(LocalDateTime.now().minusHours(5));
                item2.setStatus("APPROVED");
                item2.setCreatedAt(LocalDateTime.now());
                itemRepository.insert(item2);
            }

            if (student2 != null) {
                Item item3 = new Item();
                item3.setUserId(student2.getId());
                item3.setType("LOST");
                item3.setCategory("证件");
                item3.setTitle("丢失校园卡");
                item3.setDescription("丢失一张校园卡，卡号2024002");
                item3.setLocation("食堂");
                item3.setSerialNumber("2024002");
                item3.setLostTime(LocalDateTime.now().minusHours(3));
                item3.setStatus("PENDING");
                item3.setCreatedAt(LocalDateTime.now());
                itemRepository.insert(item3);
            }

            log.info("Initialized {} items", 3);
        }
    }
}
