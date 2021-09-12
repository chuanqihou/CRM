package com.chuanqihou.crm.settings.service.impl;

import com.chuanqihou.crm.settings.dao.UserDao;
import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.settings.service.UserService;
import com.chuanqihou.crm.utils.SqlSessionUtil;

/**
 * @auther 传奇后
 * @date 2021/9/12 13:45
 * @veersion 1.0
 */
public class UserServiceIml implements UserService {
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    @Override
    public User login(String loginAct, String loginPwd, String ip) {
        return null;
    }
}
