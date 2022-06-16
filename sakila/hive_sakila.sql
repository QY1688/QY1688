show databases ;
create database if not exists sakila ;
use sakila ;
---- create actor
create table if not exists actor (
    actor_id SMALLINT comment "演员id",
    first_name VARCHAR(45) comment "first_name",
    last_name VARCHAR(45)comment "last_name",
    last_update TIMESTAMP comment "上一次更新时间"
) comment "演员信息表"
row format delimited
fields terminated by "," ;

---创建中间表保存，以加载timestamp 字段
create table if not exists actor_tmp (
                                         actor_id SMALLINT comment "自增ID",
                                         first_name VARCHAR(45) comment "first_name",
                                         last_name VARCHAR(45)comment "last_name",
                                         last_update STRING comment "上一次更新时间"
) comment "演员信息表"
    row format delimited
    fields terminated by ","
    tblproperties("skip.header.line.count"="1");  --跳过第一行表头数据
select * from actor_tmp ;
load data local inpath '/otherdata/actor.txt' into table  actor_tmp ;
insert overwrite table actor
select actor_id ,first_name,last_name, date_format(last_update,'yyyy-MM-dd hh:mm:ss') FROM actor_tmp ;
--date_format(  cast(last_update as timestamp),'yyyy-MM-dd hh:mm:ss')  注意格式的大小写
select *  from actor ;
drop table if exists actor_tmp ;

--address
CREATE TABLE if not exists address (
                         address_id SMALLINT  comment "地址ID" ,
                         address VARCHAR(50) comment "地址",
                         address2 VARCHAR(50) comment "地址2",
                         district VARCHAR(20) comment "地区",
                         city_id SMALLINT  comment "城市ID",
                         postal_code VARCHAR(10) comment "邮编",
                         phone VARCHAR(20) comment "电话",
                         location varchar(50) comment "经纬度",
                         last_update timestamp comment "上一次更新时间")
                         comment "地址表"
    row format delimited
    fields terminated by "," ;

---创建中间表保存，以加载timestamp 字段
CREATE TABLE if not exists address_tmp (
                                       address_id SMALLINT  comment "地址ID" ,
                                       address VARCHAR(50) comment "地址",
                                       address2 VARCHAR(50) comment "地址2",
                                       district VARCHAR(20) comment "地区",
                                       city_id SMALLINT  comment "城市ID",
                                       postal_code VARCHAR(10) comment "邮编",
                                       phone VARCHAR(20) comment "电话",
                                       location varchar(50) comment "经纬度",
                                       last_update string comment "上一次更新时间")
    comment "地址表"
    row format delimited
    fields terminated by ","
    tblproperties("skip.header.line.count"="1");
describe  address ;
load data local inpath '/otherdata/address.txt' into table  address_tmp ;
select * from address_tmp ;
insert overwrite table address
select address_id ,address,address2,district, city_id,postal_code, phone ,location,date_format(last_update,'yyyy-MM-dd hh:mm:ss') FROM address_tmp ;
select *  from address ;
drop table if exists address_tmp ;

--create category
CREATE TABLE if not exists category (
                        category_id TINYINT comment "类别id",
                        name VARCHAR(25) comment "类别名称",
                        last_update TIMESTAMP comment "上一次更新时间"
) comment "类别表"
    row format delimited
    fields terminated by ",";

CREATE TABLE if not exists category_tmp (
                                        category_id TINYINT comment "类别id",
                                        name VARCHAR(25) comment "类别名称",
                                        last_update string comment "上一次更新时间"
) comment "类别表"
    row format delimited
    fields terminated by ","
    tblproperties("skip.header.line.count"="1");
describe  category ;
load data local inpath '/otherdata/category.txt' into table  category_tmp ;
select * from category_tmp ;
insert overwrite table category
select category_id ,name,date_format(last_update,'yyyy-MM-dd hh:mm:ss') FROM category_tmp ;
select *  from category ;
drop table if exists category_tmp ;

--CREATE  city
CREATE TABLE if not exists city (
                      city_id SMALLINT comment"城市id" ,
                      city VARCHAR(50) comment"城市",
                      country_id SMALLINT comment"国家id",
                      last_update TIMESTAMP comment"上一次更新时间"
) comment "城市表"
    row format delimited
    fields terminated by "," ;

