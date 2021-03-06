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
    //搜索表单应用ligerui样式
    $("#formsearch").ligerForm({
        labelWidth: 100,
        inputWidth: 150,
        space: 30,
        fields: [
            {display: "理财经理", name: "financialUser.userName", newline: true, type: "text", cssClass: "field"},
            {display: "产品名称", name: "customerProduct.fldFullName", newline: false, type: "text", cssClass: "field"},
            {display: "合同签订日期", name: "startDate", newline: true, type: "date", cssClass: "field",
                attr: {op: 'greaterorequal', vt: 'date', field: "fldSignDate"}},
            {display: "至", name: "endDate", newline: false, type: "date", cssClass: "field",
                attr: {op: 'lessorequal', vt: 'date', field: "fldSignDate"}}
        ],
        toJSON: JSON2.stringify
    });

    //列表结构
    var grid = $("#maingrid").ligerGrid({
        checkbox: true,
        rownumbers: true,
        delayLoad: true,
        columnWidth: 150,
        columns: [
            {display: "理财经理", name: "financialUserName"},
            {display: "合同签订日期", name: "fldSignDate"},
            {display: "产品全称", name: "productFullName"},
            {display: "产品实际天数", name: "productClearDays"},
            {display: "年化收益率", name: "fldAnnualizedRate",
                render:function(item) {
                    return item.fldAnnualizedRate+"%";
                }},
            {display: "购买金额(万元)", name: "fldPurchaseMoney"},
            {display: "业绩系数", name: "fldPerformanceRadio"},
            {display: "业绩额度(万)", name: "fldPerformanceMoney"}
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
            case "view":
                if (grid.getSelectedRows().length > 1 || grid.getSelectedRows().length == 0) {
                    LG.tip('请选择一行数据!');
                    return;
                }
                var selected = grid.getSelected();
                top.f_addTab(null, '查看合同信息', '<c:url value="/customer/contract/view"/>' + '?menuNo=${menuNo}&fldId=' + selected.fldId);
                break;
            case "export":
                f_export('<c:url value="/customer/contract/export"/>');
                break;
        }
    }

    function f_reload() {
        grid.loadData();
    }

    resizeDataGrid(grid);

</script>
</body>
</html>