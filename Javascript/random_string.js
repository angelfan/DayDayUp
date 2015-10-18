/**
 * Created by gengf.jy on 2015/03/23.
 */

// 获取随机字符串
var gen_random_string = function(){
    var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz';
    var len = 35;
    var random_string = '';
    for (var i=0; i<len; i++){
        var random_poz = Math.floor(Math.random() * chars.length);
        random_string += chars.substring(random_poz,random_poz+1);
    }
    return random_string;
};