// 找零问题
function makeChange(origAmt, coins) {
    var remainAmt = 0;

    if (origAmt % .25 < origAmt) {
        coins[3] = parseInt(origAmt / .25);
        remainAmt = origAmt % .25;
        origAmt = remainAmt;
    }

    if (origAmt % .1 < origAmt) {
        coins[2] = parseInt(origAmt / .1);
        remainAmt = origAmt % .1;
        origAmt = remainAmt;
    }

    if (origAmt % .05 < origAmt) {
        coins[1] = parseInt(origAmt / .05);
        remainAmt = origAmt % .05;
        origAmt = remainAmt;
    }

    coins[0] = parseInt(origAmt / .01);
}

function showChange(coins) {
    if (coins[3] > 0) {
        console.log("25-" + coins[3] + "-" + coins[3] * .25)
    }
    if (coins[2] > 0) {
        console.log("10-" + coins[2] + "-" + coins[2] * .10)
    }
    if (coins[1] > 0) {
        console.log("5-" + coins[1] + "-" + coins[1] * .05)
    }
    if (coins[0] > 0) {
        console.log("1-" + coins[0] + "-" + coins[0] * .01)
    }
}

var origAmt = .63;
var coins = [];
makeChange(origAmt, coins);
showChange(coins);

// 背包问题
function ksack(values, weights, capacity) {
    var load = 0;
    var i = 0;
    var w = 0;
    while (load < capacity && i < 4) {
        if (weights[i] <= (capacity - load)) {
            w += values[i];
            load += weights[i];
        } else {
            var r = (capacity - load) / weights[i];
            w += r * values[i];
            load += weights[i];
        }
        ++i;
    }
    return w;
}

var items = ['A', 'B', 'C', 'D'],
    values = [50, 140, 60, 60],
    weights = [5, 20, 10, 12],
    capacity = 30;
console.log(ksack(values, weights, capacity));