package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.TranHistory;

public interface TranHistoryDao {

    //将交易历史数据插入
    int save(TranHistory tranHistory);
}
