package com.chuanqihou.crm.settings.service;

import com.chuanqihou.crm.settings.domain.User;

/**
 * @auther 传奇后
 * @date 2021/9/12 13:45
 * @veersion 1.0
 */
public interface UserService {
    User login(String loginAct, String loginPwd, String ip);
}
