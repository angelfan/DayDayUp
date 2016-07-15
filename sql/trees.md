邻接表
```sql
CREATE TABLE Comments(
    comment_id   SERIAL PRIMARY KEY
    parent_id    BIGNIT UNSIGNED
    comment      TEXT NOT NULL
    FOREIGN KEY (parent_id) REGERENCES Comments(comment_id)
);

```
查询直接后代
```sql
SELECT c1.*, c2.*
FROM Comments c1 LEFT OUTER JOIN Comments c2
ON c2.parent_id = c1.comment_id
```

递归查询
```sql
WITH CommentTree (comment_id, parent_id, comment, depth)
AS(
SELECT *, 0 AS depth FROM Comments WHERE parent_id IS NULL
UNION ALL
SELECT c.*, ct.depth + 1 AS depth FROM CommentTree ct
    JOIN Comments c ON (ct.comment_id = c.parent_id)
)
```

1. 查询所有层级开销大
2. 增加节点容易, 修改节点容易
3. 删除节点复杂, 因为不得不执行多次查询来找到多有的后代节点, 然后逐个从最低级别开始删除这些节点 以满足外键完整性

路径枚举
方便根据层级进行排序
path
1
1/2
1/2/3
```ruby
select * from tree2 where path like '%/2/%'
select count(*) from tree2 where path like '1/2/%';


update tree2 set
path=(select path from tree2 where nodeid=12)
||last_insert_rowid()||'/'
where
nodeid= last_insert_rowid();

```

嵌套集
两个数字 nsleft, nsright

闭包表
分级存储简单而优雅的一个解决方案
维护一张新的表来存储节点的关系
treepath
Ancestor Descendant  PathLength
1             1          0
1             2          1


## resource
<<SQL 反模式>>
[单纯的树](http://www.cnblogs.com/kissdodog/p/3297894.html)