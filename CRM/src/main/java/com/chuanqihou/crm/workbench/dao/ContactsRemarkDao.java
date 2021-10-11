package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.ContactsRemark;
import com.chuanqihou.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface ContactsRemarkDao {
    //插入联系人备注
    int save(ContactsRemark contactsRemark);

    List<ContactsRemark> getRemarkListById(String contactsId);

    int deleteRemarkById(String id);

    int updateRemark(ContactsRemark contactsRemark);
}
