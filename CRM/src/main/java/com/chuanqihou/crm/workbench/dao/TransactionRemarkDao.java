package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.TranRemark;

import java.util.List;

/**
 * @auther 传奇后
 * @date 2021/10/12 0:34
 * @veersion 1.0
 */
public interface TransactionRemarkDao {
    List<TranRemark> getRemarkListById(String transactionId);
}
