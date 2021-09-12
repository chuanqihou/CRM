<%--
Created by IntelliJ IDEA.
User: 传奇后
Date: 2021/9/12
Time: 15:28
To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script>
		<%--页面加载完成后执行--%>
		$(function (){

			//给登录按钮绑定验证事件
			$("#submitButt").click(function (){
				jiaoDiao();
				if ($("#msg").html()==""){
					login();
				}
			})
			//回车键登录验证事件
			$(window).keydown(function (event){
				if (event.keyCode==13){
					jiaoDiao();
					if ($("#msg").html()==""){
						login();
					}
				}
			})

			// 判断用户名和密码输入状态
			$("#loginAct").blur(function (){
				var loginAct = $.trim($("#loginAct").val());
				if (loginAct==""){
					$("#msg").html("用户名不能为空");
				}
			});
			$("#loginAct").focus(function (){
				$("#msg").html("");
			})
			$("#loginpwd").blur(function (){
				var loginPwd = $.trim($("#loginpwd").val());
				if ($("#loginAct").val()==""){
					$("#msg").html("用户名不能为空");
				}
				if ($("#loginAct").val()!="" && loginPwd==""){
					$("#msg").html("密码不能为空");
				}
			});
			$("#loginpwd").focus(function (){
				$("#msg").html("");
			})
		})
		//获得和失去焦点
		function jiaoDiao(){
			$("#loginAct").focus();
			$("#loginAct").blur();
			$("#loginpwd").focus();
			$("#loginpwd").blur();
		}

		//验证登录方法
		function login(){
			$.ajax({
				url : "setting/user/login.do",
				data : {
					"loginAct" : $("#loginAct").val(),
					"loginPwd" : $("#loginpwd").val()
				},
				type : "post",
				dataType : "json",
				success : function (data){
					if (data.success){
						window.location.href = "workbench/index.html";
					}else {
						$("#msg").html(data.msg);
					}
				}
			})
		}

	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2021&nbsp;传奇后</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" placeholder="用户名" id="loginAct">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" placeholder="密码" id="loginpwd">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						
							<span id="msg" style="color: red"></span>
						
					</div>
					<button type="button" id="submitButt" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>