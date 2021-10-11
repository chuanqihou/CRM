package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.utils.DateTimeUtil;
import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.utils.UUIDUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.dao.CustomerDao;
import com.chuanqihou.crm.workbench.dao.TranDao;
import com.chuanqihou.crm.workbench.dao.TranHistoryDao;
import com.chuanqihou.crm.workbench.domain.Customer;
import com.chuanqihou.crm.workbench.domain.Tran;
import com.chuanqihou.crm.workbench.domain.TranHistory;
import com.chuanqihou.crm.workbench.service.TransactionService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/27 15:20
 * @veersion 1.0
 */
public class TransactionServiceImpl implements TransactionService {
    TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);

    @Override
    public PaginationVo<Tran> pageList(Map<String, Object> map) {
        //根据条件查询客户信息列表总数
        int total = tranDao.getTotalByCondition(map);
        //根据条件查询所有客户信息
        List<Tran> tran = tranDao.getActivityByCondition(map);
        //创建PaginationVo<Customer>对象
        PaginationVo<Tran> vo = new PaginationVo<>();
        //将结果添加
        vo.setTotal(total);
        vo.setDataList(tran);
        //返回PaginationVo<Customer>对象
        return vo;
    }

    @Override
    public boolean add(Tran tran, String customerName) {
        boolean flag = true;
        Customer cus = customerDao.getCustomerByName(customerName);
        if (cus==null){
            cus = new Customer();
            cus.setId(UUIDUtil.getUUID());
            cus.setName(customerName);
            cus.setCreateBy(tran.getCreateBy());
            cus.setCreateTime(DateTimeUtil.getSysTime());
            cus.setContactSummary(tran.getContactSummary());
            cus.setNextContactTime(tran.getNextContactTime());
            cus.setOwner(tran.getOwner());
            if (customerDao.save(cus)!=1){
                flag = false;
            }
        }
        tran.setCustomerId(cus.getId());

        if (tranDao.save(tran)!=1){
            flag = false;
        }

        TranHistory th = new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setTranId(tran.getId());
        th.setStage(tran.getStage());
        th.setMoney(tran.getMoney());
        th.setExpectedDate(tran.getExpectedDate());
        th.setCreateBy(tran.getCreateBy());
        th.setCreateTime(DateTimeUtil.getSysTime());
        if (tranHistoryDao.save(th)!=1){
            flag = false;
        }


        return flag;
    }

    @Override
    public Tran detail(String id) {
        Tran t = tranDao.detail(id);

        return t;
    }

    @Override
    public List<TranHistory> getHistoryByTranId(String tranId) {
        List<TranHistory> tranHistories = tranHistoryDao.getHistoryListByTranId(tranId);
        return tranHistories;
    }

    @Override
    public boolean changeStage(Tran t) {
        boolean flag = true;

        if(tranDao.changeStage(t)!=1){
            flag = false;
        }

        TranHistory th = new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setCreateBy(t.getEditBy());
        th.setExpectedDate(t.getExpectedDate());
        th.setMoney(t.getMoney());
        th.setTranId(t.getId());
        th.setStage(t.getStage());
        th.setPossibility(t.getPossibility());

        if(tranHistoryDao.save(th)!=1){
            flag = false;
        }

        return flag;
    }

    @Override
    public Map<String, Object> getCharts() {
        int total = tranDao.getTotal();
        List<Map<String, Object>> mapList = tranDao.getCharts();
        Map<String, Object> map = new HashMap<>();
        map.put("total",total);
        map.put("dataList",mapList);
        return map;
    }

    @Override
    public Tran editShow(String transactionId) {
        Tran t = tranDao.editShow(transactionId);
        return t;
    }

    @Override
    public boolean update(Tran tran, String customerName) {
        boolean flag = true;
        Customer cus = customerDao.getCustomerByName(customerName);
        if (cus==null){
            cus = new Customer();
            cus.setId(UUIDUtil.getUUID());
            cus.setName(customerName);
            cus.setCreateBy(tran.getCreateBy());
            cus.setCreateTime(DateTimeUtil.getSysTime());
            cus.setContactSummary(tran.getContactSummary());
            cus.setNextContactTime(tran.getNextContactTime());
            cus.setOwner(tran.getOwner());
            if (customerDao.save(cus)!=1){
                flag = false;
            }
        }
        tran.setCustomerId(cus.getId());

        if (tranDao.update(tran)!=1){
            flag = false;
        }

        return flag;
    }

    @Override
    public boolean delete(String id) {
        boolean flag = true;
        if (tranDao.deleteTransactionById(id)!=1){
            flag = false;
        }
        return flag;
    }
}
