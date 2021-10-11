<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){

		//点击页面加载客户列表
		pageList(1,5);

		//点击查询按钮
		$("#searchBtn").click(function (){
			//将查询条件隐藏在隐藏域中
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-stage").val($.trim($("#search-stage").val()));
			$("#hidden-source").val($.trim($("#search-source").val()));
			$("#hidden-customerName").val($.trim($("#search-customerName").val()));
            $("#hidden-contactsName").val($.trim($("#search-contactsName").val()));
            $("#hidden-type").val($.trim($("#type").val()));
			//根据条件刷新客户列表页面
			pageList(1,5);
		})

		//获得全选框Jquery对象
		$("#qx").click(function (){
			//所有选择框子对象选中条件：全选框选中
			$("input[name=xz]").prop("checked",this.checked)
		});

		//获得选择框子对象
		$("#transactionTbody").on("click",$("input[name=xz]"),function () {
			//全选框选中条件：所有选择框子对象选中个数等于选择框子对象的总数
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		});

		$("#updateTransaction").click(function(){
			var xz = $("input[name=xz]:checked").length;
			if (xz==1){
				var param = $("input[name=xz]:checked").val();
				window.location.href='/crm/workbench/transaction/editShow.do?transactionId='+param+'';
				// alert(param)
			}else if (xz>1){
				alert("请选择一项交易进行修改！")
			}else {
				alert("请选择需要修改的交易！")
			}
		})

		$("#deleteTransaction").click(function(){
			//获取选中需要删除市场活动信息数量
			var $xz = $("input[name=xz]:checked");
			//判断数量
			if ($xz.length==0){
				alert("请选择需要删除的交易！")
			}else {
				if (confirm("确定删除数据吗？")){
					//拼接参数（需要删除市场活动信息的Id）
					var param = "";
					for (var i = 0;i<$xz.length;i++){
						param+="id="+$($xz[i]).val();
						//给拼接参数中添加分隔符“,”
						if (i<$xz.length-1){
							param+="&";
						}
					}
					//发送删除的ajax请求
					$.ajax({
						url : "workbench/transaction/delete.do",
						//参数：需要删除的市场活动Id
						data : param,
						type : "post",
						dataType : "json",
						//返回删除状态信息
						success : function (data){
							if (data.success){
								//删除成功，取消全选框
								$("#qx").prop("checked",false);
								//刷新列表，跳转到第一页，维持用户选择每页展示数据条数
								pageList(1,$("#transactionPage").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								//删除失败提示
								alert("删除交易失败！")
							}
						}
					})
				}
			}
		})
		
	});

	//根据条件获取客户信息列表并分页
	function pageList(pageNo,pageSize) {
		//将隐藏域中的查询条件重新展示
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-customerName").val($.trim($("#hidden-customerName").val()));
		$("#search-stage").val($.trim($("#hidden-stage").val()));
		$("#search-contactsName").val($.trim($("#hidden-contactsName").val()));
		$("#search-type").val($.trim($("#hidden-type").val()));
		$("#search-source").val($.trim($("#hidden-source").val()));

/*		alert($("#search-type").val());
		alert($("#search-state").val());*/

		//调用ajax方法根据条件获取所有客户信息列表
		$.ajax({
			url: "workbench/transaction/pageList.do",
			data: {
				"pageNo": pageNo,		//页码
				"pageSize": pageSize,		//每页展示数据条数
				"name": $.trim($("#search-name").val()),		//查询条件：客户名称
				"owner": $.trim($("#search-owner").val()),		//查询条件：所有者
				"customerName": $.trim($("#search-customerName").val()),		//查询条件：客户座机
				"contactsName": $.trim($("#search-contactsName").val()),
				"source": $.trim($("#search-source").val()),		//查询条件：客户网站
				"stage": $.trim($("#search-state").val()),
				"type": $.trim($("#search-type").val()),
			},
			type: "get",
			dataType: "json",
			//返回根据条件查询出的所有客户信息，以及客户总数
			success: function (data) {
				//定义一个字符串
				var html = "";
				//使用$.each循环取出客户数据
				$.each(data.dataList, function (i, n) {

					html+='<tr>';
					html+='<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
					html+='<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/transaction/detail.do?id=' + n.id + '\';">' + n.name + '</a></td>';
					html+='<td>'+n.customerId+'</td>';
					html+='<td>'+n.stage+'</td>';
					html+='<td>'+n.type+'</td>';
					html+='<td>'+n.owner+'</td>';
                    html+='<td>'+n.source+'</td>';
                    html+='<td>'+n.createBy+'</td>';
					html+='</tr>';
				})
				//将数据展示到前端
				$("#transactionTbody").html(html);
				//没有查询出数据提示语
				if ($("#transactionTbody").html() == "" || $("#transactionTbody").html() == null) {
					html += '<tr class="active" align="center">';
					html += '<td colspan="7">没有数据哦！</td>';
					html += '</tr>';
				}
				// 将提示语输出
				$("#transactionTbody").html(html);
				//获取总页数（根据查询条件而改变）
				var totalPages = data.total % pageSize == 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;
				//调用分页样式方法
				$("#transactionPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数
					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,
					//单击分页按钮后执行回调函数
					onChangePage: function (event, data) {
						//将全选框取消选中
						// $("#qx")[0].checked=false;
						$("#qx").prop("checked", false);
						//根据条件刷新市场活动列表
						pageList(data.currentPage, data.rowsPerPage);
					}
				});
			}
		})
	}
	
</script>
</head>
<body>
	<%--隐藏域(用来保存临时查询条件数据)--%>
	<input type="hidden" id="hidden-name"/>
	<input type="hidden" id="hidden-owner"/>
	<input type="hidden" id="hidden-customerName"/>
	<input type="hidden" id="hidden-stage"/>
	<input type="hidden" id="hidden-type"/>
	<input type="hidden" id="hidden-contactsName"/>
	<input type="hidden" id="hidden-source"/>

	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerName">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="search-stage">
					  	<option></option>
						  <c:forEach items="${stage}" var="a">
							  <option value="${a.value}">${a.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="search-type">
					  	<option></option>
						  <c:forEach items="${transactionType}" var="a">
							  <option value="${a.value}">${a.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${source}" var="a">
							  <option value="${a.value}">${a.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="search-contactsName">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='/crm/workbench/transaction/save.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="updateTransaction"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteTransaction"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="transactionTbody">

					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 20px;" >
				<div id="transactionPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>