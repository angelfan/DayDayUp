$('#button').click(function () {
    var msg = '信息保存成功';    // 提示消息
    var title = '操作结果';      // 消息title
    var shortCutFunction = 'success'; // 结果
    toastr.options = {
        "closeButton": true,
        "debug": false,
        "positionClass": "toast-top-center",
        "onclick": null,
        "showDuration": "1000",
        "hideDuration": "1000",
        "timeOut": "5000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    };
    toastr[shortCutFunction](msg, title);
});
