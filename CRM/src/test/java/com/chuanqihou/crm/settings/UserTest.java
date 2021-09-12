package com.chuanqihou.crm.settings;

import com.chuanqihou.crm.utils.DateTimeUtil;
import org.junit.Test;

/**
 * @auther 传奇后
 * @date 2021/9/12 14:17
 * @veersion 1.0
 */
public class UserTest {
    @Test
    public void testTime(){
//        验证失效时间
//        失效时间
        String expireTime = "2025-8-13 08:00:00";
//        当前系统时间
        String currentTime = DateTimeUtil.getSysTime();
        int count  = expireTime.compareTo(currentTime);
        System.out.println(count);
    }

    @Test
    public void testLockState(){
//      验证账号状态
        String lockState = "0";
        if ("0".equals(lockState)){
            System.out.println("账号已锁定，请联系管理员");
        }
    }

    @Test
    public void testIp(){
//        验证Ip地址
        String ip = "192.168.8.1";
        String allowIp = "192.168.1.1,127.0.0.1";
        if (!(allowIp.contains(ip))){
            System.out.println("ip地址受限，请联系管理员！");
        }
    }
}
