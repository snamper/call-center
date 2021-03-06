<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="../header.jsp" %>
<style>
    .ui-autocomplete-loading {
        background: white url('<c:url value="/static/ligerUI/jquery/themes/base/images/ui-anim_basic_16x16.gif"/>') right center no-repeat;
    }
</style>
<body style="padding:10px;height:100%; text-align:center;">
<input type="hidden" id="MenuNo" value="${menuNo}"/>
<div id="mainsearch" style=" width:98%">
    <div class="searchtitle">
        <span>搜索</span><img src='<c:url value="/static/ligerUI/icons/32X32/searchtool.gif"/>'/>
        <div class="togglebtn"></div>
    </div>
    <div class="navline" style="margin-bottom:4px; margin-top:4px;"></div>
    <div class="searchbox">
        <form id="formsearch" class="l-form"></form>
    </div>
</div>
<div id="maingrid"></div>
<script type="text/javascript">
	var statusData =<sys:dictList type = "8" nullable="true"/>;
	var cardLevelData =<sys:dictList type = "13"/>;
	var dayUnitData =<sys:dictList type = "14"/>;
	var typeData= <sys:dictList type = "7"/>;
    var finishStatus = <sys:dictList type = "21" nullable="true"/>;
	
	//搜索表单应用ligerui样式
	$("#formsearch").ligerForm({
	    labelWidth: 100,
	    inputWidth: 150,
	    space: 30,
	    fields: [
	        {display: "客户姓名", name: "customer.fldName", newline: true, type: "text", cssClass: "field"},
	        {display: "合同编号", name: "fldId", newline: false, type: "text", cssClass: "field"},
            {display: "理财经理", name: "financialUser.userName", newline: false, type: "text", cssClass: "field"},
            {display: "合同状态", name: "fldStatus", newline: false, type: "select", cssClass: "field",
                options: {
                    valueFieldID: "fldStatus",
                    valueField: "value",
                    initValue:'0',
                    textField: "text",
                    data: statusData
                }, attr: {"op": "equal", "vt": "int"}
            },
            {display: "产品全称", name: "productDetail.customerProduct.fldFullName", newline: true, type: "text", cssClass: "field"},
	        {display: "产品实际天数", name: "productDetail.fldClearDays", newline: false, type: "text", attr: {"op": "equal", "vt": "int"}, cssClass: "field"},
            {display: "客服经理", name: "serviceUser.userName", newline: false, type: "text", cssClass: "field"},
            {display: "是否到期", name: "fldFinishStatus", newline: false, type: "select", cssClass: "field",
                options: {
                    valueFieldID: "fldFinishStatus",
                    valueField: "value",
                    textField: "text",
                    data: finishStatus
                }, attr: {"op": "equal", "vt": "int"}
            },
            { display:"签订时间", newline:true, name:"fldSignDateStart", type:'date', cssClass:"field", attr:{op:'greaterorequal', vt:'date', field:"fldSignDate"}},
            { display:"至", newline:false, name:"fldSignDateEnd", type:'date', cssClass:"field", attr:{op:'lessorequal', vt:'date', field:"fldSignDate"}},
            {display: "客户经理", name: "customerUser.userName", newline: false, type: "text", cssClass: "field"}
        ],
	    toJSON: JSON2.stringify
	});
	
	//列表结构
	var grid = $("#maingrid").ligerGrid({
	    checkbox: true,
	    rownumbers: true,
	    delayLoad: true,
	    columnWidth: 180,
	    columns: [
            {display: "合同编号", name: "fldId"},
            {display: "签订日期", name: "fldSignDate"},
            {display: "客户姓名", name: "customerName"},
	        {display: "产品全称", name: "productFullName"},
            {display: "产品实际天数", name: "productClearDays"},
            {display: "成立日期", name: "fldEstablishDate"},
            {display: "到期日期", name: "fldDueDate"},
            {display: "打款日期", name: "fldMoneyDate"},
            {display: "年化收益率", name: "fldAnnualizedRate",
                render:function(item) {
                    return item.fldAnnualizedRate+"%";
                }},
            {display: "购买金额(万元)", name: "fldPurchaseMoney"},
            {display: "预期收益(元)", name: "fldAnnualizedMoney",
                render:function(item) {
                    return formatCurrency(item.fldAnnualizedMoney);
                }},
            {display: "合同状态", name: "fldStatus",
                render:function(item) {
                    return renderLabel(statusData,item.fldStatus);
                }
            },
            {display: "是否已到期", name: "fldFinishStatus",
                render:function(item) {
                    return renderLabel(finishStatus,item.fldFinishStatus);
                }},
            {display: "理财经理", name: "financialUserName"},
            {display: "客服经理", name: "serviceUserName"},
            {display: "客户经理", name: "customerUserName"},
            {display: "银行卡号", name: "fldBankNo"},
	        {display: "瑞得卡号", name: "fldCardNo"},
	        {display: "瑞得卡等级", name: "fldCardLevel",
	        	render:function(item) {
	        		return renderLabel(cardLevelData,item.fldCardLevel);
	        	}
	        },
	        {display: "操作人", name: "operateUserName"},
	        {display: "操作时间", name: "fldOperateDate"}
	    ], dataAction: 'server', pageSize: 20, toolbar: {}, url: '<c:url value="/customer/contract/list"/>', sortName: 'fldOperateDate', sortOrder: 'desc',
	    width: '98%', height: '98%', toJSON: JSON2.stringify, onReload: f_reload
	});

	//增加搜索按钮,并创建事件
	LG.appendSearchButtons("#formsearch", grid, true, true);

	//加载toolbar
	LG.loadToolbar(grid, toolbarBtnItemClick);

	//工具条事件
	function toolbarBtnItemClick(item) {
	    switch (item.id) {
	        case "add":
	            top.f_addTab(null, '新增合同信息', '<c:url value="/customer/contract/add"/>' + '?menuNo=${menuNo}');
	            break;
	        case "view":
	            if (grid.getSelectedRows().length > 1 || grid.getSelectedRows().length == 0) {
	                LG.tip('请选择一行数据!');
	                return;
	            }
	            var selected = grid.getSelected();
	            top.f_addTab(null, '查看合同信息', '<c:url value="/customer/contract/view"/>' + '?menuNo=${menuNo}&fldId=' + selected.fldId);
	            break;
	        case "modify":
	            if (grid.getSelectedRows().length > 1 || grid.getSelectedRows().length == 0) {
	                LG.tip('请选择一行数据!');
	                return;
	            }
	            var selected = grid.getSelected();
	            top.f_addTab(null, '修改合同信息', '<c:url value="/customer/contract/edit"/>' + '?menuNo=${menuNo}&fldId=' + selected.fldId);
	            break;
	        case "delete":
	            if (grid.getSelectedRows().length > 1 || grid.getSelectedRows().length == 0) {
	                LG.tip('请选择一行数据!');
	                return;
	            }
	            jQuery.ligerDialog.confirm('确定删除吗?', function (confirm) {
	                if (confirm)
	                    f_delete();
	            });
	            break;
	    }
	}

	function f_reload() {
	    grid.loadData();
	}

	function f_delete() {
	    var selected = grid.getSelected();
	    if (selected) {
	        LG.ajax({
	            url: '<c:url value="/customer/contract/delete"/>',
	            loading: '正在删除中...',
	            data: { fldId: selected.fldId},
	            success: function () {
	                LG.showSuccess('删除合同成功');
	                f_reload();
	            },
	            error: function (message) {
	                LG.showError(message);
	            }
	        });
	    } else {
	        LG.tip('请选择行!');
	    }
	}

	resizeDataGrid(grid);
</script>
</body>
</html>