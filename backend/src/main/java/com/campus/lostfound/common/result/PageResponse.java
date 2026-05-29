package com.campus.lostfound.common.result;

import java.util.List;

/**
 * 分页响应
 */
public class PageResponse<T> {

    private int current;
    private int pageSize;
    private long total;
    private int pages;
    private List<T> records;

    public PageResponse() {
    }

    public PageResponse(int current, int pageSize, long total, int pages, List<T> records) {
        this.current = current;
        this.pageSize = pageSize;
        this.total = total;
        this.pages = pages;
        this.records = records;
    }

    public int getCurrent() {
        return current;
    }

    public void setCurrent(int current) {
        this.current = current;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public long getTotal() {
        return total;
    }

    public void setTotal(long total) {
        this.total = total;
    }

    public int getPages() {
        return pages;
    }

    public void setPages(int pages) {
        this.pages = pages;
    }

    public List<T> getRecords() {
        return records;
    }

    public void setRecords(List<T> records) {
        this.records = records;
    }

    public static <T> PageResponse<T> of(List<T> records, long total, int current, int pageSize) {
        int pages = (int) Math.ceil((double) total / pageSize);
        return new PageResponse<>(current, pageSize, total, pages, records);
    }
}
