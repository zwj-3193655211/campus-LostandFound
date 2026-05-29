package com.campus.lostfound.modules.item.entity;

import com.baomidou.mybatisplus.annotation.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 失物招领实体
 */
@TableName("items")
public class Item {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    /** 类型: LOST寻物, FOUND招领 */
    private String type;

    private String category;

    private String title;

    private String description;

    private String brand;

    private String color;

    /** 用户填写的详细位置 */
    private String location;

    private Long locationId;

    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lostTime;

    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime foundTime;

    /** 序列号/证件号，用于精确匹配 */
    private String serialNumber;

    private String contactInfo;

    /** 状态: PENDING待审核, APPROVED已审核, REJECTED审核未通过, FOUND_BACK已找到, RETURNED已归还, EXPIRED已过期, CLOSED已关闭 */
    private String status;

    private Integer viewCount;

    private BigDecimal matchScore;

    private Long matchItemId;

    @TableField(exist = false)
    private List<String> images;

    @TableField(exist = false)
    private Boolean highConfidenceMatched;

    @TableField(exist = false)
    private String pendingCompletionStatus;

    @TableField(exist = false)
    private String pendingCompletionTargetStatus;

    @TableField(exist = false)
    private Boolean potentialOwnerNotified;

    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public Long getLocationId() {
        return locationId;
    }

    public void setLocationId(Long locationId) {
        this.locationId = locationId;
    }

    public LocalDateTime getLostTime() {
        return lostTime;
    }

    public void setLostTime(LocalDateTime lostTime) {
        this.lostTime = lostTime;
    }

    public LocalDateTime getFoundTime() {
        return foundTime;
    }

    public void setFoundTime(LocalDateTime foundTime) {
        this.foundTime = foundTime;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getContactInfo() {
        return contactInfo;
    }

    public void setContactInfo(String contactInfo) {
        this.contactInfo = contactInfo;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getViewCount() {
        return viewCount;
    }

    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }

    public BigDecimal getMatchScore() {
        return matchScore;
    }

    public void setMatchScore(BigDecimal matchScore) {
        this.matchScore = matchScore;
    }

    public Long getMatchItemId() {
        return matchItemId;
    }

    public void setMatchItemId(Long matchItemId) {
        this.matchItemId = matchItemId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getDeleted() {
        return deleted;
    }

    public void setDeleted(Integer deleted) {
        this.deleted = deleted;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }

    public Boolean getHighConfidenceMatched() {
        return highConfidenceMatched;
    }

    public void setHighConfidenceMatched(Boolean highConfidenceMatched) {
        this.highConfidenceMatched = highConfidenceMatched;
    }

    public String getPendingCompletionStatus() {
        return pendingCompletionStatus;
    }

    public void setPendingCompletionStatus(String pendingCompletionStatus) {
        this.pendingCompletionStatus = pendingCompletionStatus;
    }

    public String getPendingCompletionTargetStatus() {
        return pendingCompletionTargetStatus;
    }

    public void setPendingCompletionTargetStatus(String pendingCompletionTargetStatus) {
        this.pendingCompletionTargetStatus = pendingCompletionTargetStatus;
    }

    public Boolean getPotentialOwnerNotified() {
        return potentialOwnerNotified;
    }

    public void setPotentialOwnerNotified(Boolean potentialOwnerNotified) {
        this.potentialOwnerNotified = potentialOwnerNotified;
    }
}
