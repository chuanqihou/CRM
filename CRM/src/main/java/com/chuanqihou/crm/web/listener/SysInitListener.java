package com.chuanqihou.crm.web.listener; /**
 * @auther 传奇后
 * @date 2021/9/18 13:29
 * @veersion 1.0
 */

import com.chuanqihou.crm.settings.domain.DicValue;
import com.chuanqihou.crm.settings.service.DicService;
import com.chuanqihou.crm.settings.service.impl.DicServiceImpl;
import com.chuanqihou.crm.utils.ServiceFactory;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SysInitListener implements ServletContextListener {

    public SysInitListener() {
    }

    /**
     * 监听服务器的启动，当启动时从数据库中获取数据字典信息保存到服务器缓存中
     * @param sce
     */
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        //获取全局作用域对象
        ServletContext application = sce.getServletContext();
        //获取处理数据字典业务对象
        DicService dicService = (DicService) ServiceFactory.getService(new DicServiceImpl());
        //调用处理业务方法返回封装成map的数据字典类型和对应的数据
        Map<String, List<DicValue>> map = dicService.getAll();
        //取出map中的key（数据字典类型）
        Set<String> set = map.keySet();
        //遍历key
        for (String key : set) {
            //每取得一个key（数据字典类型），通过key获取数据
            application.setAttribute(key,map.get(key));
        }

    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
}
