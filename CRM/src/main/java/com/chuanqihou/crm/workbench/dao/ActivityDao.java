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
    //添加市场活动信息
    int save(Activity activity);
    //根据条件查询所有市场活动信息
    List<Activity> getActivityByCondition(Map<String, Object> map);
    //根据条件查询市场活动信息列表总数
    int getTotalByCondition(Map<String, Object> map);

    int delete(String[] ids);

    Activity getById(String id);

    int update(Activity activity);
}
