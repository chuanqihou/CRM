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
	
	$(function(){

		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})


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

		//当页面加载完毕，展示客户关联的市场活动
		showActivityList();

		//点击回车关联市场活动按钮后的模糊查询文本框
		$("#aname").keydown(function (event){
			//获得全选框Jquery对象
			$("#qx").click(function (){
				//所有选择框子对象选中条件：全选框选中
				$("input[name=xz]").prop("checked",this.checked)
			});

			//获得选择框子对象
			$("#activitySearchBody").on("click",$("input[name=xz]"),function () {
				//全选框选中条件：所有选择框子对象选中个数等于选择框子对象的总数
				$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
			});

			//判断按下的键
			if (event.keyCode==13){
				//发送ajax请求，获取市场活动信息（除已关联的）
				$.ajax({
					url : "workbench/clue/getActivityListByNameByClueId.do",
					data : {
						//参数：用户输入的查询数据、线索ID
						"aname" : $.trim($("#aname").val()),
						"clueId" : "${c.id}"
					},
					type : "get",
					dataType : "json",
					//返回市场活动信息
					success : function (data){
						//拼接字符串
						var html = "";
						$.each(data,function(i,n){
							html += '<tr>';
							html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
							html += '<td>'+n.name+'</td>';
							html += '<td>'+n.startDate+'</td>';
							html += '<td>'+n.endDate+'</td>';
							html += '<td>'+n.owner+'</td>';
							html += '</tr>';
						})
						//将数据展示在前端页面
						$("#activitySearchBody").html(html);
					}
				})
				//结束
				return false;
			}
		})

		//点击关联按钮
		$("#bundBtn").click(function(){
			//判断用户选中个数
			var $xz = $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要关联的市场活动")
			}else {
				//拼接参数：线索Id、选中的市场活动Id
				var param = "cid=${c.id}&"
				for (var i = 0;i<$xz.length;i++){
					param+="aid="+$($xz[i]).val();
					if (i<$xz.length-1){
						param+="&";
					}
				}
				//发送请求
				$.ajax({
					url : "workbench/clue/bund.do",
					data : param,
					type : "post",
					dataType : "json",
					//返回关联状态信息
					success : function (data){
						if (data.success){
							//成功后刷新关联的市场活动列表
							showActivityList()
							//重置
							$("#activitySearchBody").html("");
							//关闭模态窗口
							$("#bundModal").modal("hide");
						}else {
							alert("关联市场活动失败！")
						}
					}
				})
			}
		})

		//页面打开后自动加载线索备注信息
		showRemarkList()

		//新建和保存备注信息
		$("#saveRemarkBtn").click(function (){
			//ajax局部
			$.ajax({
				url : "workbench/clue/saveRemark.do",
				data : {
					//参数：备注内容、线索Id
					"noteContent" : $.trim($("#remark").val()),
					"clueId" : "${c.id}"
				},
				type : "post",
				dataType : "json",
				//返回状态信息以及备注信息，
				success : function (data){
					if (data.success){
						var html = "";
						//清空页面之前新建完成后的缓存备注信息
						$("#remark").val("");
						//将新建备注信息添加至页面中
						html+='<div id="'+data.cr.id+'" class="remarkDiv" style="height: 60px;">';
						html+='<img title="'+(data.cr.editFlag==0?data.cr.createBy:data.cr.editBy)+'" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
						html+='<div style="position: relative; top: -40px; left: 40px;" >';
						html+='<h5 id="e'+data.cr.id+'">'+data.cr.noteContent+'</h5>';
						html+='<font color="gray">线索（潜在客户）</font> <font color="gray">-</font> <b>'+ "${c.fullname}"+"${c.appellation}"+'-'+"${c.company}" +'</b> <small style="color: gray;" id="s'+data.cr.id+'"> '+(data.cr.editFlag==0?data.cr.createTime:data.cr.editTime)+' 由'+(data.cr.editFlag==0 ? data.cr.createBy+'创建':data.cr.editBy+'修改')+'</small>';
						html+='<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html+='<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.cr.id+'\',\''+data.cr.noteContent+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>';
						html+='&nbsp;&nbsp;&nbsp;&nbsp;';
						html+='<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.cr.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
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


		//点击更新备注按钮，更新线索备注信息
		$("#updateRemarkBtn").click(function(){
			//从隐藏域中获取备注Id
			var id = $("#remarkId").val();
			//ajax请求
			$.ajax({
				url : "workbench/clue/updateRemark.do",
				data : {
					//参数：备注Id、更改备注的内容
					"id" : id,
					"noteContent" : $.trim($("#noteContent").val())
				},
				type : "post",
				dataType : "json",
				success : function (data){
					//返回状态信息以及线索信息
					if (data.success){
						//将更新后的数据更新到页面
						$("#e"+id).html(data.cr.noteContent);
						$("#s"+id).html(data.cr.editTime+" 由 "+data.cr.editBy);
						//关闭更新模态窗口
						$("#editRemarkModal").modal("hide");
					}else {
						alert("更新备注失败！")
					}
				}
			})
		});


		//点击修改线索信息模板
		$("#editBtn").click(function (){

			//获取选择需要更新的线索Id
			var id = "${c.id}"
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
		});

		//点击更新线索按钮执行操作
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
						//刷新页面
						self.location.href="/crm/workbench/clue/detail.do?id="+"${c.id}"
					}else {
						alert("修改线索失败！")
					}
				}
			})
		});

		//点击删除按钮
		$("#deleteBtn").click(function (){
			if (confirm("确定删除数据吗？")){

				//发送删除的ajax请求
				$.ajax({
					url : "workbench/clue/delete.do",
					//参数：需要删除的线索Id
					data : {
						"id" : "${c.id}"
					},
					type : "post",
					dataType : "json",
					//返回删除状态信息
					success : function (data){
						if (data.success){
							//跳转到线索信息页面
							self.location.href="/crm/workbench/clue/index.jsp"
						}else {
							//删除失败提示
							alert("删除市场活动失败！")
						}
					}
				})
			}
		})


	});

	//删除备注信息
	function deleteRemark(id){
		if (confirm("确定删除备注信息吗？"))(
				$.ajax({
					url : "workbench/clue/deleteRemark.do",
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

	//根据请求作用域共享获取线索Id,根据线索Id查询该线索中关联的市场活动
	function showActivityList(){
		$.ajax({
			url : "workbench/clue/getActivityListByClueId.do",
			data : {
				"clueId" : "${c.id}"
			},
			type : "get",
			dataType : "json",
			//返回List<Activity>
			success : function (data){
				//拼接字符串
				var html = "";
				//循环取出数据
				$.each(data,function(i,n){
					html +='<tr>';
					html +='<td>'+n.name+'</td>';
					html +='<td>'+n.startDate+'</td>';
					html +='<td>'+n.endDate+'</td>';
					html +='<td>'+n.owner+'</td>';
					html +='<td><a href="javascript:void(0);" onclick="unbund(\''+n.id+'\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>';
					html +='</tr>';

				})
				//将数据传至页面
				$("#activityBody").html(html);
			}
		})
	}
	//取消线索与某一条市场活动信息的关联
	function unbund(id){
		if (confirm("确定解除关联？")) {
			$.ajax({
				url: "workbench/clue/unbund.do",
				data: {
					//参数：市场活动Id
					"id": id
				},
				type: "post",
				dataType: "json",
				//返回状态信息
				success: function (data) {
					if (data.success) {
						showActivityList()
					} else {
						alert("解除关系失败！")
					}
				}
			})
		}
	}

	//页面加载完成时自动加载线索备注信息
	function showRemarkList(){
		$.ajax({
			url : "workbench/clue/getRemarkListById.do",
			data : {
				//参数：线索Id
				"clueId" : "${c.id}"
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
					html+='<font color="gray">线索（潜在客户）</font> <font color="gray">-</font> <b>'+ "${c.fullname}"+"${c.appellation}"+'-'+"${c.company}" +'</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editBy==null?n.createTime:n.editTime)+' 由'+(n.editFlag==0 ? n.createBy+'创建':n.editBy+'修改')+'</small>';
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
	
</script>

</head>
<body>

	<!-- 修改线索备注的模态窗口 -->
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

	<!-- 关联市场活动的模态窗口 -->
	<div class="modal fade" id="bundModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="aname" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="qx"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">

						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="bundBtn">关联</button>
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

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${c.fullname}${c.appellation} <small>${c.company}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='/crm/workbench/clue/convert.jsp?id=${c.id}&fullname=${c.fullname}&appellation=${c.appellation}&company=${c.company}&owner=${c.owner}';"><span class="glyphicon glyphicon-retweet"></span> 转换</button>
			<button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.fullname}${c.appellation}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.owner}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.company}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.job}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">线索状态</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.state}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${c.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${c.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 100px;">
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
	<div id="remarkBody" style="position: relative; top: 40px; left: 40px;">
		<div class="page-header">
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
	
	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="activityBody">

					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" data-toggle="modal" data-target="#bundModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>