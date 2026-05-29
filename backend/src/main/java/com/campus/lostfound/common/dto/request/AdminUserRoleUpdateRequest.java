package com.campus.lostfound.common.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * 管理端修改用户角色请求
 */
public class AdminUserRoleUpdateRequest {

    @NotBlank(message = "角色不能为空")
    @Pattern(regexp = "^(USER|CAMPUS_ADMIN|SUPER_ADMIN)$", message = "角色值不合法")
    private String role;

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
