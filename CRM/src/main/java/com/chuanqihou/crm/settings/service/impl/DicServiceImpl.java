package com.chuanqihou.crm.settings.service.impl;

import com.chuanqihou.crm.settings.dao.DicTypeDao;
import com.chuanqihou.crm.settings.dao.DicValueDao;
import com.chuanqihou.crm.settings.domain.DicType;
import com.chuanqihou.crm.settings.domain.DicValue;
import com.chuanqihou.crm.settings.service.DicService;
import com.chuanqihou.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/18 12:12
 * @veersion 1.0
 */
public class DicServiceImpl implements DicService {
    //获取处理数据字典类型的Dao
    private DicTypeDao dicTypeDao = SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    //获取处理数据字典类型中的数据的Dao
    private DicValueDao dicValueDao = SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    /**
     * 获取所有的数据字典数据
     * @return 返回封装成map的数据字典类型和对应的数据
     */
    @Override
    public Map<String, List<DicValue>> getAll() {
        //定义一个map集合
        Map<String,List<DicValue>> map = new HashMap<>();
        //调用处理数据字典类型Dao取得所有数据字典类型
        List<DicType> dicTypeList = dicTypeDao.getTypeList();
        //遍历数据字典类型
        for (DicType dt : dicTypeList) {
            //取得数据字典类型的Code
            String code  = dt.getCode();
            //调用处理数据字典类型数据的Dao，传入数据字典类型作为查询条件，取得单个数据字典类型中的数据
            List<DicValue> dicValueList = dicValueDao.getListByCode(code);
            //将数据字典类型Code作为key和对应的数据字典数据作为value添加到map集合中
            map.put(code,dicValueList);
        }
        //返回map集合
        return map;
    }
}
