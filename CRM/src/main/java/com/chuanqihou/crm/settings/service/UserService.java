package com.chuanqihou.crm.settings.service;

import com.chuanqihou.crm.exception.LoginException;
import com.chuanqihou.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

/**
 * 用户接口
 * @auther 传奇后
 * @date 2021/9/12 13:45
 * @veersion 1.0
 */
public interface UserService {
//    用户登录验证
    User login(String loginAct, String loginPwd, String ip) throws LoginException;

//    用户信息查询
    List<User> getUserList();

    Map<String,Boolean> updatePwd(String userId, String oldPwd, String newPwd);
}
