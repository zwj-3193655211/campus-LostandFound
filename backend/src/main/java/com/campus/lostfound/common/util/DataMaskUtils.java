package com.campus.lostfound.common.util;

/**
 * 简单敏感信息脱敏工具
 */
public final class DataMaskUtils {

    private DataMaskUtils() {
    }

    public static String maskIdCard(String idCard) {
        if (idCard == null || idCard.isBlank()) {
            return idCard;
        }
        if (idCard.length() <= 8) {
            return repeat('*', idCard.length());
        }
        return idCard.substring(0, 4) + repeat('*', idCard.length() - 8) + idCard.substring(idCard.length() - 4);
    }

    public static String maskContact(String contact) {
        if (contact == null || contact.isBlank()) {
            return contact;
        }
        if (contact.length() <= 7) {
            return repeat('*', contact.length());
        }
        return contact.substring(0, 3) + repeat('*', contact.length() - 7) + contact.substring(contact.length() - 4);
    }

    public static String maskSerialNumber(String serialNumber) {
        if (serialNumber == null || serialNumber.isBlank()) {
            return serialNumber;
        }
        if (serialNumber.length() <= 6) {
            return repeat('*', serialNumber.length());
        }
        return serialNumber.substring(0, 2) + repeat('*', serialNumber.length() - 4) + serialNumber.substring(serialNumber.length() - 2);
    }

    private static String repeat(char ch, int count) {
        return String.valueOf(ch).repeat(Math.max(0, count));
    }
}