CREATE TABLE if not exists city_tmp (
                                    city_id SMALLINT comment"城市id" ,
                                    city VARCHAR(50) comment"城市",
                                    country_id SMALLINT comment"国家id",
                                    last_update string comment"上一次更新时间"
) comment "城市表"
    row format delimited
    fields terminated by ","
    tblproperties("skip.header.line.count"="1");

describe  city ;
load data local inpath '/otherdata/city.txt' into table  city_tmp ;
select * from city_tmp ;
insert overwrite table city
select city_id ,city,country_id,date_format(last_update,'yyyy-MM-dd hh:mm:ss') FROM city_tmp ;
select *  from city ;
drop table if exists city_tmp ;

--CREATE country
CREATE TABLE country (
                         country_id SMALLINT   comment"城市id" ,
                         country VARCHAR(50)  comment"城市id",
                         last_update TIMESTAMP   comment"上一次更新时间"
)comment "国家表"
    row format delimited
    fields terminated by "," ;

CREATE TABLE country_tmp (
                         country_id SMALLINT   comment"城市id" ,
                         country VARCHAR(50)  comment"城市id",
                         last_update string   comment"上一次更新时间"
)comment "国家表"
    row format delimited
    fields terminated by ","
    tblproperties("skip.header.line.count"="1");
describe  country ;
load data local inpath '/otherdata/country.txt' into table  country_tmp ;
select * from country_tmp ;
insert overwrite table country
select country_id ,country,date_format(last_update,'yyyy-MM-dd hh:mm:ss') FROM country_tmp ;
select *  from country ;
drop table if exists country_tmp ;

--CREATE customer
CREATE TABLE customer (
                          customer_id SMALLINT  comment"客户id",
                          store_id TINYINT  comment"店铺id",
                          first_name VARCHAR(45)  comment"first_name",
                          last_name VARCHAR(45)  comment"last_name",
                          email VARCHAR(50)  comment"email",
                          address_id SMALLINT  comment"位置id",
                          active BOOLEAN  comment"是否活跃",
                          create_date TIMESTAMP  comment"创建时间",
                          last_update TIMESTAMP comment"上一次更新时间"
)comment "客户表"
    row format delimited
    fields terminated by "," ;

CREATE TABLE customer_tmp (
                          customer_id SMALLINT  comment"客户id",
                          store_id TINYINT  comment"店铺id",
                          first_name VARCHAR(45)  comment"first_name",
                          last_name VARCHAR(45)  comment"last_name",
                          email VARCHAR(50)  comment"email",
                          address_id SMALLINT  comment"位置id",
                          active SMALLINT comment"是否活跃",
                          create_date string  comment"创建时间",
                          last_update string comment"上一次更新时间"
)comment "客户表"
    row format delimited
    fields terminated by ","
    tblproperties("skip.header.line.count"="1");
describe  customer ;
load data local inpath '/otherdata/customer.txt' into table  customer_tmp ;
select * from customer_tmp ;
insert overwrite table customer
select customer_id,store_id ,first_name,last_name,email,
       address_id,case when active =1 then TRUE ELSE FALSE END  ,date_format(create_date,'yyyy-MM-dd hh:mm:ss') ,
       date_format(last_update,'yyyy-MM-dd hh:mm:ss') FROM customer_tmp ;
select *  from customer ;
drop table if exists customer_tmp ;

--- create film
CREATE TABLE if not exists film (
                                    film_id SMALLINT comment "电影id",
                                    title VARCHAR(128) comment "电影标题",
                                    description string  comment "电影细节描述",
                                    release_year smallint  comment "发布年份",
                                    language_id TINYINT  comment "语言id",
                                    original_language_id TINYINT   comment "电影源语言id",
                                    rental_duration TINYINT   comment "租借期限",
                                    rental_rate DECIMAL(4,2)    comment "租借费率",
                                    length SMALLINT comment "电影时长",
                                    replacement_cost DECIMAL(5,2)   comment "置换成本",
                                    rating  string comment "评级",
                                    special_features string comment "电影特征",
                                    last_update TIMESTAMP comment "上一次更新时间"
)comment "电影表"
    row format delimited
        fields terminated by ";" ;

