package com.chuanqihou.crm.workbench.service;

import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.*;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/27 14:06
 * @veersion 1.0
 */
public interface ContactsService {
    PaginationVo<Customer> pageList(Map<String, Object> map);

    List<Contacts> getContactsListByName(String fullName);

    List<String> getContactsName(String name);

    boolean save(Contacts c);

    Map<String, Object> getUserListAndCustomer(String contactsId);

    boolean update(Contacts c);

    boolean delete(String[] ids);

    Contacts detail(String id);

    List<Tran> getTranByContactsId(String contactsId);

    List<Activity> showActivity(String contactsId);

    List<Activity> getActivityListByNameByContactsId(Map<String,String> map);

    boolean bund(String contactsId, String[] activityIds);

    boolean ubund(String activityId);

    boolean saveRemark(ContactsRemark ar);

    List<ContactsRemark> getRemarkListById(String contactsId);

    boolean deleteRemark(String id);

    boolean updateRemark(ContactsRemark contactsRemark);
}
