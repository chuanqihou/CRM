package com.chuanqihou.crm.workbench.web.controller; /**
 * @auther 传奇后
 * @date 2021/9/25 16:54
 * @veersion 1.0
 */

import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.utils.DateTimeUtil;
import com.chuanqihou.crm.utils.PrintJson;
import com.chuanqihou.crm.utils.ServiceFactory;
import com.chuanqihou.crm.utils.UUIDUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.*;
import com.chuanqihou.crm.workbench.service.ActivityService;
import com.chuanqihou.crm.workbench.service.ClueService;
import com.chuanqihou.crm.workbench.service.ContactsService;
import com.chuanqihou.crm.workbench.service.CustomerService;
import com.chuanqihou.crm.workbench.service.impl.ActivityServiceImpl;
import com.chuanqihou.crm.workbench.service.impl.ClueServiceImpl;
import com.chuanqihou.crm.workbench.service.impl.ContactsServiceImpl;
import com.chuanqihou.crm.workbench.service.impl.CustomerServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CustomerServlet extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取来访网站信息
        String path = request.getServletPath();
        //根据条件查询客户信息
        if ("/workbench/customer/pageList.do".equals(path)){
            pageList(request,response);
        //插入客户信息
        }else if ("/workbench/customer/save.do".equals(path)){
            save(request,response);
        //根据客户Id查新客户详细信息
        }else if ("/workbench/customer/getUserListAndCustomer.do".equals(path)){
            getUserListAndCustomer(request,response);
        //根据客户Id删除客户信息
        }else if ("/workbench/customer/delete.do".equals(path)){
            delete(request,response);
        //根据客户ID更新客户信息
        }else if ("/workbench/customer/update.do".equals(path)){
            update(request,response);
        //获取客户详细信息,请求转发
        }else if ("/workbench/customer/detail.do".equals(path)){
            detail(request,response);
        //根据客户Id获取旗下的备注信息
        }else if ("/workbench/customer/getRemarkListById.do".equals(path)){
            getRemarkListById(request,response);
        //根据客户Id插入一天备注信息
        }else if ("/workbench/customer/saveRemark.do".equals(path)){
            saveRemark(request,response);
        //根据客户Id更新备注信息
        }else if ("/workbench/customer/updateRemark.do".equals(path)){
            updateRemark(request,response);
        //根据备注Id删除备注信息
        }else if ("/workbench/customer/deleteRemark.do".equals(path)){
            deleteRemark(request,response);
        //根据客户信息Id查找交易信息
        }else if ("/workbench/customer/getTranByCustomerId.do".equals(path)){
            getTranByCustomerId(request,response);
        //根据交易Id删除交易信息
        }else if ("/workbench/customer/deleteTransactionById.do".equals(path)){
            deleteTransactionById(request,response);
        //根据客户Id查找联系人信息
        }else if ("/workbench/customer/getContactsByCustomerId.do".equals(path)){
            getContactsByCustomerId(request,response);
        }
    }

    /**
     * 根据客户Id查找联系人信息
     * @param request   请求
     * @param response  响应
     */
    private void getContactsByCustomerId(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数（客户Id）
        String customerId = request.getParameter("id");
        //调用业务层处理相关信息得到客户信息
        List<Contacts> contacts = customerService.getContactsByCustomerId(customerId);
        //将客户信息展示到前端
        PrintJson.printJsonObj(response,contacts);
    }

    /**
     * 根据交易Id删除交易信息
     * @param request   请求
     * @param response  响应
     */
    private void deleteTransactionById(HttpServletRequest request, HttpServletResponse response) {
        //获取参数信息（交易ID）
        String tranId = request.getParameter("tranId");
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //调用业务层方法获取删状态
        boolean flag = customerService.deleteTransactionById(tranId);
        //将删除状态信息转换成json数据并传入前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     *根据客户Id获取交易信息
     * @param request   请求
     * @param response  响应
     */
    private void getTranByCustomerId(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数信息（客户Id）
        String customerId = request.getParameter("id");
        //调用业务层方法
        List<Tran> trans = customerService.getTranByCustomerId(customerId);
        //从全局作用域中取得交易阶段以及对应的可能性数据
        Map<String,String> pMap = (Map<String, String>) request.getServletContext().getAttribute("pmap");
        //遍历map集合
        for (Tran t : trans) {
            //获得每个交易信息对应的交易阶段
            String stage = t.getStage();
            //将交易阶段作为key传入map中取得可能性
            String possibility = pMap.get(stage);
            //将可能性封装到交易类中
            t.setPossibility(possibility);
        }
        //将数据转换成json数据并传入前端
        PrintJson.printJsonObj(response,trans);
    }

    /**
     * 根据客户Id删除备注信息
     * @param request
     * @param response
     */
    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        boolean flag = customerService.deleteRemark(id);
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 根据客户备注Id更新备注信息
     * @param request
     * @param response
     */
    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");

        String editTime = DateTimeUtil.getSysTime();
        String editName = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "1";

        CustomerRemark customerRemark = new CustomerRemark();
        customerRemark.setId(id);
        customerRemark.setNoteContent(noteContent);
        customerRemark.setEditTime(editTime);
        customerRemark.setEditBy(editName);
        customerRemark.setEditFlag(editFlag);
        //调用dao层，传入对象条件并返回状态信息
        boolean flag = customerService.updateRemark(customerRemark);
        //将状态信息以及对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",customerRemark);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 插入一条备注信息
     * @param request
     * @param response
     */
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数信息
        String noteContent = request.getParameter("noteContent");
        String customerId = request.getParameter("customerId");
        //生成备注Id
        String id = UUIDUtil.getUUID();
        //获取时间
        String createTime = DateTimeUtil.getSysTime();
        //从Session域中获取当前登录用户
        String createdBy = ((User)request.getSession().getAttribute("user")).getName();
        //将修改状态赋值为0
        String editFlag = "0";
        //创建ActivityRemark对象进行数据封装
        CustomerRemark ar = new CustomerRemark();
        ar.setCreateBy(createdBy);
        ar.setCustomerId(customerId);
        ar.setId(id);
        ar.setCreateTime(createTime);
        ar.setEditFlag(editFlag);
        ar.setNoteContent(noteContent);
        //调用dao层，传入对象条件并返回状态信息
        boolean flag = customerService.saveRemark(ar);
        //将状态信息以及对象封装成map集合返回
        Map<String, Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("ar",ar);
        //将map集合转换成json对象传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 根据客户Id获取备注信息
     * @param request
     * @param response
     */
    private void getRemarkListById(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //从请求转发域中获取市场活动Id
        String customerId = request.getParameter("customerId");
        //调用dao层，根据Id获取所有备注信息，封装成List集合
        List<CustomerRemark> arList = customerService.getRemarkListById(customerId);
        //将数据转换为json数据，并将其传入前端
        PrintJson.printJsonObj(response,arList);
    }

    /**
     * 获取客户详细信息,请求转发
     * @param request
     * @param response
     * @throws ServletException
     * @throws IOException
     */
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        //调用Dao层传入Id
        Customer customer = customerService.detail(id);
        //将对象存入请求域中
        request.setAttribute("c",customer);
        //请求转发跳转到客户详细页
        request.getRequestDispatcher("/workbench/customer/detail.jsp").forward(request,response);
    }

    /**
     * 根据客户ID更新客户信息
     * @param request
     * @param response
     */
    private void update(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String website = request.getParameter("website");
        String phone = request.getParameter("phone");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String description = request.getParameter("description");
        String address = request.getParameter("address");

        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();

        //将参数封装
        Customer customer = new Customer();
        customer.setId(id);
        customer.setOwner(owner);
        customer.setName(name);
        customer.setWebsite(website);
        customer.setPhone(phone);
        customer.setContactSummary(contactSummary);
        customer.setNextContactTime(nextContactTime);
        customer.setEditBy(editBy);
        customer.setDescription(description);
        customer.setEditTime(editTime);
        customer.setAddress(address);
        //调用业务对象方法，返回更新状态信息
        boolean flag = customerService.update(customer);
        //将状态信息转换成Json传至前端
        PrintJson.printJsonFlag(response,"success",flag);

    }

    /**
     * 根据客户Id删除客户信息
     * @param request   请求
     * @param response  响应
     */
    private void delete(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取需要删除的客户Id
        String[] ids = request.getParameterValues("id");
        //调用业务方法，返回删除状态信息
        boolean flag = customerService.delete(ids);
        //将状态信息转换成Json对象并传至前端
        PrintJson.printJsonFlag(response,"success",flag);
    }

    /**
     * 获取所有用户信息，根据客户Id获取客户详细信息
     * @param request   请求
     * @param response  响应
     */
    private void getUserListAndCustomer(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取客户Id
        String id = request.getParameter("id");
        //调用Dao处理数据，返回数据
        Map<String,Object> map = customerService.getUserListAndCustomer(id);
        //将map对象转换成json对象并将其传入前端
        PrintJson.printJsonObj(response,map);
    }

    /**
     * 插入客户信息
     * @param request   请求
     * @param response  响应
     */
    private void save(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String website = request.getParameter("website");
        String phone = request.getParameter("phone");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String description = request.getParameter("description");
        String address = request.getParameter("address");
        //生成客户ID
        String id = UUIDUtil.getUUID();
        //获取当前登录用户姓名
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        //获取当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //将参数封装
        Customer customer = new Customer();
        customer.setId(id);
        customer.setOwner(owner);
        customer.setName(name);
        customer.setWebsite(website);
        customer.setPhone(phone);
        customer.setContactSummary(contactSummary);
        customer.setNextContactTime(nextContactTime);
        customer.setCreateBy(createBy);
        customer.setDescription(description);
        customer.setCreateTime(createTime);
        customer.setAddress(address);
        //调用业务对象方法，返回插入状态信息
        boolean flag = customerService.save(customer);
        //将状态信息转换成Json传至前端
        PrintJson.printJsonFlag(response,"success",flag);


    }

    /**
     * 根据条件获取所有的客户信息
     * @param request   请求
     * @param response  响应
     */
    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        //获取处理客户业务对象
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //获取参数
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        //将页码和总页数转化成int类型
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //获取分页查询时略过数据（SQL语句 limit中的第一个条件）
        int skipCount = (pageNo-1)*pageSize;
        //将所有条件封装成map集合
        Map<String, Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("website",website);
        map.put("pageSize",pageSize);
        map.put("skipCount",skipCount);
        //调用客户业务对象中的根据条件查询方法，传入map条件，并将总条数和客户信息列表数据返回到PaginationVo<Customer>对象
        PaginationVo<Customer> vo = customerService.pageList(map);
        //将PaginationVo<Customer>对象转换成json数据并返回至前端
        PrintJson.printJsonObj(response,vo);
    }
}
