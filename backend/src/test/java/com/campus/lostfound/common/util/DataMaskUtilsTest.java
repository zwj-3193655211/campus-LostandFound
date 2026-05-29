package com.campus.lostfound.common.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DataMaskUtilsTest {

    @Test
    void shouldMaskIdCard() {
        assertEquals("1234**********5678", DataMaskUtils.maskIdCard("123456789012345678"));
    }

    @Test
    void shouldMaskContact() {
        assertEquals("138****5678", DataMaskUtils.maskContact("13812345678"));
    }

    @Test
    void shouldMaskSerialNumber() {
        assertEquals("AB****12", DataMaskUtils.maskSerialNumber("ABCD0012"));
    }
}
