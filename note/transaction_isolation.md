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

| 时间 |  	转账事务A    |     取款事务B     |
|-----|-----------------|------------------|
|  T1 |	                | 开始事务          |
|  T2 |	  开始事务       | 开始事务          |
|  T3 |	                | 查询账户余额1000  |
|  T4 |	                | 去除500元，余额500 |
|  T5 |查询余额为500(脏读)|                   |
|  T6 |	                | 撤销事务余额恢复1000 |
|  T7 |汇入100，额外改600|               |
|  T8 |	 提交事务       |           |


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
```ruby
# gem 'transaction_isolation'
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



## 第一类丢失更新
A事务撤销时，把已经提交的B事务的更新数据覆盖了。这种错误可能造成很严重的问题，通过下面的账户取款转账就可以看出来：

| 时间 | 取款事务 | 转账事务B |
|-----|---------|----------|
|  T1 | 开始事务 | |
|  T1 | | 开始事务 |
|  T1 | 查询账户余额为1000元 | |
|  T1 | | 查询账户余额为1000元 |
|  T1 | | 汇入100元， 把余额改为1100元 |
|  T1 | | 提交事务 |
|  T1 | 取出100元, 把余额改为900元 | |
|  T1 | 撤销事务 | |
|  T1 | 余额恢复为1000元 |

## 第二类丢失更新
A事务覆盖B事务已经提交的数据，造成B事务所做操作丢失：

| 时间 | 转账事务 | 取款事务B |
|-----|---------|----------|
|  T1 |  | 开始事务 |
|  T1 | 开始事务  |  |
|  T1 |  | 查询账户余额为1000元 |
|  T1 |查询账户余额为1000元  |  |
|  T1 | | 取100元， 把余额改为900元 |
|  T1 | | 提交事务 |
|  T1 | 汇100元, | |
|  T1 | 提交事务 | |
|  T1 | 把余额改为1100元 |


| 隔离级别 |	脏读 | 不可重复读 | 幻读 | 第一类丢失更新 | 第二类丢失更新 |
|---------|-------|---------|-----| -------------| ------------- |
| 读未提交 |	 可能  |  可能 	|可能  | 不允许 | 允许 |
| 读已提交 |	不可能 |   可能  | 可能 | 不允许 | 允许 |
| 可重复读 |	不可能 |	不可能 	|可能 | 不允许 | 不允许 |
| 可串行化 |	不可能 |	不可能 	|不可能 | 不允许 | 不允许 |


## 悲观锁
事务中对需要修改的结果集加行锁,常用的就是select for update,或者lock table对整个表加锁。
加锁之后,当前事务未处理完成之前,其他所有需要访问锁定行的事务都必须等待。
这虽然能解决更新丢失(覆盖)的问题,但很明显会影响数据库的并发性能。
如果并发事务冲突的几率很高,则采用悲观锁可以减少事务回滚并重试的开销。

## 乐观锁
乐观锁不锁定任何行,当更新数据时再做检查数据是否已经发生了变化。多版本并发控制MVCC(Multiversion concurrency control)可以实现乐观锁。
PostgreSQL使用MVCC实现并发控制。PostgreSQL的默认事务隔离级别为读已提交(Read Commited),在这个级别上会发生不可重复读现象,这个隔离级别是无法防止更新丢失(覆盖)的

但是在可重复读(Repeatable Read)事务隔离级别,可以完全防止更新丢失(覆盖)的问题,如果当前事务读取了某行,这期间其他并发事务修改了这一行并提交了,然后当前事务试图更新该行时,
PostgreSQL会提示: ERROR: could not serialize access due to concurrent update
事务会被回滚,只能重新开始

由于使用的是MVCC机制的乐观锁,内部有版本号(这个字段名字叫xmin)来控制并发,所以不会对数据集上锁,对性能的影响是很小的。但如果并发事务冲突的几率比较大,那么事务回滚的开销就比较大了

备注： 测试postgre在隔离级别为读已提交的情况下 也不会发生第二类丢失更新
测试demo
```ruby
# 事务1
Order.transaction do
  order = Order.find(2)
  sleep 2
  order.update(approved: false)
end

# 事务2
Order.transaction do
  order = Order.find(2)
  order.update(approved: true)
end
```

## Other

还有一种防止更新丢失(覆盖)的方法叫条件更新,也就是在更新时指定where子句,检测指定的条件是否已经变化来决定是否进行更新。
这不是一种通用的解决方案,只能根据业务逻辑来选择特定的检测条件,并不能防止这些检测条件之外的可能存在的更新丢失问题。
而且有些情况下可能很难选择合适的更新检测条件,比如一个银行账户,关键的字段有账户号和余额,很难通过WHERE条件来检测当前事务执行期间是否有其他并发事务已经修改了余额并做了提交。
所以这种方法只在特定的逻辑环境下有一定的用途。


## tip
```ruby

unless rerord.approved?
    # balabala # 多个thread可能同时到达这里
    rerord.update(approved: true)
end # 并发下会导致一些问题

# better
# combine query
update_count = Rerord.where(id: id, approved: false).update_all(approved: true)
# 根据上面的理论 并发下 不会导致某个record会被重复更新
if update_count == 1
    # balabala
end

# Optimistic locking

# Pessimistic locking
```


## Optimistic locking
有的时候可能是指希望某些逻辑使用乐观锁
```ruby
# Optimistic locking
module OptimisticallyLockable
  extend ActiveSupport::Concern
  included do
    self.lock_optimistically = false
  end

  module ClassMethods
    def with_optimistic_locking
      self.lock_optimistically = true

      begin
        yield
      ensure
        self.lock_optimistically = false
      end
    end
  end
end
```
redis-objects会重写active_record中的lock
不想打patch可以这样

# Pessimistic locking
```ruby
module RedisCacheable
  extend ActiveSupport::Concern

  included do
    class << self
      alias_method(:temp_lock_method, :lock)
    end

    include Redis::Objects

    class << self
      alias_method(:redis_lock, :lock)
      alias_method(:lock, :temp_lock_method)
      remove_method(:temp_lock_method)
    end
  end
end
```

