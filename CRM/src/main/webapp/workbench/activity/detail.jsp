<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        $("#remarkBody").on("mouseover",".remarkDiv",function(){
            $(this).children("div").children("div").show();
        })
        $("#remarkBody").on("mouseout",".remarkDiv",function(){
            $(this).children("div").children("div").hide();
        })

        //加载市场活动备注信息
        showRemarkList();

        //新建和保存备注信息
        $("#saveRemarkBtn").click(function (){
            //ajax局部
            $.ajax({
                url : "workbench/activity/saveRemark.do",
                data : {
                    //参数：备注内容、市场活动Id
                    "noteContent" : $.trim($("#remark").val()),
                    "activityId" : "${a.id}"
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
                        html+='<h5>'+data.ar.noteContent+'</h5>';
                        html+='<font color="gray">市场活动</font> <font color="gray">-</font> <b>'+ "${a.name}" +'</b> <small style="color: gray;"> '+(data.ar.editFlag==0?data.ar.createTime:data.ar.editTime)+' 由'+(data.ar.editFlag==0?data.ar.createBy+'创建':data.ar.editBy+'修改')+'</small>';
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

        //更新市场活动备注信息
        $("#updateRemarkBtn").click(function(){
            //从隐藏域中获取市场活动Id
            var id = $("#remarkId").val();
            //ajax请求
            $.ajax({
                url : "workbench/activity/updateRemark.do",
                data : {
                    //参数：市场活动Id、更改备注的内容
                    "id" : id,
                    "noteContent" : $.trim($("#noteContent").val())
                },
                type : "post",
                dataType : "json",
                success : function (data){
                    //返回状态信息以及市场活动信息
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

        //删除市场活动信息
        $("#deleteBtn").click(function(){
            if (confirm("确定删除数据吗？")){
                var param = "${a.id}";
                //发送删除的ajax请求
                $.ajax({
                    url : "workbench/activity/delete.do",
                    data : {
                        //参数：需要删除的市场活动Id
                        id : param
                    },
                    type : "post",
                    dataType : "json",
                    success : function (data){
                        //返回状态信息
                        if (data.success){
                            //跳转到市场活动信息页面
                            self.location.href="/crm/workbench/activity/index.jsp"
                        }else {
                            //删除失败提示
                            alert("删除市场活动失败！")
                        }
                    }
                })
            }
        });

        //点击修改市场活动信息模板
        $("#editBtn").click(function (){
                //获取选择需要更新的市场活动Id
                var id = "${a.id}";
                $.ajax({
                    url : "workbench/activity/getUserListAndActivity.do",
                    data : {
                        id
                    },
                    type : "get",
                    dataType : "json",
                    success : function (data){
                        //拼接字符串
                        var html = "";
                        $.each(data.uList,function (i,n){
                            //如果用户信息表中的用户Id等于选中的市场活动信息表中所有者Id则选中
                            if(data.a.owner==n.id){
                                html+="<option selected value='"+n.id+"'>"+n.name+"</option>";
                            }else {
                                html+="<option value='"+n.id+"'>"+n.name+"</option>";
                            }
                        })
                        //将该市场活动中的信息加载到页面中
                        $("#edit-marketActivityOwner").html(html);
                        $("#edit-describe").val(data.a.description);
                        $("#edit-cost").val(data.a.cost);
                        $("#edit-endTime").val(data.a.endDate);
                        $("#edit-startTime").val(data.a.startDate);
                        $("#edit-marketActivityName").val(data.a.name);
                        $("#edit-id").val(data.a.id);
                        //展示修改页面
                        $("#editActivityModal").modal("show");
                    }
                })
        });

        //点击更新市场活动按钮执行操作
        $("#updateBtn").click(function(){
            //ajax局部刷新更新操作 参数：需要更新的所有信息
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
                        //更新成功，隐藏页面模板
                        $("#editActivityModal").modal("hide");
                        //刷新页面
                        self.location.href="/crm/workbench/activity/detail.do?id="+"${a.id}"
                    }else {
                        alert("修改市场活动失败！")
                    }
                }
            })
        });

    });

	//页面加载完成时自动加载市场活动备注信息
	function showRemarkList(){
		$.ajax({
			url : "workbench/activity/getRemarkListById.do",
			data : {
			    //参数：市场活动Id
				"activityId" : "${a.id}"
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
					html+='<font color="gray">市场活动</font> <font color="gray">-</font> <b>'+ "${a.name}" +'</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy+'创建':n.editBy+'修改')+'</small>';
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
                url : "workbench/activity/deleteRemark.do",
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
	
</script>

</head>
<body>
	
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

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${a.name} <small>${a.startDate} ~ ${a.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button id="deleteBtn" type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${a.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${a.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${a.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${a.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${a.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${a.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${a.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 30px; left: 40px;">
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
	<div style="height: 200px;"></div>
</body>
</html>