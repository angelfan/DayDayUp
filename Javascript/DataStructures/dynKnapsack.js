function max(a, b) {
    return (a > b) ? a : b;
}
function dynKnapsack(capacity, size, value, n) {
    var k = [];

    for (var i = 0; i < capacity + 1; i++) {
        k[i] = [];
    }

    for (var i = 0; i <= n; i++) {
        for (var w = 0; w <= capacity; w++) {
            if (i == 0 || w == 0) {
                k[i][w] = 0;
            } else if (size[i - 1] <= w) {
                k[i][w] = max(value[i - 1] + k[i - 1][w - size[i - 1]], k[i - 1][w]);
            } else {
                k[i][w] = k[i - 1][w];
            }
        }
    }
    return k[n][capacity];
}

var value = [4, 5, 10, 11, 13],
    size = [3, 4, 7, 8, 9],
    capacity = 16,
    n = 5;
console.log(dynKnapsack(capacity, size, value, n));