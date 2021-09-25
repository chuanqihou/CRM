package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Contacts;

public interface ContactsDao {
    //保存（插入）联系人信息
    int save(Contacts contacts);
}
