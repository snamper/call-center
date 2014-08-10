<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="../../include/header.jsp" %>
<title>我的外拨</title>
<script src="<c:url value="/static/ligerUI/ligerUI/js/plugins/ligerLayout.js"/>" type="text/javascript"></script>
<style type="text/css">
    .cell-label {
        width: 80px;
    }

    #tabcontainer .l-tab-links {
        border-top: 1px solid #D0D0D0;
        border-left: 1px solid #D0D0D0;
        border-right: 1px solid #D0D0D0;
    }

    .projectgrid .l-selected .l-grid-row-cell, .projectgrid .l-selected {
        background: none;
    }

    .access-icon {
        background: url('<c:url value="/static/ligerUI/ligerUI/skins/Aqua/images/controls/checkbox.gif"/>') 0px 0px;
        height: 13px;
        line-height: 13px;
        width: 13px;
        margin: 4px 20px;
        display: block;
        cursor: pointer;
    }

    .access-icon-selected {
        background-position: 0px -13px;
    }

    .l-panel td.l-grid-row-cell-editing {
        padding-bottom: 2px;
        padding-top: 2px;
    }
</style>
</head>
<body>
<div id="layout" style="margin:2px; margin-right:3px;">
    <div position="center" id="mainmenu" title="我的任务">
            <div id="tasklist" style="margin:2px auto;"></div>
    </div>
    <div position="bottom" title="客户相关信息">
        <div id="tabcontainer" style="margin:2px;">
            <div title="客户信息" tabid="custInfo">
                <form:form id="customerInfo" name="customerInfo" method="post"></form:form>
            </div>
            <div title="合同信息" tabid="contractInfo">
                <div id="contractInfo" style="margin:2px auto;"></div>
            </div>
            <div title="拨打历史" tabid="dialHis">
                <div id="dialHistory" style="margin:2px auto;"></div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
	//覆盖本页面grid的loading效果
	LG.overrideGridLoading();
	
	var genderData = <sys:dictList type = "1"/>;
	var resultTypeData = <sys:dictList type = "27"/>;
	var statusData = <sys:dictList type = "8"/>;
	var finishStatus = <sys:dictList type = "21" nullable="true"/>;
	var cardLevelData = <sys:dictList type = "13"/>;
	var callTypeData = <sys:dictList type = "28"/>;

	var layout = $("#layout").ligerLayout({
    bottomHeight:$(window).height()*0.50,
    heightDiff:-6,
    onEndResize:updateGridHeight,
    onHeightChanged:updateGridHeight
	});
	
	var bottomHeader = $(".l-layout-bottom > .l-layout-header:first");

	var tab = $("#tabcontainer").ligerTab();

	var taskListGrid;

	taskListGrid = $("#tasklist").ligerGrid({
    columns:[
        {display:'客户姓名', name:'fldCustomerName',width:300},
           {display:'性别', name:'fldGender',width:60,
        	   render:function(item) {
   		 			   return renderLabel(genderData,item.fldGender);
             }
         	 },
           {display:'手机', name:'fldMobile',width:300,
         	 		render:function(item){
         	 			if(null == item.fldMobile  || "" == item.fldMobile)
         	 				return "";
         	 			return '<span>'+item.fldMobile+'&nbsp;&nbsp;<a href="javascript:void(0);" title="拨打" style="background:url(/static/ligerUI/icons/silkicons/phone.png) no-repeat;text-decoration:none;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></span>';
         	 		}
           },
           {display:'固定电话', name:'fldPhone',width:300,
        	   render:function(item){
        		   if(null == item.fldPhone  || "" == item.fldPhone)
    	 				   return "";
		    	 	   return '<span>'+item.fldPhone+'&nbsp;&nbsp;<a href="javascript:void(0);" title="拨打" style="background:url(/static/ligerUI/icons/silkicons/telephone.png) no-repeat;text-decoration:none;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></span>';
		    	 	 }
           },
           {display:'任务时间', name:'fldTaskDate'}
    ], 
    width:'99%', height:190, rowHeight:20, fixedCellHeight:true,
    frozen:false, checkbox:false, rownumbers:true,
    url:'<c:url value="/telephone/dial/listTask"/>'
	});
	
	var customeForm,taskId;
	taskListGrid.bind('SelectRow', function (rowdata) {
	    var customerName = rowdata.fldCustomerName;
	    var mobile = rowdata.fldMobile;
	    var phone = rowdata.fldPhone;
	    taskId = rowdata.fldId;
	    
	    LG.ajax({
            url:'<c:url value="/telephone/dial/findCustomer"/>',
            data:{customerName:customerName,mobile:mobile,phone:phone},
            dataType:'json', type:'post',
            success:function (data) {
              if(null != data && null != data[0]){
            	  var customer = data[0];
            	  
            	  var origCustomer = null;
            	  if(null != data[1]) {
            		  origCustomer = data[1];
            	  }
            	  
            	  customeForm = $("#customerInfo").ligerForm({
							    labelWidth: 80,
							    inputWidth: 150,
							    space: 30,
							    heightDiff:-100,
							    fields: [
											{display: "ID",name: "fldId", newline: true, type: "hidden", attr:{value:customer.fldId}},
							        {display: "客户名称", name: "fldCustomerName", attr:{value:customer.fldCustomerName,readonly: "readonly"}, newline: true, type: "text", cssClass: "field"},
							        {display: "性别", name: "fldGender", attr:{value:customer.fldGender}, newline: false, type: "select", cssClass: "field",
							        	options:{
						                    valueField: 'value',
						                    textField: 'text',
						                    isMultiSelect:false,
						                    data:genderData,
						                    initValue: customer.fldGender,
						                    valueFieldID:"fldGender"
						            }
							        },
							        {display: "出生日期", name: "fldBirthday", attr:{value:null!=origCustomer&&null!=origCustomer.fldBirthday?origCustomer.fldBirthday:""}, newline: false, type: "text", cssClass: "field"},
							        {display: "手机", name: "fldMobile", attr:{value:customer.fldMobile}, newline: true, type: "text", cssClass: "field"},
							        {display: "电话号码", name: "fldPhone", attr:{value:customer.fldPhone}, newline: false, type: "text", cssClass: "field"},
							        {display: "身份证号", name: "fldIdentityNo", attr:{value:null!=origCustomer&&null!=origCustomer.fldIdentityNo?origCustomer.fldIdentityNo:""}, newline: false, type: "text", cssClass: "field"},
							        {display: "地址", name: "fldAddress", attr:{value:null!=origCustomer&&null!=origCustomer.fldComment?origCustomer.fldComment:(customer.fldAddress!=null?customer.fldAddress:"")}, newline: true, type: "text", cssClass: "field"},
							        {display: "邮箱", name: "fldEmail", attr:{value:null!=origCustomer&&null!=origCustomer.fldEmail?origCustomer.fldEmail:""}, newline: false, type: "text", cssClass: "field"},
							        {display: "任务结果", name: "fldResultType", newline: false, type: "select", cssClass: "field",validate: {required: true},
							        	options:{
						                    valueField: 'value',
						                    textField: 'text',
						                    isMultiSelect:false,
						                    data:resultTypeData,
						                    valueFieldID:"fldResultType"
						            }
							        },
							    ],
							    toJSON: JSON2.stringify
								});
            	  
           	  if(null != data[1]) {
           		  origCustomer = data[1];
           			var where = '{"op":"and","rules":[{"op":"like","field":"fldCustomerId","value":"'+origCustomer.fldId+'","type":"string"},{"op":"equal","field":"fldStatus","value":"0","type":"int"}]}';
						    $("#contractInfo").ligerGrid({
						        checkbox: false,
						        rownumbers: true,
						        delayLoad: false,
						        columnWidth: 180,
						        columns: [
						            {display: "合同编号", name: "fldId"},
						            {display: "签订日期", name: "fldSignDate"},
						            {display: "客户姓名", name: "customerName"},
						            {display: "产品全称", name: "productFullName"},
						            {display: "产品实际天数", name: "productClearDays"},
						            {display: "成立日期", name: "establishDate"},
						            {display: "到期日期", name: "dueDate"},
						            {display: "打款日期", name: "fldMoneyDate"},
						            {display: "年化收益率", name: "fldAnnualizedRate",
						                render: function (item) {
						                    return item.fldAnnualizedRate + "%";
						                }},
						            {display: "购买金额(万元)", name: "fldPurchaseMoney"},
						            {display: "预期收益(元)", name: "fldAnnualizedMoney",
						                render: function (item) {
						                    return formatCurrency(item.fldAnnualizedMoney);
						                }},
						            {display: "合同状态", name: "fldStatus",
						                render: function (item) {
						                    return renderLabel(statusData, item.fldStatus);
						                }
						            },
						            {display: "是否已到期", name: "fldFinishStatus",
						                render: function (item) {
						                    return renderLabel(finishStatus, item.fldFinishStatus);
						                }},
						            {display: "理财经理", name: "financialUserName"},
						            {display: "客服经理", name: "serviceUserName"},
						            {display: "客户经理", name: "customerUserName"},
						            {display: "银行卡号", name: "fldBankNo"},
						            {display: "瑞得卡号", name: "fldCardNo"},
						            {display: "瑞得卡等级", name: "fldCardLevel",
						                render: function (item) {
						                    return renderLabel(cardLevelData, item.fldCardLevel);
						                }
						            },
						            {display: "操作人", name: "operateUserName"},
						            {display: "操作时间", name: "fldOperateDate"}
						        ], dataAction: 'server', pageSize: 50, toolbar: null, url: '<c:url value="/customer/contract/list?where='+where+'"/>', sortName: 'fldOperateDate', sortOrder: 'desc',
						        width: '98%', height: '32%', toJSON: JSON2.stringify
						    });
           	  } else {
           			var where = '{"op":"and","rules":[{"op":"like","field":"fldCustomerId","value":"-1","type":"string"},{"op":"equal","field":"fldStatus","value":"0","type":"int"}]}';
						    $("#contractInfo").ligerGrid({
						        checkbox: false,
						        rownumbers: true,
						        delayLoad: false,
						        columnWidth: 180,
						        columns: [
						            {display: "合同编号", name: "fldId"},
						            {display: "签订日期", name: "fldSignDate"},
						            {display: "客户姓名", name: "customerName"},
						            {display: "产品全称", name: "productFullName"},
						            {display: "产品实际天数", name: "productClearDays"},
						            {display: "成立日期", name: "establishDate"},
						            {display: "到期日期", name: "dueDate"},
						            {display: "打款日期", name: "fldMoneyDate"},
						            {display: "年化收益率", name: "fldAnnualizedRate",
						                render: function (item) {
						                    return item.fldAnnualizedRate + "%";
						                }},
						            {display: "购买金额(万元)", name: "fldPurchaseMoney"},
						            {display: "预期收益(元)", name: "fldAnnualizedMoney",
						                render: function (item) {
						                    return formatCurrency(item.fldAnnualizedMoney);
						                }},
						            {display: "合同状态", name: "fldStatus",
						                render: function (item) {
						                    return renderLabel(statusData, item.fldStatus);
						                }
						            },
						            {display: "是否已到期", name: "fldFinishStatus",
						                render: function (item) {
						                    return renderLabel(finishStatus, item.fldFinishStatus);
						                }},
						            {display: "理财经理", name: "financialUserName"},
						            {display: "客服经理", name: "serviceUserName"},
						            {display: "客户经理", name: "customerUserName"},
						            {display: "银行卡号", name: "fldBankNo"},
						            {display: "瑞得卡号", name: "fldCardNo"},
						            {display: "瑞得卡等级", name: "fldCardLevel",
						                render: function (item) {
						                    return renderLabel(cardLevelData, item.fldCardLevel);
						                }
						            },
						            {display: "操作人", name: "operateUserName"},
						            {display: "操作时间", name: "fldOperateDate"}
						        ], dataAction: 'server', pageSize: 50, toolbar: null, url: '<c:url value="/customer/contract/list?where='+where+'"/>', sortName: 'fldOperateDate', sortOrder: 'desc',
						        width: '98%', height: '32%', toJSON: JSON2.stringify
						    });
           	  }
					    }
            },
            error:function (message) {}
        });
	    
	    var where = encodeURI('?customerName='+customerName+'&phone='+phone+'&mobile='+mobile);
	    $("#dialHistory").ligerGrid({
	        checkbox: false,
	        rownumbers: true,
	        delayLoad: false,
	        columnWidth: 180,
	        columns: [
	            {display: "呼叫类型", name: "fldCallType",
	            	render: function (item) {
                    return renderLabel(callTypeStatus, item.fldCallType);
                }},
              {display: "拨打号码", name: "fldPhone"},
	            {display: "拨打/呼入时间", name: "fldCallDate"},
	            {display: "通话时长", name: "fldCallLong"},
	            {display: "通话开始时间", name: "fldCallBeginTime"},
	            {display: "通话结束时间", name: "fldCallEndTime"}
	        ], dataAction: 'server', pageSize: 50, toolbar: null, url: '<c:url value="/telephone/dial/dialHis'+where+'"/>', sortName: 'fldOperateDate', sortOrder: 'desc',
	        width: '98%', height: '32%', toJSON: JSON2.stringify
	    });
	});
	
	//表单底部按钮
  LG.setFormDefaultBtn(null, f_save);
	
	function f_save() {
		var fldResultType = $("#fldResultType").val();
		if(undefined == fldResultType)return;
		if("" == fldResultType) {
			LG.showError('请选择任务结果');
			return;
		}
		
		LG.ajax({
      url: '<c:url value="/telephone/dial/save"/>',
      data: {fldId:taskId,fldResultType:fldResultType},
      beforeSend: function () {
      	
      },
      complete: function () {
      },
      success: function () {
    	  taskListGrid.loadData();
    	  $("#customerInfo").html("");
      	LG.tip("保存成功");
      },
      error: function (message) {
       LG.showError(message);
      }
    });
	}

	function updateGridHeight() {
    var bottomHeight = $(".l-layout-bottom");
		bottomHeight.css("height",205);    	
	}
	
	updateGridHeight();
</script>
</body>
</html>