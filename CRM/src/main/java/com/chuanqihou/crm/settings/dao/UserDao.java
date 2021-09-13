package com.chuanqihou.crm.settings.dao;

import com.chuanqihou.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/12 13:40
 * @veersion 1.0
 */
public interface UserDao {
    User login(Map<String, String> map);

    List<User> getUserList();
}
