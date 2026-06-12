package com.campus.lostfound.modules.match.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.regex.Pattern;

/**
 * 智能匹配引擎 - 优化版
 * 改进文本相似度算法，更好支持中文匹配
 */
@Component
public class MatchingEngine {

    private static final Logger log = LoggerFactory.getLogger(MatchingEngine.class);

    private static final BigDecimal WEIGHT_TEXT = new BigDecimal("0.35");
    private static final BigDecimal WEIGHT_CATEGORY = new BigDecimal("0.25");
    private static final BigDecimal WEIGHT_LOCATION = new BigDecimal("0.15");
    private static final BigDecimal WEIGHT_BRAND = new BigDecimal("0.10");
    private static final BigDecimal WEIGHT_COLOR = new BigDecimal("0.05");
    private static final BigDecimal WEIGHT_TIME = new BigDecimal("0.10");

    private static final BigDecimal MATCH_THRESHOLD = new BigDecimal("0.70");
    private static final BigDecimal SERIAL_CONFLICT_PENALTY = new BigDecimal("0.40");

    public BigDecimal calculateScore(LostItem lostType, FoundItem foundType) {
        if (hasSerialMatch(lostType, foundType)) {
            log.info("串号精确匹配: lost={}, found={}", lostType.serialNumber, foundType.serialNumber);
            return new BigDecimal("1.00");
        }

        boolean hasSerialConflict = hasSerialConflict(lostType, foundType);
        BigDecimal categoryScore = calculateCategoryScore(lostType.category, foundType.category);
        BigDecimal locationScore = calculateLocationScore(lostType.locationText, foundType.locationText);
        BigDecimal brandScore = calculateBrandScore(lostType.brand, foundType.brand);
        BigDecimal colorScore = calculateColorScore(lostType.color, foundType.color);
        BigDecimal timeScore = calculateTimeScore(lostType.lostTime, foundType.foundTime);
        BigDecimal textScore = calculateTextScore(lostType, foundType);

        BigDecimal totalScore = WEIGHT_TEXT.multiply(textScore)
                .add(WEIGHT_CATEGORY.multiply(categoryScore))
                .add(WEIGHT_LOCATION.multiply(locationScore))
                .add(WEIGHT_BRAND.multiply(brandScore))
                .add(WEIGHT_COLOR.multiply(colorScore))
                .add(WEIGHT_TIME.multiply(timeScore))
                .setScale(2, RoundingMode.HALF_UP);

        if (hasSerialConflict) {
            totalScore = totalScore.multiply(SERIAL_CONFLICT_PENALTY).setScale(2, RoundingMode.HALF_UP);
        }

        log.debug("加权匹配分数: text={}, category={}, location={}, brand={}, color={}, time={}, total={}",
                textScore, categoryScore, locationScore, brandScore, colorScore, timeScore, totalScore);

        if (totalScore.compareTo(MATCH_THRESHOLD) >= 0) {
            return totalScore;
        }

        return BigDecimal.ZERO;
    }

    private boolean hasSerialMatch(LostItem lostType, FoundItem foundType) {
        if (lostType.serialNumber == null || foundType.serialNumber == null) {
            return false;
        }
        String lost = lostType.serialNumber.trim().toUpperCase();
        String found = foundType.serialNumber.trim().toUpperCase();
        return lost.equals(found);
    }

    private boolean hasSerialConflict(LostItem lostType, FoundItem foundType) {
        if (lostType.serialNumber == null || lostType.serialNumber.isBlank()) {
            return false;
        }
        if (foundType.serialNumber == null || foundType.serialNumber.isBlank()) {
            return false;
        }
        String lost = lostType.serialNumber.trim().toUpperCase();
        String found = foundType.serialNumber.trim().toUpperCase();
        return !lost.equals(found);
    }

    private BigDecimal calculateCategoryScore(String category1, String category2) {
        if (Objects.equals(category1, category2)) {
            return BigDecimal.ONE;
        }
        if (category1 != null && category2 != null) {
            if (category1.contains(category2) || category2.contains(category1)) {
                return new BigDecimal("0.8");
            }
        }
        return BigDecimal.ZERO;
    }

