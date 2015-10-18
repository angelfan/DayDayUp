function search(data) {
    var $searchResult = $("#search-result .result-panel");

    if (resultDataTable) {
        resultDataTable.fnClearTable();
        $searchResult.dataTable().fnDestroy();
        $("#resultList").empty();
    } else {
        $searchResult.show();
    }
    resultDataTable = $searchResult.dataTable({
        "bPaginate": true,
        "bAutoWidth": false,
        "bProcessing": true,
        "bFilter": false,
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
        "oLanguage": {                          //汉化
            "sLengthMenu": "每页显示 _MENU_ 条记录",
            "sZeroRecords": "没有检索到数据",
            "sInfo": "当前数据为从第 _START_ 到第 _END_ 条数据；总共有 _TOTAL_ 条记录",
            "sInfoEmtpy": "没有数据",
            "sProcessing": "正在加载数据...",
            "oPaginate": {
                "sFirst": "首页",
                "sPrevious": "前页",
                "sNext": "后页",
                "sLast": "尾页"
            }
        },
        "bServerSide": true,
        "sServerMethod": "POST",
        "sAjaxSource": "${baseUrl}/zpzxResumeSearch.do?&method=<bean:message key=" + "zjzxResume.button.search" + ">",
        //"fnServerData": executeQuery,
        "fnServerParams": function (aoData) {
            aoData.push({"name": "conds", "value": data});
        },
        "aoColumns": [
            {"mData": null},
            {"mData": "name"},
            {"mData": "sex"},
            {"mData": "birthday"},
            {"mData": "mobilePhone"},
            {"mData": "diploma"},
            {"mData": "workYears"},
            {"mData": "currentAddress"},
            {"mData": "hukouAddress"},
            {"mData": "updateTime"},
            {"mData": null}
        ],
        "aoColumnDefs": [
            {
                "aTargets": [1],
                "mRender": function (data, type, full) {
                    return "'>"
                        + data + "";
                }
            },
            {
                "aTargets": [0],
                "mRender": function (data, type, full) {
                    return "<input value=full.resumeId class= chkExportResume type= checkbox>";
                }
            },
            {
                "aTargets": [10],
                "mRender": function (data, type, full) {
                    return buildLink(data, type, full);
                }
            }
        ]
    })
}