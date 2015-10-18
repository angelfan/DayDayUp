-- 1. 数据分组(max,min,avg,sum,count)

SQL>SELECT MAX(sal),MIN(age),AVG(sal),SUM(sal) from emp;

SQL>SELECT * FROM emp where sal=(SELECT MAX(sal) from emp));

SQL>SELEC COUNT(*) FROM emp;

-- 2. group by（用于对查询结果的分组统计） 和 having子句（用于限制分组显示结果）

SQL>SELECT deptno,MAX(sal),AVG(sal) FROM emp GROUP BY deptno;

SQL>SELECT deptno, job, AVG(sal),MIN(sal) FROM emp group by deptno,job having AVG(sal)<2000;

-- 对于数据分组的总结：
--
-- a. 分组函数只能出现在选择列表、having、order by子句中（不能出现在where中）
--
-- b. 如果select语句中同时包含有group by, having, order by，那么它们的顺序是group by, having, order by。
--
-- c. 在选择列中如果有列、表达式和分组函数，那么这些列和表达式必须出现在group by子句中，否则就是会出错。
--
-- 使用group by不是使用having的前提条件。

-- 3. 多表查询

SQL>SELECT e.name,e.sal,d.dname FROM emp e, dept d WHERE e.deptno=d.deptno order by d.deptno;

SQL>SELECT e.ename,e.sal,s.grade FROM emp e,salgrade s WHERE e.sal BETWEEN s.losal AND s.hisal;

-- 4. 自连接（指同一张表的连接查询）

SQL>SELECT er.ename, ee.ename mgr_name from emp er, emp ee where er.mgr=ee.empno;

-- 5. 子查询（嵌入到其他sql语句中的select语句，也叫嵌套查询）
--
-- 5.1 单行子查询

SQL>SELECT ename FROM emp WHERE deptno=(SELECT deptno FROM emp where ename='SMITH'); --查询表中与smith同部门的人员名字。因为返回结果只有一行，所以用“=”连接子查询语句

-- 5.2 多行子查询

SQL>SELECT ename,job,sal,deptno from emp WHERE job IN (SELECT DISTINCT job FROM emp WHERE deptno=10); --查询表中与部门号为10的工作相同的员工的姓名、工作、薪水、部门号。因为返回结果有多行，所以用“IN”连接子查询语句。

-- in与exists的区别： exists() 后面的子查询被称做相关子查询，它是不返回列表的值的。只是返回一个ture或false的结果，其运行方式是先运行主查询一次，再去子查询里查询与其对 应的结果。如果是ture则输出，反之则不输出。再根据主查询中的每一行去子查询里去查询。in()后面的子查询，是返回结果集的，换句话说执行次序和 exists()不一样。子查询先产生结果集，然后主查询再去结果集里去找符合要求的字段列表去。符合要求的输出，反之则不输出。
--
-- 5.3 使用ALL
-- 查询工资比部门号为30号的所有员工工资都高的员工的姓名、薪水和部门号。以上两个语句在功能上是一样的，但执行效率上，函数会高 得多。
SQL>SELECT ename,sal,deptno FROM emp WHERE sal> ALL (SELECT sal FROM emp WHERE deptno=30);
SQL>SELECT ename,sal,deptno FROM emp WHERE sal> (SELECT MAX(sal) FROM emp WHERE deptno=30);

-- 5.4 使用ANY
-- 查询工资比部门号为30号的任意一个员工工资高（只要比某一员工工资高即可）的员工的姓名、薪水和部门号。以上两个语句在功能上是 一样的，但执行效率上，函数会高得多。
SQL>SELECT ename,sal,deptno FROM emp WHERE sal> ANY (SELECT sal FROM emp WHERE deptno=30);
SQL>SELECT ename,sal,deptno FROM emp WHERE sal> (SELECT MIN(sal) FROM emp WHERE deptno=30);

-- 5.5 多列子查询

SQL>SELECT * FROM emp WHERE (job, deptno)=(SELECT job, deptno FROM emp WHERE ename='SMITH');

-- 5.6 在from子句中使用子查询

SQL>SELECT emp.deptno,emp.ename,emp.sal,t_avgsal.avgsal FROM emp,(SELECT emp.deptno,avg(emp.sal) avgsal FROM emp GROUP BY emp.deptno) t_avgsal where emp.deptno=t_avgsal.deptno AND emp.sal>t_avgsal.avgsal ORDER BY emp.deptno;

-- 5.7 分页查询
--
-- 数据库的每行数据都有一个对应的行号，称为rownum.

SQL>SELECT a2.* FROM (SELECT a1.*, ROWNUM rn FROM (SELECT * FROM emp ORDER BY sal) a1 WHERE ROWNUM<=10) a2 WHERE rn>=6;

-- 指定查询列、查询结果排序等，都只需要修改最里层的子查询即可。
--
-- 5.8 用查询结果创建新表

SQL>CREATE TABLE mytable (id,name,sal,job,deptno) AS SELECT empno,ename,sal,job,deptno FROM emp;

-- 5.9 合并查询（union 并集, intersect 交集, union all 并集+交集, minus差集)

SQL>SELECT ename, sal, job FROM emp WHERE sal>2500 UNION(INTERSECT/UNION ALL/MINUS) SELECT ename, sal, job FROM emp WHERE job='MANAGER';

-- 合并查询的执行效率远高于and,or等逻辑查询。
--
--  5.10 使用子查询插入数据

SQL>CREATE TABLE myEmp(empID number(4), name varchar2(20), sal number(6), job varchar2(10), dept number(2)); -- 先建一张空表；

SQL>INSERT INTO myEmp(empID, name, sal, job, dept) SELECT empno, ename, sal, job, deptno FROM emp WHERE deptno=10; -- 再将emp表中部门号为10的数据插入到新表myEmp中，实现数据的批量查询。

-- 5.11 使用了查询更新表中的数据

SQL>UPDATE emp SET(job, sal, comm)=(SELECT job, sal, comm FROM emp where ename='SMITH') WHERE ename='SCOTT';