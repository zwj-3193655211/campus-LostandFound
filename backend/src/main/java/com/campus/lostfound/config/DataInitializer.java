package com.campus.lostfound.config;

import com.campus.lostfound.common.constant.ItemConstants;
import com.campus.lostfound.modules.common.service.RedisCacheService;
import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.item.entity.Location;
import com.campus.lostfound.modules.item.repository.ItemRepository;
import com.campus.lostfound.modules.item.repository.LocationRepository;
import com.campus.lostfound.modules.match.service.MatchingService;
import com.campus.lostfound.modules.system.entity.User;
import com.campus.lostfound.modules.system.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final LocationRepository locationRepository;
    private final UserRepository userRepository;
    private final ItemRepository itemRepository;
    private final PasswordEncoder passwordEncoder;
    private final MatchingService matchingService;
    private final RedisCacheService cacheService;
    private final boolean enabled;

    public DataInitializer(LocationRepository locationRepository, UserRepository userRepository, 
                          ItemRepository itemRepository, PasswordEncoder passwordEncoder,
                          MatchingService matchingService,
                          RedisCacheService cacheService,
                          @Value("${app.init-demo-data:false}") boolean enabled) {
        this.locationRepository = locationRepository;
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
            initLocations();
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

    private void initLocations() {
        if (locationRepository.selectCount(null) == 0) {
            List<Location> locations = new ArrayList<>();
            
            Location loc1 = new Location();
            loc1.setName("教学楼A栋");
            loc1.setBuilding("教学楼A栋");
            loc1.setFloor(1);
            loc1.setDescription("第一教学楼");
            locations.add(loc1);

            Location loc2 = new Location();
            loc2.setName("教学楼B栋");
            loc2.setBuilding("教学楼B栋");
            loc2.setFloor(1);
            loc2.setDescription("第二教学楼");
            locations.add(loc2);

            Location loc3 = new Location();
            loc3.setName("图书馆");
            loc3.setBuilding("图书馆");
            loc3.setFloor(1);
            loc3.setDescription("主图书馆");
            locations.add(loc3);

            Location loc4 = new Location();
            loc4.setName("食堂");
            loc4.setBuilding("食堂");
            loc4.setFloor(1);
            loc4.setDescription("第一食堂");
            locations.add(loc4);

            Location loc5 = new Location();
            loc5.setName("操场");
            loc5.setBuilding("操场");
            loc5.setFloor(0);
            loc5.setDescription("主操场");
            locations.add(loc5);

            Location loc6 = new Location();
            loc6.setName("体育馆");
            loc6.setBuilding("体育馆");
            loc6.setFloor(1);
            loc6.setDescription("室内体育馆");
            locations.add(loc6);

            Location loc7 = new Location();
            loc7.setName("宿舍区1");
            loc7.setBuilding("宿舍区");
            loc7.setFloor(1);
            loc7.setDescription("学生宿舍1-4号楼");
            locations.add(loc7);

            Location loc8 = new Location();
            loc8.setName("宿舍区2");
            loc8.setBuilding("宿舍区");
            loc8.setFloor(1);
            loc8.setDescription("学生宿舍5-8号楼");
            locations.add(loc8);

            Location loc9 = new Location();
            loc9.setName("行政楼");
            loc9.setBuilding("行政楼");
            loc9.setFloor(1);
            loc9.setDescription("学校行政楼");
            locations.add(loc9);

            Location loc10 = new Location();
            loc10.setName("实验楼");
            loc10.setBuilding("实验楼");
            loc10.setFloor(1);
            loc10.setDescription("理科实验楼");
            locations.add(loc10);

            for (Location loc : locations) {
                locationRepository.insert(loc);
            }
            log.info("Initialized {} locations", locations.size());
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
