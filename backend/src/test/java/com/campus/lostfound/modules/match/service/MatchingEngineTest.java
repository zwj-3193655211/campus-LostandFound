package com.campus.lostfound.modules.match.service;

import com.campus.lostfound.modules.match.service.impl.MatchingEngine;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 智能匹配引擎测试
 */
class MatchingEngineTest {

    private final MatchingEngine engine = new MatchingEngine();

    @Test
    void testSerialExactMatch() {
        // 串号精确匹配
        MatchingEngine.LostItem lost = new MatchingEngine.LostItem(
                "证件", null, null, null, null, null, "320111199001011234", LocalDateTime.now()
        );
        MatchingEngine.FoundItem found = new MatchingEngine.FoundItem(
                "证件", null, null, null, null, null, "320111199001011234", LocalDateTime.now()
        );

        BigDecimal score = engine.calculateScore(lost, found);
        assertEquals(new BigDecimal("1.00"), score);
    }

    @Test
    void testWeightedMatch() {
        // 加权匹配 - 相同属性
        MatchingEngine.LostItem lost = new MatchingEngine.LostItem(
                "电子产品", "A教学楼一层大厅", "iPhone", "黑色",
                "丢失 iPhone", "在A教学楼一层大厅丢失黑色iPhone", "SN123456", LocalDateTime.now()
        );
        MatchingEngine.FoundItem found = new MatchingEngine.FoundItem(
                "电子产品", "A教学楼一层大厅", "iPhone", "黑色",
                "捡到 iPhone", "在A教学楼一层大厅捡到黑色iPhone", null, LocalDateTime.now()
        );

        BigDecimal score = engine.calculateScore(lost, found);
        assertTrue(score.compareTo(new BigDecimal("0.65")) >= 0);
    }

    @Test
    void testNoMatch() {
        // 不匹配
        MatchingEngine.LostItem lost = new MatchingEngine.LostItem(
                "电子产品", "A教学楼一层大厅", "iPhone", "黑色",
                "丢失 iPhone", "在A教学楼一层大厅丢失黑色iPhone", null, LocalDateTime.now().minusDays(30)
        );
        MatchingEngine.FoundItem found = new MatchingEngine.FoundItem(
                "书籍", "图书馆一楼自习室", "Nike", "红色",
                "捡到 高等数学", "在图书馆捡到一本高数教材", null, LocalDateTime.now()
        );

        BigDecimal score = engine.calculateScore(lost, found);
        assertTrue(score.compareTo(new BigDecimal("0.65")) < 0);
    }

    @Test
    void testIsMatch() {
        assertTrue(engine.isMatch(new BigDecimal("0.70")));
        assertFalse(engine.isMatch(new BigDecimal("0.50")));
        assertFalse(engine.isMatch(null));
    }
}
