package com.chuanqihou.crm.web.filter; /**
 * @auther 传奇后
 * @date 2021/9/13 13:49
 * @veersion 1.0
 */

import javax.servlet.*;
import java.io.IOException;

public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws ServletException, IOException {
        System.out.println("字符编码过滤器");
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=utf-8");
        chain.doFilter(request, response);
    }
}
