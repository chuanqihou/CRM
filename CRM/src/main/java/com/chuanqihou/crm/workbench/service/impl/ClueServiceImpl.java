package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.settings.dao.UserDao;
import com.chuanqihou.crm.settings.domain.User;
import com.chuanqihou.crm.utils.DateTimeUtil;
import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.utils.UUIDUtil;
import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.dao.*;
import com.chuanqihou.crm.workbench.domain.*;
import com.chuanqihou.crm.workbench.service.ClueService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/18 11:55
 * @veersion 1.0
 */
public class ClueServiceImpl implements ClueService {
    //获取处理用户表Dao对象
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    //获取处理线索表Dao对象
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    //获取处理线索与市场活动关系表Dao对象
    private ClueActivityRelationDao clueActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    //获取处理线索备注表Dao对象
    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);

    //获取处理客户表Dao对象
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    //获取处理客户备注表Dao对象
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

    //获取处理联系人表Dao对象
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    //获取处理联系人备注表Dao对象
    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    //获取处理联系人与市场活动关系表表Dao对象
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);

    // 获取交易表Dao对象
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    // 获取交易历史表Dao对象
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);


    /**
     * 处理转换操作
     * @param clueId    线索Id
     * @param tran  交易对象（交易数据）
     * @param createBy  创建人（当前登录用户）
     * @return  返回状态信息
     */
    @Override
    public boolean convert(String clueId, Tran tran, String createBy) {
        //定义初始化状态信息
        boolean flag = true;
        //获取当前时间
        String createTime = DateTimeUtil.getSysTime();
        //通过线索Id查新线索信息
        Clue clue = clueDao.getById(clueId);

        /**
         * 处理客户信息表
         */
        //获取线索公司名称
        String company = clue.getCompany();
        //通过公司名称获取客户信息
        Customer customer = customerDao.getCustomerByName(company);
        //判断数据库中是否存有客户信息
        if (customer==null){
            //数据库中没有就创建客户对象
            customer = new Customer();
            //封装客户信息
            customer.setId(UUIDUtil.getUUID());
            customer.setAddress(clue.getAddress());
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setOwner(clue.getOwner());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setName(company);
            customer.setDescription(clue.getDescription());
            customer.setCreateTime(clue.getCreateTime());
            customer.setCreateBy(clue.getCreateBy());
            customer.setContactSummary(clue.getContactSummary());
            //调用dao保存（插入客户信息）
            if (customerDao.save(customer)!=1){
                flag = false;
            }
        }

        /**
         * 处理联系人表
         */

        //创建联系人
        Contacts contacts = new Contacts();
        //封装数据
        contacts.setId(UUIDUtil.getUUID());
        contacts.setSource(clue.getSource());
        contacts.setOwner(clue.getOwner());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setFullname(clue.getFullname());
        contacts.setEmail(clue.getEmail());
        contacts.setDescription(clue.getDescription());
        contacts.setCustomerId(customer.getId());
        contacts.setCreateTime(createTime);
        contacts.setCreateBy(createBy);
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setAppellation(clue.getAppellation());
        contacts.setAddress(clue.getAddress());
        //保存（插入）联系人信息
        if (contactsDao.save(contacts)!=1){
            flag = false;
        }

        /**
         * 处理线索备注表
         */

        //根据线索Id获取备注信息
        List<ClueRemark> clueRemarkList = clueRemarkDao.getListByClueId(clueId);
        //遍历备注信息
        for (ClueRemark c : clueRemarkList) {
            //获取备注
            String noteContent = c.getNoteContent();
            //创建客户备注对象
            CustomerRemark customerRemark = new CustomerRemark();
            //添加数据
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setCreateBy(createBy);
            customerRemark.setCreateTime(createTime);
            customerRemark.setCustomerId(customer.getId());
            customerRemark.setEditFlag("0");
            customerRemark.setNoteContent(noteContent);
            //插入客户备注信息表
            if (customerRemarkDao.save(customerRemark)!=1){
                flag = false;
            }
            //创建联系人备注对象
            ContactsRemark contactsRemark = new ContactsRemark();
            //添加数据
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setContactsId(contacts.getId());
            contactsRemark.setEditFlag("0");
            contactsRemark.setNoteContent(noteContent);
            //插入联系人备注表
            if (contactsRemarkDao.save(contactsRemark)!=1){
                flag = false;
            }
        }

        /**
         * 处理关系表
         */

        //根据线索Id查询线索与市场活动关系信息表
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getListByClueId(clueId);
        //遍历关系表
        for (ClueActivityRelation clueActivityRelation : clueActivityRelationList) {
            //获取市场活动Id
            String activityId = clueActivityRelation.getActivityId();
            //创建联系人与市场活动关系对象
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            //添加数据
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setActivityId(activityId);
            contactsActivityRelation.setContactsId(contacts.getId());
            //将数据插入联系人与市场活动关系表
            if (contactsActivityRelationDao.save(contactsActivityRelation)!=1){
                flag = false;
            }
        }

        //判断是否创建了交易
        if (tran!=null){
            //给交易对象添加部分数据
            tran.setSource(contacts.getSource());
            tran.setOwner(contacts.getOwner());
            tran.setNextContactTime(contacts.getNextContactTime());
            tran.setCustomerId(customer.getId());
            tran.setContactSummary(contacts.getContactSummary());
            tran.setDescription(contacts.getDescription());
            tran.setContactsId(contacts.getId());
            //插入交易信息
            if (tranDao.save(tran)!=1){
                flag = false;
            }
            //创建交易历史对象
            TranHistory tranHistory = new TranHistory();
            //添加数据
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setStage(tran.getStage());
            tranHistory.setTranId(tran.getId());
            //将交易历史数据插入表中
            if (tranHistoryDao.save(tranHistory)!=1){
                flag = false;
            }
        }


        /**
         * 删除表中数据
         */

        //删除线索备注信息
        for (ClueRemark c : clueRemarkList) {
            if (clueRemarkDao.delete(c)!=1){
                flag = false;
            }
        }
        //删除线索与市场活动关系数据
        for (ClueActivityRelation clueActivityRelation : clueActivityRelationList) {
            if (clueActivityRelationDao.delete(clueActivityRelation)!=1){
                flag = false;
            }
        }
        //删除线索
        if (clueDao.delete(clueId)!=1){
            flag = false;
        }
        //返回状态信息
        return flag;
    }

    /**
     * 插入一条线索
     * @param clue  线索数据
     * @return  插入状态
     */
    @Override
    public boolean save(Clue clue) {
        //定义初始状态值
        boolean flag = true;
        //调用Dao层插入数据
        if (clueDao.save(clue)!=1){
            //更改状态
            flag = false;
        }
        //返回状态信息
        return flag;
    }

    /**
     * 获取线索详细信息
     * @param id    线索Id
     * @return
     */
    @Override
    public Clue detail(String id) {
        Clue c = clueDao.detail(id);
        return c;
    }

    /**
     * 取消线索与某一条市场活动信息的关联
     * @param id    市场活动Id
     * @return  返回状态信息
     */
    @Override
    public boolean unbund(String id) {
        //定义初始化状态信息
        boolean flag = true;
        //调用Dao层，连接数据库
        if (clueActivityRelationDao.unbund(id)!=1){
            flag = false;
        }
        //返回状态信息
        return flag;
    }

    /**
     * 根据线索Id和市场活动Id将市场活动与线索进行关联
     * @param clueId    线索ID
     * @param aids  市场活动Id
     * @return  状态信息
     */
    @Override
    public boolean bund(String clueId, String[] aids) {
        //定义初始状态信息
        boolean flag = true;
        //遍历取出市场活动Id
        for (String aid : aids) {
            //获取线索与市场活动关系表对象封装参数
            ClueActivityRelation car = new ClueActivityRelation();
            //生成id
            car.setId(UUIDUtil.getUUID());
            car.setClueId(clueId);
            car.setActivityId(aid);
            //调用Dao层
            if (clueActivityRelationDao.bund(car)!=1){
                flag = false;
            }
        }
        //返回状态信息
        return flag;
    }


    /**
     * 根据条件查询线索列表
     * @param map   查询条件、分页条件
     * @return  返回PaginationVo<Clue>对象（线索数量、List<Clue>）
     */
    @Override
    public PaginationVo<Clue> pageList(Map<String, Object> map) {

        //根据条件查询线索列表总数
        int total = clueDao.getTotalByCondition(map);
        //根据条件查询所有线索信息
        List<Clue> clues = clueDao.getClueByCondition(map);
        //创建PaginationVo<Clue>对象
        PaginationVo<Clue> vo = new PaginationVo<>();
        //将结果添加
        vo.setTotal(total);
        vo.setDataList(clues);
        //返回PaginationVo<Clue>对象
        return vo;
    }

    /**
     * 查询所有用户信息以及根据线索Id查询一天线索信息
     * @param clueId    查询条件
     * @return
     */
    @Override
    public Map<String, Object> getUserListAndClue(String clueId) {
        //获取所有用户信息
        List<User> userList = userDao.getUserList();
        //获取线索信息
        Clue c = clueDao.getById(clueId);
        //将结果封装至map对象
        Map<String,Object> map = new HashMap<>();
        map.put("c",c);
        map.put("uList",userList);
        //返回结果
        return map;
    }

    /**
     * 更新线索
     * @param clue  更新数据
     * @return  返回更新状态
     */
    @Override
    public boolean update(Clue clue) {
        //定义初始状态
        boolean flag = true;
        //调用更新DAO
        if (clueDao.update(clue)!=1){
            flag=false;
        }
        //返回状态信息
        return flag;
    }

    /**
     * 删除线索
     * @param id   需要删除线索的Id
     * @return  返回删除状态
     */
    @Override
    public boolean delete(String[] id) {

        //定义初始状态
        boolean flag = true;
        //遍历线索Id
        for (String i : id) {
            //通过线索ID查询除备注信息
            List<ClueRemark> remarks = clueRemarkDao.getRemarkListById(i);
            //判断是否存在
            if (remarks.size()!=0){
                //遍历备注集合
                for (ClueRemark cr : remarks) {
                    //删除备注
                    if (clueRemarkDao.delete(cr)!=1){
                        flag = false;
                    }
                }
            }
            //删除线索
            if (clueDao.delete(i)!=1){
                flag = false;
            }
        }
        //返回状态
        return flag;
    }

    /**
     * 根据线索Id查询备注信息
     * @param clueId    线索Id
     * @return  线索集合
     */
    @Override
    public List<ClueRemark> getRemarkListById(String clueId) {
        //调用DAO
        List<ClueRemark> clueRemarkList = clueRemarkDao.getRemarkListById(clueId);
        //返回线索集合
        return clueRemarkList;
    }


    /**
     * 新建备注信息
     * @param cr    备注数据
     * @return  返回状态信息
     */
    @Override
    public boolean saveRemark(ClueRemark cr) {
        //定义初始化状态
        boolean flag = true;
        //调用Dao层
        if (clueRemarkDao.saveRemark(cr)!=1){
            flag = false;
        }
        //返回状态信息
        return flag;
    }

    @Override
    public boolean deleteRemark(String id) {
        //定义初始化状态
        boolean flag = true;
        ClueRemark clueRemark = new ClueRemark();
        clueRemark.setId(id);
        //调用Dao层
        if (clueRemarkDao.delete(clueRemark)!=1){
            flag = false;
        }
        //返回状态信息
        return flag;
    }

    @Override
    public boolean updateRemark(ClueRemark clueRemark) {
        //定义初始化状态
        boolean flag = true;
        //调用Dao层
        if (clueRemarkDao.updateRemark(clueRemark)!=1){
            flag = false;
        }
        //返回状态信息
        return flag;
    }

}