CREATE TABLE if not exists film_tmp (
                                        film_id SMALLINT comment "电影id",
                                        title VARCHAR(128) comment "电影标题",
                                        description string  comment "电影细节描述",
                                        release_year smallint  comment "发布年份",
                                        language_id TINYINT  comment "语言id",
                                        original_language_id TINYINT   comment "电影源语言id",
                                        rental_duration TINYINT   comment "租借期限",
                                        rental_rate DECIMAL(4,2)    comment "租借费率",
                                        length SMALLINT comment "电影时长",
                                        replacement_cost DECIMAL(5,2)   comment "置换成本",
                                        rating  string comment "评级",
                                        special_features string comment "电影特征",
                                        last_update TIMESTAMP comment "上一次更新时间"
)comment "电影表"
    row format delimited
        fields terminated by ";"
    tblproperties("skip.header.line.count"="1");
describe  film ;
load data local inpath '/otherdata/film.txt' into table film_tmp ;
insert overwrite table  film
select film_id,title,description,release_year,language_id,original_language_id,rental_duration,
       rental_rate,length,replacement_cost,rating,special_features,date_format(last_update, 'yyyy-MM-dd hh:mm:ss') from film_tmp ;
select * from film ;
drop table if exists film_tmp;

---create  film_actor
CREATE TABLE if not exists film_actor (
                                          actor_id SMALLINT comment "演员id",
                                          film_id SMALLINT comment "电影id",
                                          last_update TIMESTAMP comment "上一次更新时间"
) comment "电影演员关系表"
    row format delimited
        fields terminated by "," ;

CREATE TABLE if not exists film_actor_tmp (
                                              actor_id SMALLINT comment "演员id",
                                              film_id SMALLINT comment "电影id",
                                              last_update string comment "上一次更新时间"
) comment "电影演员关系表"
    row format delimited
        fields terminated by ","
    tblproperties('skip.header.line.count'='1') ;
describe  film_actor ;
load data local inpath '/otherdata/film_actor.txt' into table film_actor_tmp;
insert overwrite table  film_actor
select actor_id,film_id,date_format(last_update, 'yyyy-MM-dd hh:mm:ss') from film_actor_tmp;
select * from film_actor ;
drop table if exists film_actor_tmp;

--create  film_category
CREATE TABLE if not exists film_category (
                                             film_id SMALLINT comment "电影id",
                                             category_id TINYINT comment "类别id",
                                             last_update TIMESTAMP  comment "上一次更新时间"
)comment "电影类别表"
    row format delimited
    fields terminated by ","
    tblproperties('skip.header.line.count'='1') ;

describe  film_category ;
load data local inpath '/otherdata/film_category.txt' into table film_category ;

select * from film_category ;

---create  film_text
CREATE TABLE if not exists film_text (
                                         film_id SMALLINT  comment "电影id",
                                         title VARCHAR(255)  comment "电影标题",
                                         description string  comment "电影描述" ,
                                         FULLTEXT string  comment "电影描述明细"
) comment "电影描述表"
    row format delimited
    fields terminated by ","
    tblproperties('skip.header.line.count'='1');
describe  film_text ;
load data local inpath '/otherdata/film_text.txt' into table film_text ;
select * from film_text ;
--- create inventory
CREATE TABLE if not exists inventory (
                                         inventory_id INT comment "库存id"  ,
                                         film_id SMALLINT comment "电影id",
                                         store_id TINYINT comment "商店id",
                                         last_update TIMESTAMP comment "上一次更新时间"
)comment "库存表"
    row format delimited
    fields terminated by ","
    tblproperties('skip.header.line.count'='1');

describe  inventory ;
load data local inpath '/otherdata/inventory.txt' into table inventory ;
select * from inventory ;

--create language
CREATE TABLE if not exists  language (
                                         language_id TINYINT comment "语言id"  ,
                                         name CHAR(20) comment "语言名称" ,
                                         last_update TIMESTAMP  comment "上一次更新时间"
)comment "语言表"
    row format delimited
        fields terminated by ","
    tblproperties('skip.header.line.count'='1');

