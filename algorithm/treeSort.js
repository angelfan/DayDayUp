function TreeSort() {
    this.left = null;
    this.right = null;
    this.value = null;
}

TreeSort.prototype.add = function (value) {
    if (value != null && typeof value != 'undefined') {
        if (this.value == null) {
            this.value = value;
            return;
        }

        var node = new TreeSort();
        node.value = value;
        if (this.value >= value) {
            if (this.left == null) {
                this.left = node;
            }
            else {
                this.left.add(value);
            }
        }
        else {
            if (this.right == null) {
                this.right = node;
            }
            else {
                this.right.add(value);
            }
        }
    }
};

TreeSort.prototype.print = function (data) {
    if ((typeof data == 'undefined') || !(data instanceof Array))return;
    if (this.left != null) {
        this.left.print(data);
    }
    data.push(this.value);
    if (this.right != null) {
        this.right.print(data);
    }
};

Array.prototype.treeSort = function () {
    var root = new TreeSort();
    for (var i = 0; i < this.length; i++) {
        root.add(this[i]);
    }
    this.length = 0;
    root.print(this);
};

var arr = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 9, 11, 15, 12];

arr.treeSort();
console.log(arr);