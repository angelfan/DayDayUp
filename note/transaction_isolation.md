# 事务隔离

>  MVCC的实现方法有两种：

>   1.写新数据时，把旧数据移到一个单独的地方，如回滚段中，其他人读数据时，从回滚段中把旧的数据读出来；

>   2.写数据时，旧数据不删除，而是把新数据插入。

>   PostgreSQL数据库使用第二种方法，而Oracle数据库和MySQL中的innodb引擎使用的是第一种方法。

>   与racle数据库和MySQL中的innodb引擎相比较，PostgreSQL的MVCC实现方式的优缺点如下。

>   优点：

>   1.事务回滚可以立即完成，无论事务进行了多少操作；

>   2.数据可以进行很多更新，不必像Oracle和MySQL的Innodb引擎那样需要经常保证回滚段不会被用完，也不会像oracle数据库那样经常遇到“ORA-1555”错误的困扰；

>   缺点：

>   1.旧版本数据需要清理。PostgreSQL清理旧版本的命令成为Vacuum；

>   2.旧版本的数据会导致查询更慢一些，因为旧版本的数据存在于数据文件中，查询时需要扫描更多的数据块。

>   (本段转自《PostgreSQL修炼之道》)

## 脏读（dirty reads）
一个事务读取了另一个未提交的并行事务写的数据。

## 不可重复读（non-repeatable reads）
一个事务重新读取前面读取过的数据， 发现该数据已经被另一个已提交的事务修改过。

## 幻读（phantom read）
一个事务重新执行一个查询，返回一套符合查询条件的行， 发现这些行因为其他最近提交的事务而发生了改变。


```SQL
BEGIN;
SELECT title FROM books WHERE id = 1;
-- 'Old'

gap

SELECT titoe FROm books WHERE id = 1
-- '???'
```

```SQL
UPDATE books SET title 'New' WHERE id = 1
```

## 读未提交 Read Uncommitted
另一个事务中只要更新的记录， 当前事务就会读取到更新的数据 (脏读)

## 读已提交 Read Committed
另一个事务必须提交， 当前事务才会读取到最新数据 (不可脏读 但是可重复读)

## 可重复读 Repeatable Read
即使另一个事务几条， 当前事务也不会读取到新的数据 （不可重复读）
如果另一事务做插入操作， 当前事务是可以取得数量上的变化（select count(*) from table）(可以幻读)

## 可串行化 Serializable
另一事务做了插入操作， 当前事务不会取得数量上的变化（select count(*) from table）(不可以幻读)


| 隔离级别 |	脏读 | 不可重复读 | 幻读 |
|---------|-------|---------|-----|
| 读未提交 |	 可能  |  可能 	|可能  |
| 读已提交 |	不可能 |   可能  | 可能 |
| 可重复读 |	不可能 |	不可能 	|可能 |
| 可串行化 |	不可能 |	不可能 	|不可能 |


## 读已提交隔离级别( BEGIN TRANSACTION ISOLATION LEVEl READ COMMITTED; )
当一个事务运行在这个隔离级别时:
SELECT查询(没有FOR UPDATE/SHARE子句)只能看到查询开始之前已提交的数据而无法看到未提交的数据或者在查询执行期间其它事务已提交的数据 (仅读当时数据库快照)。
不过，SELECT看得见其自身所在事务中前面更新执行结果，即使它们尚未提交。
（注意：在同一个事务里两个相邻的SELECT命令可能看到不同的快照，因为其它事务会在第一个SELECT执行期间提交。）
### 分析
要是同时有两个事务修改同一行数据会怎么样？
这就是事务隔离级别（transaction isolation levels）登场的时候了。
Postgres支持两个基本的模型来让你控制应该怎么处理这样的情况。默认情况下使用读已提交（READ COMMITTED），
等待初始的事务完成后再读取行记录然后执行语句。如果在等待的过程中记录被修改了，它就从头再来一遍。
举一个例子，当你执行一条带有WHERE子句的UPDATE时，WHERE子句会在最初的事务被提交后返回命中的记录结果，
如果这时WHERE子句的条件仍然能得到满足的话，UPDATE才会被执行。
在下面这个例子中，两个事务同时修改同一行记录，最初的UPDATE 语句导致第二个事务的WHERE不会返回任何记录，因此第二个事务根本没有修改到任何记录

```ruby
Order.transaction do
  Order.where(ship_code: '123').update_all(ship_code: '123456')
  sleep 20
end

# 在第一个事务执行完update_all后提交之前执行
Order.transaction do
  Order.where(ship_code: '123').update_all(ship_code: '1234567')
end
# ship_code => 123456
# Order.where(ship_code: '123').update_all(ship_code: '1234567') 的时候已经找不到 where(ship_code: '123')

Order.transaction do
  Order.where(ship_code: '123').first.update(ship_code: '1234567')
end
# ship_code => 1234567
# 这种情况下会修改记录是因为 它先执行的是Order.where(ship_code: '123').first
# 因为默认的隔离级别是读已提交, 所以这个时候
# Order.where(ship_code: '123') 是可以拿到数据的
# 执行的sql语句是
## 先拿到order#id
## UPDATE "orders" SET "ship_code" = 1234567 WHERE "orders"."id" = order#id


# repeatable
Order.transaction do
   old_ship_code =  Order.where(id: 2).pluck(:ship_code)
   sleep 10
   new_ship_code =  Order.where(id: 2).pluck(:ship_code)
   p [old_ship_code, new_ship_code] # 数据是不一样的
end

Order.where(id: 2).update_all(ship_code: 123456123)

```

## 可重复读隔离级别
# gem 'transaction_isolation'
```ruby
ActiveRecord::Base.isolation_level(:repeatable_read) do
   Order.transaction do
       old_ship_code =  Order.where(id: 2).pluck(:ship_code)
       sleep 10
       new_ship_code =  Order.where(id: 2).pluck(:ship_code)
       p [old_ship_code, new_ship_code] # 数据是一样的
    end
end
```

## 可串行化隔离级别
可串行化级别提供最严格的事务隔离。这个级别为所有已提交事务模拟串行的事务执行，
就好像事务将被一个接着一个那样串行(而不是并行)的执行。不过，正如可重复读隔离级别一样，
使用这个级别的应用必须准备在串行化失败的时候重新启动事务。
事实上，该隔离级别和可重复读希望的完全一样，它只是监视这些条件，以所有事务的可能的序列不一致的（一次一个）的方式执行并行的可序列化事务执行的行为。
这种监测不引入任何阻止可重复读出现的行为，但有一些开销的监测，检测条件这可能会导致序列化异常 将触发序列化失败。

分析：如果你需要更好的“两个事务同时修改同一行数据”控制这种行为，你可以把事务隔离级别设置为 可串行化（SERIALIZABLE） 。
在这个策略下，上面的场景会直接失败，因为它遵循这样的规则：“如果我正在修改的行被其他事务修改过的话，就不再尝试”，
同时 Postgres会返回这样的错误信息：由于并发修改导致无法进行串行访问 。
捕获这个错误然后重试就是你的应用需要去做的事情了，或者不重试直接放弃也行，如果那样合理的话。
```ruby
ActiveRecord::Base.isolation_level(:serializable) do
   Order.transaction do
       old_ship_code =  Order.where(id: 2).update_all(ship_code: 123)
       sleep 10
    end
end

Order.where(id: 2).update_all(ship_code: 123)
# PG::TRSerializationFailure: ERROR:  could not serialize access due to concurrent update
# ActiveRecord::TransactionIsolationConflict
```