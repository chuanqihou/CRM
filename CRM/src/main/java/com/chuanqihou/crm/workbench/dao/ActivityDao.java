package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/13 16:38
 * @veersion 1.0
 */

//市场DAO层
public interface ActivityDao {
    //添加市场活动信息DAO
    int save(Activity activity);

    List<Activity> getActivityByCondition(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);
}
