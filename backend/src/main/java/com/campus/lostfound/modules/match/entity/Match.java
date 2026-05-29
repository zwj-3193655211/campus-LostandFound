package com.campus.lostfound.modules.match.entity;

import com.baomidou.mybatisplus.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 智能匹配记录实体
 */
@TableName("matches")
public class Match {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long lostItemId;

    private Long foundItemId;

    private BigDecimal score;

    /** 匹配类型: SERIAL_EXACT精确匹配, WEIGHTED加权匹配, NONE无匹配 */
    private String matchType;

    /** 状态: PENDING待确认, CONFIRMED已确认, REJECTED已拒绝 */
    private String status;

    private Integer isRead;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String lostItemTitle;

    @TableField(exist = false)
    private String foundItemTitle;

    @TableField(exist = false)
    private String lostItemCategory;

    @TableField(exist = false)
    private String foundItemCategory;

    public BigDecimal getScore() {
        return score;
    }

    public void setScore(BigDecimal score) {
        this.score = score;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getLostItemId() {
        return lostItemId;
    }

    public void setLostItemId(Long lostItemId) {
        this.lostItemId = lostItemId;
    }

    public Long getFoundItemId() {
        return foundItemId;
    }

    public void setFoundItemId(Long foundItemId) {
        this.foundItemId = foundItemId;
    }

    public String getMatchType() {
        return matchType;
    }

    public void setMatchType(String matchType) {
        this.matchType = matchType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getIsRead() {
        return isRead;
    }

    public void setIsRead(Integer isRead) {
        this.isRead = isRead;
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

    public String getLostItemTitle() {
        return lostItemTitle;
    }

    public void setLostItemTitle(String lostItemTitle) {
        this.lostItemTitle = lostItemTitle;
    }

    public String getFoundItemTitle() {
        return foundItemTitle;
    }

    public void setFoundItemTitle(String foundItemTitle) {
        this.foundItemTitle = foundItemTitle;
    }

    public String getLostItemCategory() {
        return lostItemCategory;
    }

    public void setLostItemCategory(String lostItemCategory) {
        this.lostItemCategory = lostItemCategory;
    }

    public String getFoundItemCategory() {
        return foundItemCategory;
    }

    public void setFoundItemCategory(String foundItemCategory) {
        this.foundItemCategory = foundItemCategory;
    }
}
