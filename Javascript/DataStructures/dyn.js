// 斐波那契数列的计算

/**
 * 1. 迭代
 */
function recurFib(n) {
    if (n < 2) {
        return n
    } else {
        return recurFib(n - 1) + recurFib(n - 2)
    }
}

console.log(recurFib(10)); // 55

/**
 * 2. 动态规划（通过数组保存， 方便累加求和）
 */
function dynFib(n) {
    var val = [];
    if (n === 1 || n === 2) {
        return 1;
    } else {
        val[0] = 1;
        val[1] = 1;
        for (var i = 2; i <= n; ++i) {
            val[i] = val[i - 1] + val[i - 2]
        }
        return val[n - 1]
    }
}

console.log(dynFib(10)); // 55

/**
 * 3. 动态规划(不使用数组保存)
 */
function iterFib(n) {
    var last = 1;
    var nextLast = 1;
    var result = 1;
    for (var i = 2; i < n; ++i) {
        result = last + nextLast;
        nextLast = last;
        last = result;
    }
    return result;
}

console.log(iterFib(10)); // 55

/**
 * 4. 动态规划
 */
var memoizer = function (memo, func) {
    var recur = function (n) {
        var result = memo[n];
        if (typeof result !== 'number') {
            result = func(recur, n);
        }
        return result;
    };
    return recur;
};

var fibonacci = memoizer([0, 1], function (recur, n) {
    return recur(n - 1) + recur(n - 2);
});

console.log(fibonacci(10));