function Node(data, left, right) {
    this.data = data;
    this.left = left;
    this.right = right;
    this.show = show;
}

function show() {
    return this.data;
}

function BST() {
    this.root = null;
    this.insert = insert;
    this.inOrder = inOrder;
    this.preOrder = preOrder;
    this.postOrder = postOrder;
}

function insert(data) {
    var n = new Node(data, null, null);
    if (this.root == null) {
        this.root = n;
    } else {
        var current = this.root;
        var parent;
        while (true) {
            parent = current;
            if (data < current.data) {
                current = current.left;
                if (current == null) {
                    parent.left = n;
                    break;
                }
            } else {
                current = current.right;
                if (current == null) {
                    parent.right = n;
                    break;
                }
            }

        }
    }
}

function inOrder(node) {
    var list = [];
    function order(node){
        if (!(node == null)) {
            arguments.callee(node.left);
            list.push(node.show());
            arguments.callee(node.right)
        }
    };
    order(node);
    return list
}

function preOrder(node) {
    if (!(node == null)) {
        list.push(node.show());
        preOrder(node.left);
        preOrder(node.right)
    }
    return list
}( list = []);

function postOrder(node) {
    if (!(node == null)) {
        postOrder(node.left);
        postOrder(node.right)
        list.push(node.show());
    }
    return list
}( list = []);


var num = new BST();
num.insert(10);
num.insert(30);
num.insert(22);
num.insert(56);
num.insert(81);
num.insert(77);
num.insert(92);
console.log(num.inOrder(num.root));