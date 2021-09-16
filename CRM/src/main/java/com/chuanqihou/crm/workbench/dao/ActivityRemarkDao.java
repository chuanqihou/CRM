package com.chuanqihou.crm.workbench.dao;

/**
 * @auther 传奇后
 * @date 2021/9/14 16:15
 * @veersion 1.0
 */
public interface ActivityRemarkDao {
    int getCountByIds(String[] ids);

    int deleteByIds(String[] ids);
}
