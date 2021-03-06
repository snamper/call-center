<%@ page contentType="text/html;charset=UTF-8" %>
<%@include file="../../include/header.jsp" %>
<body style="padding:10px;height:100%; text-align:center;">
<ipnut type="hidden" id="MenuNo" value="${menuNo}"/>
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
<div id="maingrid">
</div>
<script type="text/javascript">

    var typeData = <sys:dictList type="77" nullable="true"/>;
    var queryTypeData = <sys:dictList type="78"/>;
    var statusOrderType = <sys:dictList type="75" nullable="true"/>;

    //搜索表单应用ligerui样式
    $("#formsearch").ligerForm({
        labelWidth: 100,
        width: 180,
        fields: [
            {display: "统计时间", name: "startDate", newline: true, cssClass: "field", type: "date",options:{showTime: true},  attr: {"op": 'equal'}},
            {display: "至", name: "endDate", newline: false, cssClass: "field", type: "date",options:{showTime: true}, attr: {"op": 'equal'}},
            {display: "话务员", name: "userName", newline: false, cssClass: "field", type: "text", attr: {"op": 'like'}},
            {display: "通话时长 >", name: "totalCallLongStart", newline: true, cssClass: "field", type: "text", attr: {"op": 'greater',"type":'int'}},
            {display: "通话时长 <", name: "totalCallLongEnd", newline: false, cssClass: "field", type: "text", attr: {"op": 'less',"type":'int'}},
            {display: "部门名称", name: "deptName", newline: false, cssClass: "field", type: "text", attr: {"op": 'like'}}
        ],
        toJSON: JSON2.stringify
    });

    var grid = $("#maingrid").ligerGrid({
        delayLoad: true,
        columnWidth: 180,
        columns: [
            { display: "统计日期", name: "reportDateStr", type: "text", align: "center" },
            { display: "部门", name: "deptName", type: "text", align: "center" },
            { display: "话务员", name: "userName", type: "text", align: "center" },
            { display: "总时长(秒)", name: "totalCallLong", type: "text", align: "right",
                render: function (item) {
                    return item.totalCallLong+"";
                }, totalSummary: { type: 'sum',
                render: function (suminf, column, cell) {
                    return '<div>合计:&nbsp;&nbsp;<b>' + suminf.sum + '（秒）</b></div>';
                }
            }
            },
            { display: "有效时长(秒)", name: "totalValidCallLong", type: "text", align: "right",
                render: function (item) {
                    return item.totalValidCallLong+"";
                }, totalSummary: { type: 'sum',
                render: function (suminf, column, cell) {
                    return '<div>合计:&nbsp;&nbsp;<b>' + suminf.sum + '（秒）</b></div>';
                }
            }
            },
            { display: "总通次", name: "totalCallNum", type: "text", align: "right",
                render: function (item) {
                    return item.totalCallNum+"";
                }, totalSummary: { type: 'sum',
                render: function (suminf, column, cell) {
                    return '<div>合计:&nbsp;&nbsp;<b>' + suminf.sum + '（秒）</b></div>';
                }
            }
            },
            { display: "有效通次", name: "totalValidCallNum", type: "text", align: "right",
                render: function (item) {
                    return item.totalValidCallNum+"";
                }, totalSummary: { type: 'sum',
                render: function (suminf, column, cell) {
                    return '<div>合计:&nbsp;&nbsp;<b>' + suminf.sum + '（秒）</b></div>';
                }
            }
            },
            { display: "客户数", name: "totalCutomerNum", type: "text", align: "right",
                render: function (item) {
                    return item.totalCutomerNum+"";
                }, totalSummary: { type: 'sum',
                render: function (suminf, column, cell) {
                    return '<div>合计:&nbsp;&nbsp;<b>' + suminf.sum + '</b></div>';
                }
            }
            }
        ], dataAction: 'server', toolbar: {}, url: '<c:url value="/report/callInDay/list"/>',
        width: '98%', height: '98%', checkbox: false,
        rownumbers: true, usePager: false
    });

    //增加搜索按钮,并创建事件
    LG.appendSearchButtons("#formsearch", grid);

    //加载toolbar
    LG.loadToolbar(grid, toolbarBtnItemClick);

    //验证
    //工具条事件
    function toolbarBtnItemClick(item) {
        switch (item.id) {
            case "export":
                var columns = grid.getColumns();
                var columnNames = [];
                var propertyNames = [];
                for (var i = 1; i < columns.length; i++) {
                    if (columns[i].name == 'userId') {
                        continue;
                    }
                    columnNames.push(columns[i].display);
                    propertyNames.push(columns[i].name);
                }
                f_export(columnNames, propertyNames);
                break;
        }
    }

    function f_reload() {
        grid.loadData();
    }

    function f_export(columnNames, propertyNames) {
        var rule = LG.bulidFilterGroup("#formsearch");
        LG.ajax({
            loading: '正在导出数据中...',
            url: '<c:url value="/report/callInDay/export"/>',
            data: {where: JSON2.stringify(rule), columnNames: JSON2.stringify(columnNames), propertyNames: JSON2.stringify(propertyNames)},
            success: function (data, message) {
                window.location.href = '<c:url value="/common/download?filepath="/>' + encodeURIComponent(data[0]);
            },
            error: function (message) {
                LG.tip(message);
            }
        });
    }
    resizeDataGrid(grid);
</script>
</body>
</html>