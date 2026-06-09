package com.campus.lostfound.modules.common.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * Redis缓存服务
 * 提供通用的缓存操作方法
 */
@Service
public class RedisCacheService {

    private static final Logger log = LoggerFactory.getLogger(RedisCacheService.class);

    private final RedisTemplate<String, Object> redisTemplate;
    private final ValueOperations<String, Object> valueOperations;
    private final ObjectMapper objectMapper;

    // 缓存 Key 前缀
    public static final String PREFIX_STATISTICS = "cache:statistics:";
    public static final String PREFIX_ITEM = "cache:item:";
    public static final String PREFIX_CATEGORY = "cache:category:";
    public static final String PREFIX_USER = "cache:user:";

    // 默认缓存时间（分钟）
    public static final long DEFAULT_TTL = 30;
    public static final long SHORT_TTL = 5;    // 短缓存（5分钟）
    public static final long LONG_TTL = 60;    // 长缓存（1小时）

    public RedisCacheService(RedisTemplate<String, Object> redisTemplate, ObjectMapper objectMapper) {
        this.redisTemplate = redisTemplate;
        this.valueOperations = redisTemplate.opsForValue();
        this.objectMapper = objectMapper;
    }

    /**
     * 设置缓存（使用默认过期时间）
     */
    public void set(String key, Object value) {
        set(key, value, DEFAULT_TTL, TimeUnit.MINUTES);
    }

    /**
     * 设置缓存（指定过期时间）
     */
    public void set(String key, Object value, long timeout, TimeUnit unit) {
        try {
            String json = objectMapper.writeValueAsString(value);
            valueOperations.set(key, json, timeout, unit);
            log.debug("缓存设置成功: key={}, ttl={}{}", key, timeout, unit);
        } catch (JsonProcessingException e) {
            log.error("缓存序列化失败: key={}", key, e);
        }
    }

    /**
     * 设置缓存（使用Duration）
     */
    public void set(String key, Object value, Duration duration) {
        try {
            String json = objectMapper.writeValueAsString(value);
            valueOperations.set(key, json, duration);
            log.debug("缓存设置成功: key={}, duration={}", key, duration);
        } catch (JsonProcessingException e) {
            log.error("缓存序列化失败: key={}", key, e);
        }
    }

    /**
     * 获取缓存
     */
    public <T> T get(String key, Class<T> clazz) {
        try {
            Object value = valueOperations.get(key);
            if (value == null) {
                log.debug("缓存未命中: key={}", key);
                return null;
            }
            if (value instanceof String) {
                return objectMapper.readValue((String) value, clazz);
            }
            return objectMapper.convertValue(value, clazz);
        } catch (Exception e) {
            log.error("缓存反序列化失败: key={}", key, e);
            return null;
        }
    }

    /**
     * 获取缓存（支持泛型）
     */
    @SuppressWarnings("unchecked")
    public <T> T get(String key) {
        try {
            Object value = valueOperations.get(key);
            if (value == null) {
                log.debug("缓存未命中: key={}", key);
                return null;
            }
            if (value instanceof String) {
                return (T) objectMapper.readValue((String) value, Object.class);
            }
            return (T) value;
        } catch (Exception e) {
            log.error("缓存获取失败: key={}", key, e);
            return null;
        }
    }

    /**
     * 删除缓存
     */
    public Boolean delete(String key) {
        Boolean result = redisTemplate.delete(key);
        log.debug("缓存删除: key={}, result={}", key, result);
        return result;
    }

    /**
     * 删除匹配的所有缓存（支持通配符）
     */
    public Long deleteByPattern(String pattern) {
        Set<String> keys = redisTemplate.keys(pattern);
        if (keys != null && !keys.isEmpty()) {
            Long count = redisTemplate.delete(keys);
            log.info("批量删除缓存: pattern={}, count={}", pattern, count);
            return count;
        }
        return 0L;
    }

