package com.chuanqihou.crm.workbench.service;

import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.Clue;
import com.chuanqihou.crm.workbench.domain.ClueRemark;
import com.chuanqihou.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/18 11:55
 * @veersion 1.0
 */
public interface ClueService {
    //插入一条线索数据
    boolean save(Clue clue);

    //获取线索详细信息
    Clue detail(String id);

    //取消线索与某一条市场活动信息的关联
    boolean unbund(String id);

    //根据线索Id和市场活动Id将市场活动与线索进行关联
    boolean bund(String clueId, String[] aids);

    //将线索转换
    boolean convert(String clueId, Tran tran, String createBy);

    //根据条件查询线索列表
    PaginationVo<Clue> pageList(Map<String, Object> map);

    //查询用户信息和一条线索信息
    Map<String, Object> getUserListAndClue(String clueId);

    //更新线索
    boolean update(Clue clue);

    //删除线索
    boolean delete(String[] id);

    //查询线索备注信息
    List<ClueRemark> getRemarkListById(String clueId);

    //新建备注信息
    boolean saveRemark(ClueRemark cr);

    //删除线索备注信息
    boolean deleteRemark(String id);

    //更新线索备注信息
    boolean updateRemark(ClueRemark clueRemark);
}
