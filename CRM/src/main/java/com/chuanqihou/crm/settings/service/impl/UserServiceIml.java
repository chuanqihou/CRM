package com.chuanqihou.crm.settings.service.impl;

import com.chuanqihou.crm.exception.LoginException;
import com.chuanqihou.crm.settings.dao.UserDao;
import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.settings.service.UserService;
import com.chuanqihou.crm.utils.DateTimeUtil;
import com.chuanqihou.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/12 13:45
 * @veersion 1.0
 */
public class UserServiceIml implements UserService {
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    @Override
    public User login(String loginAct, String loginPwd, String ip) throws LoginException {
        Map<String,String> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
        User user = userDao.login(map);
//        验证账号和密码
        if (user==null){
            throw new LoginException("账号或密码错误");
        }
//        验证失效时间
        String expireTime = user.getExpireTime();
        String currentTime = DateTimeUtil.getSysTime();
        if ((expireTime.compareTo(currentTime))<0){
            throw new LoginException("账号授权时间已过期，请联系管理员");
        }
//        判定账号是否锁定
        String lockState = user.getLockState();
        if ("0".equals(lockState)){
            throw new LoginException("账号已锁定，请联系管理员");
        }
//        判断Ip地址
        String allowIp = user.getAllowIps();
        if (!allowIp.contains(ip)){
            throw new LoginException("ip地址受限，请联系管理员");
        }
//
        return user;
    }

    @Override
    public List<User> getUserList() {
        List<User> userList = userDao.getUserList();
        return userList;
    }
}
