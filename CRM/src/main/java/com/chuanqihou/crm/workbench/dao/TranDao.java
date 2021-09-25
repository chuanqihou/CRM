package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Tran;

public interface TranDao {

    //插入交易信息
    int save(Tran tran);
}
