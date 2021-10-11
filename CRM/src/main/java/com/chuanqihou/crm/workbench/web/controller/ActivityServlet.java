package com.chuanqihou.crm.workbench.web.controller;

import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.settings.service.UserService;
import com.chuanqihou.crm.settings.service.impl.UserServiceIml;
import com.chuanqihou.crm.utils.*;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.Activity;
import com.chuanqihou.crm.workbench.domain.ActivityRemark;
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
public class ActivityServlet extends HttpServlet {
    /**
     * 判断来访网站资源
     * @param request 请求
     * @param response  响应
     * @throws ServletException 返回异常信息
     * @throws IOException  返回异常信息
     */
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        //进入获取用户信息方法（get）
        if ("/workbench/activity/getUserList.do".equals(path)){
            getUserList(request,response);
        //进入创建市场活动信息方法(insert)
        }else if ("/workbench/activity/save.do".equals(path)){
            save(request,response);
        //进入根据条件获取市场活动信息列表并返回总页数和市场活动信息
        }else if ("/workbench/activity/pageList.do".equals(path)){
            pageList(request,response);
        //进入根据选中Id删除市场活动信息
        }else if ("/workbench/activity/delete.do".equals(path)){
            delete(request,response);
        //根据市场活动Id查询市场活动信息；查询所有用户信息；目的：获取修改市场活动信息模板页面中的数据
        }else if ("/workbench/activity/getUserListAndActivity.do".equals(path)){
            getUserListAndActivity(request,response);
        //根据条件更新市场活动信息
        }else if("/workbench/activity/update.do".equals(path)){
            update(request,response);
        //展示市场活动的详细信息（仅市场活动信息）
        }else if ("/workbench/activity/detail.do".equals(path)){
            detail(request,response);
        //展示市场活动的备注信息
        }else if ("/workbench/activity/getRemarkListById.do".equals(path)){
            getRemarkListById(request,response);
        //根据Id删除备注信息
        }else if ("/workbench/activity/deleteRemark.do".equals(path)){
            deleteRemark(request,response);
        //新建和保存备注信息
        }else if ("/workbench/activity/saveRemark.do".equals(path)){
            saveRemark(request,response);
        //根据Id更新备注信息
        }else if ("/workbench/activity/updateRemark.do".equals(path)){
            updataRemark(request,response);
        }
    }

    /**
     * 根据市场活动Id更新备注信息
     * @param request   请求
     * @param response  响应
     */
    private void updataRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");
        //获取时间
        String editTime = DateTimeUtil.getSysTime();
        //获取当前用户信息
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        //将修改状态赋值为1
        String editFlag = "1";
        //创建ActivityRemark对象进行数据封装
        ActivityRemark activityRemark = new ActivityRemark();
        activityRemark.setId(id);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setEditTime(editTime);
        activityRemark.setEditBy(editBy);
        activityRemark.setEditFlag(editFlag);
        //调用dao层，传入ActivityRemark对象条件并返回状态信息
        boolean flag = activityService.updateRemark(activityRemark);
        //将状态信息以及ActivityRemark对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",activityRemark);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 根据市场活动Id插入备注信息
     * @param request   请求
     * @param response  响应
     */
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数信息
        String noteContent = request.getParameter("noteContent");
        String activityId = request.getParameter("activityId");
        //生成备注Id
        String id = UUIDUtil.getUUID();
        //获取时间
        String createTime = DateTimeUtil.getSysTime();
        //从Session域中获取当前登录用户
        String createdBy = ((User)request.getSession().getAttribute("user")).getName();
        //将修改状态赋值为0
        String editFlag = "0";
        //创建ActivityRemark对象进行数据封装
        ActivityRemark ar = new ActivityRemark();
        ar.setCreateBy(createdBy);
        ar.setActivityId(activityId);
        ar.setId(id);
        ar.setCreateTime(createTime);
        ar.setEditFlag(editFlag);
        ar.setNoteContent(noteContent);
        //调用dao层，传入ActivityRemark对象条件并返回状态信息
        boolean flag = activityService.saveRemark(ar);
        //将状态信息以及ActivityRemark对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",ar);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 根据市场活动Id删除备注信息
     * @param request   请求
     * @param response  响应
     */
    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        //调用dao层，返回状态信息
        boolean flag = activityService.deleteRemark(id);
        //将状态信息转换成json对象，传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 根据市场活动Id查询备注信息（多条）
     * @param request   请求
     * @param response  响应
     */
    private void getRemarkListById(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //从请求转发域中获取市场活动Id
        String activityId = request.getParameter("activityId");
        //调用dao层，根据Id获取所有备注信息，封装成List集合
        List<ActivityRemark> arList = activityService.getRemarkListById(activityId);
        //将数据转换为json数据，并将其传入前端
        PrintJson.printJsonObj(response,arList);
    }

    /**
     * 展示市场活动的详细信息（仅市场活动信息）
     * @param request   请求
     * @param response  响应
     * @throws ServletException
     * @throws IOException
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        //调用Dao层传入Id,返回Activity对象
        Activity activity = activityService.detail(id);
        //将Activity对象存入请求域中
        request.setAttribute("a",activity);
        //请求转发跳转到市场活动详细页
        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request,response);
    }

    /**
     * 根据市场活动信息Id更新市场活动信息
     * @param request   请求
     * @param response 响应
     */
    private void update(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        //利用工具获取当前系统时间
        String editTime = DateTimeUtil.getSysTime();
        //从Session域中取得当前登录Use信息
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        //将更新内容封装到Activity对象中
        Activity activity = new Activity();
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setId(id);
        activity.setName(name);
        activity.setOwner(owner);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setEditTime(editTime);
        activity.setEditBy(editBy);
        //调用Dao对象并返回更新状态
        boolean flag = activityService.update(activity);
        //将更新结果利用工具转换成json对象并传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 根据市场活动Id查询市场活动信息；查询所有用户信息；目的：获取修改市场活动信息模板页面中的数据
     * @param request 请求
     * @param response 响应
     */
    private void getUserListAndActivity(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数信息
        String id = request.getParameter("id");
        //调用Dao处理数据
        Map<String,Object> map = activityService.getUserListAndActivity(id);
        //将map对象转换成json对象并将其传入前端
        PrintJson.printJsonObj(response,map);
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取删除条件（市场活动Id）
        String[] ids = request.getParameterValues("id");
        //调用DAO执行删除操作并返回结果
        boolean flag = activityService.delete(ids);
        //将结果转换成json对象并传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 查询市场活动信息列表操作（结合条件查询和分页查询）
     * @param request 请求
     * @param response 响应
     */
    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        //将页码和总页数转化成int类型
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //获取分页查询时略过数据（SQL语句 limit中的第一个条件）
        int skipCount = (pageNo-1)*pageSize;
        //将所有条件封装成map集合
        Map<String, Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("pageSize",pageSize);
        map.put("skipCount",skipCount);
        //调用市场活动业务对象中的根据条件查询方法，传入map条件，并将总条数和市场活动信息列表数据返回到PaginationVo<Activity>对象
        PaginationVo<Activity> vo = activityService.pageList(map);
        //将PaginationVo<Activity>对象转换成json数据并返回至前端
        PrintJson.printJsonObj(response,vo);
    }

    /**
     * 添加市场活动信息Servlet
     * @param request   请求
     * @param response  响应
     */
    private void save(HttpServletRequest request, HttpServletResponse response) {
        //获取市场活动信息Service业务逻辑对象（反射机制）
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数信息
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        //利用工具生成Id
        String id = UUIDUtil.getUUID();
        //利用工具获取当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //从Session域中获取用户信息
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
        //用户信息处理Service业务逻辑对象（反射机制）
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceIml());
        //调用用户查询方法获取用户信息
        List<User> userList = userService.getUserList();
        //将用户信息转换成json对象并传入前端
        PrintJson.printJsonObj(response,userList);
    }

}
