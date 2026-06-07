package com.campus.lostfound.common.dto.request;

/**
 * 管理员审核物品的请求体。
 * approved=true 时 reason 可空,=false 时 reason 必填(由 Controller 校验)。
 */
public class ItemReviewRequest {
    private Boolean approved;
    private String reason;

    public Boolean getApproved() { return approved; }
    public void setApproved(Boolean approved) { this.approved = approved; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
