package com.campus.lostfound.modules.match.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

/**
 * 智能匹配引擎
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

    private static final BigDecimal MATCH_THRESHOLD = new BigDecimal("0.65");
    private static final BigDecimal SERIAL_CONFLICT_PENALTY = new BigDecimal("0.40");

    public BigDecimal calculateScore(LostItem lostType, FoundItem foundType) {
        if (hasSerialMatch(lostType, foundType)) {
            log.info("串号精确匹配: lost={}, found={}", lostType.serialNumber, foundType.serialNumber);
            return new BigDecimal("1.00");
        }

        boolean hasSerialConflict = hasSerialConflict(lostType, foundType);
        BigDecimal categoryScore = calculateCategoryScore(lostType.category, foundType.category);
        BigDecimal locationScore = calculateLocationScore(lostType.locationId, lostType.locationText, foundType.locationId, foundType.locationText);
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

    private BigDecimal calculateLocationScore(Long locationId1, String locationText1, Long locationId2, String locationText2) {
        if (locationId1 != null && locationId2 != null) {
            if (locationId1.equals(locationId2)) {
                return BigDecimal.ONE;
            }
            return new BigDecimal("0.35");
        }
        BigDecimal textScore = similarityScore(locationText1, locationText2);
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
        return similarityScore(brand1, brand2).multiply(new BigDecimal("0.7")).setScale(2, RoundingMode.HALF_UP);
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
        BigDecimal score = similarityScore(left, right);
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

    private BigDecimal similarityScore(String left, String right) {
        Set<String> a = tokenize(left);
        Set<String> b = tokenize(right);
        if (a.isEmpty() || b.isEmpty()) {
            return BigDecimal.ZERO;
        }
        int intersection = 0;
        for (String token : a) {
            if (b.contains(token)) {
                intersection++;
            }
        }
        int total = a.size() + b.size();
        if (total == 0) {
            return BigDecimal.ZERO;
        }
        double dice = (2.0 * intersection) / total;
        return BigDecimal.valueOf(dice).setScale(2, RoundingMode.HALF_UP);
    }

    private Set<String> tokenize(String text) {
        if (text == null || text.isBlank()) {
            return Set.of();
        }

        String normalized = normalizeText(text);
        Set<String> tokens = new HashSet<>();

        for (String word : normalized.split("[^a-z0-9]+")) {
            if (word.length() >= 2) {
                tokens.add(word);
            }
        }

        String han = normalized.replaceAll("[^\\p{IsHan}]+", "");
        for (int i = 0; i + 1 < han.length(); i++) {
            tokens.add(han.substring(i, i + 2));
        }
        return tokens;
    }

    private String normalizeText(String text) {
        String value = text == null ? "" : text.trim().toLowerCase();
        return value.replaceAll("\\s+", " ");
    }

    public static class LostItem {
        public String category;
        public Long locationId;
        public String locationText;
        public String brand;
        public String color;
        public String title;
        public String description;
        public String serialNumber;
        public LocalDateTime lostTime;

        public LostItem(String category,
                        Long locationId,
                        String locationText,
                        String brand,
                        String color,
                        String title,
                        String description,
                        String serialNumber,
                        LocalDateTime lostTime) {
            this.category = category;
            this.locationId = locationId;
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
        public Long locationId;
        public String locationText;
        public String brand;
        public String color;
        public String title;
        public String description;
        public String serialNumber;
        public LocalDateTime foundTime;

        public FoundItem(String category,
                         Long locationId,
                         String locationText,
                         String brand,
                         String color,
                         String title,
                         String description,
                         String serialNumber,
                         LocalDateTime foundTime) {
            this.category = category;
            this.locationId = locationId;
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
