// 拷贝继承  （还有类式继承， 原型继承...）

//扩展工具方法
$.extend({
  function1: function () {
    console.log(1);
  },

  function2: function () {
    console.log(2);
  }
});

//扩展实例方法
$.fn.extend({
  function1: function () {
    console.log(3);
  },

  function2: function () {
    console.log(4);
  }
});

$.function1(); // 1 -- 调用工具方法

$.().function1(); // 3 -- 调用实例方法

// -------------

var a = {};
// 可以将多个对象扩展到第一个对象上
$.extend(a, {name: 'angelfan'}, {age: 24});

// 深拷贝 浅拷贝
var c = {};
var b = {name: {age: 30}};
$.extend(c, b); // 浅拷贝
c.name.age = 20;
console.log(b.name.age); // 20

$.extend(true, c, b); // 深拷贝 修改c.name.age 不会硬系那个b

