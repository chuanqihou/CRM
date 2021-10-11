package com.chuanqihou.crm.workbench.service;

import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.*;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/25 16:56
 * @veersion 1.0
 */
public interface CustomerService {
    PaginationVo<Customer> pageList(Map<String, Object> map);

    boolean save(Customer customer);

    Map<String, Object> getUserListAndCustomer(String id);

    boolean delete(String[] ids);

    boolean update(Customer customer);

    Customer detail(String id);

    List<CustomerRemark> getRemarkListById(String customerId);

    boolean saveRemark(CustomerRemark ar);

    boolean updateRemark(CustomerRemark customerRemark);

    boolean deleteRemark(String id);

    List<Customer> getCustomerName(String name);

    List<Tran> getTranByCustomerId(String customerId);

    boolean deleteTransactionById(String tranId);

    List<Contacts> getContactsByCustomerId(String customerId);
}
