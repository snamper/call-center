<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="../../include/formHeader.jsp" %>
<body style="padding-bottom:31px;">
<form:form id="mainform" name="mainform" method="post" modelAttribute="contract">
</form:form>
<script type="text/javascript">
	var genderData =<sys:dictList type = "1"/>;
	var cardLevelData =<sys:dictList type = "13"/>;
	var dayUnitData =<sys:dictList type = "14"/>;
	
    //覆盖本页面grid的loading效果
    LG.overrideGridLoading();

    //创建表单结构
    var mainform = $("#mainform");
    mainform.ligerForm({
        inputWidth: 250,
        labelWidth: 110,
        space: 30,
        fields: [
            {display: "合同编号", name: "fldId", newline: true, type: "text", validate: {required: true, maxlength: 40},group: "<label style=white-space:nowrap;>合同信息</label>", groupicon: '<c:url value="/static/ligerUI/icons/32X32/communication.gif"/>'},
            {display: "合同签订日期", name: "fldSignDate", newline: false, type: "date", validate: {required: true},attr:{readonly: "readonly"}},
            {display: "购买姓名",name: "fldCustomerId", newline: true, type: "select", validate: {required: true},
                comboboxName: "customerName", options: {valueFieldID: "customerName"}},
            {display: "购买产品", name: "fldProductDetailId", newline: true, type: "select", comboboxName:"productId", options:{valueFieldID:'productId'}, validate: {required: true},group: "<label style=white-space:nowrap;>购买产品</label>", groupicon: '<c:url value="/static/ligerUI/icons/32X32/communication.gif"/>'},
            {display: "成立日期", name: "fldEstablishDate", newline: true, type: "date"},
            {display: "到期日期", name: "fldDueDate", newline: false, type: "date"},
            {display: "起息日期", name: "fldValueDate", newline: true, type: "date"},
            {display: "实际天/月数", name: "fldClearDays", newline: false, type: "text", attr:{readonly: "readonly"}},
            {display: "年化收益率(%)", name: "fldAnnualizedRate", newline: true, type: "text", attr:{readonly: "readonly"}},
            {display: "年化7天存款率(%)", name: "fldDepositRate", newline: false, type: "text", attr:{readonly: "readonly"}},
            {display: "购买金额(万元)", name: "fldPurchaseMoney", newline: true, validate: {required: true},type: "text",group: "<label style=white-space:nowrap;>购买金额</label>", groupicon: '<c:url value="/static/ligerUI/icons/32X32/communication.gif"/>'},
            {display: "预期收益(元)", name: "fldAnnualizedMoney", newline: false, type: "text"},
            {display: "银行卡号", name: "fldBankNo", newline: true, type: "text", validate: { maxlength: 64},group: "<label style=white-space:nowrap;>打款信息</label>", groupicon: '<c:url value="/static/ligerUI/icons/32X32/communication.gif"/>'},
            {display: "开户银行", name: "fldBankName", newline: false, type: "text", validate: { maxlength: 64}},
            {display: "打款日期", name: "fldMoneyDate", newline: true, type: "date", validate: {required: true}},
            {display: "募集期天数", name: "fldCollectDays", newline: true, type: "text"},
            {display: "募集期贴息(元)", name: "fldCollectMoney", newline: false, type: "text"},
            {display: "卡号", name: "fldCardNo", newline: true,attr:{value:"${customer.fldCardNo}"}, type: "text", validate: { maxlength: 32},group: "<label style=white-space:nowrap;>瑞得卡信息</label>", groupicon: '<c:url value="/static/ligerUI/icons/32X32/communication.gif"/>'},
            {display: "等级", name: "fldCardLevel", newline: false, type: "select",comboboxName:"cardLevel",
                options:{
                    valueField: 'value',
                    textField: 'text',
                    isMultiSelect:false,
                    data:cardLevelData,
                    initValue:"${customer.fldCardLevel}",
                    valueFieldID:"cardLevel"
                }},
            {display: "赠送金额", name: "fldCardMoney", newline: true, type: "text"},
            {display: "理财经理", name: "fldFinancialUserNo", newline: true, type: "select", group: "<label style=white-space:nowrap;>其他信息</label>", groupicon: '<c:url value="/static/ligerUI/icons/32X32/communication.gif"/>',
                comboboxName: "financialUserNo", options: {valueFieldID: "financialUserNo"}},
            {display: "客户经理", name: "fldCustomerUserNo", newline: false, type: "select",
                comboboxName: "customerUserNo", options: {valueFieldID: "customerUserNo"}},
            {display: "客服经理", name: "fldServiceUserNo", newline: true, type: "select",
                comboboxName: "serviceUserNo", options: {valueFieldID: "serviceUserNo"}},
            {display: "天数单位", name: "fldDayUnit", newline: false, type: "hidden"},
            {display: "业绩系数", name: "fldPerformanceRadio", newline: true, type: "hidden"},
            {display: "业绩额度", name: "fldPerformanceMoney", newline: false, type: "hidden"},
            {display: "佣金系数", name: "fldCommissionRadio", newline: true, type: "hidden"},
            {display: "佣金金额", name: "fldCommissionMoney", newline: false, type: "hidden"}
        ]
    });
    
    $.ligerui.get("customerName")._changeValue('${custId}', '${custName}');
    
    $.ligerui.get("fldMoneyDate").bind("changedate",function(){
    	var fldMoneyDate = $("#fldMoneyDate").val();
    	if(fldMoneyDate == "") {
    		$("#fldCollectDays").val(0);
    		$("#fldCollectMoney").val(0);
    		return;
    	}
    	
    	var fldPurchaseMoney = $("#fldPurchaseMoney").val();
    	var fldEstablishDate = $("#fldEstablishDate").val();
    	if(Date.parse(fldEstablishDate) > Date.parse(fldMoneyDate)) {//成立日期晚于打款日期
    		var collectDays = (new Date(Date.parse(fldEstablishDate)) - new Date(Date.parse(fldMoneyDate)))/(1000*60*60*24);
    		$("#fldCollectDays").val(collectDays);
    		if(fldPurchaseMoney!="") {
    			//募集期贴息=购买金额*(年化7天存款率*募集期天数/365)
    			var fldCollectMoney = Math.round(parseFloat(fldPurchaseMoney)*10000*(parseFloat($("#fldDepositRate").val())/100*collectDays/365));
    			$("#fldCollectMoney").val(fldCollectMoney);
    		} else {
    			$("#fldCollectMoney").val(0);
    		}
    	} else {
    		$("#fldCollectDays").val(0);
    		$("#fldCollectMoney").val(0);
    	}
    });
    
    $("#fldPurchaseMoney").change(function(){
    	var fldPurchaseMoney = $("#fldPurchaseMoney").val();
    	if(fldPurchaseMoney == "") {
    		$("#fldAnnualizedMoney").val(0);
    		$("#fldCollectMoney").val(0);
    		$("#fldPerformanceMoney").val(0);
    		$("#fldCommissionMoney").val(0);
    		return;
    	}
    	
    	if($("#fldProductDetailId").val() == "") {
    		return;
    	}
    	
    	//预期收益=购买金额*(年化收益率*实际天数/365)
		var days = parseInt($("#fldClearDays").val());
		var dayUnit = parseInt($("#fldDayUnit").val());
		var fldAnnualizedMoney = 0;
		if(dayUnit == 0) {
			fldAnnualizedMoney = Math.round(parseFloat(fldPurchaseMoney)*10000*(parseFloat($("#fldAnnualizedRate").val())/100*days/365));
		} else if(dayUnit == 1) {
			fldAnnualizedMoney = Math.round(parseFloat(fldPurchaseMoney)*10000*(parseFloat($("#fldAnnualizedRate").val())/100*days/12));
		}
    	$("#fldAnnualizedMoney").val(fldAnnualizedMoney);
    	
    	//募集期贴息=购买金额*(年化7天存款率*募集期天数/365)
    	var collectDays = parseInt($("#fldCollectDays").val());
    	var fldCollectMoney = Math.round(parseFloat(fldPurchaseMoney)*10000*(parseFloat($("#fldDepositRate").val())/100*collectDays/365));
    	$("#fldCollectMoney").val(fldCollectMoney);
    	
    	//佣金金额=购买金额*佣金系数
		var fldCommissionMoney = Math.round(parseFloat(fldPurchaseMoney)*parseFloat(parseFloat($("#fldCommissionRadio").val())));
		$("#fldCommissionMoney").val(fldCommissionMoney);
		
		//业绩额度=购买金额*业绩系数
		var fldPerformanceMoney = Math.round(parseFloat(fldPurchaseMoney)*parseFloat(parseFloat($("#fldPerformanceRadio").val())));
		$("#fldPerformanceMoney").val(fldPerformanceMoney);
    });
    
    $("#productId").change(function(){
    	var productId = $("#fldProductDetailId").val();
    	if(productId == "") {
    		$("#fldAnnualizedRate").val("");
    		$("#fldAnnualizedMoney").val("");
    		$("#fldDepositRate").val("");
    		$("#fldCollectMoney").val("");
    		$("#fldCommissionRadio").val("");
    		$("#fldCommissionMoney").val("");
    		$("#fldPerformanceRadio").val("");
    		$("#fldPerformanceMoney").val("");
    		$("#fldDayUnitText").val("");
    		$("#fldDayUnit").val("");
    		$("#fldClearDays").val("");
    		$("#fldCollectDays").val("");
    		$("#fldEstablishDate").val("");
    		return;
    	}
    	
    	LG.ajax({
            url: '<c:url value="/customer/product/findProductDetail"/>',
            data: {fldId:productId},
            beforeSend: function () {
            	
            },
            complete: function () {
            },
            success: function (data) {
		    	var productDetail = data[0];
		    	var fldAnnualizedRate = productDetail.fldAnnualizedRate;
		    	$("#fldAnnualizedRate").val(fldAnnualizedRate);
		    	$("#fldClearDays").val(productDetail.fldClearDays);
		    	$("#fldDayUnit").val(productDetail.fldDayUnit);
		    	$("#fldDayUnitText").val(renderLabel(dayUnitData,productDetail.fldDayUnit));
		    	$("#fldEstablishDate").val(productDetail.fldEstablishDate);
		    	
		    	var fldPurchaseMoney = $("#fldPurchaseMoney").val();
		    	if(fldPurchaseMoney != "") {
		    		//预期收益=购买金额*(年化收益率*实际天数/365)
		    		var days = parseInt(productDetail.fldClearDays);
		    		var dayUnit = parseInt(productDetail.fldDayUnit);
		    		var fldAnnualizedMoney = 0;
		    		if(dayUnit == 0) {
		    			fldAnnualizedMoney = Math.round(parseFloat(fldPurchaseMoney)*10000*(parseFloat(fldAnnualizedRate)/100*days/365));
		    		} else if(dayUnit == 1) {
		    			fldAnnualizedMoney = Math.round(parseFloat(fldPurchaseMoney)*10000*(parseFloat(fldAnnualizedRate)/100*days/12));
		    		}
    				$("#fldAnnualizedMoney").val(fldAnnualizedMoney);
    			} else {
    				$("#fldAnnualizedMoney").val(0);
    			}
    			$("#fldDepositRate").val(productDetail.fldDepositRate);
    			if($("#fldMoneyDate").val()!="" && productDetail.fldEstablishDate > $("#fldMoneyDate").val()) {//成立日期晚于打款日期
    				var collectDays = (new Date(Date.parse(productDetail.fldEstablishDate)) - new Date(Date.parse($("#fldMoneyDate").val())))/(1000*60*60*24);
    				$("#fldCollectDays").val(collectDays);
    				if(fldPurchaseMoney!="") {
    					//募集期贴息=购买金额*(年化7天存款率*募集期天数/365)
    					var fldCollectMoney = Math.round(parseFloat(fldPurchaseMoney)*10000*(parseFloat(productDetail.fldDepositRate)/100*collectDays/365));
    					$("#fldCollectMoney").val(fldCollectMoney);
    				} else {
    					$("#fldCollectMoney").val(0);
    				}
    			} else {
    				$("#fldCollectMoney").val(0);
    				$("#fldCollectDays").val(0);
    			}
    			$("#fldCommissionRadio").val(null != productDetail.fldCommissionRadio ? productDetail.fldCommissionRadio : 0);
    			//佣金金额=购买金额*佣金系数
    			if(fldPurchaseMoney != "" && null != productDetail.fldCommissionRadio) {
    				var fldCommissionMoney = Math.round(parseFloat(fldPurchaseMoney)*parseFloat(productDetail.fldCommissionRadio));
    				$("#fldCommissionMoney").val(fldCommissionMoney);
    			} else {
    				$("#fldCommissionMoney").val(0);
    			}
    			$("#fldPerformanceRadio").val(productDetail.fldPerformanceRadio);
    			//业绩额度=购买金额*业绩系数
    			if(fldPurchaseMoney != "") {
    				var fldPerformanceMoney = Math.round(parseFloat(fldPurchaseMoney)*parseFloat(productDetail.fldPerformanceRadio));
    				$("#fldPerformanceMoney").val(fldPerformanceMoney);
    			} else {
    				$("#fldPerformanceMoney").val(0);
    			}
            },
            error: function (message) {
          		
            }
        });
    });
    
    $.ligerui.get("productId").openSelect({
	    grid:{
	    	columnWidth: 100,
	        columns:[
	        	{display: "ID", name: "fldId", hide:1,width:1},
	            {display: "产品全称", name: "fldFullName"},
		        {display: "产品简称", name: "fldShortName"},
		        {display: "成立日期", name: "fldEstablishDate"},
		        {display: "起息日期", name: "fldValueDate"},
		        {display: "天数单位", name: "fldDayUnit",
		        	render:function(item) {
	        			return renderLabel(dayUnitData,item.fldDayUnit);
	        		}
		        },
		        {display: "实际天数", name: "fldClearDays"},
		        {display: "到期日期", name: "fldDueDate"},
		        {display: "最低认购金额", name: "fldMinPurchaseMoney"},
		        {display: "最高认购金额", name: "fldMaxPurchaseMoney"},
		        {display: "年化收益率", name: "fldAnnualizedRate"},
		        {display: "年化7天存款率", name: "fldDepositRate"},
		        {display: "业绩系数", name: "fldPerformanceRadio"}
	        ], pageSize:20,heightDiff:-10,
	        url:'<c:url value="/customer/product/listDetail"/>',checkbox:false
	    },
	    search:{
	        fields:[
	            {display:"产品全称", name:"customerProduct.fldFullName", newline:true, type:"text", cssClass:"field"}
	        ]
	    },
	    valueField:'fldId', textField:'fldFullName', top:30
	});
	
	var financialWhere = '{"op":"and","rules":[{"field":"type","value":"10","op":"equal","type":"string"}]}';
	$.ligerui.get("financialUserNo").openSelect({
	    grid:{
	    	columnWidth: 255,
	        columns:[
	            {display:"用户名称", name:"userName"},
	            {display:"登录名称", name:"loginName"},
	            {display:"部门", name:"deptName"}
	        ], pageSize:20,heightDiff:-10,
	        url:'<c:url value="/security/user/list"/>?where='+financialWhere, sortName:'userName', checkbox:false
	    },
	    search:{
	        fields:[
	            {display:"用户名称", name:"userName", newline:true, type:"text", cssClass:"field"}
	        ]
	    },
	    valueField:'loginName', textField:'userName', top:160
	});

	var customerWhere = '{"op":"and","rules":[{"field":"type","value":"30","op":"equal","type":"string"}]}';
    $.ligerui.get("customerUserNo").openSelect({
        grid:{
            columnWidth: 255,
            columns:[
                {display:"用户名称", name:"userName"},
                {display:"登录名称", name:"loginName"},
                {display:"部门", name:"deptName"}
            ], pageSize:20,heightDiff:-10,
            url:'<c:url value="/security/user/list"/>?where='+customerWhere, sortName:'userName', checkbox:false
        },
        search:{
            fields:[
                {display:"用户名称", name:"userName", newline:true, type:"text", cssClass:"field"}
            ]
        },
        valueField:'loginName', textField:'userName', top:160
    });
    
    var serviceWhere = '{"op":"and","rules":[{"field":"type","value":"20","op":"equal","type":"string"}]}';
    $.ligerui.get("serviceUserNo").openSelect({
        grid:{
            columnWidth: 255,
            columns:[
                {display:"用户名称", name:"userName"},
                {display:"登录名称", name:"loginName"},
                {display:"部门", name:"deptName"}
            ], pageSize:20,heightDiff:-10,
            url:'<c:url value="/security/user/list"/>?where='+serviceWhere, sortName:'userName', checkbox:false
        },
        search:{
            fields:[
                {display:"用户名称", name:"userName", newline:true, type:"text", cssClass:"field"}
            ]
        },
        valueField:'loginName', textField:'userName', top:160
    });

    mainform.attr("action", '<c:url value="/customer/contract/save"/>');

    //表单底部按钮
    LG.setFormDefaultBtn(f_cancel, f_save);
    
    function f_save() {
    	LG.validate(mainform);
    	
    	if(!$("#fldCustomerId").val()){
        	LG.showError("请选择客户");
        	return;
    	}
    	
    	if(!$("#fldProductDetailId").val()){
        	LG.showError("请选择产品");
        	return;
    	}
    	
    	LG.ajax({
            url: '<c:url value="/customer/contract/isExist"/>',
            data: {fldId:$("#fldId").val()},
            beforeSend: function () {
            	
            },
            complete: function () {
            },
            success: function () {
		    	LG.submitForm(mainform, function (data) {
	        		var win = parent || window;
	        		if (data.IsError == false) {
	            		win.LG.showSuccess('保存成功', function () {
	                	win.LG.closeAndReloadParent(null, "${menuNo}");
	            	});
	        		} else {
	           			win.LG.showError('错误:' + data.Message);
	        		}
    			});
            },
            error: function (message) {
          		LG.showError(message);
            }
        });
    }
    
    function f_cancel() {
        var win = parent || window;
        win.LG.closeCurrentTab(null);
    }
</script>
</body>
</html>
