package com.chuanqihou.crm.settings.dao;

import com.chuanqihou.crm.settings.domain.DicValue;

import java.util.List;

/**
 * @auther 传奇后
 * @date 2021/9/18 12:09
 * @veersion 1.0
 */
public interface DicValueDao {
    //数据字典类型作为查询条件，取得单个数据字典类型中的数据
    List<DicValue> getListByCode(String code);
}
