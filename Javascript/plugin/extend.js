function entend() {
    return {
        deepExtend: function (des, src) {
            entend.cleanDesArrayBySrc(des, src);
            $.extend(true, des, src);
        },
        //clear array property of destination object
        cleanDesArrayBySrc: function (des, src) {
            if (des) {
                if ($.isArray(src)) {
                    des = undefined;
                } else if ($.isPlainObject(src)) {
                    $.each(src, function (key, val) {
                        des[key] = entend.cleanDesArrayBySrc(des[key], val);
                    });
                }
            }
            return des;
        }
    }
}

entend.deepExtend( "des", $.extend( true, {}, "src" ) );


var toUpperFirstLetter = function(upperCaseString){
    return upperCaseString.substring(0,1).toUpperCase() + upperCaseString.substring(1);
}