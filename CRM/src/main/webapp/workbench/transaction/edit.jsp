<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
	Map<String,String> map = (Map<String,String>)application.getAttribute("pmap");
	Set<String> keys = map.keySet();
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_typeahead0/bootstrap3-typeahead.min.js"></script>

	<script type="text/javascript">
		$(function (){
			var json = {
				<%
                for (String key : keys) {
                    String value = map.get(key);
                %>

				"<%=key%>" : "<%=value%>",

				<%
                }
                %>
			}

			$("#edit-transactionStage").change(function(){
				var stage = $("#edit-transactionStage").val();
				var possibility = json[stage];
				$("#edit-possibility").val(possibility+"%")
			})

			$("#edit-accountName").typeahead({
				source: function (query, process) {
					$.get(
							"workbench/transaction/getCustomerName.do",
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

			$("#openSearchActivityModalBtn").click(function(){
				//??????????????????
				$("#searchActivityModal").modal("show")
				//????????????????????????
				$("#aname").keydown(function (event){
					//????????????
					if (event.keyCode==13){
						//??????ajax???????????????????????????????????????
						$.ajax({
							url : "workbench/clue/getActivityListByName.do",
							data : {
								//????????????????????????
								"aname" : $.trim($("#aname").val()),
							},
							type : "get",
							dataType : "json",
							//???????????????????????????
							success : function (data){
								//???????????????
								var html = "";
								$.each(data,function(i,n){
									html += '<tr>';
									html += '<td><input type="radio" name="xz" value="'+n.id+'"/></td>';
									html += '<td id="'+n.id+'">'+n.name+'</td>';
									html += '<td>'+n.startDate+'</td>';
									html += '<td>'+n.endDate+'</td>';
									html += '<td>'+n.owner+'</td>';
									html += '</tr>';
								})
								//?????????????????????
								$("#activitySearchBody").html(html);
							}
						})
						//???????????????
						return false;
					}
				})
			})

			//???????????????????????????
			$("#submitActivityBtn").click(function(){
				//?????????????????????
				var $xz = $("input[name=xz]:checked")
				//???????????????????????????Id
				var id = $xz.val();
				//??????????????????????????????
				var name = $("#"+id).html();
				//?????????????????????????????????
				$("#edit-activitySrc").val(name);
				//???????????????Id??????????????????
				$("#activityId").val(id);
				//??????????????????
				$("#searchActivityModal").modal("hide")

			})

			$("#openSearchContactsModalBtn").click(function(){
				//??????????????????
				$("#findContacts").modal("show")
				//????????????????????????
				$("#contactsName").keydown(function (event){
					//????????????
					if (event.keyCode==13){
						//??????ajax???????????????????????????????????????
						$.ajax({
							url : "workbench/transaction/getContactsListByName.do",
							data : {
								//????????????????????????
								"contactsName" : $.trim($("#contactsName").val()),
							},
							type : "get",
							dataType : "json",
							//???????????????????????????
							success : function (data){
								//???????????????
								var html = "";
								$.each(data,function(i,n){
									html += '<tr>';
									html += '<td><input type="radio" name="xz" value="'+n.id+'"/></td>';
									html += '<td id="'+n.id+'">'+n.fullname+'</td>';
									html += '<td>'+n.email+'</td>';
									html += '<td>'+n.mphone+'</td>';
									html += '</tr>';
								})
								//?????????????????????
								$("#contactsSearchBody").html(html);
							}
						})
						//???????????????
						return false;
					}
				})
			})

			//???????????????????????????
			$("#submitContactsBtn").click(function(){
				//?????????????????????
				var $xz = $("input[name=xz]:checked")
				//???????????????????????????Id
				var id = $xz.val();
				//??????????????????????????????
				var name = $("#"+id).html();
				//?????????????????????????????????
				$("#edit-contactsName").val(name);
				//???????????????Id??????????????????
				$("#contactsId").val(id);
				//??????????????????
				$("#findContacts").modal("hide")

			})

			$("#updateBtn").click(function(){
				$("#tranForm").submit();
			})

		})
	</script>

</head>
<body>

	<!-- ?????????????????? -->
	<div class="modal fade" id="searchActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">??</span>
					</button>
					<h4 class="modal-title">??????????????????</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
							<div class="form-group has-feedback">
								<input id="aname" type="text" class="form-control" style="width: 300px;" placeholder="????????????????????????????????????????????????">
								<span class="glyphicon glyphicon-search form-control-feedback"></span>
							</div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
						<tr style="color: #B3B3B3;">
							<td></td>
							<td>??????</td>
							<td>????????????</td>
							<td>????????????</td>
							<td>?????????</td>
						</tr>
						</thead>
						<tbody id="activitySearchBody">
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">??????</button>
					<button type="button" class="btn btn-primary" id="submitActivityBtn">??????</button>
				</div>
			</div>
		</div>
	</div>

	<!-- ??????????????? -->
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">??</span>
					</button>
					<h4 class="modal-title">???????????????</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
							<div class="form-group has-feedback">
								<input type="text" id="contactsName" class="form-control" style="width: 300px;" placeholder="?????????????????????????????????????????????">
								<span class="glyphicon glyphicon-search form-control-feedback"></span>
							</div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
						<tr style="color: #B3B3B3;">
							<td></td>
							<td>??????</td>
							<td>??????</td>
							<td>??????</td>
						</tr>
						</thead>
						<tbody id="contactsSearchBody">
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">??????</button>
					<button type="button" class="btn btn-primary" id="submitContactsBtn">??????</button>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>????????????</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="updateBtn">??????</button>
			<button type="button" class="btn btn-default">??????</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" id="tranForm" action="workbench/transaction/update.do" method="post" style="position: relative; top: -30px;">
		<input type="hidden" id="id" name="id" value="${t.id}">
		<div class="form-group">
			<label for="edit-transactionOwner" class="col-sm-2 control-label">?????????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-transactionOwner" name="owner">
					<c:forEach items="${userList}" var="u">
						<option value="${u.id}" ${t.owner eq u.id ? "selected":""}>${u.name}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-amountOfMoney" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-amountOfMoney" name="money" value="${t.money}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-transactionName" class="col-sm-2 control-label">??????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-transactionName" name="name" value="${t.name}">
			</div>
			<label for="edit-expectedClosingDate" class="col-sm-2 control-label">??????????????????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-expectedClosingDate" name="expectedDate" value="${t.expectedDate}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-accountName" class="col-sm-2 control-label">????????????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-accountName" name="customerName" value="${t.customerId}" placeholder="???????????????????????????????????????????????????">
			</div>
			<label for="edit-transactionStage" class="col-sm-2 control-label">??????<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="edit-transactionStage" name="stage">
			  	<option></option>
				  <c:forEach items="${stage}" var="a">
					  <option value="${a.value}" ${a.text eq t.stage ? "selected":""} >${a.text}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-transactionType" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-transactionType" name="type">
				  <option></option>
					<c:forEach items="${transactionType}" var="a">
						<option value="${a.value}" ${a.text eq t.type ? "selected":""} >${a.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-possibility" class="col-sm-2 control-label">?????????</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-possibility" value="${t.possibility}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-clueSource" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-clueSource" name="source">
				  <option></option>
					<c:forEach items="${source}" var="a">
						<option value="${a.value}" ${a.text eq t.source ? "selected":""} >${a.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-activitySrc" class="col-sm-2 control-label">???????????????&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchActivityModalBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-activitySrc" value="${t.activityId}" readonly>
				<input type="hidden" id="activityId" name="activityId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-contactsName" class="col-sm-2 control-label">???????????????&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearchContactsModalBtn"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-contactsName" value="${t.contactsId}" readonly >
				<input type="hidden" id="contactsId" name="contactsId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">??????</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe">&nbsp;${t.description}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">????????????</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" name="description" id="create-contactSummary">&nbsp;${t.contactSummary}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">??????????????????</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-nextContactTime" name="nextContactTime" value="${t.nextContactTime}" >
			</div>
		</div>
		
	</form>
</body>
</html>