package com.chuanqihou.crm.settings.service.impl;

import com.chuanqihou.crm.exception.LoginException;
import com.chuanqihou.crm.settings.dao.UserDao;
import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.settings.service.UserService;
import com.chuanqihou.crm.utils.DateTimeUtil;
import com.chuanqihou.crm.utils.MD5Util;
import com.chuanqihou.crm.utils.SqlSessionUtil;
import org.apache.log4j.NDC;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/12 13:45
 * @veersion 1.0
 */
public class UserServiceIml implements UserService {
//    用户dao动态sql对象
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    /**
     * 用户信息验证（数据库）
     * @param loginAct 用户账号
     * @param loginPwd 用户密码（已加密）
     * @param ip 用户IP
     * @return  User对象
     * @throws LoginException 登录失败异常信息
     */
    @Override
    public User login(String loginAct, String loginPwd, String ip) throws LoginException {
        //将数据库条件封装成map集合
        Map<String,String> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
        //调用数据库返回User对象
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
        //返回User对象
        return user;
    }

    /**
     * 获取所有用户信息
     * @return  返回用户信息集合
     */
    @Override
    public List<User> getUserList() {
//        查询（调用数据库）
        UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
        List<User> userList = userDao.getUserList();
        return userList;
    }

    @Override
    public Map<String,Boolean> updatePwd(String userId, String oldPwd, String newPwd) {
        String oldPwdMD = MD5Util.getMD5(oldPwd);
        String newPwdMD = MD5Util.getMD5(newPwd);
        Map<String,String> map = new HashMap<>();
        map.put("userId",userId);
        map.put("oldPwd",oldPwdMD);
        map.put("newPwd",newPwdMD);
        boolean updatePwd = false;
        boolean checkingPwd = false;
        if (userDao.checkingPwd(map)==1){
            checkingPwd = true;
            if (userDao.updatePwd(map) == 1) {
                updatePwd = true;
            }
        }

        Map<String,Boolean> resultmap = new HashMap<>();
        resultmap.put("checkingPwd",checkingPwd);
        resultmap.put("updatePwd",updatePwd);
        return resultmap;
    }
}
