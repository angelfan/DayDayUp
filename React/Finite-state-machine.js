var menu = {

    // 当前状态
    currentState: 'hide',

    // 绑定事件
    initialize: function () {
        var self = this;
        self.on("hover", self.transition);

    },

    // 状态转换
    transition: function (event) {
        switch (this.currentState) {
            case "hide":
                this.currentState = 'show';
                doSomething();
                break;

            case "show":
                this.currentState = 'hide';
                doSomething();
                break;

            default:
                console.log('Invalid State!');
                break;
        }
    }
};
//下面介绍一个有限状态机的函数库Javascript Finite State Machine。这个库非常好懂，可以帮助我们加深理解，而且功能一点都不弱。
//https://github.com/jakesgordon/javascript-state-machine