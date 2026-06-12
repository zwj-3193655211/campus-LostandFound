package com.campus.lostfound;

import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.match.service.impl.MatchingEngine;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * 测试物品匹配度
 * 物品337: LOST, 宿舍钥匙, 类别:其他, 时间:2026-06-12 12:45:43, 位置:软件楼、食堂, 颜色:红、蓝
 * 物品338: FOUND, 一串钥匙, 类别:其他, 时间:2026-06-12 12:51:23, 位置:食堂, 描述:食堂捡到一串钥匙，有一个志愿者钥匙扣
 */
@SpringBootTest
public class MatchScoreTest {

    @Autowired
    private MatchingEngine matchingEngine;

    @Test
    void testMatchScore() {
        // 物品337 - 寻物
        Item lostItem = new Item();
        lostItem.setId(337L);
        lostItem.setType("LOST");
        lostItem.setCategory("其他");
        lostItem.setTitle("宿舍钥匙");
        lostItem.setDescription("我弄丢了我的宿舍钥匙，它有一个志愿者协会的钥匙扣挂饰，我去过教学楼、食堂，不确定是哪里丢的");
        lostItem.setBrand(null);
        lostItem.setColor("红、蓝");
        lostItem.setLocation("软件楼、食堂");
        lostItem.setLostTime(java.time.LocalDateTime.of(2026, 6, 12, 12, 45, 43));
        lostItem.setSerialNumber(null);

        // 物品338 - 招领
        Item foundItem = new Item();
        foundItem.setId(338L);
        foundItem.setType("FOUND");
        foundItem.setCategory("其他");
        foundItem.setTitle("一串钥匙");
        foundItem.setDescription("食堂捡到一串钥匙，有一个志愿者钥匙扣，具体如图，失主请联系我");
        foundItem.setBrand(null);
        foundItem.setColor(null);
        foundItem.setLocation("食堂");
        foundItem.setFoundTime(java.time.LocalDateTime.of(2026, 6, 12, 12, 51, 23));
        foundItem.setSerialNumber(null);

        // 手动调试文本相似度
        String left = joinNonBlank(lostItem.getTitle(), lostItem.getDescription(), lostItem.getLocation());
        String right = joinNonBlank(foundItem.getTitle(), foundItem.getDescription(), foundItem.getLocation());
        
        System.out.println("========================================");
        System.out.println("LOST 合并文本: " + left);
        System.out.println("FOUND 合并文本: " + right);
        System.out.println();
        
        Set<String> a = tokenize(left);
        Set<String> b = tokenize(right);
        System.out.println("LOST tokens: " + a);
        System.out.println("FOUND tokens: " + b);
        System.out.println("交集: " + getIntersection(a, b));
        
        BigDecimal textSim = similarityScore(left, right);
        System.out.println("文本相似度(Dice): " + textSim);

        MatchingEngine.LostItem lost = new MatchingEngine.LostItem(
                lostItem.getCategory(),
                lostItem.getLocation(),
                lostItem.getBrand(),
                lostItem.getColor(),
                lostItem.getTitle(),
                lostItem.getDescription(),
                lostItem.getSerialNumber(),
                lostItem.getLostTime()
        );

        MatchingEngine.FoundItem found = new MatchingEngine.FoundItem(
                foundItem.getCategory(),
                foundItem.getLocation(),
                foundItem.getBrand(),
                foundItem.getColor(),
                foundItem.getTitle(),
                foundItem.getDescription(),
                foundItem.getSerialNumber(),
                foundItem.getFoundTime()
        );

        BigDecimal score = matchingEngine.calculateScore(lost, found);
        System.out.println();
        System.out.println("最终匹配分数: " + score);
        System.out.println("匹配阈值: 0.65");
        System.out.println("是否匹配: " + (score.compareTo(new BigDecimal("0.65")) >= 0 ? "是" : "否"));
        System.out.println("========================================");
    }
    
    private String joinNonBlank(String... parts) {
        StringBuilder out = new StringBuilder();
        for (String part : parts) {
            if (part == null || part.isBlank()) continue;
            if (!out.isEmpty()) out.append(' ');
            out.append(part);
        }
        return out.toString();
    }
    
    private Set<String> tokenize(String text) {
        if (text == null || text.isBlank()) return Set.of();
        String normalized = text.toLowerCase().replaceAll("[^\\u4e00-\\u9fa5a-z0-9]", " ");
        Set<String> tokens = new HashSet<>(Arrays.asList(normalized.split("\\s+")));
        tokens.removeIf(String::isEmpty);
        return tokens;
    }
    
    private Set<String> getIntersection(Set<String> a, Set<String> b) {
        Set<String> result = new HashSet<>(a);
        result.retainAll(b);
        return result;
    }
    
    private BigDecimal similarityScore(String left, String right) {
        Set<String> a = tokenize(left);
        Set<String> b = tokenize(right);
        if (a.isEmpty() || b.isEmpty()) return BigDecimal.ZERO;
        int intersection = 0;
        for (String token : a) {
            if (b.contains(token)) intersection++;
        }
        int total = a.size() + b.size();
        if (total == 0) return BigDecimal.ZERO;
        double dice = (2.0 * intersection) / total;
        return BigDecimal.valueOf(dice).setScale(2, java.math.RoundingMode.HALF_UP);
    }
}