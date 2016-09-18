# Postgresql Index

[Explain](https://www.postgresql.org/docs/9.4/static/using-explain.html)
[Index Types](https://www.postgresql.org/docs/9.3/static/indexes-types.html)



尽量减少like，但不是绝对不可用 ”xxxx%” 不会用到索引的
不同的索引类型支持不同条件的索引

## Note
需要注意的是并不是建立了索引在查询的时候就一定会用到索引
当返回行数非常多的时候就不会索引扫描
这是因为索引扫描，需要为每一行多个IO操作（查找行中的索引，然后检索来自堆的行）。
而顺序扫描仅需要为每一行的单个IO - 或甚至更少，因为在盘上的块（页）包含多个行，因此一个以上的行可以用单个IO操作获取。

一般来说，列的值唯一性太小（如性别，类型什么的），不适合建索引

