邻接表
```sql
CREATE TABLE Comments(
    comment_id   SERIAL PRIMARY KEY
    parent_id    BIGNIT UNSIGNED
    comment      TEXT NOT NULL
    FOREIGN KEY (parent_id) REGERENCES Comments(comment_id)
);

```
1. 查询开销大
2. 增加节点容易
3. 删除节点复杂, 因为不得不执行多次查询来找到多有的后代节点, 然后逐个从最低级别开始删除这些节点 以满足外键完整性