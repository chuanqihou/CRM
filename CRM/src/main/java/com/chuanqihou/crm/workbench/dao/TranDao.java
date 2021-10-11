package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Contacts;
import com.chuanqihou.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    //插入交易信息
    int save(Tran tran);

    int getTotalByCondition(Map<String, Object> map);

    List<Tran> getActivityByCondition(Map<String, Object> map);

    Tran detail(String id);

    int changeStage(Tran t);

    List<Tran> getTranByCustomerId(String customerId);

    int deleteTransactionById(String tranId);

    int getTotal();

    List<Map<String, Object>> getCharts();

    List<Tran> getTranByContactsId(String contactsId);

    String[] getActivityByContactsId(String contactsId);

    Tran editShow(String transactionId);

    int update(Tran tran);
}
