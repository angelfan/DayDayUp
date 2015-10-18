/**
 * Created by gengf.jy on 2015/03/23.
 */
var i18n = function () {
    return {
        /**
         * the source is from yaml and with {{}}
         * replace {{}} with substitution_array
         */
        t: function(key, substitution_array){
            var source_msg = jQuery('#' + key).val();
            if(substitution_array != null){
                for (var i = 0; i < substitution_array.length; i++) {
                    source_msg = source_msg.replace('{{}}', substitution_array[i]);
                }
            }
            return source_msg;
        },

        /**
         * replace key with hash[key]
         */
        t_msg: function(key, substitution_hash){
            var source_msg = jQuery('#' + key).val();
            if(substitution_hash != null){
                for (var i in substitution_hash) {
                    var reg = new RegExp("%{" + i + "}");
                    source_msg = source_msg.replace(reg, substitution_hash[i]);
                }
            }
            return source_msg;
        }
    };
}();