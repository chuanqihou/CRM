package com.chuanqihou.crm.workbench.service;

import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.Activity;
import com.chuanqihou.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/13 16:41
 * @veersion 1.0
 */

//接口 市场活动业务处理层
public interface ActivityService {
    //添加市场活动信息
    boolean save(Activity activity);

    //根据条件查询所有市场活动信息（用于展示数据），并将结果返回至PaginationVo<Activity>对象
    PaginationVo<Activity> pageList(Map<String, Object> map);

    //根据条件（市场活动Id）删除市场活动信息
    boolean delete(String[] ids);

    //获取List<User>,和一个市场活动信息
    Map<String, Object> getUserListAndActivity(String id);

    //根据条件更新市场活动信息
    boolean update(Activity activity);

    //展示市场活动的详细信息（仅市场活动信息）
    Activity detail(String id);

    //获取市场活动备注信息
    List<ActivityRemark> getRemarkListById(String id);

    //删除市场活动备注信息
    boolean deleteRemark(String id);

    //添加市场活动备注信息
    boolean saveRemark(ActivityRemark ar);

    //更新市场活动备注信息
    boolean updateRemark(ActivityRemark activityRemark);

    //根据线索Id查询该线索中关联的市场活动
    List<Activity> getActivityByClueID(String id);

    //获取市场活动信息（除线索已关联的）
    List<Activity> getActivityByNameByClueID(Map<String, String> map);
    //根据市场活动名称模糊查询市场活动信息
    List<Activity> getActivityListByName(String aname);
}
