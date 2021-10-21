package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.settings.dao.UserDao;
import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.dao.*;
import com.chuanqihou.crm.workbench.domain.*;
import com.chuanqihou.crm.workbench.service.CustomerService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/25 16:57
 * @veersion 1.0
 */
public class CustomerServiceImpl implements CustomerService {
    //获取DAO对象
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);

    /**
     * 根据条件查询所有客户信息
     * @param map   条件
     * @return
     */
    @Override
    public PaginationVo<Customer> pageList(Map<String, Object> map) {
        //根据条件查询客户信息列表总数
        int total = customerDao.getTotalByCondition(map);
        //根据条件查询所有客户信息
        List<Customer> customers = customerDao.getActivityByCondition(map);
        //创建PaginationVo<Customer>对象
        PaginationVo<Customer> vo = new PaginationVo<>();
        //将结果添加
        vo.setTotal(total);
        vo.setDataList(customers);
        //返回PaginationVo<Customer>对象
        return vo;
    }

    /**
     * 插入客户信息
     * @param customer  客户信息
     * @return
     */
    @Override
    public boolean save(Customer customer) {
        //定义初始化状态
        boolean flag = false;
        //调用Dao
        if (customerDao.save(customer)==1){
            flag = true;
        }
        //返回状态信息
        return flag;
    }

    /**
     * 获取所有用户信息，根据客户Id获取客户详细信息
     * @param id    客户Id
     * @return
     */
    @Override
    public Map<String, Object> getUserListAndCustomer(String id) {
        //获取所有用户信息
        List<User> user = userDao.getUserList();
        //获取客户信息
        Customer customer = customerDao.getCustomerById(id);
        //封装
        Map<String,Object> map = new HashMap<>();
        map.put("uList",user);
        map.put("c",customer);
        //返回
        return map;
    }

    /**
     * 根据Id删除客户信息
     * @param ids
     * @return
     */
    @Override
    public boolean delete(String[] ids) {
        //定义初始化状态
        boolean flag = true;
        //遍历客户Id
        for (String id : ids) {
            //根据客户Id查询旗下的备注数量
            int count1 = customerRemarkDao.getTotalById(id);
            //根据客户Id删除旗下的所有的备注
            int count2 = customerRemarkDao.delete(id);
            //判断查询出的数量与实际数量是否相等
            if (count1==count2){
                //删除客户信息
                if (customerDao.delete(id)!=1){
                    flag = false;
                }
            }else {
                flag = false;
            }
        }
        //返回状态信息
        return flag;
    }

    /**
     * 根据客户Id更新客户信息
     * @param customer
     * @return
     */
    @Override
    public boolean update(Customer customer) {
        //定义初始化状态
        boolean flag = false;
        //调用Dao
        if (customerDao.update(customer)==1){
            flag = true;
        }
        //返回状态信息
        return flag;
    }

    /**
     * 根据Id查询客户详细信息
     * @param id
     * @return
     */
    @Override
    public Customer detail(String id) {
        Customer customer = customerDao.getCustomerByIdAndOwner(id);
        return customer;
    }

    /**
     * 根据客户Id查询备注信息
     * @param customerId
     * @return
     */
    @Override
    public List<CustomerRemark> getRemarkListById(String customerId) {
        List<CustomerRemark> arList = customerRemarkDao.getRemarkListById(customerId);
        return arList;
    }

    /**
     * 插入一条备注信息
     * @param ar
     * @return
     */
    @Override
    public boolean saveRemark(CustomerRemark ar) {
        //定义默认值
        boolean flag = true;
        //判断状态
        if (customerRemarkDao.saveRemark(ar)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    /**
     * 根据备注Id更新备注信息
     * @param customerRemark
     * @return
     */
    @Override
    public boolean updateRemark(CustomerRemark customerRemark) {
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (customerRemarkDao.updateRemark(customerRemark)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    /**
     * 根据备注Id删除备注信息
     * @param id
     * @return
     */
    @Override
    public boolean deleteRemark(String id) {
        //定义默认值
        boolean flag = true;
        //判断更新状态
        if (customerRemarkDao.deleteRemarkById(id)!=1){
            flag = false;
        }
        //返回结果
        return flag;
    }

    /**
     * 根据客户名称模糊查询客户信息
     * @param name  客户名称
     * @return  返回客户信息
     */
    @Override
    public List<Customer> getCustomerName(String name) {
        //调用DAO层
        List<Customer> customers = customerDao.getCustomerName(name);
        return customers;
    }

    /**
     * 通过客户Id获取交易信息
     * @param customerId    客户Id
     * @return  返回交易信息
     */
    @Override
    public List<Tran> getTranByCustomerId(String customerId) {
        //调用DAO层
        List<Tran> trans = tranDao.getTranByCustomerId(customerId);
        return trans;
    }

    /**
     * 根据交易Id删除交易信息
     * @param tranId    交易Id
     * @return  返回删除交易状态信息
     */
    @Override
    public boolean deleteTransactionById(String tranId) {
        //定义初始化状态
        boolean flag = true;
        //调用DAO层
        if(tranDao.deleteTransactionById(tranId)!=1){
            flag = false;
        }
        //返回状态信息
        return flag;
    }

    /**
     * 根据客户Id获取联系人信息
     * @param customerId    客户Id
     * @return  返回联系人信息
     */
    @Override
    public List<Contacts> getContactsByCustomerId(String customerId) {
        //获取处理联系人业务对象
        List<Contacts> contacts = contactsDao.getContactsByCustomerId(customerId);
        return contacts;
    }
}
