package com.chuanqihou.crm.settings.web.controller;

import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.settings.service.UserService;
import com.chuanqihou.crm.settings.service.impl.UserServiceIml;
import com.chuanqihou.crm.utils.MD5Util;
import com.chuanqihou.crm.utils.PrintJson;
import com.chuanqihou.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/12 13:47
 * @veersion 1.0
 */
public class UserServlet extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到用户Servlet");
        //获取网站资源名并判断
        String path = request.getServletPath();
        //用户登录验证
        if ("/setting/user/login.do".equals(path)){
            login(request,response);
        }else if ("/setting/user/updatePwd.do".equals(path)){
            updatePwd(request,response);
        }
    }

    private void updatePwd(HttpServletRequest request, HttpServletResponse response) {
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceIml());
        String userId = request.getParameter("userId");
        String oldPwd = request.getParameter("oldPwd");
        String newPwd = request.getParameter("newPwd");
        Map<String,Boolean> map = userService.updatePwd(userId,oldPwd,newPwd);
        PrintJson.printJsonObj(response,map);
    }

    //    用户登录验证
    private void login(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到用户登录验证阶段");
        //获取用户账号和密码
        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        //将密码利用MD5技术进行加密
        loginPwd = MD5Util.getMD5(loginPwd);
        //获取访问网站ip地址
        String ip = request.getRemoteAddr();
        System.out.println("===================ip："+ip);
        //获取userService动态sql服务对象
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceIml());
        try {
            User user = userService.login(loginAct,loginPwd,ip);    //如果抛异常则执行try...catch语句
            //用户信息验证成功后将其加入到Session会话作用域中
            request.getSession().setAttribute("user",user);
            //将登录成功信息转换为json数据传入前端
            PrintJson.printJsonFlag(response,"success",true);
        }catch (Exception e){
            e.printStackTrace();
            //获取异常信息
            String msg = e.getMessage();
            //将登陆失败信息加入map集合
            Map<String,Object> map = new HashMap<>();
            map.put("success",false);
            map.put("msg",msg);
            //将map集合转换为json数据并传入前端
            PrintJson.printJsonObj(response,map);
        }

    }
}
