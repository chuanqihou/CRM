package com.chuanqihou.crm.vo;

import java.util.List;

/**
 * PaginationVo对象用来封装返回结果
 * @auther 传奇后
 * @date 2021/9/14 19:44
 * @veersion 1.0
 */
public class PaginationVo<T> {
    //总页数
    private int total;
    //相关数据
    private List<T> dataList;

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public List<T> getDataList() {
        return dataList;
    }

    public void setDataList(List<T> dataList) {
        this.dataList = dataList;
    }
}
