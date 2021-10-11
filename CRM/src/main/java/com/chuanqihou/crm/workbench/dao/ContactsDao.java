package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Contacts;
import com.chuanqihou.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface ContactsDao {
    //保存（插入）联系人信息
    int save(Contacts contacts);


    int getTotalByCondition(Map<String, Object> map);

    List<Customer> getActivityByCondition(Map<String, Object> map);

    List<Contacts> getContactsListByName(String fullName);

    List<String> getContactsName(String name);

    List<Contacts> getContactsByCustomerId(String customerId);

    Contacts getContactsById(String contactsId);

    int update(Contacts c);

    int delete(String id);

}
