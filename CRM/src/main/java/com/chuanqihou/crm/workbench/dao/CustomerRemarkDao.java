package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface CustomerRemarkDao {

    //插入客户备注信息
    int save(CustomerRemark customerRemark);

    List<CustomerRemark> getRemarkListById(String customerId);

    int saveRemark(CustomerRemark ar);

    int getTotalById(String id);

    int delete(String id);

    int updateRemark(CustomerRemark customerRemark);

    int deleteRemarkById(String id);
}