    private BigDecimal calculateLocationScore(String locationText1, String locationText2) {
        BigDecimal textScore = calculateChineseSimilarity(locationText1, locationText2);
        if (textScore.compareTo(BigDecimal.ZERO) == 0) {
            return new BigDecimal("0.5");
        }
        return textScore.multiply(new BigDecimal("0.8")).setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateBrandScore(String brand1, String brand2) {
        if (brand1 == null || brand2 == null) {
            return new BigDecimal("0.5");
        }
        if (Objects.equals(brand1, brand2)) {
            return BigDecimal.ONE;
        }
        String b1 = brand1.toLowerCase();
        String b2 = brand2.toLowerCase();
        if (b1.contains(b2) || b2.contains(b1)) {
            return new BigDecimal("0.8");
        }
        return calculateChineseSimilarity(brand1, brand2).multiply(new BigDecimal("0.7")).setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateColorScore(String color1, String color2) {
        if (color1 == null || color2 == null) {
            return new BigDecimal("0.5");
        }
        if (Objects.equals(color1, color2)) {
            return BigDecimal.ONE;
        }
        String c1 = normalizeColor(color1);
        String c2 = normalizeColor(color2);
        if (c1.equals(c2)) {
            return BigDecimal.ONE;
        }
        return BigDecimal.ZERO;
    }

    private BigDecimal calculateTimeScore(LocalDateTime lostTime, LocalDateTime foundTime) {
        if (lostTime == null || foundTime == null) {
            return new BigDecimal("0.5");
        }
        long daysBetween = Math.abs(Duration.between(lostTime, foundTime).toDays());
        double tau = 10.0;
        double score = Math.exp(-daysBetween / tau);
        return BigDecimal.valueOf(score).setScale(2, RoundingMode.HALF_UP);
    }

    private String normalizeColor(String color) {
        if (color == null) return null;
        return color.toLowerCase().trim();
    }

    public boolean isMatch(BigDecimal score) {
        return score != null && score.compareTo(MATCH_THRESHOLD) >= 0;
    }

    private BigDecimal calculateTextScore(LostItem lostType, FoundItem foundType) {
        String left = joinNonBlank(lostType.title, lostType.description, lostType.locationText);
        String right = joinNonBlank(foundType.title, foundType.description, foundType.locationText);
        BigDecimal score = calculateChineseSimilarity(left, right);
        if (score.compareTo(BigDecimal.ZERO) == 0) {
            return new BigDecimal("0.5");
        }
        return score;
    }

    private String joinNonBlank(String... parts) {
        StringBuilder out = new StringBuilder();
        for (String part : parts) {
            if (part == null || part.isBlank()) {
                continue;
            }
            if (!out.isEmpty()) {
                out.append(' ');
            }
            out.append(part);
        }
        return out.toString();
    }

    /**
     * 优化的中文文本相似度计算
     * 结合多种策略：
     * 1. 关键词匹配（完整词语匹配，权重更高）
     * 2. N-gram匹配（字符级别的匹配）
     * 3. 包含关系检测
     */
    private BigDecimal calculateChineseSimilarity(String text1, String text2) {
        if (text1 == null || text2 == null || text1.isBlank() || text2.isBlank()) {
            return BigDecimal.ZERO;
        }

        String left = text1.trim().toLowerCase();
        String right = text2.trim().toLowerCase();

        // 完全相等
        if (left.equals(right)) {
            return BigDecimal.ONE;
        }

        // 包含关系检测
        if (left.contains(right) || right.contains(left)) {
            return new BigDecimal("0.8");
        }

        // 提取关键词并匹配
        Set<String> keywords1 = extractKeywords(left);
        Set<String> keywords2 = extractKeywords(right);
        
        if (keywords1.isEmpty() && keywords2.isEmpty()) {
            return BigDecimal.ZERO;
        }

        // 计算关键词匹配分数
        int keywordMatch = 0;
        int totalKeywords = keywords1.size() + keywords2.size();
        
        for (String kw1 : keywords1) {
            for (String kw2 : keywords2) {
                if (kw1.equals(kw2) || kw1.contains(kw2) || kw2.contains(kw1)) {
                    keywordMatch += 2; // 完整匹配权重更高
                }
            }
        }

        // N-gram字符匹配
        Set<String> ngrams1 = extractNgrams(left);
        Set<String> ngrams2 = extractNgrams(right);
        
        int ngramMatch = 0;
        for (String ng1 : ngrams1) {
            if (ngrams2.contains(ng1)) {
                ngramMatch++;
            }
        }

        // 结合两种分数
        double keywordScore = totalKeywords > 0 ? (double) keywordMatch / totalKeywords : 0;
        double ngramScore = calculateJaccardSimilarity(ngrams1, ngrams2);
        
        // 关键词权重更高
        double combinedScore = keywordScore * 0.6 + ngramScore * 0.4;
        
        return BigDecimal.valueOf(Math.min(1.0, combinedScore)).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 提取关键词（中文词语）
     */
    private Set<String> extractKeywords(String text) {
        Set<String> keywords = new HashSet<>();
        if (text == null || text.isBlank()) {
            return keywords;
        }

        // 移除特殊字符，保留中文、英文、数字
        String cleaned = text.replaceAll("[^\\p{IsHan}a-zA-Z0-9\\s]", " ");
        
        // 按空格分割
        String[] parts = cleaned.split("\\s+");
        for (String part : parts) {
            part = part.trim();
            if (part.length() >= 2) {
                keywords.add(part.toLowerCase());
            }
            // 对于中文，提取2-gram和3-gram
            String han = part.replaceAll("[^\\p{IsHan}]", "");
            for (int i = 0; i + 1 < han.length(); i++) {
                keywords.add(han.substring(i, i + 2));
            }
            for (int i = 0; i + 2 < han.length(); i++) {
                keywords.add(han.substring(i, i + 3));
            }
        }
        return keywords;
    }

    /**
     * 提取N-gram特征
     */
    private Set<String> extractNgrams(String text) {
        Set<String> ngrams = new HashSet<>();
        if (text == null || text.isBlank()) {
            return ngrams;
        }

        String cleaned = text.replaceAll("[^\\p{IsHan}a-zA-Z0-9]", "");
        if (cleaned.length() < 2) {
            ngrams.add(cleaned);
            return ngrams;
        }

        // 字符级别的bigram
        for (int i = 0; i + 1 < cleaned.length(); i++) {
            ngrams.add(cleaned.substring(i, i + 2).toLowerCase());
        }
        return ngrams;
    }

    /**
     * Jaccard相似度
     */
    private double calculateJaccardSimilarity(Set<String> set1, Set<String> set2) {
        if (set1.isEmpty() && set2.isEmpty()) {
            return 0;
        }
        if (set1.isEmpty() || set2.isEmpty()) {
            return 0;
        }

        Set<String> intersection = new HashSet<>(set1);
        intersection.retainAll(set2);
        
        Set<String> union = new HashSet<>(set1);
        union.addAll(set2);
        
        return (double) intersection.size() / union.size();
    }

    public static class LostItem {
        public String category;
        public String locationText;
        public String brand;
        public String color;
        public String title;
        public String description;
        public String serialNumber;
        public LocalDateTime lostTime;

        public LostItem(String category,
                        String locationText,
                        String brand,
                        String color,
                        String title,
                        String description,
                        String serialNumber,
                        LocalDateTime lostTime) {
            this.category = category;
            this.locationText = locationText;
            this.brand = brand;
            this.color = color;
            this.title = title;
            this.description = description;
            this.serialNumber = serialNumber;
            this.lostTime = lostTime;
        }
    }

    public static class FoundItem {
        public String category;
        public String locationText;
        public String brand;
        public String color;
        public String title;
        public String description;
        public String serialNumber;
        public LocalDateTime foundTime;

        public FoundItem(String category,
                         String locationText,
                         String brand,
                         String color,
                         String title,
                         String description,
                         String serialNumber,
                         LocalDateTime foundTime) {
            this.category = category;
            this.locationText = locationText;
            this.brand = brand;
            this.color = color;
            this.title = title;
            this.description = description;
            this.serialNumber = serialNumber;
            this.foundTime = foundTime;
        }
    }
}