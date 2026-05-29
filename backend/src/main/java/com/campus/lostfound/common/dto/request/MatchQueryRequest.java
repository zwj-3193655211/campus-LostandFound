package com.campus.lostfound.common.dto.request;

/**
 * 匹配查询请求DTO
 */
public class MatchQueryRequest {

    private Integer page = 1;

    private Integer pageSize = 10;

    private String status;

    private Long userId;

    public Integer getPage() {
        return page;
    }

    public void setPage(Integer page) {
        this.page = page;
    }

    public Integer getPageSize() {
        return pageSize;
    }

    public void setPageSize(Integer pageSize) {
        this.pageSize = pageSize;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
