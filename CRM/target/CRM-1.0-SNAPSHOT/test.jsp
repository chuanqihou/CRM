<%--
  Created by IntelliJ IDEA.
  User: 传奇后
  Date: 2021/9/12
  Time: 15:28
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";%>
<base href="<%=basePath%>">
<html>
<head>
    <title>Title</title>
</head>
<body>
<script>
    $.ajax({
        url : "",
        data : {},
        type : "",
        dataType : "json",
        success : function (data){}
    })
</script>
</body>
</html>
