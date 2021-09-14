package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.dao.ActivityDao;
import com.chuanqihou.crm.workbench.domain.Activity;
import com.chuanqihou.crm.workbench.service.ActivityService;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/13 16:42
 * @veersion 1.0
 */

//实现类 市场活动业务处理层
public class ActivityServiceImpl implements ActivityService {
    //处理SQL语句DAO对象
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    /**
     * 添加市场活动信息
     * @param activity
     * @return  返回添加状态
     */
    @Override
    public boolean save(Activity activity) {
        boolean flag = true;
        if (activityDao.save(activity)!=1){
            flag = false;
        }
        return flag;
    }

    @Override
    public PaginationVo<Activity> pageList(Map<String, Object> map) {
        int total = activityDao.getTotalByCondition(map);
        List<Activity> activities = activityDao.getActivityByCondition(map);
        PaginationVo<Activity> vo = new PaginationVo<>();
        vo.setTotal(total);
        vo.setDataList(activities);
        return vo;
    }
}
