package com.chuanqihou.crm.settings.service;

import com.chuanqihou.crm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/18 12:12
 * @veersion 1.0
 */
public interface DicService {
    //获取所有的数据字典数据，返回封装成map的数据字典类型和对应的数据
    Map<String, List<DicValue>> getAll();
}
