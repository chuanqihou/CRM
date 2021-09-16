<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
		//点击调用模态窗口
		$("#addBtn").click(function (){
			//时间插件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			//加载用户信息
			$.ajax({
				url : "workbench/activity/getUserList.do",
				type : "get",
				dataType : "json",
				success : function (data){
					var html = "<option>---请选择---</option>"
					$.each(data,function (i,n){
						html+="<option value='"+n.id+"'>"+n.name+"</option>"
					})
					//将用户姓名添加至下拉框
					$("#create-marketActivityOwner").html(html);
					var id = "${user.id}";
					$("#create-marketActivityOwner").val(id);
					//打开模态窗口
					$("#createActivityModal").modal("show");
				}
			})
		})

		//点击添加市场活动信息
		$("#saveBtn").click(function(){
			//ajax局部刷新添加操作
			$.ajax({
				url : "workbench/activity/save.do",
				data : {
					"owner" : $.trim($("#create-marketActivityOwner").val()),
					"name" : $.trim($("#create-marketActivityName").val()),
					"startDate" : $.trim($("#create-startTime").val()),
					"endDate" : $.trim($("#create-endTime").val()),
					"cost" : $.trim($("#create-cost").val()),
					"description" : $.trim($("#create-describe").val())
				},
				type: "post",
				dataType: "json",
				success : function (data){
					if (data.success){
						$("#activitySaveForm")[0].reset();
						$("#createActivityModal").modal("hide");
						pageList(1,2);
					}else {
						alert("添加市场活动失败！")
					}
				}
			})
		});

		//点击市场活动后页面加载市场活动列表
		pageList(1,2);

		//点击查询按钮
		$("#searchBtn").click(function (){
			//将查询条件临时保存在隐藏域中
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-startDate").val($.trim($("#search-startDate").val()));
			$("#hidden-endDate").val($.trim($("#search-endDate").val()));
			//页面加载市场活动列表
			pageList(1,2);
		});

		//获得全选框Jquery对象
		$("#qx").click(function (){
			//所有选择框子对象选中条件：全选框选中
			$("input[name=xz]").prop("checked",this.checked)
		});

		//获得选择框子对象
		$("#activityBody").on("click",$("input[name=xz]"),function () {
			//全选框选中条件：所有选择框子对象选中个数等于选择框子对象的总数
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		});

		//点击删除市场活动信息
		$("#deleteBtn").click(function(){
			//获取选中需要删除市场活动信息数量
			var $xz = $("input[name=xz]:checked");
			//判断数量
			if ($xz.length==0){
				alert("请选择需要删除的市场活动！")
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
						url : "workbench/activity/delete.do",
						data : param,
						type : "post",
						dataType : "json",
						success : function (data){
							if (data.success){
								//删除成功，刷新市场活动列表
								pageList(1,2);
							}else {
								//删除失败提示
								alert("删除市场活动失败！")
							}
						}
					})
				}
			}
		});

		//点击修改市场活动信息
		$("#editBtn").click(function (){
			//获取选中需要删除市场活动信息数量
			var $xz = $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要修改的市场活动！")
			}else if ($xz.length>=2){
				alert("只能选择一条记录进行修改！")
			}else {
				var id = $xz.val();

				$.ajax({
					url : "workbench/activity/getUserListAndActivity.do",
					data : {
						id
					},
					type : "get",
					dataType : "json",
					success : function (data){
						var html = "";
						$.each(data.uList,function (i,n){
							html+="<option id='"+n.id+"'>"+n.name+"</option>";
						})
						$("#edit-marketActivityOwner").html(html);
						$("#edit-describe").val(data.a.description);
						$("#edit-cost").val(data.a.cost);
						$("#edit-endTime").val(data.a.endDate);
						$("#edit-startTime").val(data.a.startDate);
						$("#edit-marketActivityName").val(data.a.name);
						$("#edit-id").val(data.a.id);

						$("#editActivityModal").modal("show");
					}
				})
			}
		});

		$("#updateBtn").click(function(){
			//ajax局部刷新更新操作
			$.ajax({
				url : "workbench/activity/update.do",
				data : {
					"id" : $.trim($("#edit-id").val()),
					"owner" : $.trim($("#edit-marketActivityOwner").val()),
					"name" : $.trim($("#edit-marketActivityName").val()),
					"startDate" : $.trim($("#edit-startTime").val()),
					"endDate" : $.trim($("#edit-endTime").val()),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-describe").val())
				},
				type: "post",
				dataType: "json",
				success : function (data){
					if (data.success){
						// $("#activitySaveForm")[0].reset();
						$("#editActivityModal").modal("hide");
						pageList(1,2);
					}else {
						alert("修改市场活动失败！")
					}
				}
			})
		});
	});


	//获取市场活动信息列表并分页
	function pageList(pageNo,pageSize){
		//将隐藏域中的查询条件重新展示
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-startDate").val($.trim($("#hidden-startDate").val()));
		$("#search-endDate").val($.trim($("#hidden-endDate").val()));

		//调用ajax方法获取所有市场活动信息列表
		$.ajax({
			url : "workbench/activity/pageList.do",
			data : {
				"pageNo" : pageNo,		//页码
				"pageSize" : pageSize,		//每页展示数据条数
				"name" : $.trim($("#search-name").val()),		//查询条件：市场活动名称
				"owner" : $.trim($("#search-owner").val()),		//查询条件：市场活动所有者
				"startDate" : $.trim($("#search-startDate").val()),		//查询条件：市场活动开始时间
				"endDate" : $.trim($("#search-endDate").val()),		//查询条件：市场活动结束时间
			},
			type : "get",
			dataType : "json",
			//成功后执行
			success : function (data){
				//定义一个字符串
				var html = "";
				//使用$.each循环取出市场活动数据
				$.each(data.dataList,function (i,n){
					//将数据拼接
					html+='<tr class="active">';
					html+='<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>';
					html+='<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.jsp\';">'+n.name+'</a></td>';
					html+='<td>'+n.owner+'</td>';
					html+='<td>'+n.startDate+'</td>';
					html+='<td>'+n.endDate+'</td>';
					html+='</tr>';
				})
				//将数据展示到前端
				$("#activityBody").html(html);
				//没有查询出数据提示语
				if ($("#activityBody").html()=="" || $("#activityBody").html()==null){
					html+='<tr class="active" align="center">';
					html+='<td colspan="5">没有数据哦！</td>';
					html+='</tr>';
				}
				// 将提示语输出
				$("#activityBody").html(html);
				//获取总页数（根据查询条件而改变）
				var totalPages = data.total%pageSize==0 ? data.total/pageSize:parseInt(data.total/pageSize)+1;
				//调用分页样式方法
				$("#activityPage").bs_pagination({
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
					onChangePage : function(event, data){
						//将全选框取消选中
						// $("#qx")[0].checked=false;
						$("#qx").prop("checked",false);
						//根据条件刷新市场活动列表
						pageList(data.currentPage , data.rowsPerPage);
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
	<input type="hidden" id="hidden-startDate"/>
	<input type="hidden" id="hidden-endDate"/>
	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activitySaveForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startTime" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endTime" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startTime" readonly>
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endTime" readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>
				  
				  <button id="searchBtn" type="button" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
<%--						<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
<%--				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>--%>
<%--				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>--%>
			</div>
			
		</div>
		
	</div>
</body>
</html>