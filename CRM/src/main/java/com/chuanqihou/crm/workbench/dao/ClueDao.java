package com.chuanqihou.crm.workbench.dao;

import com.chuanqihou.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    //插入一条线索
    int save(Clue clue);
    //展示线索详细页
    Clue detail(String id);

    //通过线索Id查新线索信息
    Clue getById(String clueId);

    //删除线索
    int delete(String clueId);
    //根据条件查询线索信息列表总数动态SQL
    int getTotalByCondition(Map<String, Object> map);
    // 根据条件查询线索信息列表总数动态SQL
    List<Clue> getClueByCondition(Map<String, Object> map);
    //更新线索信息
    int update(Clue clue);
}
