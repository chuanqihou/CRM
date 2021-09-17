package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.ActivityRemark;

import java.util.List;

/**
 * @auther 传奇后
 * @date 2021/9/14 16:15
 * @veersion 1.0
 */
public interface ActivityRemarkDao {

    int getCountByIds(String[] ids);

    int deleteByIds(String[] ids);

    List<ActivityRemark> getRemarkListById(String id);

    int deleteRemark(String id);

    int saveRemark(ActivityRemark ar);

    int updateRemark(ActivityRemark activityRemark);
}
