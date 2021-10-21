package com.chuanqihou.crm.workbench.web.controller; /**
 * @auther 传奇后
 * @date 2021/9/27 14:03
 * @veersion 1.0
 */

import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.utils.DateTimeUtil;
import com.chuanqihou.crm.utils.PrintJson;
import com.chuanqihou.crm.utils.ServiceFactory;
import com.chuanqihou.crm.utils.UUIDUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.*;
import com.chuanqihou.crm.workbench.service.ContactsService;
import com.chuanqihou.crm.workbench.service.CustomerService;
import com.chuanqihou.crm.workbench.service.impl.ContactsServiceImpl;
import com.chuanqihou.crm.workbench.service.impl.CustomerServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ContactsServlet extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取来访网站信息
        String path = request.getServletPath();

            //根据条件刷新联系人列表并分页
        if ("/workbench/contacts/pageList.do".equals(path)){
            pageList(request,response);
            //根据联系人姓名模糊查询联系人详细信息
        }else if ("/workbench/contacts/getContactsName.do".equals(path)){
            getContactsName(request,response);
            //插入一条联系人信息
        }else if ("/workbench/contacts/save.do".equals(path)){
            save(request,response);
            //获取所有用户和联系人信息
        }else if ("/workbench/contacts/getUserListAndContacts.do".equals(path)){
            getUserListAndContacts(request,response);
            //更新联系人信息
        }else if ("/workbench/contacts/update.do".equals(path)){
            update(request,response);
            //删除联系人信息
        }else if ("/workbench/contacts/delete.do".equals(path)){
            delete(request,response);
            //进入联系人详细信息页面
        }else if ("/workbench/contacts/detail.do".equals(path)){
            detail(request,response);
            //根据联系人Id获取交易信息
        }else if ("/workbench/contacts/getTranByContactsId.do".equals(path)){
            getTranByContactsId(request,response);
            //根据联系人展示相关市场活动信息
        }else if ("/workbench/contacts/showActivity.do".equals(path)){
            showActivity(request,response);
            //根据联系人Id和姓名获取市场活动信息
        }else if ("/workbench/contacts/getActivityListByNameByContactsId.do".equals(path)){
            getActivityListByNameByContactsId(request,response);
            //解除联系人与市场活动的关系
        }else if ("/workbench/contacts/unbund.do".equals(path)){
            ubund(request,response);
            //关联联系人与市场活动
        }else if ("/workbench/contacts/bund.do".equals(path)){
            bund(request,response);
            //保存联系人备注信息
        }else if ("/workbench/contacts/saveRemark.do".equals(path)){
            saveRemark(request,response);
            //根据联系人Id获取其所有的备注信息
        }else if ("/workbench/contacts/getRemarkListById.do".equals(path)){
            getRemarkListById(request,response);
            //删除备注信息
        }else if ("/workbench/contacts/deleteRemark.do".equals(path)){
            deleteRemark(request,response);
            //更新联系人备注信息
        }else if ("/workbench/contacts/updateRemark.do".equals(path)){
            updateRemark(request,response);
        }
    }

    /**
     * 更新联系人备注信息
     * @param request   请求
     * @param response  响应
     */
    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");

        String editTime = DateTimeUtil.getSysTime();
        String editName = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "1";

        ContactsRemark contactsRemark = new ContactsRemark();
        contactsRemark.setId(id);
        contactsRemark.setNoteContent(noteContent);
        contactsRemark.setEditTime(editTime);
        contactsRemark.setEditBy(editName);
        contactsRemark.setEditFlag(editFlag);
        //调用dao层，传入对象条件并返回状态信息
        boolean flag = contactsService.updateRemark(contactsRemark);
        //将状态信息以及对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",contactsRemark);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 删除联系人备注信息
     * @param request   请求
     * @param response  响应
     */
    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        //调用处理删除联系人备注业务返回状态信息
        boolean flag = contactsService.deleteRemark(id);
        //将状态信息转换成json数据并传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 根据联系人Id获取其所有的备注信息
     * @param request   请求
     * @param response  响应
     */
    private void getRemarkListById(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //从请求转发域中获取市场活动Id
        String contactsId = request.getParameter("contactsId");
        //调用dao层，根据Id获取所有备注信息，封装成List集合
        List<ContactsRemark> arList = contactsService.getRemarkListById(contactsId);
        //将数据转换为json数据，并将其传入前端
        PrintJson.printJsonObj(response,arList);
    }

    /**
     * 插入一天联系人备注信息
     * @param request   请求
     * @param response  响应
     */
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数信息
        String noteContent = request.getParameter("noteContent");
        String customerId = request.getParameter("contactsId");
        //生成备注Id
        String id = UUIDUtil.getUUID();
        //获取时间
        String createTime = DateTimeUtil.getSysTime();
        //从Session域中获取当前登录用户
        String createdBy = ((User)request.getSession().getAttribute("user")).getName();
        //将修改状态赋值为0
        String editFlag = "0";
        //创建ContactsRemark对象进行数据封装
        ContactsRemark ar = new ContactsRemark();
        ar.setCreateBy(createdBy);
        ar.setContactsId(customerId);
        ar.setId(id);
        ar.setCreateTime(createTime);
        ar.setEditFlag(editFlag);
        ar.setNoteContent(noteContent);
        //调用dao层，传入对象条件并返回状态信息
        boolean flag = contactsService.saveRemark(ar);
        //将状态信息以及对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",ar);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 联系人关联市场活动
     * @param request   请求
     * @param response  响应
     */
    private void bund(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取联系人Id
        String contactsId = request.getParameter("cid");
        //获取市场活动Id
        String[] activityIds = request.getParameterValues("aid");
        //调用业务方法返回关联状态
        boolean flag = contactsService.bund(contactsId,activityIds);
        //将状态信息转换成json传至前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 解除联系人与市场活动的关联
     * @param request   请求
     * @param response  响应
     */
    private void ubund(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数：市场活动Id
        String activityId = request.getParameter("id");
        //调用解除业务方法返回解除状态
        boolean flag = contactsService.ubund(activityId);
        //将状态信息转换成json并传入前端页面
        PrintJson.printJsonFlag(response,"success",flag);
    }


    private void getActivityListByNameByContactsId(HttpServletRequest request, HttpServletResponse response) {
        String activityName = request.getParameter("aname");
        String contactsId = request.getParameter("contactsId");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //将参数封装在map集合中
        Map<String,String> map = new HashMap<>();
        map.put("aname",activityName);
        map.put("contactsId",contactsId);
        List<Activity> activities = contactsService.getActivityListByNameByContactsId(map);
        PrintJson.printJsonObj(response,activities);
    }

    /**
     * 展示联系人所有关联的市场活动信息
     * @param request   请求
     * @param response  响应
     */
    private void showActivity(HttpServletRequest request, HttpServletResponse response) {
        //获取参数：联系人Id
        String contactsId = request.getParameter("contactsId");
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //将参数封装在map集合中
        List<Activity> activities = contactsService.showActivity(contactsId);
        //将市场活动信息转换成json传至前端页面
        PrintJson.printJsonObj(response,activities);

    }

    /**
     * 根据联系人Id获取其所有关联的交易信息
     * @param request   请求
     * @param response  响应
     */
    private void getTranByContactsId(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数：联系人Id
        String contactsId = request.getParameter("id");
        //调用业务方法，返回交易信息
        List<Tran> trans = contactsService.getTranByContactsId(contactsId);
        //从全局作用域中获取交易阶段和对应的成交可能性
        Map<String,String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pmap");
        //将交易信息遍历
        for (Tran t : trans) {
            //取出交易阶段
            String stage = t.getStage();
            //根据交易阶段查询对应的可能性
            String possibility = pMap.get(stage);
            //将可能信息封装
            t.setPossibility(possibility);
        }
        //将交易信息转换成json传至前端页面
        PrintJson.printJsonObj(response,trans);
    }

    /**
     * 跳转到联系人详细页面
     * @param request   请求
     * @param response  响应
     * @throws ServletException
     * @throws IOException
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        //调用Dao层传入Id
        Contacts contacts = contactsService.detail(id);
        //将对象存入请求域中
        request.setAttribute("c",contacts);
        //请求转发跳转到联系人详细页
        request.getRequestDispatcher("/workbench/contacts/detail.jsp").forward(request,response);
    }

    /**
     * 删除联系人信息
     * @param request   请求
     * @param response  响应
     */
    private void delete(HttpServletRequest request, HttpServletResponse response) {
        //处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数：需要删除的联系人Id
        String[] ids = request.getParameterValues("id");
        //调用删除业务方法，返回删除状态信息
        boolean flag = contactsService.delete(ids);
        //将状态信息转换成json并传入前端页面
        PrintJson.printJsonFlag(response,"success",flag);

    }

    /**
     * 更新联系人信息
     * @param request   请求
     * @param response  响应
     */
    private void update(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String owner = request.getParameter("owner");
        String source = request.getParameter("source");
        String customerName = request.getParameter("customerName");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String email = request.getParameter("email");
        String mphone = request.getParameter("mphone");
        String job = request.getParameter("job");
        String birth = request.getParameter("birth");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        //将参数封装
        Contacts c = new Contacts();
        c.setId(id);
        c.setEditTime(editTime);
        c.setEditBy(editBy);
        c.setOwner(owner);
        c.setSource(source);
        c.setFullname(fullname);
        c.setAppellation(appellation);
        c.setEmail(email);
        c.setMphone(mphone);
        c.setJob(job);
        c.setBirth(birth);
        c.setDescription(description);
        c.setContactSummary(contactSummary);
        c.setNextContactTime(nextContactTime);
        c.setAddress(address);
        c.setCustomerId(customerName);
        //调用更新联系人业务方法并返回状态信息
        boolean flag = contactsService.update(c);
        //将状态信息转换成json并传入前端页面
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 获取所有用户信息和联系人信息
     * @param request   请求
     * @param response  响应
     */
    private void getUserListAndContacts(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String contactsId = request.getParameter("id");
        //调用业务方法返回数据
        Map<String,Object> map = contactsService.getUserListAndCustomer(contactsId);
        //将数据转换成json并传入前端页面
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 插入一条联系人信息
     * @param request   请求
     * @param response  响应
     */
    private void save(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String owner = request.getParameter("owner");
        String source = request.getParameter("source");
        String customerId = request.getParameter("customerId");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String email = request.getParameter("email");
        String mphone = request.getParameter("mphone");
        String job = request.getParameter("job");
        String birth = request.getParameter("birth");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        //将参数封装
        Contacts c = new Contacts();
        c.setId(id);
        c.setCreateTime(createTime);
        c.setCreateBy(createBy);
        c.setOwner(owner);
        c.setSource(source);
        c.setCustomerId(customerId);
        c.setFullname(fullname);
        c.setAppellation(appellation);
        c.setEmail(email);
        c.setMphone(mphone);
        c.setJob(job);
        c.setBirth(birth);
        c.setDescription(description);
        c.setContactSummary(contactSummary);
        c.setNextContactTime(nextContactTime);
        c.setAddress(address);
        //调用插入业务方法
        boolean flag = contactsService.save(c);
        //将状态信息转换成json并传入前端页面
        PrintJson.printJsonFlag(response,"success",flag);

    }

    /**
     * 根据联系人姓名模糊查询联系人信息
     * @param request   请求
     * @param response  响应
     */
    private void getContactsName(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String name = request.getParameter("name");
        //调用业务方法
        List<String> contactsNames = contactsService.getContactsName(name);
        //将数据转换成json并传入前端页面
        PrintJson.printJsonObj(response,contactsNames);
    }

    /**
     *  根据条件刷新联系人列表并分页
     * @param request 请求
     * @param response 响应
     */
    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        //获取处理联系人业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String owner = request.getParameter("owner");
        String source = request.getParameter("source");
        String customerName = request.getParameter("customerName");
        String fullname = request.getParameter("fullname");
        String birth = request.getParameter("birth");
        //将页码和总页数转化成int类型
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //获取分页查询时略过数据（SQL语句 limit中的第一个条件）
        int skipCount = (pageNo-1)*pageSize;
        //将所有条件封装成map集合
        Map<String, Object> map = new HashMap<>();
        map.put("fullname",fullname);
        map.put("owner",owner);
        map.put("source",source);
        map.put("birth",birth);
        map.put("pageSize",pageSize);
        map.put("skipCount",skipCount);
        map.put("customerName",customerName);
        //调用联系人业务对象中的根据条件查询方法，传入map条件，并将总条数和客户信息列表数据返回到PaginationVo<Contacts>对象
        PaginationVo<Customer> vo = contactsService.pageList(map);
        //将PaginationVo<Contacts>对象转换成json数据并返回至前端
        PrintJson.printJsonObj(response,vo);
    }
}
