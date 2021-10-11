package com.chuanqihou.crm.workbench.web.controller; /**
 * @auther 传奇后
 * @date 2021/9/18 11:57
 * @veersion 1.0
 */

import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.settings.service.UserService;
import com.chuanqihou.crm.settings.service.impl.UserServiceIml;
import com.chuanqihou.crm.utils.DateTimeUtil;
import com.chuanqihou.crm.utils.PrintJson;
import com.chuanqihou.crm.utils.ServiceFactory;
import com.chuanqihou.crm.utils.UUIDUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.*;
import com.chuanqihou.crm.workbench.service.ActivityService;
import com.chuanqihou.crm.workbench.service.ClueService;
import com.chuanqihou.crm.workbench.service.impl.ActivityServiceImpl;
import com.chuanqihou.crm.workbench.service.impl.ClueServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueServlet extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取访问来源
        String path = request.getServletPath();
        //查询所有用户信息
        if ("/workbench/clue/getUserList.do".equals(path)){
            getUserList(request,response);
        //根据条件获取线索信息列表并分页
        }else if ("/workbench/clue/pageList.do".equals(path)){
            pageList(request,response);
        //根据参数保存（插入）一条线索信息
        } else if ("/workbench/clue/save.do".equals(path)){
            save(request,response);
        //根据线索ID更新线索信息
        }else if ("/workbench/clue/update.do".equals(path)){
            update(request,response);
        //根据线索Id删除线索信息
        }else if ("/workbench/clue/delete.do".equals(path)){
            delete(request,response);
        //查询所有用户信息、一条线索信息（根据线索Id）
        }else if("/workbench/clue/getUserListAndClue.do".equals(path)){
            getUserListAndClue(request,response);
        //根据线索Id查询线索信息并将其添加至共享请求作用域中，通过请求转发跳转到线索详细页
        }else if("/workbench/clue/detail.do".equals(path)){
            detail(request,response);
        //根据线索Id查询该线索中关联的市场活动
        }else if ("/workbench/clue/getActivityListByClueId.do".equals(path)){
            getActivityByClueID(request,response);
        //取消线索与某一条市场活动信息的关联
        }else if ("/workbench/clue/unbund.do".equals(path)){
            unbund(request,response);
        //获取市场活动信息（除线索已关联的）
        }else if ("/workbench/clue/getActivityListByNameByClueId.do".equals(path)){
            getActivityListByNameByClueID(request,response);
        //将市场活动与线索进行关联
        }else if ("/workbench/clue/bund.do".equals(path)){
            bund(request,response);
        //获取线索备注信息
        }else if("/workbench/clue/getRemarkListById.do".equals(path)){
            getRemarkListById(request,response);
        //新建线索备注信息
        }else if ("/workbench/clue/saveRemark.do".equals(path)){
            saveRemark(request,response);
        //根据市场活动名称模糊查询市场活动信息
        } else if("/workbench/clue/getActivityListByName.do".equals(path)){
            getActivityListByName(request,response);
        //将线索转换成客户，联系人等
        }else if ("/workbench/clue/convert.do".equals(path)){
             convert(request,response);
         //删除线索备注信息
        }else if ("/workbench/clue/deleteRemark.do".equals(path)){
            deleteRemark(request,response);
        }else if ("/workbench/clue/updateRemark.do".equals(path)){
            updateRemark(request,response);
        }
    }

    /**
     * 根据线索备注Id更新备注信息
     * @param request   请求
     * @param response  响应
     */
    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");

        String editTime = DateTimeUtil.getSysTime();
        String editName = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "1";

        ClueRemark clueRemark = new ClueRemark();
        clueRemark.setId(id);
        clueRemark.setNoteContent(noteContent);
        clueRemark.setEditTime(editTime);
        clueRemark.setEditBy(editName);
        clueRemark.setEditFlag(editFlag);
        //调用dao层，传入ActivityRemark对象条件并返回状态信息
        boolean flag = clueService.updateRemark(clueRemark);
        //将状态信息以及ActivityRemark对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("cr",clueRemark);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 根据线索备注Id删除线索备注信息
     * @param request   请求
     * @param response  响应
     */
    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        //调用业务层方法删除，返回删除状态信息
        boolean flag = clueService.deleteRemark(id);
        //将状态信息转换成json传至前端
        PrintJson.printJsonFlag(response,"success",flag);
    }


    /**
     *为转换处理参数信息
     * @param request   请求
     * @param response  响应
     * @throws IOException
     */
    private void convert(HttpServletRequest request, HttpServletResponse response) throws IOException {
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数（线索Id）
        String clueId = request.getParameter("clueId");
        //获取请求方式
        String method = request.getMethod();
        //获取当前登录用户
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        //定义交易类
        Tran tran = null;
        //判断请求方式
        if ("POST".equals(method)){
            //需要创建交易信息
            tran = new Tran();
            //获取表单参数
            String money = request.getParameter("money");
            String name = request.getParameter("name");
            String expectDate = request.getParameter("expectedDate");
            String stage = request.getParameter("stage");
            String activityId = request.getParameter("activityId");
            //生成交易Id
            String id = UUIDUtil.getUUID();
            //获取当前系统时间
            String createTime = DateTimeUtil.getSysTime();
            //将数据封装在Tran对象中
            tran.setId(id);
            tran.setActivityId(activityId);
            tran.setCreateTime(createTime);
            tran.setCreateBy(createBy);
            tran.setStage(stage);
            tran.setMoney(money);
            tran.setName(name);
            tran.setExpectedDate(expectDate);
        }
        //调用处理业务方法，将线索Id，交易对象，创建人传入，返回转换状态
        boolean flag = clueService.convert(clueId,tran,createBy);
        if (flag){
            //请求转发到线索列表
            response.sendRedirect(request.getContextPath()+"/workbench/clue/index.jsp");
        }

/*
        String flag = request.getParameter("flag");
       if ("a".equals(flag)){
            System.out.println("需要");
        }else {
            System.out.println("不需要");
        }*/
    }

    /**
     * 新建线索备注信息
     * @param request   请求
     * @param response  响应
     */
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数信息
        String noteContent = request.getParameter("noteContent");
        String clueId = request.getParameter("clueId");
        //生成备注Id
        String id = UUIDUtil.getUUID();
        //获取时间
        String createTime = DateTimeUtil.getSysTime();
        //从Session域中获取当前登录用户
        String createdBy = ((User)request.getSession().getAttribute("user")).getName();
        //将修改状态赋值为0
        String editFlag = "0";
        //创建ClueRemark对象进行数据封装
        ClueRemark cr = new ClueRemark();
        cr.setCreateBy(createdBy);
        cr.setClueId(clueId);
        cr.setId(id);
        cr.setCreateTime(createTime);
        cr.setEditFlag(editFlag);
        cr.setNoteContent(noteContent);
        //调用dao层，传入ClueRemark对象条件并返回状态信息
        boolean flag = clueService.saveRemark(cr);
        //将状态信息以及ClueRemark对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("cr",cr);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 根据线索Id查询备注信息
     * @param request   请求
     * @param response  响应
     */
    private void getRemarkListById(HttpServletRequest request, HttpServletResponse response) {
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数
        String clueId = request.getParameter("clueId");
        //调用业务层方法执行业务，返回线索备注集合
        List<ClueRemark> clueRemarkList = clueService.getRemarkListById(clueId);
        //将数据转换成json对象传入前端
        PrintJson.printJsonObj(response,clueRemarkList);
    }


    /**
     * 获取参数，调用处理Clue业务方法。根据市场活动名称模糊查询市场活动信息
     * @param request   请求
     * @param response  响应
     */
    private void getActivityListByName(HttpServletRequest request, HttpServletResponse response) {
        //创建处理市场活动业务对象
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数
        String aname = request.getParameter("aname");
        //调用业务方法，返回市场活动信息
        List<Activity> activities = activityService.getActivityListByName(aname);
        //将数据转换成json传至前端
        PrintJson.printJsonObj(response,activities);
    }

    /**
     * 根据线索Id和市场活动Id将市场活动与线索进行关联
     * @param request   请求
     * @param response  响应
     */
    private void bund(HttpServletRequest request, HttpServletResponse response) {
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数
        String clueId = request.getParameter("cid");
        String[] aids = request.getParameterValues("aid");
        //调用业务方法返回关联状态
        boolean flag = clueService.bund(clueId,aids);
        //将状态信息转换成json传至前端
        PrintJson.printJsonFlag(response,"success",flag);

    }

    /**
     * 获取市场活动信息（除线索已关联的）
     * @param request   请求
     * @param response  响应
     */
    private void getActivityListByNameByClueID(HttpServletRequest request, HttpServletResponse response) {
        //获取处理市场活动业务对象
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数
        String aname = request.getParameter("aname");
        String clueId = request.getParameter("clueId");
        //将参数封装在map集合中
        Map<String,String> map = new HashMap<>();
        map.put("aname",aname);
        map.put("clueId",clueId);
        //调用业务方法返回市场活动信息
        List<Activity> activity = activityService.getActivityByNameByClueID(map);
        //将数据转换成json传至前端
        PrintJson.printJsonObj(response,activity);

    }

    /**
     * 取消线索与某一条市场活动信息的关联
     * @param request   请求
     * @param response  响应
     */
    private void unbund(HttpServletRequest request, HttpServletResponse response) {
        //获取参数
        String id = request.getParameter("id");
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //返回状态信息
        boolean flag = clueService.unbund(id);
        //将状态信息转换成json传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 根据线索Id查询该线索中关联的市场活动
     * @param request   请求
     * @param response  响应
     */
    private void getActivityByClueID(HttpServletRequest request, HttpServletResponse response) {
        //获取处理市场活动业务对象
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        //获取参数（线索ID）
        String id = request.getParameter("clueId");
        //调用业务方法返回List<Activity>
        List<Activity> activities = activityService.getActivityByClueID(id);
        //将数据转换成json传至前端
        PrintJson.printJsonObj(response,activities);
    }

    /**
     * 根据线索Id查询线索信息并将其添加至共享请求作用域中，通过请求转发跳转到线索详细页
     * @param request   请求
     * @param response  响应
     * @throws ServletException
     * @throws IOException
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //创建处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数（线索Id）
        String id = request.getParameter("id");
        //调用业务层返回Clue对象
        Clue clue = clueService.detail(id);
        //将Clue对象添加至请求转发共享
        request.setAttribute("c",clue);
        //通过请求转发的方式跳转到线索详细页
        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request,response);

    }

    /**
     * 根据线索Id删除线索信息
     * @param request   请求
     * @param response  响应
     */
    private void delete(HttpServletRequest request, HttpServletResponse response) {
        //获取处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取需要删除的Id
        String[] id = request.getParameterValues("id");
        //调用业务删除方法传入Id,返回删除状态
        boolean flag = clueService.delete(id);
        //将状态信息转换成json对象传到前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 根据线索Id更新线索信息
     * @param request   请求
     * @param response  响应
     */
    private void update(HttpServletRequest request, HttpServletResponse response) {
        //获取处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        //获取当前登录用户
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        //获取当前系统时间
        String editTime = DateTimeUtil.getSysTime();
        // 将参数封装成Clue对象
        Clue clue = new Clue();
        clue.setId(id);
        clue.setFullname(fullname);
        clue.setAppellation(appellation);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);
        clue.setEditBy(editBy);
        clue.setEditTime(editTime);
        //调用业务对象中的更新方法，传入参数，返回更新状态
        boolean flag = clueService.update(clue);
        //将结果转换成Json对象
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 查询所有用户信息、一条线索信息（根据线索Id）
     * @param request   请求
     * @param response  响应
     */
    private void getUserListAndClue(HttpServletRequest request, HttpServletResponse response) {
        //获取处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数信息
        String clueId = request.getParameter("id");
        //调用业务对象中的方法取得数据（List<User>和Clue）封装成map
        Map<String,Object> map = clueService.getUserListAndClue(clueId);
        //将数据（List<User>和Clue）map转换成json数据并传入前端
        PrintJson.printJsonObj(response,map);

    }

    /**
     * 更具条件查询所有的线索信息（使用动态SQL）
     * @param request   请求
     * @param response  响应
     */
    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        //获取处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String phone = request.getParameter("phone");
        String mphone = request.getParameter("mphone");
        String source = request.getParameter("source");
        String state = request.getParameter("state");
        String company = request.getParameter("company");
        //将页码和总页数转化成int类型
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //获取分页查询时略过数据（SQL语句 limit中的第一个条件）
        int skipCount = (pageNo-1)*pageSize;
        //将所有条件封装成map集合
        Map<String, Object> map = new HashMap<>();
        map.put("fullname",name);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("mphone",mphone);
        map.put("company",company);
        map.put("source",source);
        map.put("state",state);
        map.put("pageSize",pageSize);
        map.put("skipCount",skipCount);
        //调用pageList方法传入map集合，返回PaginationVo<Clue>
        PaginationVo<Clue> vo = clueService.pageList(map);
        //将Vo对象转换成Json对象并传入前端
        PrintJson.printJsonObj(response,vo);
    }



    /**
     * 插入一条线索数据
     * @param request   请求
     * @param response  响应
     */
    private void save(HttpServletRequest request, HttpServletResponse response) {
        //获取处理线索业务对象
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        //获取参数信息
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        //获取当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //获取当前登录用户
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        //生成id
        String id = UUIDUtil.getUUID();
        //创建Clue对象封装参数
        Clue clue = new Clue();
        clue.setId(id);
        clue.setOwner(owner);
        clue.setFullname(fullname);
        clue.setAppellation(appellation);
        clue.setCompany(company);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);
        clue.setCreateTime(createTime);
        clue.setCreateBy(createBy);
        //调用业务层sava方法，并传入参数，返回插入状态
        boolean flag = clueService.save(clue);
        //将状态信息转换成json对象并传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 查询所有用户信息
     * @param request   请求
     * @param response  响应
     */
    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        //获取处理用户业务对象
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceIml());
        //调用业务层方法，返回List<User>
        List<User> userList = userService.getUserList();
        //将用户信息转换为json对象并传至前端
        PrintJson.printJsonObj(response,userList);
    }
}
