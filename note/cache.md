# Cache

## Etag(客户端缓存)
ActionController::ConditionalGet

其过程如下：
客户端请求一个页面（A）。 服务器返回页面A，并在给A加上一个ETag。
客户端展现该页面，并将页面连同ETag一起缓存。
客户再次请求页面A，并将上次请求时服务器返回的ETag一起传递给服务器。
服务器检查该ETag，并判断出该页面自上次客户端请求之后还未被修改，直接返回响应304（未修改——Not Modified）和一个空的响应体。

ps:
如果nginx开启了gzip，Nginx会简单的把Etag去掉, 导致Etag无效了。
解决办法：
1. 用Rack中间件进行gzip压缩;
```ruby
config.middleware.use Rack::Deflater
```
2. 修改nginx源代码;
```
src/http/modules/ngx_http_gzip_filter_module.c
//ngx_http_clear_etag(r);
```
3. [Weak Etag](en.wikipedia.org/wiki/HTTP_ETag)

## Nginx缓存

## 整页缓存

## 片段缓存
ActionController::Caching::Fragments

## 数据查询缓存


## 数据库缓存
```shell
mysql> SHOW VARIABLES LIKE 'have_query_cache';

mysql> SHOW VARIABLES LIKE ’%query_cache%’;
```
+------------------------------+---------+
| Variable_name                | Value   |
+------------------------------+---------+
| have_query_cache             | YES     | --查询缓存是否可用
| query_cache_limit            | 1048576 | --可缓存具体查询结果的最大值
| query_cache_min_res_unit     | 4096    |
| query_cache_size             | 599040  | --查询缓存的大小
| query_cache_type             | ON      | --阻止或是支持查询缓存
| query_cache_wlock_invalidate | OFF     |
+------------------------------+---------+

