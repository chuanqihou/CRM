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

<script type="text/javascript" src="jquery/bs_typeahead0/bootstrap3-typeahead.min.js"></script>

<script type="text/javascript">

	$(function(){
		//时间插件
		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});

		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		//点击页面加载客户列表
		pageList(1,5);

		//点击查询按钮
		$("#searchBtn").click(function (){
			//将查询条件隐藏在隐藏域中
			$("#hidden-fullname").val($.trim($("#search-fullname").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-birth").val($.trim($("#search-birth").val()));
			$("#hidden-source").val($.trim($("#search-source").val()));
			$("#hidden-customerName").val($.trim($("#search-customerName").val()));
			//根据条件刷新客户列表页面
			pageList(1,5);
		})

		//获得全选框Jquery对象
		$("#qx").click(function (){
			//所有选择框子对象选中条件：全选框选中
			$("input[name=xz]").prop("checked",this.checked)
		});

		//获得选择框子对象
		$("#customerTbody").on("click",$("input[name=xz]"),function () {
			//全选框选中条件：所有选择框子对象选中个数等于选择框子对象的总数
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		});

		//点击调用创建联系人模态窗口
		$("#addBtn").click(function (){
			//加载用户信息下拉框
			$.ajax({
				url : "workbench/activity/getUserList.do",
				type : "get",
				dataType : "json",
				//返回所有用户信息
				success : function (data){
					//拼接字符串
					var html = "<option></option>"
					$.each(data,function (i,n){
						html+="<option value='"+n.id+"'>"+n.name+"</option>"
					})
					//将用户姓名添加至下拉框值
					$("#create-marketContactsOwner").html(html);
					//从Session作用域中取出用户Id（使用EL表达式）
					var id = "${user.id}";
					//将用户Id添加至下拉框的value值
					$("#create-marketContactsOwner").val(id);
					//打开模态窗口
					$("#createContactsModal").modal("show");
				}
			})
		})

		//点击添加联系人信息
		$("#saveBtn").click(function(){
			//ajax局部刷新添加操作
			$.ajax({
				url : "workbench/contacts/save.do",
				data : {
					"owner" : $.trim($("#create-marketContactsOwner").val()),
					"source" : $.trim($("#create-clueSource").val()),
					"customerId" : $.trim($("#create-customerName").val()),
					"fullname" : $.trim($("#create-surname").val()),
					"appellation" : $.trim($("#create-call").val()),
					"email" : $.trim($("#create-email").val()),
					"mphone" : $.trim($("#create-mphone").val()),
					"job" : $.trim($("#create-job").val()),
					"birth" : $.trim($("#create-birth").val()),
					"description" : $.trim($("#create-describe").val()),
					"contactSummary" : $.trim($("#create-contactSummary1").val()),
					"nextContactTime" : $.trim($("#create-nextContactTime1").val()),
					"address" : $.trim($("#edit-address1").val())
				},
				type: "post",
				dataType: "json",
				//获取添加状态信息
				success : function (data){
					if (data.success){
						//添加成功后清空添加表单
						$("#contactsSaveForm")[0].reset();
						//隐藏创建模态窗口
						$("#createContactsModal").modal("hide");
						//刷新列表，跳转到第一页，维持用户选择每页展示数据条数
						pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
					}else {
						alert("添加联系人信息失败！")
					}
				}
			})
		});

		//【创建】根据模糊查询自动填充客户名称
		$("#create-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/contacts/getContactsName.do",
						{ "name" : query },
						function (data) {
							//alert(data);
							process(data);
						},
						"json"
				);
			},
			//延迟
			delay: 1500
		});

		//更新联系人信息（获取需要更新联系人信息的数据）
		$("#updateContacts").click(function(){
			//获取选中需要修改联系人信息数量
			var $xz = $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要修改的联系人信息！")
			}else if ($xz.length>=2){
				alert("只能选择一条记录进行修改！")
			}else {
				//获取选择需要更新的联系人Id
				var id = $xz.val();
				$("#edit-id").val(id);
				$.ajax({
					url : "workbench/contacts/getUserListAndContacts.do",
					data : {
						//参数：需要更新的联系人Id
						"id" : id
					},
					type : "get",
					dataType : "json",
					//返回根据Id查询出的联系人信息以及所有用户信息
					success : function (data){
						//拼接字符串
						var html = "";
						$.each(data.uList,function (i,n){
							//如果用户信息表中的用户Id等于选中的市场活动信息表中所有者Id则选中
							if(data.c.owner==n.id){
								html+="<option selected value='"+n.id+"'>"+n.name+"</option>";
							}else {
								html+="<option value='"+n.id+"'>"+n.name+"</option>";
							}
						})
						//将该客户中的信息加载到页面中
						$("#edit-contactsOwner").html(html);
						$("#edit-clueSource1").val(data.c.source);
						$("#edit-surname").val(data.c.fullname);
						$("#edit-call").val(data.c.appellation);
						$("#edit-job").val(data.c.job);
						$("#edit-mphone").val(data.c.mphone);
						$("#edit-email").val(data.c.email);
						$("#edit-birth").val(data.c.birth);
						$("#edit-describe").val(data.c.description);
						$("#create-contactSummary").val(data.c.contactSummary);
						$("#create-nextContactTime").val(data.c.nextContactTime);
						$("#edit-address2").val(data.c.address);
						$("#edit-customerName").val(data.c.customerId);
						//展示修改页面
						$("#editContactsModal").modal("show");
					}
				})
			}
		})

		//【修改】根据模糊查询自动填充客户名称
		$("#edit-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/contacts/getContactsName.do",
						{ "name" : query },
						function (data) {
							//alert(data);
							process(data);
						},
						"json"
				);
			},
			delay: 1500
		});

		//点击更新按钮
		$("#updateBtn").click(function(){
			var id = $("#edit-id").val();
			//ajax局部刷新添加操作
			$.ajax({
				url : "workbench/contacts/update.do",
				data : {
					"id" : id,
					"owner" : $.trim($("#edit-contactsOwner").val()),
					"source" : $.trim($("#edit-clueSource1").val()),
					"customerName" : $.trim($("#edit-customerName").val()),
					"fullname" : $.trim($("#edit-surname").val()),
					"appellation" : $.trim($("#edit-call").val()),
					"email" : $.trim($("#edit-email").val()),
					"mphone" : $.trim($("#edit-mphone").val()),
					"job" : $.trim($("#edit-job").val()),
					"birth" : $.trim($("#edit-birth").val()),
					"description" : $.trim($("#edit-describe").val()),
					"contactSummary" : $.trim($("#create-contactSummary").val()),
					"nextContactTime" : $.trim($("#create-nextContactTime").val()),
					"address" : $.trim($("#edit-address2").val())
				},
				type: "post",
				dataType: "json",
				//获取添加状态信息
				success : function (data){
					if (data.success){
						//添加成功后清空添加表单
						$("#contactsSaveForm")[0].reset();
						//隐藏创建模态窗口
						$("#editContactsModal").modal("hide");
						//刷新列表，跳转到第一页，维持用户选择每页展示数据条数
						pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
					}else {
						alert("修改联系人信息失败！")
					}
				}
			})
		})

		//删除联系人信息
		$("#deleteBtn").click(function(){
			//获取选中需要修改市场活动信息数量
			var $xz = $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要删除的联系人！")
			}else {
				if (confirm("确定删除数据吗？")){
					//拼接参数（需要删除的联系人Id）
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
						url : "workbench/contacts/delete.do",
						//参数：需要删除的联系人Id
						data : param,
						type : "post",
						dataType : "json",
						//返回删除状态信息
						success : function (data){
							if (data.success){
								//删除成功，取消全选框
								$("#qx").prop("checked",false);
								//刷新列表，跳转到第一页，维持用户选择每页展示数据条数
								pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								//删除失败提示
								alert("删除联系人信息失败！")
							}
						}
					})
				}
			}
		})

	});

	//根据条件获取联系人信息列表并分页
	function pageList(pageNo,pageSize) {
		//将隐藏域中的查询条件重新展示
		 $("#search-fullname").val($.trim($("#hidden-fullname").val()));
		 $("#search-owner").val($.trim($("#hidden-owner").val()));
		 $("#search-customerName").val($.trim($("#hidden-customerName").val()));
		 $("#search-birth").val($.trim($("#hidden-birth").val()));
		//调用ajax方法根据条件获取所有客户信息列表
		$.ajax({
			url: "workbench/contacts/pageList.do",
			data: {
				"pageNo": pageNo,		//页码
				"pageSize": pageSize,		//每页展示数据条数
				"fullname": $.trim($("#search-fullname").val()),		//查询条件：联系人姓名
				"owner": $.trim($("#search-owner").val()),		//查询条件：所有者
				"customerName": $.trim($("#search-customerName").val()),		//查询条件：客户名称
				"birth": $.trim($("#search-birth").val()),				//查询条件：联系人生日
				"source": $.trim($("#search-source").val()),		//查询条件：来源
			},
			type: "get",
			dataType: "json",
			//返回根据条件查询出的所有联系人信息，以及联系人总数
			success: function (data) {
				//定义一个字符串
				var html = "";
				//使用$.each循环取出联系人数据
				$.each(data.dataList, function (i, n) {
					html+='<tr>';
					html+='<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
					html+='<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/contacts/detail.do?id=' + n.id + '\';">' + n.fullname + '</a></td>';
					html+='<td>'+n.customerId+'</td>';
					html+='<td>'+n.owner+'</td>';
					html+='<td>'+n.source+'</td>';
					html+='<td>'+n.birth+'</td>';
					html+='</tr>';
				})
				//将数据展示到前端
				$("#contactsTbody").html(html);
				//没有查询出数据提示语
				if ($("#contactsTbody").html() == "" || $("#contactsTbody").html() == null) {
					html += '<tr class="active" align="center">';
					html += '<td colspan="7">没有数据哦！</td>';
					html += '</tr>';
				}
				// 将提示语输出
				$("#contactsTbody").html(html);
				//获取总页数（根据查询条件而改变）
				var totalPages = data.total % pageSize == 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;
				//调用分页样式方法
				$("#contactsPage").bs_pagination({
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
	<input type="hidden" id="hidden-fullname"/>
	<input type="hidden" id="hidden-owner"/>
	<input type="hidden" id="hidden-customerName"/>
	<input type="hidden" id="hidden-birth"/>
	<input type="hidden" id="hidden-source"/>
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="contactsSaveForm">
					
						<div class="form-group">
							<label for="create-marketContactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketContactsOwner">

								</select>
							</div>
							<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-clueSource">
								  <option></option>
									<c:forEach items="${source}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-surname">
							</div>
							<label for="create-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-call">
								  <option></option>
									<c:forEach items="${appellation}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-birth">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary1"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime1" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="create-nextContactTime1">
								</div>
							</div>
						</div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address1"></textarea>
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
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-contactsOwner">

								</select>
							</div>
							<label for="edit-clueSource1" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-clueSource1">
								  <option></option>
									<c:forEach items="${source}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-surname" >
							</div>
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-call">
								  <option></option>
									<c:forEach items="${appellation}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" >
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" >
							</div>
							<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-birth">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe">&nbsp;</textarea>
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
                                <label for="edit-address2" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address2">


									</textarea>
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
				<h3>联系人列表</h3>
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
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="search-fullname">
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
				      <div class="input-group-addon">生日</div>
				      <input class="form-control time" type="text" id="search-birth">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="updateContacts"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
							<td>生日</td>
						</tr>
					</thead>
					<tbody id="contactsTbody">

					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 10px;" id="contactsPage">

			</div>
			
		</div>
		
	</div>
</body>
</html>