package com.chuanqihou.crm.workbench.web.controller; /**
 * @auther 传奇后
 * @date 2021/9/27 15:19
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
import com.chuanqihou.crm.workbench.service.ContactsService;
import com.chuanqihou.crm.workbench.service.CustomerService;
import com.chuanqihou.crm.workbench.service.TransactionService;
import com.chuanqihou.crm.workbench.service.impl.ContactsServiceImpl;
import com.chuanqihou.crm.workbench.service.impl.CustomerServiceImpl;
import com.chuanqihou.crm.workbench.service.impl.TransactionServiceImpl;
import org.apache.ibatis.transaction.Transaction;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TransactionServlet extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/workbench/transaction/pageList.do".equals(path)){
            pageList(request,response);
        }else if ("/workbench/transaction/detail.do".equals(path)){
            detail(request,response);
        }else if ("/workbench/transaction/save.do".equals(path)){
            save(request,response);
        }else if ("/workbench/transaction/getContactsListByName.do".equals(path)){
            getContactsListByName(request,response);
        }else if ("/workbench/transaction/getCustomerName.do".equals(path)){
            getCustomerName(request,response);
        }else if ("/workbench/transaction/add.do".equals(path)){
            add(request,response);
        }else if ("/workbench/transaction/getHistoryByTranId.do".equals(path)){
            getHistoryByTranId(request,response);
        }else if ("/workbench/transaction/changeStage.do".equals(path)){
            changeStage(request,response);
        }else if ("/workbench/transaction/getCharts.do".equals(path)){
            getCharts(request,response);
        }else if ("/workbench/transaction/editShow.do".equals(path)){
            editShow(request,response);
        }else if ("/workbench/transaction/update.do".equals(path)){
            update(request,response);
        }else if ("/workbench/transaction/delete.do".equals(path)){
            delete(request,response);
        }else if ("/workbench/transaction/getRemarkListById.do".equals(path)){
            getRemarkListById(request,response);
        }
    }

    private void getRemarkListById(HttpServletRequest request, HttpServletResponse response) {
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String transactionId = request.getParameter("transactionId");
        List<TranRemark> tranRemarks = transactionService.getRemarkListById(transactionId);
        PrintJson.printJsonObj(response,tranRemarks);
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        boolean flag = true;
        String[] ids = request.getParameterValues("id");
        for (String id : ids) {
            if (!transactionService.delete(id)){
                flag = false;
            }
        }
        PrintJson.printJsonFlag(response,"success",flag);
    }

    private void update(HttpServletRequest request, HttpServletResponse response) throws IOException {
        //获取处理客户业务对象
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());

        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        String customerName = request.getParameter("customerName");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");

        Tran tran = new Tran();
        tran.setId(id);
        tran.setOwner(owner);
        tran.setMoney(money);
        tran.setName(name);
        tran.setExpectedDate(expectedDate);
        tran.setStage(stage);
        tran.setType(type);
        tran.setSource(source);
        tran.setActivityId(activityId);
        tran.setContactsId(contactsId);
        tran.setEditTime(editTime);
        tran.setEditBy(editBy);
        tran.setDescription(description);
        tran.setContactSummary(contactSummary);
        tran.setNextContactTime(nextContactTime);

        boolean flag = transactionService.update(tran,customerName);

        if (flag){
            response.sendRedirect(request.getContextPath()+"/workbench/transaction/editShow.do?transactionId="+tran.getId()+"");
        }

    }

    private void editShow(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String transactionId = request.getParameter("transactionId");
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceIml());
        Tran tran = transactionService.editShow(transactionId);

        String stage = tran.getStage();
        Map<String,String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pmap");
        String possibility = pMap.get(stage);
        tran.setPossibility(possibility);

        List<User> userList = userService.getUserList();
        request.setAttribute("t",tran);
        request.setAttribute("userList",userList);
        request.getRequestDispatcher("/workbench/transaction/edit.jsp").forward(request,response);
    }

    private void getCharts(HttpServletRequest request, HttpServletResponse response) {
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        Map<String, Object> map = transactionService.getCharts();
        PrintJson.printJsonObj(response,map);
    }

    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());

        String tranId = request.getParameter("id");
        String stage = request.getParameter("stage");
        String money = request.getParameter("money");
        String expectedDate = request.getParameter("expectedDate");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();

        Tran t = new Tran();
        t.setId(tranId);
        t.setMoney(money);
        t.setStage(stage);
        t.setEditBy(editBy);
        t.setEditTime(editTime);
        t.setExpectedDate(expectedDate);

        Map<String,String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pmap");
        t.setPossibility(pMap.get(stage));

        boolean flag =transactionService.changeStage(t);
        Map<String,Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("t",t);
        PrintJson.printJsonObj(response,map);
    }

    private void getHistoryByTranId(HttpServletRequest request, HttpServletResponse response) {
        String tranId = request.getParameter("tranId");
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        List<TranHistory> tranHistories = transactionService.getHistoryByTranId(tranId);
        Map<String,String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pmap");
        for (TranHistory th : tranHistories) {
            String stage = th.getStage();
            String possibility = pMap.get(stage);
            th.setPossibility(possibility);
        }

        PrintJson.printJsonObj(response,tranHistories);
    }

    private void add(HttpServletRequest request, HttpServletResponse response) throws IOException {

        //获取处理客户业务对象
       TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());

       String id = UUIDUtil.getUUID();
       String owner = request.getParameter("owner");
       String money = request.getParameter("money");
       String name = request.getParameter("name");
       String expectedDate = request.getParameter("expectedDate");
       String customerName = request.getParameter("customerName");
       String stage = request.getParameter("stage");
       String type = request.getParameter("type");
       String source = request.getParameter("source");
       String activityId = request.getParameter("activityId");
       String contactsId = request.getParameter("contactsId");
       String createBy = ((User)request.getSession().getAttribute("user")).getName();
       String createTime = DateTimeUtil.getSysTime();
       String description = request.getParameter("description");
       String contactSummary = request.getParameter("contactSummary");
       String nextContactTime = request.getParameter("nextContactTime");

       Tran tran = new Tran();
       tran.setId(id);
       tran.setOwner(owner);
       tran.setMoney(money);
       tran.setName(name);
       tran.setExpectedDate(expectedDate);
       tran.setStage(stage);
       tran.setType(type);
       tran.setSource(source);
       tran.setActivityId(activityId);
       tran.setContactsId(contactsId);
       tran.setCreateTime(createTime);
       tran.setCreateBy(createBy);
       tran.setDescription(description);
       tran.setContactSummary(contactSummary);
       tran.setNextContactTime(nextContactTime);

       boolean flag = transactionService.add(tran,customerName);

       if (flag){
           response.sendRedirect(request.getContextPath()+"/workbench/transaction/index.jsp");
       }
    }

    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        String name = request.getParameter("name");
        List<Customer> list = customerService.getCustomerName(name);
        List<String> names = new ArrayList<>();
        for (Customer c : list) {
            names.add(c.getName());
        }
        PrintJson.printJsonObj(response,names);

    }

    private void getContactsListByName(HttpServletRequest request, HttpServletResponse response) {
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String fullName = request.getParameter("fullName");
        List<Contacts> contacts = contactsService.getContactsListByName(fullName);
        PrintJson.printJsonObj(response,contacts);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceIml());
        List<User> userList = userService.getUserList();
        String customerName= request.getParameter("customerName");
        String contactsName = request.getParameter("contactsName");
        request.setAttribute("customerName",customerName);
        request.setAttribute("contactsName",contactsName);
        request.setAttribute("userList",userList);
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        //获取处理客户业务对象
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        Tran t = transactionService.detail(id);

        String stage = t.getStage();
        Map<String,String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pmap");
        String possibility = pMap.get(stage);
        t.setPossibility(possibility);

        request.setAttribute("t",t);
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request,response);

    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        //获取参数
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String owner = request.getParameter("owner");
        String source = request.getParameter("source");
        String customerName = request.getParameter("customerName");
        String contactsName = request.getParameter("contactsName");
        String type = request.getParameter("type");
        String name = request.getParameter("name");
        String stage = request.getParameter("stage");

        //将页码和总页数转化成int类型
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //获取分页查询时略过数据（SQL语句 limit中的第一个条件）
        int skipCount = (pageNo-1)*pageSize;
        //将所有条件封装成map集合
        Map<String, Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("source",source);
        map.put("stage",stage);
        map.put("type",type);
        map.put("customerName",customerName);
        map.put("contactsName",contactsName);
        map.put("pageSize",pageSize);
        map.put("skipCount",skipCount);
        //调用客户业务对象中的根据条件查询方法，传入map条件，并将总条数和客户信息列表数据返回到PaginationVo<Customer>对象
        PaginationVo<Tran> vo = transactionService.pageList(map);
        //将PaginationVo<Customer>对象转换成json数据并返回至前端
        PrintJson.printJsonObj(response,vo);
    }
}
