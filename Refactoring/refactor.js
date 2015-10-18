// user_name对应的灰化逻辑
var enable_disable_request_with_user_name = function () {
    if ($.trim($("#user_name").val()) === "") {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "disable/button"].join("/"), ["request"]);
    } else {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "enable/button"].join("/"), ["request"]);
    }
};

// auth_passrowd对应的灰化逻辑
var enable_disable_request_with_auth_password = function () {
    if ($("#auth_password").val() === "") {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "disable/button"].join("/"), ["request"]);
    } else {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "enable/button"].join("/"), ["request"]);
    }
};

// priv_password对应的灰化逻辑
var enable_disable_request_with_priv_password = function () {
    if ($("#priv_password").val() === "") {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "disable/button"].join("/"), ["request"]);
    } else {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "enable/button"].join("/"), ["request"]);
    }
};

var enable_disable_request = function () {
    if ($('input:radio[name="auth_setting"]:checked').val() === "Enable") {
        if ($('input:radio[name="priv_setting"]:checked').val() === "Enable") {
            enable_disable_request_with_user_name();
            enable_disable_request_with_auth_password();
            enable_disable_request_with_priv_password();
        } else {
            enable_disable_request_with_user_name();
            enable_disable_request_with_auth_password();
        }
    } else {
        enable_disable_request_with_user_name();
    }
};


// step one 抽取共同部分
var new_logic = function (flag) {
    if (flag) {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "enable/button"].join("/"), ["request"]);
    } else {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "disable/button"].join("/"), ["request"]);
    }
};

var new_logic2 = function () {
    if ($('input:radio[name="auth_setting"]:checked').val() === "Enable") {
        if ($('input:radio[name="priv_setting"]:checked').val() === "Enable") {
            var flag = $.trim($("#user_name").val()) === "" && $("#auth_password").val() === "" && $("#priv_password").val() === "";
            new_logic(flag)
        } else {
            var flag = $.trim($("#user_name").val()) === "" && $("#auth_password").val() === "";
            new_logic(flag)
        }
    } else {
        var flag = $.trim($("#user_name").val()) === "";
        new_logic(flag)
    }
};

// step two 将标志位方法内部可见
var new_logic = function (flag) {
    var flag = true;
    if ($('input:radio[name="auth_setting"]:checked').val() === "Enable") {
        if ($('input:radio[name="priv_setting"]:checked').val() === "Enable") {
            flag = $.trim($("#user_name").val()) === "" && $("#auth_password").val() === "" && $("#priv_password").val() === "";

        } else {
            flag = $.trim($("#user_name").val()) === "" && $("#auth_password").val() === "";

        }
    } else {
        flag = $.trim($("#user_name").val()) === "";
    }
    if (flag) {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "enable/button"].join("/"), ["request"]);
    } else {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "disable/button"].join("/"), ["request"]);
    }
};

//step three 简化条件逻辑
var enable_disable_request = function () {
    var flag = true;
    if ($.trim($("#add_modify_user_configuration #user_conf_user_name").val()) === "") {
        flag = false;
    }
    if ($('#add_modify_user_configuration input:radio[name="auth_setting"]:checked').val() === "Enable") {
        if ($("#auth_password").val() === "") {
            flag = false;
        }
    }
    if ($('#add_modify_user_configuration input:radio[name="priv_setting"]:checked').val() === "Enable") {
        if ($("#priv_password").val() === "") {
            flag = false;
        }
    }
    if (flag) {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "enable/button"].join("/"), ["request"]);
    } else {
        $("#wizard_inner").fjPublish(["", "wizard_inner", "disable/button"].join("/"), ["request"]);
    }
};

// 关注点变成 该对象在什么条件下需要关注