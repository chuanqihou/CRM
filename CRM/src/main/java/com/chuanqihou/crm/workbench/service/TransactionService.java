package com.chuanqihou.crm.workbench.service;

import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.Customer;
import com.chuanqihou.crm.workbench.domain.Tran;
import com.chuanqihou.crm.workbench.domain.TranHistory;
import com.chuanqihou.crm.workbench.domain.TranRemark;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/27 15:20
 * @veersion 1.0
 */
public interface TransactionService {
    PaginationVo<Tran> pageList(Map<String, Object> map);

    boolean add(Tran tran, String customerName);

    Tran detail(String id);

    List<TranHistory> getHistoryByTranId(String tranId);

    boolean changeStage(Tran t);

    Map<String, Object> getCharts();

    Tran editShow(String transactionId);

    boolean update(Tran tran, String customerName);

    boolean delete(String id);

    List<TranRemark> getRemarkListById(String transactionId);
}
