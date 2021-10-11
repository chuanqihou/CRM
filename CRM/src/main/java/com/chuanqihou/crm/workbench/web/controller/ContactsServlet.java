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
        if ("/workbench/contacts/pageList.do".equals(path)){
            pageList(request,response);
        }else if ("/workbench/contacts/getContactsName.do".equals(path)){
            getContactsName(request,response);
        }else if ("/workbench/contacts/save.do".equals(path)){
            save(request,response);
        }else if ("/workbench/contacts/getUserListAndContacts.do".equals(path)){
            getUserListAndContacts(request,response);
        }else if ("/workbench/contacts/update.do".equals(path)){
            update(request,response);
        }else if ("/workbench/contacts/delete.do".equals(path)){
            delete(request,response);
        }else if ("/workbench/contacts/detail.do".equals(path)){
            detail(request,response);
        }else if ("/workbench/contacts/getTranByContactsId.do".equals(path)){
            getTranByContactsId(request,response);
        }else if ("/workbench/contacts/showActivity.do".equals(path)){
            showActivity(request,response);
        }else if ("/workbench/contacts/getActivityListByNameByContactsId.do".equals(path)){
            getActivityListByNameByContactsId(request,response);
        }else if ("/workbench/contacts/unbund.do".equals(path)){
            ubund(request,response);
        }else if ("/workbench/contacts/bund.do".equals(path)){
            bund(request,response);
        }else if ("/workbench/contacts/saveRemark.do".equals(path)){
            saveRemark(request,response);
        }else if ("/workbench/contacts/getRemarkListById.do".equals(path)){
            getRemarkListById(request,response);
        }else if ("/workbench/contacts/deleteRemark.do".equals(path)){
            deleteRemark(request,response);
        }else if ("/workbench/contacts/updateRemark.do".equals(path)){
            updateRemark(request,response);
        }
    }

    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
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

    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        boolean flag = contactsService.deleteRemark(id);
        PrintJson.printJsonFlag(response,"success",flag);
    }

    private void getRemarkListById(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //从请求转发域中获取市场活动Id
        String contactsId = request.getParameter("contactsId");
        //调用dao层，根据Id获取所有备注信息，封装成List集合
        List<ContactsRemark> arList = contactsService.getRemarkListById(contactsId);
        //将数据转换为json数据，并将其传入前端
        PrintJson.printJsonObj(response,arList);
    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
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
        //创建ActivityRemark对象进行数据封装
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

    private void bund(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String contactsId = request.getParameter("cid");
        String[] activityIds = request.getParameterValues("aid");
        //调用业务方法返回关联状态
        boolean flag = contactsService.bund(contactsId,activityIds);
        //将状态信息转换成json传至前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    private void ubund(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String activityId = request.getParameter("id");
        boolean flag = contactsService.ubund(activityId);
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

    private void showActivity(HttpServletRequest request, HttpServletResponse response) {
        String contactsId = request.getParameter("contactsId");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //将参数封装在map集合中
        List<Activity> activities = contactsService.showActivity(contactsId);
        PrintJson.printJsonObj(response,activities);

    }

    private void getTranByContactsId(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String contactsId = request.getParameter("id");
        List<Tran> trans = contactsService.getTranByContactsId(contactsId);
        Map<String,String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pmap");
        for (Tran t : trans) {
            String stage = t.getStage();
            String possibility = pMap.get(stage);
            t.setPossibility(possibility);
        }
        PrintJson.printJsonObj(response,trans);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取处理客户业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        //调用Dao层传入Id
        Contacts contacts = contactsService.detail(id);
        //将对象存入请求域中
        request.setAttribute("c",contacts);
        //请求转发跳转到客户详细页
        request.getRequestDispatcher("/workbench/contacts/detail.jsp").forward(request,response);
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String[] ids = request.getParameterValues("id");
        boolean flag = contactsService.delete(ids);
        PrintJson.printJsonFlag(response,"success",flag);

    }

    private void update(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
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
        boolean flag = contactsService.update(c);
        PrintJson.printJsonFlag(response,"success",flag);
    }

    private void getUserListAndContacts(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String contactsId = request.getParameter("id");
        Map<String,Object> map = contactsService.getUserListAndCustomer(contactsId);
        PrintJson.printJsonObj(response,map);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
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
        boolean flag = contactsService.save(c);
        PrintJson.printJsonFlag(response,"success",flag);

    }

    private void getContactsName(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String name = request.getParameter("name");
        List<String> contactsNames = contactsService.getContactsName(name);
        PrintJson.printJsonObj(response,contactsNames);
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
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
        //调用客户业务对象中的根据条件查询方法，传入map条件，并将总条数和客户信息列表数据返回到PaginationVo<Customer>对象
        PaginationVo<Customer> vo = contactsService.pageList(map);
        //将PaginationVo<Customer>对象转换成json数据并返回至前端
        PrintJson.printJsonObj(response,vo);
    }
}
