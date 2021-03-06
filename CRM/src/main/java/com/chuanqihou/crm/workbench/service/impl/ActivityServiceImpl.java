package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.settings.dao.UserDao;
import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.dao.ActivityDao;
import com.chuanqihou.crm.workbench.dao.ActivityRemarkDao;
import com.chuanqihou.crm.workbench.domain.Activity;
import com.chuanqihou.crm.workbench.domain.ActivityRemark;
import com.chuanqihou.crm.workbench.service.ActivityService;

import java.util.HashMap;
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
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

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

    /**
     * 根据条件更新市场活动信息
     * @param id 更新条件
     * @return  返回更新状态
     */
    @Override
    public Map<String, Object> getUserListAndActivity(String id) {
        //获取所有用户信息
        List<User> userList = userDao.getUserList();
        //获取市场活动信息
        Activity a = activityDao.getById(id);
        //将结果封装至map对象
        Map<String,Object> map = new HashMap<>();
        map.put("a",a);
        map.put("uList",userList);
        //返回结果
        return map;
    }

    /**
     * 根据条件更新市场活动信息
     * @param activity  需要更新的内容
     * @return  返回更新状态
     */
    @Override
    public boolean update(Activity activity){
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (activityDao.update(activity)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    /**
     * 查询市场活动详细信息
     * @param id
     * @return
     */
    @Override
    public Activity detail(String id) {
        Activity a = activityDao.detail(id);
        return a;
    }

    /**
     * 查询备注信息
     * @param id
     * @return
     */
    @Override
    public List<ActivityRemark> getRemarkListById(String id) {
        List<ActivityRemark> arList = activityRemarkDao.getRemarkListById(id);
        return arList;
    }

    /**
     * 删除备注信息
     * @param id
     * @return
     */
    @Override
    public boolean deleteRemark(String id) {
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (activityRemarkDao.deleteRemark(id)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    /**
     * 保存备注信息
     * @param ar  ActivityRemark对象
     * @return
     */
    @Override
    public boolean saveRemark(ActivityRemark ar) {
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (activityRemarkDao.saveRemark(ar)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    /**
     * 修改备注信息
     * @param activityRemark
     * @return
     */
    @Override
    public boolean updateRemark(ActivityRemark activityRemark) {
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (activityRemarkDao.updateRemark(activityRemark)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    /**
     * 根据线索Id查询该线索中关联的市场活动
     * @param id    线索Id
     * @return  市场活动集合
     */
    @Override
    public List<Activity> getActivityByClueID(String id) {
        //调用Dao层连接数据库
        List<Activity> activities = activityDao.getActivityByClueID(id);
        return activities;
    }

    /**
     * 获取市场活动信息（除线索已关联的）
     * @param map   参数
     * @return  市场活动信息
     */
    @Override
    public List<Activity> getActivityByNameByClueID(Map<String, String> map) {
        //调用DAO层连接数据库
        List<Activity> activities = activityDao.getActivityByNameByClueID(map);
        return activities;
    }

    /**
     * 根据市场活动名称模糊查询市场活动信息
     * @param aname 市场活动名
     * @return  市场活动信息
     */
    @Override
    public List<Activity> getActivityListByName(String aname) {
        //调用dao层
        List<Activity> activities = activityDao.getActivityListByName(aname);
        //返回List<Activity>
        return activities;
    }
}
