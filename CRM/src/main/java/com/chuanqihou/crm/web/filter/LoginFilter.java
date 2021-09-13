package com.chuanqihou.crm.web.filter; /**
 * @auther 传奇后
 * @date 2021/9/13 15:04
 * @veersion 1.0
 */

import com.chuanqihou.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws ServletException, IOException {
        System.out.println("登录过滤器");
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String path = request.getServletPath();
        if (path.contains("login")) {
            chain.doFilter(req, res);
        } else {
            User user = (User) request.getSession().getAttribute("user");
            if (user != null) {
                chain.doFilter(req, res);
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
        }
    }
}
