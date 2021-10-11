package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Contacts;
import com.chuanqihou.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerDao {

    //通过公司名称获取客户信息
    Customer getCustomerByName(String company);
    //插入客户信息
    int save(Customer customer);

    int getTotalByCondition(Map<String, Object> map);

    List<Customer> getActivityByCondition(Map<String, Object> map);

    Customer getCustomerById(String id);

    int delete(String id);

    int update(Customer customer);

    Customer getCustomerByIdAndOwner(String id);

    List<Customer> getCustomerName(String name);

    String getIdByName(Contacts c);
}
