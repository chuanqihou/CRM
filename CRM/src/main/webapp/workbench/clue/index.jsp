<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--引入--%>
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
<%--引入分页样式--%>
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){

		//时间插件
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		//当页面加载时自动加载线索列表并分页
		pageList(1,5);

		//获得全选框Jquery对象
		$("#qx").click(function (){
			//所有选择框子对象选中条件：全选框选中
			$("input[name=xz]").prop("checked",this.checked)
		});

		//获得选择框子对象
		$("#clueBody").on("click",$("input[name=xz]"),function () {
			//全选框选中条件：所有选择框子对象选中个数等于选择框子对象的总数
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		});

		//给创建线索按钮绑定事件
		$("#addBtn").click(function(){
			//使用ajax请求获取所有用户信息
			$.ajax({
				url : "workbench/clue/getUserList.do",
				type : "get",
				dataType : "json",
				//返回用户信息
				success : function (data){
					//拼接字符串
					var html = "<option></option>"
					//遍历
					$.each(data,function (i,n){
						//拼接
						html+="<option value='"+n.id+"'>"+n.name+"</option>"
					})
					//将用户姓名添加至下拉框值
					$("#create-Owner").html(html);
					//从Session作用域中取出用户Id（使用EL表达式）
					var id = "${user.id}";
					//将用户Id添加至下拉框的value值（展示当前登录用户）
					$("#create-Owner").val(id);
					//打开模态窗口
					$("#createClueModal").modal("show");
				}
			})
		});

		//给创建线索的模态窗口中的保存按钮绑定事件
		$("#saveBtn").click(function(){
			//使用ajax请求将线索数据保存到数据库
			$.ajax({
				url : "workbench/clue/save.do",
				data : {
					"fullname" : $.trim($("#create-fullname").val()),		// 姓名
					"appellation" : $.trim($("#create-appellation").val()),		// 称呼
					"owner" : $.trim($("#create-Owner").val()),		// 所有者
					"company" : $.trim($("#create-company").val()),		// 公司名
					"job" : $.trim($("#create-job").val()),		//	职位
					"email" : $.trim($("#create-email").val()),		//	邮箱
					"phone" : $.trim($("#create-phone").val()),		//	公司座机
					"website" : $.trim($("#create-website").val()),		//	公司网站
					"mphone" : $.trim($("#create-mphone").val()),		//	手机
					"state" : $.trim($("#create-state").val()),		//	线索状态
					"source" : $.trim($("#create-source").val()),		//	线索来源
					"description" : $.trim($("#create-description").val()),		//	线索描述
					"contactSummary" : $.trim($("#create-contactSummary").val()),		//	联系纪要
					"nextContactTime" : $.trim($("#create-nextContactTime").val()),		//	下次联系时间
					"address" : $.trim($("#create-address").val())		//	详细地址
				},
				type : "post",
				dataType : "json",
				//返回保存状态
				success : function (data){
					if (data.success){
						//成功后重置表单
						$("#createClueForm")[0].reset();
						//隐藏创建线索的模态窗口
						$("#createClueModal").modal("hide");
						//刷新列表，跳转到第一页，维持用户选择每页展示数据条数
						pageList(1,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
					}else{
						alert("添加线索失败！")
					}
				}
			})
		});

		//点击查询按钮
		$("#searchBtn").click(function (){
			//将查询条件临时保存在隐藏域中
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-company").val($.trim($("#search-company").val()));
			$("#hidden-phone").val($.trim($("#search-phone").val()));
			$("#hidden-mphone").val($.trim($("#search-mphone").val()));
			$("#hidden-source").val($.trim($("#search-source").val()));
			$("#hidden-state").val($.trim($("#search-state").val()));
			//查询后页面加载市场活动列表
			pageList(1,5);
		});

		//点击修改线索信息模板
		$("#editBtn").click(function (){
			//获取选中需要修改线索数量
			var $xz = $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要修改的线索！")
			}else if ($xz.length>=2){
				alert("只能选择一条记录进行修改！")
			}else {
				//获取选择需要更新的线索Id
				var id = $xz.val();
				$.ajax({
					url : "workbench/clue/getUserListAndClue.do",
					data : {
						//参数：需要更新的线索Id
						"id":id
					},
					type : "get",
					dataType : "json",
					//返回根据Id查询出的线索以及所有用户信息
					success : function (data){
						//拼接字符串
						var html = "";
						$.each(data.uList,function (i,n){
							//如果用户信息表中的用户Id等于选中的线索表中所有者Id则选中
							if(data.c.owner==n.id){
								html+="<option selected value='"+n.id+"'>"+n.name+"</option>";
							}else {
								html+="<option value='"+n.id+"'>"+n.name+"</option>";
							}
						})
						$("#edit-clueOwner").html(html);
						//将该线索中的信息加载到页面中
						$("#edit-call").val(data.c.appellation);
						$("#edit-address").val(data.c.address);
						$("#edit-nextContactTime").val(data.c.nextContactTime);
						$("#edit-contactSummary").val(data.c.contactSummary);
						$("#edit-describe").val(data.c.description);
						$("#edit-mphone").val(data.c.mphone);
						$("#edit-website").val(data.c.website);
						$("#edit-phone").val(data.c.phone);
						$("#edit-email").val(data.c.email);
						$("#edit-job").val(data.c.job);
						$("#edit-surname").val(data.c.fullname);
						$("#edit-company").val(data.c.company);
						$("#edit-source").val(data.c.source);
						$("#edit-status").val(data.c.state);
						$("#edit-id").val(data.c.id);

						//展示修改页面
						$("#editClueModal").modal("show");
					}
				})
			}
		});

		//点击更新市场活动按钮执行操作
		$("#updateBtn").click(function(){
			//ajax局部刷新更新操作 参数：需要更新的所有信息
			$.ajax({
				url : "workbench/clue/update.do",
				data : {
					//参数：
					"id" : $.trim($("#edit-id").val()),
					"fullname" : $.trim($("#edit-surname").val()),
					"appellation" : $.trim($("#edit-call").val()),
					"owner" : $.trim($("#edit-clueOwner").val()),
					"company" : $.trim($("#edit-company").val()),
					"job" : $.trim($("#edit-email").val()),
					"email" : $.trim($("#edit-job").val()),
					"phone" : $.trim($("#edit-phone").val()),
					"website" : $.trim($("#edit-website").val()),
					"mphone" : $.trim($("#edit-mphone").val()),
					"state" : $.trim($("#edit-status").val()),
					"source" : $.trim($("#edit-source").val()),
					"description" : $.trim($("#edit-describe").val()),
					"contactSummary" : $.trim($("#edit-contactSummary").val()),
					"nextContactTime" : $.trim($("#edit-nextContactTime").val()),
					"address" : $.trim($("#edit-address").val())

				},
				type: "post",
				dataType: "json",
				//返回更新状态信息
				success : function (data){
					if (data.success){
						//更新成功，隐藏页面模板
						$("#editClueModal").modal("hide");
						//更新成功，取消全选框
						$("#qx").prop("checked",false);
						//刷新列表，维持用户选择每页展示数据条数以及维持在当前页面
						pageList($("#cluePage").bs_pagination('getOption', 'currentPage')
								,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
					}else {
						alert("修改线索失败！")
					}
				}
			})
		});

		//点击删除按钮
		$("#deleteBtn").click(function (){
			//获取选中的线索
			var $xz = $("input[name=xz]:checked");
			//判断选中的数量
			if ($xz.length==0){
				alert("请选择需要删除的线索！")
			}else{
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
						url : "workbench/clue/delete.do",
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
								pageList(1,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								//删除失败提示
								alert("删除市场活动失败！")
							}
						}
					})
				}
			}
		})
		
	});

	//刷新线索列表
	function pageList(pageNo,pageSize){
		//将隐藏域中的查询条件重新展示
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-company").val($.trim($("#hidden-company").val()));
		$("#search-phone").val($.trim($("#hidden-phone").val()));
		$("#search-mphone").val($.trim($("#hidden-mphone").val()));
		$("#search-source").val($.trim($("#hidden-source").val()));
		$("#search-state").val($.trim($("#hidden-state").val()));

		//调用ajax方法获取所有线索信息列表
		$.ajax({
			url : "workbench/clue/pageList.do",
			data : {
				"pageNo" : pageNo,		//页码
				"pageSize" : pageSize,		//每页展示数据条数
				"name" : $.trim($("#search-name").val()),		//查询条件：线索名称
				"owner" : $.trim($("#search-owner").val()),		//查询条件：线索所有者
				"company" : $.trim($("#search-company").val()),		// 查询条件，公司名称
				"phone" : $.trim($("#search-phone").val()),		// 查询条件，公司座机
				"source" : $.trim($("#search-source").val()),		// 查询条件，线索来源
				"mphone" : $.trim($("#search-mphone").val()),		// 查询条件，手机
				"state" : $.trim($("#search-state").val())		// 查询条件，线索状态
			},
			type : "get",
			dataType : "json",
			//返回根据条件查询出的所有线索信息，以及线索的总条数
			success : function (data){
				//定义一个字符串
				var html = "";
				//使用$.each循环取出线索数据（线索信息，以及线索的总条数）
				$.each(data.dataList,function (i,n){
					//将数据拼接
					html+='<tr>';
					html+='<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>';
					//在线索列表页面点击线索名称跳转到市场线索详细Servlet，携带当前线索Id作为参数
					html+='<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/clue/detail.do?id='+n.id+'\';">'+n.fullname+''+n.appellation+'</a></td>';
					html+='<td>'+n.company+'</td>';
					html+='<td>'+n.phone+'</td>';
					html+='<td>'+n.mphone+'</td>';
					html+='<td>'+n.source+'</td>';
					html+='<td>'+n.owner+'</td>';
					html+='<td>'+n.state+'</td>';
					html+='</tr>';
				})
				//将数据展示到前端
				$("#clueBody").html(html);
				//没有查询出数据提示语
				if ($("#clueBody").html()=="" || $("#clueBody").html()==null){
					html+='<tr class="active" align="center">';
					html+='<td colspan="10">没有数据哦！</td>';
					html+='</tr>';
				}
				// 将提示语输出
				$("#clueBody").html(html);
				//获取总页数（根据查询条件而改变）
				var totalPages = data.total%pageSize==0 ? data.total/pageSize:parseInt(data.total/pageSize)+1;
				//调用分页样式方法
				$("#cluePage").bs_pagination({
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

	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form id="createClueForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-Owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-Owner">
								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
									<c:forEach items="${appellation}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
									<option></option>
									<c:forEach items="${clueState}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
									<option></option>
									<c:forEach items="${source}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						

						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="create-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>
						
						<div style="position: relative;top: 20px;">
							<div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
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
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">
					<input type="hidden" id="edit-id">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-clueOwner">

								</select>
							</div>
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-call">
									<option></option>
									<c:forEach items="${appellation}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-surname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone">
							</div>
							<label for="edit-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-status">
									<option></option>
									<c:forEach items="${clueState}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
									<option></option>
									<c:forEach items="${source}" var="a">
									<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>


						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>

						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="edit-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
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
				<h3>线索列表</h3>
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
				      <div class="input-group-addon">公司</div>
				      <input class="form-control" type="text" id="search-company">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${source}" var="a">
							  <option value="${a.value}">${a.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control" type="text" id="search-mphone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control" id="search-state">
						  <option></option>
						  <c:forEach items="${clueState}" var="a">
							  <option value="${a.value}">${a.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
					<input type="hidden" id="hidden-name">
					<input type="hidden" id="hidden-company">
					<input type="hidden" id="hidden-phone">
					<input type="hidden" id="hidden-source">
					<input type="hidden" id="hidden-owner">
					<input type="hidden" id="hidden-mphone">
					<input type="hidden" id="hidden-state">
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="clueBody">
<%--						<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.do?id=0b89c35bfdfc49dea0f1adfb9a1217b7';">曾凯教授</a></td>
							<td>动力节点</td>
							<td>010-84846003</td>
							<td>12345678901</td>
							<td>广告</td>
							<td>zhangsan</td>
							<td>已联系</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/d.jsp';">李四先生</a></td>
                            <td>动力节点</td>
                            <td>010-84846003</td>
                            <td>12345678901</td>
                            <td>广告</td>
                            <td>zhangsan</td>
                            <td>已联系</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="cluePage"></div>
			</div>
<%--			<div style="height: 50px; position: relative;top: 60px;">
				<div>
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
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
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
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>