CREATE TABLE if not exists  language_tmp (
                                             language_id TINYINT comment "语言id"  ,
                                             name CHAR(20) comment "语言名称" ,
                                             last_update TIMESTAMP  comment "上一次更新时间"
)comment "语言表"
    row format delimited
    fields terminated by ","
    tblproperties('skip.header.line.count'='1') ;
describe  language ;
load data local inpath '/otherdata/language.txt' into table language ;
select * from language ;

--- create payment
CREATE TABLE if not exists  payment (
                                        payment_id SMALLINT   comment "支付id" ,
                                        customer_id SMALLINT comment "客户id"  ,
                                        staff_id TINYINT  comment "职工id" ,
                                        rental_id INT  comment "租借id" ,
                                        amount DECIMAL(5,2) comment "总额" ,
                                        payment_date TIMESTAMP comment "付款日期" ,
                                        last_update TIMESTAMP  comment "上一次更新时间"
) comment "支付表"
    row format delimited
    fields terminated by ","
    tblproperties('skip.header.line.count'='1');

load data local inpath '/otherdata/payment.txt' into table payment ;
select * from payment ;

---create rental
CREATE TABLE if not exists rental (
                                      rental_id INT  comment "租借id"   ,
                                      rental_date TIMESTAMP   comment "租借日期" ,
                                      inventory_id int    comment "仓库id" ,
                                      customer_id SMALLINT   comment "客户id"  ,
                                      return_date TIMESTAMP   comment "归还日期" ,
                                      staff_id TINYINT    comment "职工id" ,
                                      last_update TIMESTAMP  comment "上一次更新时间"
) comment "租借表"
    row format delimited
    fields terminated by ","
    tblproperties('skip.header.line.count'='1');

describe  rental ;
load data local inpath '/otherdata/rental.txt' into table rental ;
select * from rental ;

--create
CREATE TABLE if not exists staff (
                                     staff_id TINYINT comment "职工id"  ,
                                     first_name VARCHAR(45) comment "first_name" ,
                                     last_name VARCHAR(45) comment "last_name" ,
                                     address_id SMALLINT comment "地址id" ,
                                     picture string comment "图片" ,
                                     email VARCHAR(50) comment "email" ,
                                     store_id TINYINT comment "商店id" ,
                                     active BOOLEAN comment "是否活跃" ,
                                     username VARCHAR(16) comment "用户名称" ,
                                     password VARCHAR(40) comment "密码" ,
                                     last_update TIMESTAMP comment "上一次更新时间"
)comment "职工表"
    row format delimited
    fields terminated by ",";

CREATE TABLE if not exists staff_tmp (
                                         staff_id TINYINT comment "职工id"  ,
                                         first_name VARCHAR(45) comment "first_name" ,
                                         last_name VARCHAR(45) comment "last_name" ,
                                         address_id SMALLINT comment "地址id" ,
                                         picture string comment "图片" ,
                                         email VARCHAR(50) comment "email" ,
                                         store_id TINYINT comment "商店id" ,
                                         active int comment "是否活跃" ,
                                         username VARCHAR(16) comment "用户名称" ,
                                         password VARCHAR(40) comment "密码" ,
                                         last_update TIMESTAMP comment "上一次更新时间"
)comment "职工表"
    row format delimited
        fields terminated by ","
    tblproperties('skip.header.line.count'='1');
describe  staff ;
load data local inpath '/otherdata/staff.txt' into table staff_tmp ;
insert overwrite table  staff
select  staff_id,first_name,last_name,address_id,picture,email,store_id,case when active =1 then TRUE ELSE FALSE END
     ,username,password,date_format(last_update, 'yyyy-MM-dd hh:mm:ss') from staff_tmp ;
select * from staff ;
drop table if exists staff_tmp;

--create store
CREATE TABLE if not exists store (
                                     store_id TINYINT  comment "店铺id"   ,
                                     manager_staff_id TINYINT comment "管理员职工id"   ,
                                     address_id SMALLINT   comment "地址id" ,
                                     last_update TIMESTAMP comment "上一次更新时间"
)   comment "店铺表"
    row format delimited
    fields terminated by ","
    tblproperties('skip.header.line.count'='1');
describe  store ;
load data local inpath '/otherdata/store.txt' into table store ;
select * from store ;
















