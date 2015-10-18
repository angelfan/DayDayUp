/*
*  a demo for create a plugin
*/

;
(function ($, window, document, undefined) {

    var pluginName = "pluginName",
        templates = {
            element1: "<div class='element1'></div>",
            element2: "<div class='element2'><i></i></div>",
            element3: "<a class='element3 href='#'></a>"
        },
        defaults = {
            //the following options can be reset and have "setOption" method
            appendTo: "",
            shown: true,
            smallBoxClass: "",
            height: "",
            width: "",
            innerText: "",
            iClass: "",
            footerTools: [],
            click: $.noop  // this option is used for event such as click
        };

    $.pluginNameSetup = function (option) {
        $.extend(true, defaults, option);
    };

    /**
     *  the dome ID
     *  the setting
     *  the presetting
     *  and the plugin name if it is required
     */
    function pluginFun($element, options) {
        this.$element = $element;
        this.settings = $.extend(true, {}, defaults, options);
        this._preSettings = defaults;
        this._name = pluginName;
        this._init();
    }

    $.extend(pluginFun.prototype, {
        _init: function () {
            var _this = this;
            _this.setOptionMenthod();
            _this._preSettings = $.extend({}, _this.settings);
            return _this;
        },
        /**
         *  change "options" attribute of equipped dom object
         */
        setOptionMenthod: function () {
            this.$element
                .removeClass(this._preSettings.smallBoxClass)
                .addClass(this.settings.smallBoxClass);
        },

        /**
         * bind the event such as click event for this obj
         * @private
         */
        _bindClick: function () {
            var _this = this;
            var funcReturn = true;
            var fn = function (e) {
                e.preventDefault();
                if ($.isFunction(_this.settings.click) && _this.settings.click !== $.noop) {
                    funcReturn = _this.settings.click.apply(_this, arguments);
                }
                return funcReturn;
            };
            _this.$element.off("click").on("click", fn);
        },


        option: function (data) {
            var _this = this;

            if (arguments.length > 2) {
                return;
            }

            var setFn = function (name) {
                var methodName = toUpperFirstLetter(name);
                if (typeof( _this["setOption" + methodName] ) === "function") {
                    //if this option had corresponding function, call it
                    _this["setOption" + methodName].call(_this);
                }
            };

            if (typeof( data ) === "string" && arguments.length === 1) {
                //if the number of parameter only one and type is string, there will return the option corresponding value in settings
                return _this.settings[data];
            }

            //if data is object or arguments length is 2,call setName function
            if (typeof( data ) === "string" && arguments.length === 2) {
                _this.settings[data] = arguments[1];
                setFn(data);
            } else if (typeof( data ) === "object") {
                //if it's object, there will merge the equipped value to settings
                $.extend(true,_this.settings, data);
                //call corresponding function to complete setting
                $.each(data, function (name, val) {
                    setFn(name);
                });
            }

            _this._preSettings = $.extend({}, _this.settings);
            return _this.$element;
        },

        /**
         *  remove obj from page
         */
        destroy: function () {
            this.$element.remove();
        }
    });

    /**
     *  Add a method to jQuery prototype for creating this plugin
     *  @param {Hash} options the individual option you set
     */
    $.fn[pluginName] = function (options) {
        if (typeof( options ) === "string") {
            var instance = $(this).data("plugin_" + pluginName);
            if (instance && options[0] !== "_") {
                //if this plugin has been created and parameter type is string and the prefix of parameter is not "_", there will call instance method of this plugin object
                return instance[options].apply(instance, Array.prototype.slice.call(arguments, 1));
            }
        } else {
            this.each(function () {
                if (!$(this).data("plugin_" + pluginName)) {
                    //if this plugin hasn't been created, there will call "pluginFun" to create a this plugin
                    $(this).data("plugin_" + pluginName, new pluginFun($(this), options));
                }
            });

            return this;
        }
    };

})(jQuery, window, document);