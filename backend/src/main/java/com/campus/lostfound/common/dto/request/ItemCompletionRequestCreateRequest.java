package com.campus.lostfound.common.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * 提交物品完成状态申请
 */
public class ItemCompletionRequestCreateRequest {

    @NotBlank(message = "目标状态不能为空")
    @Pattern(regexp = "^(FOUND_BACK|RETURNED)$", message = "目标状态不合法")
    private String targetStatus;

    @Size(max = 255, message = "申请说明最长255字符")
    private String reason;

    public String getTargetStatus() {
        return targetStatus;
    }

    public void setTargetStatus(String targetStatus) {
        this.targetStatus = targetStatus;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}
