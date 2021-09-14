package com.chuanqihou.crm.workbench.service;

import com.chuanqihou.crm.vo.PaginationVo;
import com.chuanqihou.crm.workbench.domain.Activity;

import java.util.Map;

/**
 * @auther 传奇后
 * @date 2021/9/13 16:41
 * @veersion 1.0
 */

//接口 市场活动业务处理层
public interface ActivityService {
    //添加市场活动信息
    boolean save(Activity activity);

    PaginationVo<Activity> pageList(Map<String, Object> map);
}
