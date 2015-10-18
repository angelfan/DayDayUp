/**
 * Created by angelfan on 15-4-8.
 */


[1, 2, 3].map(function (element) {
    return element * 2;
}); // [2, 4, 6]


someCollection.find(function (element) {
    return element.someProperty == 'searchCondition';
});


[1, 2, 3].forEach(function (element) {
    if (element % 2 != 0) {
        alert(element);
    }
}); // 1, 3


(function () {
    alert([].join.call(arguments, ';')); // 1;2;3
}).apply(this, [1, 2, 3]);


var a = 10;
setTimeout(function () {
    alert(a); // 10, after one second
}, 1000);


//...
var x = 10;
// only for example
xmlHttpRequestObject.onreadystatechange = function () {
    // 当数据就绪的时候，才会调用;
    // 这里，不论是在哪个上下文中创建
    // 此时变量“x”的值已经存在了
    alert(x); // 10
};
//...


var foo = {};

// 初始化
(function (object) {

    var x = 10;

    object.getX = function _getX() {
        return x;
    };

})(foo);

alert(foo.getX()); // 获得闭包 "x" – 10