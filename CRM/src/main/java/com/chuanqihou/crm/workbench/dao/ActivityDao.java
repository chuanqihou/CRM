package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Activity;
import com.chuanqihou.crm.workbench.domain.ActivityRemark;

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
    //删除市场活动信息
    int delete(String[] ids);
    //通过ID查询市场活动信息
    Activity getById(String id);
    //更新市场活动信息
    int update(Activity activity);
    //展示市场活动信息
    Activity detail(String id);
    //根据线索Id查询该线索中关联的市场活动
    List<Activity> getActivityByClueID(String id);
    //获取市场活动信息（除线索已关联的）
    List<Activity> getActivityByNameByClueID(Map<String, String> map);

    List<Activity> getActivityListByName(String aname);

    Activity getActivityById(String activityId);

    List<Activity> getActivityByNameByContactsID(Map<String, String> map);

    List<Activity> getActivityByContactsId(String contactsId);
}
