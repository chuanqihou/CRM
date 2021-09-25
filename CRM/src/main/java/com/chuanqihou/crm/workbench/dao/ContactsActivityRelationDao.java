package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.ContactsActivityRelation;

public interface ContactsActivityRelationDao {

    //将数据插入联系人与市场活动关系
    int save(ContactsActivityRelation contactsActivityRelation);
}
