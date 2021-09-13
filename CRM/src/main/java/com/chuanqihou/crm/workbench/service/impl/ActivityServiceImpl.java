package com.chuanqihou.crm.workbench.service.impl;

import com.chuanqihou.crm.utils.SqlSessionUtil;
import com.chuanqihou.crm.workbench.dao.ActivityDao;
import com.chuanqihou.crm.workbench.service.ActivityService;

/**
 * @auther 传奇后
 * @date 2021/9/13 16:42
 * @veersion 1.0
 */
public class ActivityServiceImpl implements ActivityService {
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

}
