package com.campus.lostfound;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 基础测试
 */
@SpringBootTest
@ActiveProfiles("test")
class CampusLostFoundApplicationTest {

    @Test
    void contextLoads() {
        assertTrue(true);
    }
}