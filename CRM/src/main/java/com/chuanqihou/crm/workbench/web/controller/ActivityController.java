package com.chuanqihou.crm.workbench.web.controller;

import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.settings.service.UserService;
import com.chuanqihou.crm.settings.service.impl.UserServiceIml;
import com.chuanqihou.crm.utils.*;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.Activity;
import com.chuanqihou.crm.workbench.service.ActivityService;
import com.chuanqihou.crm.workbench.service.impl.ActivityServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/12 13:47
 * @veersion 1.0
 */
public class ActivityController extends HttpServlet {
    /**
     * 判断来访网站资源
     * @param request 请求
     * @param response  响应
     * @throws ServletException 返回异常信息
     * @throws IOException  返回异常信息
     */
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到市场活动Servlet");
        String path = request.getServletPath();
        if ("/workbench/activity/getUserList.do".equals(path)){
            getUserList(request,response);
        }else if ("/workbench/activity/save.do".equals(path)){
            save(request,response);
        }else if ("/workbench/activity/pageList.do".equals(path)){
            pageList(request,response);
        }
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        System.out.println("进入到查询市场活动信息列表操作（结合条件查询和分页查询）");
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        int skipCount = (pageNo-1)*pageSize;

        Map<String, Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("pageSize",pageSize);
        map.put("skipCount",skipCount);
        PaginationVo<Activity> vo = activityService.pageList(map);
        PrintJson.printJsonObj(response,vo);

    }

    /**
     * 添加市场活动信息Servlet
     * @param request   请求
     * @param response  响应
     */
    private void save(HttpServletRequest request, HttpServletResponse response) {
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        System.out.println("进入到市场活动添加操作");
        //获取参数信息
        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();

        //将数据封装在Activity对象中
        Activity activity = new Activity();
        activity.setCost(cost);
        activity.setCreateBy(createBy);
        activity.setCreateTime(createTime);
        activity.setDescription(description);
        activity.setId(id);
        activity.setName(name);
        activity.setOwner(owner);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);

        //调用业务层完善插入条件和获取插入状态
        boolean flag = activityService.save(activity);
        //将插入结果转换成json对象并传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 获取所有用户信息对象Servler
     * @param request  请求
     * @param response  响应
     */
    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("取得用户信息列表");
        //用户信息处理Service对象
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceIml());
        //调用用户查询方法获取用户信息
        List<User> userList = userService.getUserList();
        //将用户信息转换成json对象并传入前端
        PrintJson.printJsonObj(response,userList);
    }

}
