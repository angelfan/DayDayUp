/**
 * Created by gengf.jy on 2015/03/23.
 */
var format_display_size = function (size){
    if (size == '' || size == '-'){
        return size;
    }
    var suffix = ' MB';
    var decimals = 2;
    if (size >= 1024 && size < 1048576) {
        //decimals = esf_common.get_display_size_decimals(size, 1024, 2);
        size = size / 1024;
        suffix = ' GB';
    }
    if (size >= 1048576) {
        //decimals = esf_common.get_display_size_decimals(size, 1048576, 2);
        size = size / 1048576;
        suffix = ' TB';
    }
    size = new Number(size);
    return size.toFixed(decimals) + suffix;
};
var convert_to_mb = function(size,suffix){
    var result = parseFloat(size);
    if (suffix === 'GB'){
        result = result*1024;
    }
    if (suffix === 'TB'){
        result = result*1024*1024;
    }
    return result;
};