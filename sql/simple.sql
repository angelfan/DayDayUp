

select * from table1 where 工资>2500 and 工资<3000 //同上

select 姓名 from table1 where 性别='0' and 工资='4000'

select * from table1 where not 工资= 3200

select * from table1 order by 工资desc //将工资按照降序排列

select * from table1 order by 工资 asc //将工资按照升序排列

select * from table1 where year(出身日期)=1987 //查询table1 中所有出身在1987的人select * from table1 where name like '%张' /'%张%' /'张%' //查询1，首位字‘张’3，尾位字‘张’2，模糊查询

select * from table1 order by money desc //查询表1按照工资的降序排列表1 (升序为asc)

select * from table1 where brithday is null //查询表1 中出身日期为空的人

use 数据库(aa) //使用数据库aa

create bb(数据库) //创建数据库bb

create table table3 ( name varchar(10),sex varchar(2),money money, brithday datetime)//创建一个表3中有姓名，性别，工资，出身日期 （此表说明有四列）

insert into table3 values ('张三'，'男'，'2500','1989-1-5')//在表中添加一行张三的记录

alter table table3 add tilte varchar(10) //向表3 中添加一列“title(职位)”

alter table table3 drop column sex //删除table3中‘性别’这一列

drop database aa //删除数据库aa

drop table table3 //删除表3

delete * from table3 //删除table3 中所有的数据，但table3这个表还在

delete from table1 where 姓名='倪涛' and 日期 is null

delete from table1 where 姓名='倪涛' and 日期='1971'

select * into table2 from table3 //将表3中的所有数据转换成表2 （相当于复制）

update table3 set money=money*1.2 //为表3所有人工资都增长20%

update table3 set money=money*1.2 where title='经理' //为表3中“职位”是经理的人工资增长20%

update table1 set 工资= 5000 where 姓名='孙八' //将姓名为孙八的人的工资改为5000

update table1 set 姓名='敬光' where 姓名='倪涛' and 性别=1 //将性别为男和姓名为倪涛的人改为敬光
