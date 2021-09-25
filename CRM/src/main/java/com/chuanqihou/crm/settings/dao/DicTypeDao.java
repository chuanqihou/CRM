package com.chuanqihou.crm.settings.dao;

import com.chuanqihou.crm.settings.domain.DicType;

import java.util.List;

/**
 * @auther 传奇后
 * @date 2021/9/18 12:08
 * @veersion 1.0
 */
public interface DicTypeDao {
    //查询所有数据字典类型
    List<DicType>  getTypeList();
}
