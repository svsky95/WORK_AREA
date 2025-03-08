--oralce 生成较少的redo和undo的语句
1、direct load option (sql loader,insert /*+append*/ into )    --高水位线插入
2、create table ..,alter table.., nologging .
3、create index ..,alter index.., nologging .
4、create materialized view ,alter materialized view nologging.


--cache buffers chains 锁存器争用
当多个sql扫描少数特定的数据块时，就会发生hot block引起的cache buffers chains争用。
解决方法：通过设计上的问题，接触反复扫描相同的数据块。

--cache buffer lru chain 锁存器争用
db file scattered read ,cache buffers chains ,cache buffer lru chain 都是sql语句执行效率较低导致，sql语句优化是最有效的方法。

--buffer lock
正常情况下，当两个session共同修改不同的行时，是可以同时修改，不受相互的影响，但当这两行数据同时存在同一个数据块时，就会出现buffer lock,若没有buffer lock,则会产生正常的行锁。

--select的buffer lock争用
当有众多的session访问相同的表时，会出现db file sequanational read ,read by other sesson,db file scanttered read 的等待事件，但是当第二次执行时，由于数据已经存放在高速缓冲区，所以相关的等待就会消失。