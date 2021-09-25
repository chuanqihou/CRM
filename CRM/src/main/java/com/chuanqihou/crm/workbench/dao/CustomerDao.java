package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Customer;

public interface CustomerDao {

    //通过公司名称获取客户信息
    Customer getCustomerByName(String company);
    //插入客户信息
    int save(Customer customer);
}
