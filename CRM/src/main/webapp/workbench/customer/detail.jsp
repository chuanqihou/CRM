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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;

	//页面加载完成之后加载执行
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		//给备注加样式
		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})

		//点击修改客户信息模板
		$("#editBtn").click(function (){
			//获取选择需要更新的客户信息Id
			var id = "${c.id}";
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
						var id = "${c.id}";
						self.location.href="/crm/workbench/customer/detail.do?id="+id+"";
					}else {
						alert("修改客户信息失败！")
					}
				}
			})
		});

		//点击删除客户信息
		$("#deleteBtn").click(function(){
			if (confirm("确定删除数据吗？")){
				//拼接参数（需要删除客户信息的Id）
				var param = "id="+"${c.id}";
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
							self.location.href="/crm/workbench/customer/index.jsp";
						}else {
							//删除失败提示
							alert("删除客户信息失败！")
						}
					}
				})
			}
		});

		showRemarkList()

		//新建和保存备注信息
		$("#saveRemarkBtn").click(function (){
			//ajax局部
			$.ajax({
				url : "workbench/customer/saveRemark.do",
				data : {
					//参数：备注内容、客户Id
					"noteContent" : $.trim($("#remark").val()),
					"customerId" : "${c.id}"
				},
				type : "post",
				dataType : "json",
				//返回状态信息以及市场活动信息，
				success : function (data){
					if (data.success){
						//清空页面之前新建完成后的缓存备注信息
						$("#remark").val("");
						//将新建备注信息添加至页面中
						var html = "";
						html+='<div id="'+data.ar.id+'" class="remarkDiv" style="height: 60px;">';
						html+='<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
						html+='<div style="position: relative; top: -40px; left: 40px;" >';
						html+='<h5 id="e'+data.ar.id+'">'+data.ar.noteContent+'</h5>';
						html+='<font color="gray">客户</font> <font color="gray">-</font> <b>'+ "${c.name}" +'</b> <small style="color: gray; id="s'+data.ar.id+'"> '+(data.ar.editFlag==0?data.ar.createTime:data.ar.editTime)+' 由'+(data.ar.editFlag==0?data.ar.createBy+'创建':data.ar.editBy+'修改')+'</small>';
						html+='<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html+='<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.ar.id+'\',\''+data.ar.noteContent+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>';
						html+='&nbsp;&nbsp;&nbsp;&nbsp;';
						html+='<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.ar.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
						html+='</div>';
						html+='</div>';
						html+='</div>';
						//在id为remarkDiv之前添加
						$("#remarkDiv").before(html);
					}else {
						alert("备注信息添加失败！")
					}
				}
			})
		});

		//更新客户备注信息
		$("#updateRemarkBtn").click(function(){
			//从隐藏域中获取客户Id
			var id = $("#remarkId").val();
			//ajax请求
			$.ajax({
				url : "workbench/customer/updateRemark.do",
				data : {
					//参数：市场活动Id、更改备注的内容
					"id" : id,
					"noteContent" : $.trim($("#noteContent").val())
				},
				type : "post",
				dataType : "json",
				success : function (data){
					//返回状态信息以及客户信息
					if (data.success){
						//将更新后的数据更新到页面
						$("#e"+id).html(data.ar.noteContent);
						$("#s"+id).html(data.ar.editTime+" 由 "+data.ar.editBy);
						//关闭更新模态窗口
						$("#editRemarkModal").modal("hide");
					}else {
						alert("更新备注失败！")
					}
				}
			})
		});

		//点击调用创建模态窗口
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
                        showContacts();
					}else {
						alert("添加市场活动失败！")
					}
				}
			})
		});

		showTransaction();
		showContacts();

	});

	//页面加载完成时自动加载客户备注信息
	function showRemarkList(){
		$.ajax({
			url : "workbench/customer/getRemarkListById.do",
			data : {
				//参数：客户Id
				"customerId" : "${c.id}"
			},
			type : "get",
			dataType : "json",
			success : function (data){
				//拼接字符串
				var html = "";
				$.each(data,function (i,n){
					html+='<div id="'+n.id+'" class="remarkDiv" style="height: 60px;">';
					html+='<img title="'+(n.editFlag==0?n.createBy:n.editBy)+'" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html+='<div style="position: relative; top: -40px; left: 40px;" >';
					html+='<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
					html+='<font color="gray">客户</font> <font color="gray">-</font> <b>'+ "${c.name}" +'</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy+'创建':n.editBy+'修改')+'</small>';
					html+='<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html+='<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\',\''+n.noteContent+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>';
					html+='&nbsp;&nbsp;&nbsp;&nbsp;';
					html+='<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
					html+='</div>';
					html+='</div>';
					html+='</div>';
				})
				//将备注信息添加到Id为remarkDiv之前
				$("#remarkDiv").before(html);
			}
		})


	}

	//删除备注信息
	function deleteRemark(id){
		if (confirm("确定删除备注信息吗？"))(
				$.ajax({
					url : "workbench/customer/deleteRemark.do",
					data : {
						//参数：需要删除备注信息的Id
						"id" : id
					},
					type : "post",
					dataType : "json",
					//返回删除状态信息
					success : function (data){
						if (data.success){
							$("#"+id).remove();
						}else {
							alert("删除备注失败！")
						}
					}
				})
		)
	}

	//点击修改备注按钮
	function editRemark(id,noteContent){
		//将备注信息加载
		$("#noteContent").val(noteContent)
		//展示页面信息
		$("#editRemarkModal").modal("show")
		//将市场活动信息Id隐藏在隐藏域中
		$("#remarkId").val(id);
	}

	function showTransaction(){
		$.ajax({
			url : "workbench/customer/getTranByCustomerId.do",
			data : {
				"id" : "${c.id}"
			},
			type : "get",
			dataType : "json",
			success : function (data){
				var html = "";
				$.each(data,function(i,n){
					html += '<tr>';
					html += '<td><a href="workbench/transaction/detail.do?id='+n.id+'" style="text-decoration: none;">'+n.name+'</a></td>';
					html += '<td>'+n.money+'</td>';
					html += '<td>'+n.stage+'</td>';
					html += '<td>'+n.possibility+'</td>';
					html += '<td>'+n.expectedDate+'</td>';
					html += '<td>'+n.type+'</td>';
					html += '<td><a href="javascript:void(0);" onclick="deleteTransaction(\''+n.id+'\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				})
				$("#transactionBody").html(html);
			}
		})
	}

	function deleteTransaction(id){
		$("#removeTransactionModal").modal("show");
		$("#deleteTransactionBtn").click(function (){
			deleteTransactionBtn(id);
		})
	}

	function deleteTransactionBtn(id){
		$.ajax({
			url : "workbench/customer/deleteTransactionById.do",
			data : {
				"tranId" : id
			},
			type : "post",
			dataType : "json",
			success : function (data){
				if (data.success){
					$("#removeTransactionModal").modal("hide");
					showTransaction();
				}else {
					alert("删除交易失败！")
				}
			}
		})
	}

	function showContacts(){
		$.ajax({
			url : "workbench/customer/getContactsByCustomerId.do",
			data : {
				"id" : "${c.id}"
			},
			type : "get",
			dataType : "json",
			success : function (data){
				var html = "";
				$.each(data,function(i,n){
					html += '<tr>';
					html += '<td><a href="workbench/contacts/detail.do?id='+n.id+'" style="text-decoration: none;">'+n.fullname+'</a></td>';
					html += '<td>'+n.email+'</td>';
					html += '<td>'+n.mphone+'</td>';
					html += '<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				})
				$("#contactsTbody").html(html);
			}
		})
	}
	
</script>

</head>
<body>

	<!-- 删除联系人的模态窗口 -->
	<div class="modal fade" id="removeContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除联系人</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该联系人吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-danger" data-dismiss="modal">删除</button>
				</div>
			</div>
		</div>
	</div>

    <!-- 删除交易的模态窗口 -->
    <div class="modal fade" id="removeTransactionModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 30%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title">删除交易</h4>
                </div>
                <div class="modal-body">
                    <p>您确定要删除该交易吗？</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                    <button type="button" class="btn btn-danger" id="deleteTransactionBtn">删除</button>
                </div>
            </div>
        </div>
    </div>

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
								<input type="text" class="form-control" id="create-birth">
							</div>
						</div>

						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建" value="${c.name}">
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
								<input type="text" class="form-control" id="edit-customerName" value="动力节点">
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
									<input type="text" class="form-control" id="create-nextContactTime2">
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

	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${c.name} <small><a href="${c.website}" target="_blank">${c.website}</a></small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
                    ${c.contactSummary}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.nextContactTime}</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${c.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
                    ${c.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 10px; left: 40px;">
		<div class="page-header" >
			<h4>备注</h4>
		</div>

		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="transactionBody">
<%--						<tr>
							<td><a href="transaction/detail.jsp" style="text-decoration: none;">动力节点-交易01</a></td>
							<td>5,000</td>
							<td>谈判/复审</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>新业务</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeTransactionModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="workbench/transaction/save.do?customerName=${c.name}" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="contactsTbody">
<%--						<tr>
							<td><a href="contacts/detail.jsp" style="text-decoration: none;">李四</a></td>
							<td>lisi@bjpowernode.com</td>
							<td>13543645364</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="addBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>
		</div>
	</div>
	
	<div style="height: 200px;"></div>
</body>
</html>