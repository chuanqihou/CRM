package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.dao.ActivityDao;
import com.chuanqihou.crm.workbench.dao.ActivityRemarkDao;
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
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);

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

    /**
     * 根据条件查询所有市场活动信息（用于展示数据），并将结果返回至PaginationVo<Activity>对象
     * @param map   查询条件
     * @return  PaginationVo<Activity>对象
     */
    @Override
    public PaginationVo<Activity> pageList(Map<String, Object> map) {
        //根据条件查询市场活动信息列表总数
        int total = activityDao.getTotalByCondition(map);
        //根据条件查询所有市场活动信息
        List<Activity> activities = activityDao.getActivityByCondition(map);
        //创建PaginationVo<Activity>对象
        PaginationVo<Activity> vo = new PaginationVo<>();
        //将结果添加
        vo.setTotal(total);
        vo.setDataList(activities);
        //返回PaginationVo<Activity>对象
        return vo;
    }

    /**
     * 根据条件（市场活动Id）删除市场活动信息方法实现
     * @param ids   删除条件
     * @return  返回删除结果
     */
    @Override
    public boolean delete(String[] ids) {
        //定义初始结果
        boolean flag = true;
        //查询出需要删除备注的数量
        int count1  = activityRemarkDao.getCountByIds(ids);
        //执行删除备注并返回实际删除的数量
        int count2 = activityRemarkDao.deleteByIds(ids);
        //判断需要删除备注数量与实际删除数量是否符合
        if (count1!=count2){
            flag = false;
        }
        //删除市场活动，并返回实际删除市场活动数量
        int count3 = activityDao.delete(ids);
        //判断需要删除市场活动数量与实际删除数量是否符合
        if (count3!=ids.length){
            flag = false;
        }
        //返回结果
        return flag;
    }
}
