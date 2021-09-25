package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    //根据线索ID查询线索备注信息
    List<ClueRemark> getListByClueId(String clueId);

    //删除线索备注信息
    int delete(ClueRemark c);

    //根据线索ID查询线索备注信息
    List<ClueRemark> getRemarkListById(String clueId);

    //插入备注信息
    int saveRemark(ClueRemark cr);

    int updateRemark(ClueRemark clueRemark);
}