    /**
     * 判断key是否存在
     */
    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    /**
     * 设置key过期时间
     */
    public Boolean expire(String key, long timeout, TimeUnit unit) {
        return redisTemplate.expire(key, timeout, unit);
    }

    /**
     * 获取key剩余过期时间
     */
    public Long getExpire(String key) {
        return redisTemplate.getExpire(key, TimeUnit.SECONDS);
    }

    /**
     * 自增操作
     */
    public Long increment(String key) {
        return valueOperations.increment(key);
    }

    /**
     * 自增操作（指定步长）
     */
    public Long increment(String key, long delta) {
        return valueOperations.increment(key, delta);
    }

    /**
     * 自减操作
     */
    public Long decrement(String key) {
        return valueOperations.decrement(key);
    }

    /**
     * 哈希存储
     */
    public void hashPut(String key, String hashKey, Object value) {
        redisTemplate.opsForHash().put(key, hashKey, value);
    }

    /**
     * 获取哈希值
     */
    public Object hashGet(String key, String hashKey) {
        return redisTemplate.opsForHash().get(key, hashKey);
    }

    /**
     * 获取所有哈希值
     */
    public Map<Object, Object> hashGetAll(String key) {
        return redisTemplate.opsForHash().entries(key);
    }

    /**
     * 删除哈希字段
     */
    public Long hashDelete(String key, Object... hashKeys) {
        return redisTemplate.opsForHash().delete(key, hashKeys);
    }

    /**
     * 添加到列表
     */
    public Long listPush(String key, Object value) {
        return redisTemplate.opsForList().rightPush(key, value);
    }

    /**
     * 获取列表
     */
    public List<Object> listRange(String key, long start, long end) {
        return redisTemplate.opsForList().range(key, start, end);
    }

    /**
     * 获取列表长度
     */
    public Long listSize(String key) {
        return redisTemplate.opsForList().size(key);
    }

    /**
     * 缓存空值（防止缓存穿透）
     */
    public void cacheNullValue(String key, long timeout, TimeUnit unit) {
        valueOperations.set(key, "NULL", timeout, unit);
    }

    /**
     * 判断是否为缓存的空值
     */
    public boolean isCachedNullValue(String key) {
        Object value = valueOperations.get(key);
        return "NULL".equals(value);
    }

    // ============ 统计缓存快捷方法 ============

    /**
     * 获取统计数据
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> getStatistics(String type) {
        return get(PREFIX_STATISTICS + type, Map.class);
    }

    /**
     * 设置统计数据
     */
    public void setStatistics(String type, Map<String, Object> data) {
        set(PREFIX_STATISTICS + type, data, Duration.ofMinutes(SHORT_TTL));
    }

    /**
     * 清除统计缓存
     */
    public void clearStatisticsCache() {
        deleteByPattern(PREFIX_STATISTICS + "*");
    }

    // ============ 物品缓存快捷方法 ============

    /**
     * 获取物品详情
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> getItem(Long id) {
        return get(PREFIX_ITEM + id, Map.class);
    }

    /**
     * 设置物品详情
     */
    public void setItem(Long id, Map<String, Object> item) {
        set(PREFIX_ITEM + id, item, Duration.ofMinutes(SHORT_TTL));
    }

    /**
     * 清除物品缓存
     */
    public void clearItemCache(Long id) {
        delete(PREFIX_ITEM + id);
    }

    /**
     * 清除物品列表缓存
     */
    public void clearItemListCache() {
        deleteByPattern(PREFIX_ITEM + "list:*");
    }

    // ============ 分类缓存快捷方法 ============

    /**
     * 获取分类列表
     */
    @SuppressWarnings("unchecked")
    public List<String> getCategories() {
        return get(PREFIX_CATEGORY + "all", List.class);
    }

    /**
     * 设置分类列表
     */
    public void setCategories(List<String> categories) {
        set(PREFIX_CATEGORY + "all", categories, Duration.ofHours(LONG_TTL));
    }

    /**
     * 清除分类缓存
     */
    public void clearCategoryCache() {
        delete(PREFIX_CATEGORY + "*");
    }
}
