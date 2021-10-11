package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.settings.dao.UserDao;
import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.utils.UUIDUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.dao.*;
import com.chuanqihou.crm.workbench.domain.*;
import com.chuanqihou.crm.workbench.service.ContactsService;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/27 14:07
 * @veersion 1.0
 */
public class ContactsServiceImpl implements ContactsService {
    ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);

    @Override
    public PaginationVo<Customer> pageList(Map<String, Object> map) {
        //根据条件查询客户信息列表总数
        int total = contactsDao.getTotalByCondition(map);
        //根据条件查询所有客户信息
        List<Customer> contacts = contactsDao.getActivityByCondition(map);
        //创建PaginationVo<Customer>对象
        PaginationVo<Customer> vo = new PaginationVo<>();
        //将结果添加
        vo.setTotal(total);
        vo.setDataList(contacts);
        //返回PaginationVo<Customer>对象
        return vo;
    }

    @Override
    public List<Contacts> getContactsListByName(String fullName) {
        List<Contacts> contacts = contactsDao.getContactsListByName(fullName);
        return contacts;
    }

    @Override
    public List<String> getContactsName(String name) {
        List<String> contactNames = contactsDao.getContactsName(name);
        return contactNames;
    }

    @Override
    public boolean save(Contacts c) {
        boolean flag = true;
        String id = customerDao.getIdByName(c);
        c.setCustomerId(id);
        if (contactsDao.save(c)!=1){
            flag = false;
        }

        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndCustomer(String contactsId) {
        //获取所有用户信息
        List<User> user = userDao.getUserList();
        //获取客户信息
        Contacts contacts = contactsDao.getContactsById(contactsId);
        //封装
        Map<String,Object> map = new HashMap<>();
        map.put("uList",user);
        map.put("c",contacts);
        //返回
        return map;
    }

    @Override
    public boolean update(Contacts c) {
        boolean flag = true;
        String id = customerDao.getIdByName(c);
        c.setCustomerId(id);
        if (contactsDao.update(c)!=1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean delete(String[] ids) {
        boolean flag = true;
        for (String id : ids) {
            if (contactsDao.delete(id)!=1){
                flag = false;
            }
        }
        return flag;
    }

    @Override
    public Contacts detail(String id) {
        Contacts contacts = contactsDao.getContactsById(id);
        return contacts;
    }

    @Override
    public List<Tran> getTranByContactsId(String contactsId) {
        List<Tran> trans = tranDao.getTranByContactsId(contactsId);
        return trans;
    }

    @Override
    public List<Activity> showActivity(String contactsId) {
        List<Activity> activities = activityDao.getActivityByContactsId(contactsId);
        return activities;
    }

    @Override
    public List<Activity> getActivityListByNameByContactsId(Map<String,String> map) {
        //调用DAO层连接数据库
        List<Activity> activities = activityDao.getActivityByNameByContactsID(map);
        return activities;
    }

    @Override
    public boolean bund(String contactsId, String[] activityIds) {
        //定义初始状态信息
        boolean flag = true;
        //遍历取出市场活动Id
        for (String aid : activityIds) {
            //获取线索与市场活动关系表对象封装参数
            ContactsActivityRelation car = new ContactsActivityRelation();
            //生成id
            car.setId(UUIDUtil.getUUID());
            car.setContactsId(contactsId);
            car.setActivityId(aid);
            //调用Dao层
            if (contactsActivityRelationDao.save(car)!=1){
                flag = false;
            }
        }
        //返回状态信息
        return flag;
    }

    @Override
    public boolean ubund(String activityId) {
        boolean flag = true;
        if (contactsActivityRelationDao.ubund(activityId)!=1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean saveRemark(ContactsRemark ar) {
        boolean flag = true;
        if (contactsRemarkDao.save(ar)!=1){
            flag = false;
        }
        return flag;
    }

    @Override
    public List<ContactsRemark> getRemarkListById(String contactsId) {
        List<ContactsRemark> arList = contactsRemarkDao.getRemarkListById(contactsId);
        return arList;
    }

    @Override
    public boolean deleteRemark(String id) {
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (contactsRemarkDao.deleteRemarkById(id)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    @Override
    public boolean updateRemark(ContactsRemark contactsRemark) {
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (contactsRemarkDao.updateRemark(contactsRemark)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }
}
