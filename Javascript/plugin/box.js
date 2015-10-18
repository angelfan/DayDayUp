var bindClick = function () {
    var _this = this;
    var funcReturn = true;
    var fn = function (e) {
        e.preventDefault();
        if ($.isFunction(_this.settings.click) && _this.settings.click !== $.noop) {
            // 将传递过来的option函数绑定到该box上
            funcReturn = _this.settings.click.apply(_this, arguments);
        }
        return funcReturn;
    };
    _this.$element.off("click").on("click", fn);
};

var setFooterTools = function() {
    var _this = this;
    $( ".small-box-footer", _this.$element ).remove();
    var $footWrapper = $("<div class='foot-wrapper'></div>");

    // footerTools ==> [{ text: "+ Status info", attr: {}, click: function(){} }, ...]
    $.each( ( _this.settings.footerTools || [] ), function( i, val ){
        var $a = $( templates.footer );
        $a.append( "<span>"+val.text+"</span>" )
            .on( "click", function( e ) {
                var funcReturn = true;
                e.preventDefault();
                if ( typeof( val.click ) === "function" ) {
                    funcReturn = val.click.call( _this, e );
                }
                return funcReturn;
            })
            .attr( val.attr)
            .appendTo( $footWrapper );
        $footWrapper.appendTo( _this.$element);
    });
}