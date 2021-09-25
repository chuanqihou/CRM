package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {

    //取消线索与某一条市场活动信息的关联
    int unbund(String id);

    //根据线索Id和市场活动Id将市场活动与线索进行关联
    int bund(ClueActivityRelation car);
    //根据线索Id查询线索与市场活动关系信息
    List<ClueActivityRelation> getListByClueId(String clueId);

    //删除线索与市场活动关系数据
    int delete(ClueActivityRelation clueActivityRelation);
}
