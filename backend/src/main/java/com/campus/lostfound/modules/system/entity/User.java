package com.campus.lostfound.modules.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

/**
 * 用户实体类
 */
@TableName("users")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String password;

    private String email;

    private String studentId;

    private String phone;

    /** 真实姓名(实名认证) */
    private String realName;

    /** 身份证号(实名认证) */
    private String idCard;

    /** 实名认证状态: UNVERIFIED/PENDING/VERIFIED/REJECTED */
    private String identityStatus;

    /** 实名认证通过时间 */
    private LocalDateTime identityVerifiedAt;

    /** 角色: SUPER_ADMIN, CAMPUS_ADMIN, USER */
    private String role;

    /** 状态: 0禁用 1正常 */
    private Integer status;

    /** 站内通知: 0关闭 1开启 */
    private Integer notificationInApp;

    /** 邮件通知: 0关闭 1开启 */
    private Integer notificationEmail;

    /** 匹配提醒: 0关闭 1开启 */
    private Integer notificationMatch;

    /** 审核提醒: 0关闭 1开启 */
    private Integer notificationVerification;

    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastLoginTime;

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

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRealName() {
        return realName;
    }

    public void setRealName(String realName) {
        this.realName = realName;
    }

    public String getIdCard() {
        return idCard;
    }

    public void setIdCard(String idCard) {
        this.idCard = idCard;
    }

    public String getIdentityStatus() {
        return identityStatus;
    }

    public void setIdentityStatus(String identityStatus) {
        this.identityStatus = identityStatus;
    }

    public LocalDateTime getIdentityVerifiedAt() {
        return identityVerifiedAt;
    }

    public void setIdentityVerifiedAt(LocalDateTime identityVerifiedAt) {
        this.identityVerifiedAt = identityVerifiedAt;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getNotificationInApp() {
        return notificationInApp;
    }

    public void setNotificationInApp(Integer notificationInApp) {
        this.notificationInApp = notificationInApp;
    }

    public Integer getNotificationEmail() {
        return notificationEmail;
    }

    public void setNotificationEmail(Integer notificationEmail) {
        this.notificationEmail = notificationEmail;
    }

    public Integer getNotificationMatch() {
        return notificationMatch;
    }

    public void setNotificationMatch(Integer notificationMatch) {
        this.notificationMatch = notificationMatch;
    }

    public Integer getNotificationVerification() {
        return notificationVerification;
    }

    public void setNotificationVerification(Integer notificationVerification) {
        this.notificationVerification = notificationVerification;
    }

    public LocalDateTime getLastLoginTime() {
        return lastLoginTime;
    }

    public void setLastLoginTime(LocalDateTime lastLoginTime) {
        this.lastLoginTime = lastLoginTime;
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
}
