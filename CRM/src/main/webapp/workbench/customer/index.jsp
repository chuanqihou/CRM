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

<%--	当页面加载完毕时执行以下函数--%>
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
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-phone").val($.trim($("#search-phone").val()));
			$("#hidden-website").val($.trim($("#search-website").val()));
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

		//点击调用创建客户模态窗口
		$("#addBtn").click(function (){
			//加载用户信息下拉框
			$.ajax({
				url : "workbench/activity/getUserList.do",
				type : "get",
				dataType : "json",
				//返回所有用户信息
				success : function (data){
					//拼接字符串
					var html = "<option>---请选择---</option>"
					$.each(data,function (i,n){
						html+="<option value='"+n.id+"'>"+n.name+"</option>"
					})
					//将用户姓名添加至下拉框值
					$("#create-customerOwner").html(html);
					//从Session作用域中取出用户Id（使用EL表达式）
					var id = "${user.id}";
					//将用户Id添加至下拉框的value值
					$("#create-customerOwner").val(id);
					//打开模态窗口
					$("#createCustomerModal").modal("show");
				}
			})
		})

		//点击添加客户信息
		$("#saveBtn").click(function(){
			//ajax局部刷新添加操作
			$.ajax({
				url : "workbench/customer/save.do",
				data : {
					//请求参数
					"owner" : $.trim($("#create-customerOwner").val()),
					"name" : $.trim($("#create-customerName").val()),
					"phone" : $.trim($("#create-phone").val()),
					"website" : $.trim($("#create-website").val()),
					"address" : $.trim($("#create-address1").val()),
					"description" : $.trim($("#create-describe").val()),
					"nextContactTime" : $.trim($("#create-nextContactTime").val()),
					"contactSummary" : $.trim($("#create-contactSummary").val())
				},
				type: "post",
				dataType: "json",
				//获取添加状态信息
				success : function (data){
					if (data.success){
						//添加成功后清空添加表单
						$("#createCustomerForm")[0].reset();
						//隐藏创建模态窗口
						$("#createCustomerModal").modal("hide");
						//刷新列表，跳转到第一页，维持用户选择每页展示数据条数
						pageList(1,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
					}else {
						alert("添加客户失败！")
					}
				}
			})
		});


		//点击修改客户信息模板
		$("#editBtn").click(function (){
			//获取选中需要修改客户信息数量
			var $xz = $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要修改的客户信息！")
			}else if ($xz.length>=2){
				alert("只能选择一条记录进行修改！")
			}else {
				//获取选择需要更新的客户信息Id
				var id = $xz.val();
				$("#edit-id").val(id);
				$.ajax({
					url : "workbench/customer/getUserListAndCustomer.do",
					data : {
						//参数：需要更新的客户信息Id
						"id" : id
					},
					type : "get",
					dataType : "json",
					//返回根据Id查询出的客户信息以及所有用户信息
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
						$("#edit-customerOwner").html(html);
						$("#create-address").val(data.c.address);
						$("#create-nextContactTime2").val(data.c.nextContactTime);
						$("#create-contactSummary1").val(data.c.contactSummary);
						$("#edit-describe").val(data.c.description);
						$("#edit-phone").val(data.c.phone);
						$("#edit-website").val(data.c.website);
						$("#edit-customerName").val(data.c.name);
						//展示修改页面
						$("#editCustomerModal").modal("show");
					}
				})
			}
		});

		//点击更新客户按钮执行操作
		$("#updateBtn").click(function(){
			//ajax局部刷新更新操作 参数：需要更新的所有信息
			$.ajax({
				url : "workbench/customer/update.do",
				data : {
					//参数
					"id" : $.trim($("#edit-id").val()),
					"owner" : $.trim($("#edit-customerOwner").val()),
					"name" : $.trim($("#edit-customerName").val()),
					"phone" : $.trim($("#edit-phone").val()),
					"website" : $.trim($("#edit-website").val()),
					"contactSummary" : $.trim($("#create-contactSummary1").val()),
					"nextContactTime" : $.trim($("#create-nextContactTime2").val()),
					"address" : $.trim($("#create-address").val()),
					"description" : $.trim($("#edit-describe").val())
				},
				type: "post",
				dataType: "json",
				//返回更新状态信息
				success : function (data){
					if (data.success){
						//更新成功，隐藏页面模板
						$("#editCustomerModal").modal("hide");
						//更新成功，取消全选框
						$("#qx").prop("checked",false);
						//刷新列表，维持用户选择每页展示数据条数以及维持在当前页面
						pageList($("#customerPage").bs_pagination('getOption', 'currentPage')
								,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
					}else {
						alert("修改客户信息失败！")
					}
				}
			})
		});

		//点击删除客户信息
		$("#deleteBtn").click(function(){
			//获取选中需要删除客户信息数量
			var $xz = $("input[name=xz]:checked");
			//判断数量
			if ($xz.length==0){
				alert("请选择需要删除的客户！")
			}else {
				if (confirm("确定删除数据吗？")){
					//拼接参数（需要删除客户信息的Id）
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
						url : "workbench/customer/delete.do",
						//参数：需要删除的客户信息Id
						data : param,
						type : "post",
						dataType : "json",
						//返回删除状态信息
						success : function (data){
							if (data.success){
								//删除成功，取消全选框
								$("#qx").prop("checked",false);
								//刷新列表，跳转到第一页，维持用户选择每页展示数据条数
								pageList(1,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								//删除失败提示
								alert("删除客户信息失败！")
							}
						}
					})
				}
			}
		});


	});

	//根据条件获取客户信息列表并分页
	function pageList(pageNo,pageSize) {
		//将隐藏域中的查询条件重新展示
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-phone").val($.trim($("#hidden-phone").val()));
		$("#search-website").val($.trim($("#hidden-website").val()));
		//调用ajax方法根据条件获取所有客户信息列表
		$.ajax({
			url: "workbench/customer/pageList.do",
			data: {
				"pageNo": pageNo,		//页码
				"pageSize": pageSize,		//每页展示数据条数
				"name": $.trim($("#search-name").val()),		//查询条件：客户名称
				"owner": $.trim($("#search-owner").val()),		//查询条件：所有者
				"phone": $.trim($("#search-phone").val()),		//查询条件：客户座机
				"website": $.trim($("#search-website").val()),		//查询条件：客户网站
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
					html+='<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/customer/detail.do?id=' + n.id + '\';">' + n.name + '</a></td>';
					html+='<td>'+n.owner+'</td>';
					html+='<td>'+n.phone+'</td>';
					html+='<td>'+n.website+'</td>';
					html+='</tr>';
				})
				//将数据展示到前端
				$("#customerTbody").html(html);
				//没有查询出数据提示语
				if ($("#customerTbody").html() == "" || $("#customerTbody").html() == null) {
					html += '<tr class="active" align="center">';
					html += '<td colspan="5">没有数据哦！</td>';
					html += '</tr>';
				}
				// 将提示语输出
				$("#customerTbody").html(html);
				//获取总页数（根据查询条件而改变）
				var totalPages = data.total % pageSize == 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;
				//调用分页样式方法
				$("#customerPage").bs_pagination({
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
	<input type="hidden" id="hidden-phone"/>
	<input type="hidden" id="hidden-website"/>
	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createCustomerForm">
					
						<div class="form-group">
							<label for="create-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-customerOwner">
								</select>
							</div>
							<label for="create-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
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
                                <label for="create-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address1"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-default" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-customerOwner">
								</select>
							</div>
							<label for="edit-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" >
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" >
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
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
                                <label for="create-nextContactTime2" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="create-nextContactTime2">
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
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>客户列表</h3>
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
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control" type="text" id="search-website">
				    </div>
				  </div>
				  
				  <button id="searchBtn" type="button" class="btn btn-default" >查询</button>
				  
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
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody id="customerTbody">

					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="customerPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>