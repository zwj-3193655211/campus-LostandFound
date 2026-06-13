package com.campus.lostfound.modules.match.service.impl;

import com.huaban.analysis.jieba.JiebaSegmenter;
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
 * 使用 Jieba 中文分词，支持智能中文分词和语义匹配
 */
@Component
public class MatchingEngine {

    private static final Logger log = LoggerFactory.getLogger(MatchingEngine.class);

    /**
     * Jieba 分词器（线程安全，可在多线程环境下使用）
     */
    private final JiebaSegmenter jiebaSegmenter = new JiebaSegmenter();

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
     * 基于 Jieba 分词的文本相似度计算
     *
     * 算法思路：
     * 1. 完全相等 → 1.0
     * 2. 包含关系 → 0.8
     * 3. 否则基于关键词匹配评分：精确匹配 +3 分，包含匹配 +2 分，最后归一化到 [0, 1]
     *
     * 示例：
     *   文本1："宿舍钥匙" → ["宿舍", "钥匙"]
     *   文本2："一串钥匙" → ["一串", "钥匙"]
     *   匹配：["钥匙"] 精确匹配 +3
     *   总分：3 / (2+2) = 0.75
     */
    private BigDecimal calculateChineseSimilarity(String text1, String text2) {
        // ========== 第一步：输入校验 ==========
        if (text1 == null || text2 == null || text1.isBlank() || text2.isBlank()) {
            return BigDecimal.ZERO;  // 任一文本为空，相似度为 0
        }

        // ========== 第二步：预处理 ==========
        // 去除首尾空格并转为小写，保证比较时不区分大小写
        String left = text1.trim().toLowerCase();
        String right = text2.trim().toLowerCase();

        // ========== 第三步：特殊情况快速返回 ==========
        // 情况1：完全相等 → 最高相似度
        if (left.equals(right)) {
            return BigDecimal.ONE;
        }

        // 情况2：包含关系（如"宿舍钥匙"包含"钥匙"） → 较高相似度
        if (left.contains(right) || right.contains(left)) {
            return new BigDecimal("0.8");
        }

        // ========== 第四步：Jieba 分词得到关键词集合 ==========
        Set<String> keywords1 = extractKeywords(left);  // 文本1 的关键词集合
        Set<String> keywords2 = extractKeywords(right); // 文本2 的关键词集合

        if (keywords1.isEmpty() && keywords2.isEmpty()) {
            return BigDecimal.ZERO;  // 双方都没有有效关键词，相似度为 0
        }

        // ========== 第五步：双层循环计算匹配分数 ==========
        // 遍历两个关键词集合的所有两两组合
        int keywordMatch = 0;  // 累计匹配分数
        int totalKeywords = keywords1.size() + keywords2.size();  // 双方关键词总数

        for (String kw1 : keywords1) {
            for (String kw2 : keywords2) {
                // 精确匹配（如 "钥匙" == "钥匙"）→ 权重 3
                if (kw1.equals(kw2)) {
                    keywordMatch += 3;
                }
                // 包含匹配（如 "宿舍钥匙" 包含 "钥匙"）→ 权重 2
                else if (kw1.contains(kw2) || kw2.contains(kw1)) {
                    keywordMatch += 2;
                }
                // 都不匹配 → 不加分
            }
        }

        // ========== 第六步：归一化到 [0, 1] 范围 ==========
        // 公式：归一化分数 = 匹配总分 / 双方关键词总数
        double keywordScore = totalKeywords > 0 ? (double) keywordMatch / totalKeywords : 0;

        // 使用 Math.min 防止极端情况下超过 1.0（如每个词都精确匹配）
        double normalizedScore = Math.min(1.0, keywordScore);

        // 返回保留 2 位小数的结果
        return BigDecimal.valueOf(normalizedScore).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 使用 Jieba 分词提取关键词
     *
     * 处理流程：
     *   1. 输入校验
     *   2. 调用 Jieba 分词器对文本进行智能分词
     *   3. 过滤：只保留长度≥2的词，或纯英文字符（避免"有"、"个"等无意义单字）
     *   4. 放入 HashSet 自动去重
     *
     * 示例：
     *   "一串钥匙，有一个钥匙扣" → ["一串", "钥匙", "有", "一个", "钥匙扣"]
     *   "iPhone 13" → ["iPhone", "13"]
     */
    private Set<String> extractKeywords(String text) {
        // ========== 第一步：输入校验 ==========
        Set<String> keywords = new HashSet<>();
        if (text == null || text.isBlank()) {
            return keywords;
        }

        // ========== 第二步：Jieba 智能分词 ==========
        // Jieba 会自动识别中文词语，例如 "宿舍钥匙" → ["宿舍", "钥匙"]
        List<String> words = jiebaSegmenter.sentenceProcess(text);

        // ========== 第三步：过滤有效词语 ==========
        for (String word : words) {
            word = word.trim();
            // 情况1：长度>=2的词（中文/英文/数字混合均可）→ 保留
            if (word.length() >= 2) {
                keywords.add(word.toLowerCase());
            }
            // 情况2：纯英文字符（即使只有一个字母也保留）→ 保留
            else if (word.matches("[a-zA-Z]+")) {
                keywords.add(word.toLowerCase());
            }
            // 情况3：单字中文（如"有"、"的"）→ 过滤掉，避免噪音
        }

        return keywords;
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