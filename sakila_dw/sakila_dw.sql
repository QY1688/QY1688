--show databases ;

create database if not exists sakila_dw ;
use sakila_dw ;

---create  dim_time
create table if not exists dim_time (
                                        date_key int comment "日期代理键",
                                        date_value date comment "日期",
                                        is_workday boolean comment "是否工作日",
                                        day_in_week tinyint comment "当周的第几天",
                                        day_in_month tinyint comment "当月的第几天",
                                        day_in_year smallint comment "当年的第几天",
                                        week_in_month tinyint  comment "月的第几周",
                                        week_in_year tinyint comment "年的第几周",
                                        month_number tinyint comment "月份",
                                        quarter_number tinyint  comment "季度",
                                        year_number tinyint  comment "年份",
                                        create_tmie timestamp comment "数据创建日期"
) comment "日期维度表" ;

--create  dim_actor
CREATE TABLE if not exists dim_actor (
                                         actor_key int comment "代理键",
                                         actor_id int comment "演员id",
                                         actor_first_name string  comment "actor_first_name",
                                         actor_last_name string comment "actor_last_name",
                                         actor_last_update timestamp comment "最后更新时间"
) comment "演员维度表" ;
--载入数据  保留最新的一份数据
with tmp as ( select  nvl(max(actor_last_update),to_date('1970-01-01 00:00:00')) max_last_update  from  dim_actor )
insert overwrite  table dim_actor
select row_number() over (order by t.actor_id), actor_id,actor_first_name,actor_last_name,actor_last_update from (
                     select b.actor_id,actor_first_name,actor_last_name,actor_last_update from dim_actor b
                            where b.actor_id not in (select a.actor_id  from sakila.actor a ,tmp where  last_update > max_last_update )
             union all
                        select actor_id,first_name,last_name,current_timestamp   from sakila.actor ,tmp
                           where  last_update > max_last_update ) t;

--create dim_customer
CREATE TABLE dim_customer (
                              customer_key int comment "代理键",
                              customer_id int comment "客户id",
                              customer_first_name string comment "customer_first_name",
                              customer_last_name string comment "customer_last_name",
                              customer_email string comment "customer_email",
                              customer_active boolean  comment "是否活跃",
                              customer_created date  comment "创建时间",
                              customer_address string  comment "地址",
                              customer_country string comment "国家",
                              customer_district string  comment "地区",
                              customer_city string comment "城市",
                              customer_postal_code string comment "邮编",
                              customer_phone_number string comment "电话",
                              customer_version_number smallint comment "版本号",
                              customer_valid_from date  comment "开始时间",
                              customer_valid_through date comment "结束时间",
                              customer_last_update timestamp comment "最后更新日期"
) comment "客户维度表" ;
--载入数据 拉链表的形式保存

insert overwrite  table dim_customer
select  row_number()over(order by customer_id) ,t.* from (
                                                             select t1.customer_id,customer_first_name,customer_last_name,customer_email,customer_active,customer_created,customer_address,
                                                                    customer_country,customer_district,customer_city,customer_postal_code,customer_phone_number,t1.customer_version_number,
                                                                    case when customer_valid_through =to_date('9999-12-31') and t2.customer_id is not null then t1.customer_valid_through else customer_valid_from  end customer_valid_from,
                                                                    case when customer_valid_through =to_date('9999-12-31') and t2.customer_id is not null then to_date(current_timestamp) else t1.customer_valid_through end customer_valid_through,
                                                                    case when customer_valid_through =to_date('9999-12-31') and t2.customer_id is not null then current_timestamp  else t1.customer_last_update end customer_last_update
                                                             from  sakila_dw.dim_customer t1 left join (select * from  sakila.customer cu,
                                                                                                                       (select nvl(max(customer_last_update),to_date('1970-01-01')) max_last_update from dim_customer) tmp
                                                                                                        where cu.last_update > max_last_update )  t2
                                                                                                       on t1.customer_id=t2.customer_id
                                                             union all
                                                             select  a.customer_id ,a.first_name,a.last_name,a.email,a.active,a.create_date, b.address,d.country,b.district,
                                                                     c.city,b.postal_code,b.phone,tmp.max_version_number+1,to_date(current_timestamp),to_date('9999-12-31'),current_timestamp
                                                             from  sakila.customer a left join  sakila.address b
                                                                                                on a.address_id=b.address_id
                                                                                     left join sakila.city c
                                                                                               on b.city_id=c.city_id
                                                                                     left join sakila.country d
                                                                                               on c.country_id =d.country_id

                                                                                     join (select nvl(max(customer_last_update),to_date('1970-01-01')) max_last_update ,
                                                                                                  nvl(max(customer_version_number),0) max_version_number from dim_customer) tmp
                                                                                          on 1=1
                                                             where a.last_update > max_last_update  ) t  ;

---dim_film
CREATE TABLE if not exists dim_film (
                                        film_key int comment  "代理键",
                                        film_id int  comment"电影id",
                                        film_last_update timestamp  comment"最后更新时间",
                                        film_title string  comment"电影标题",
                                        film_description string  comment"电影细节描述",
                                        film_release_year smallint  comment"发布年份" ,
                                        film_language string   comment"语言",
                                        film_original_language string comment "电影源语言" ,
                                        film_rental_duration tinyint  comment"租借期限" ,
                                        film_rental_rate decimal(4,2)  comment"租借费率" ,
                                        film_length  SMALLINT comment "电影时长" ,
                                        film_replacement_cost decimal(5,2) comment "置换成本" ,
                                        film_rating_code string  comment"评级",
                                        film_rating_text string  comment"评级描述",
                                        film_has_trailers string  comment"是否有预告片",
                                        film_has_commentaries string  comment"是否有评论",
                                        film_has_deleted_scenes string  comment"是否有删除片段",
                                        film_has_behind_the_scenes string  comment"是否有幕后",
                                        film_category string comment "电影类别"
    /* film_in_category_action string  comment"动作",
     film_in_category_animation string  comment"动画",
     film_in_category_children string  comment"幼儿",
     film_in_category_classics string  comment"经典",
     film_in_category_comedy string  comment"喜剧",
     film_in_category_documentary string  comment"纪录片",
     film_in_category_drama string  comment"喜剧",
     film_in_category_family string  comment"家庭",
     film_in_category_foreign string  comment"外国",
     film_in_category_games string  comment"比赛",
     film_in_category_horror string  comment"恐怖",
     film_in_category_music string  comment"音乐",
     film_in_category_new string  comment"新闻",
     film_in_category_scifi string  comment"科幻",
     film_in_category_sports string  comment"运动",
     film_in_category_travel string  comment"旅游" */
) comment "电影维度表"  ;

insert overwrite table dim_film
select  row_number() over (order by film_id ),  film_id, film_last_update, film_title, film_description,
        film_release_year, film_language, film_original_language,
        film_rental_duration, film_rental_rate , film_length,
        film_replacement_cost,
        film_rating_code,
        film_rating_text,
        max( film_has_trailers),
        max( film_has_commentaries),
        max( film_has_deleted_scenes ),
        max( film_has_behind_the_scenes),
        film_category from
    (select   f.film_id film_id,f.last_update film_last_update,f.title film_title,f.description film_description,
              f.release_year film_release_year,l1.name film_language,l2.name film_original_language,
              f.rental_duration film_rental_duration,f.rental_rate film_rental_rate ,f.length film_length,
              f.replacement_cost film_replacement_cost,
              f.rating film_rating_code,
              case f.rating  when 'PG' then 'Parental Guidance Suggested'
                             when 'G' then  'General Audiences'
                             when 'NC-17' then 'No One Under 17 Admitted'
                             when  'PG-13' then 'Parents Strongly Cautioned'
                             when 'R' then 'Restricted' end film_rating_text,
              case features when 'Trailers' then 'YES' ELSE 'NO' end film_has_trailers,
              case features when 'Commentaries' then 'YES' ELSE 'NO' end film_has_commentaries,
              case features when 'Deleted Scenes' then 'YES' ELSE 'NO' end film_has_deleted_scenes,
              case features when 'Behind the Scenes' then 'YES' ELSE 'NO' end film_has_behind_the_scenes,
              ca.name  film_category
     from (select f1.*,  features from  sakila.film f1 lateral view explode(split(special_features,',')) table_tmp  as features) f left join
          sakila.language l1
          on f.language_id=l1.language_id
                                                                                                                                   left join sakila.language l2
                                                                                                                                             on original_language_id=l2.language_id
                                                                                                                                   left join sakila.film_category fc
                                                                                                                                             on f.film_id =fc.film_id
                                                                                                                                   left join sakila.category  ca
                                                                                                                                             on fc.category_id=ca.category_id ) tt
group by film_id, film_last_update, film_title, film_description,
         film_release_year, film_language, film_original_language,
         film_rental_duration, film_rental_rate , film_length,
         film_replacement_cost,
         film_rating_code,
         film_rating_text,film_category;

--create CREATE  dim_staff

CREATE TABLE  if not exists dim_staff (
                                          staff_key int comment"代理键",
                                          staff_id int comment"职工ID",
                                          staff_first_name string comment"staff_first_name",
                                          staff_last_name string comment"staff_last_name",
                                          staff_address_id SMALLINT comment "地址id" ,
                                          staff_email VARCHAR(50) comment "email" ,
                                          staff_store_id int comment"商店id",
                                          staff_active boolean  comment"是否活跃",
                                          staff_last_update timestamp comment"最后更新时间",
                                          staff_version_number smallint comment"版本号",
                                          staff_valid_from date comment"有效起始时间",
                                          staff_valid_through date  comment"有效结束时间"
) comment "职工维度表" ;
insert overwrite  table dim_staff
select  row_number()over(order by staff_id) ,t.* from (
                                                          select t1.staff_id,staff_first_name,staff_last_name,staff_address_id,staff_email,staff_store_id,staff_active,
                                                                 case when staff_valid_through =to_date('9999-12-31') and t2.staff_id is not null then current_timestamp  else t1.staff_last_update end staff_last_update ,
                                                                 t1.staff_version_number,
                                                                 case when store_valid_through =to_date('9999-12-31') and t2.staff_id is not null then t1.staff_valid_through else staff_valid_from  end staff_valid_from,
                                                                 case when staff_valid_through =to_date('9999-12-31') and t2.staff_id is not null then to_date(current_timestamp) else t1.staff_valid_through end staff_valid_through
                                                          from  sakila_dw.dim_staff t1 left join (select * from  sakila.staff st,
                                                                                                                 (select nvl(max(staff_last_update),to_date('1970-01-01')) max_last_update from dim_staff) tmp
                                                                                                  where st.last_update > max_last_update )  t2
                                                                                                 on t1.staff_id=t2.staff_id
                                                          union all
                                                          select  a.staff_id ,a.first_name,a.last_name,a.address_id,a.email,store_id,a.active  ,current_timestamp,
                                                                  max_version_number+1,to_date(current_timestamp),to_date('9999-12-31')
                                                          from  sakila.staff a join (select nvl(max(staff_last_update),to_date('1970-01-01')) max_last_update,
                                                                                            nvl(max(staff_version_number),0) max_version_number  from dim_staff ) tmp
                                                                                    on 1=1
                                                          where a.last_update > max_last_update  ) t  ;


--CREATE  dim_store
CREATE TABLE if not exists dim_store (
                                         store_key int comment"代理键",
                                         store_id int comment"店铺id",
                                         store_address string comment"店铺地址",
                                         store_country string comment"国家",
                                         store_district string comment"地区",
                                         store_city string comment"城市",
                                         store_postal_code string comment"邮编",
                                         store_phone_number string comment"店铺电话",
                                         store_manager_staff_id int comment"店铺管理员id",
                                         store_manager_first_name string comment"店铺管理员first_name",
                                         store_manager_last_name string comment"店铺管理员last_name",
                                         store_last_update timestamp comment"最后更新时间",
                                         store_version_number smallint comment"版本号" ,
                                         store_valid_from date comment"有效起始时间" ,
                                         store_valid_through date  comment"有效结束时间"
) comment "店铺维度表" ;
insert overwrite table dim_store
select row_number()over (order  by store_id) ,store_id,store_address,store_country,store_district,store_city,store_postal_code,store_phone_number,
       store_manager_staff_id,store_manager_first_name,store_manager_last_name,store_last_update,store_version_number,store_valid_from,store_valid_through
       from ( select t1.store_id,store_address,store_country,store_district,store_city,store_postal_code,store_phone_number,
                     store_manager_staff_id,store_manager_first_name,store_manager_last_name,
                     case when store_valid_through =to_date('9999-12-31') and t2.store_id is not null then current_timestamp  else t1.store_last_update end store_last_update,
                     t1.store_version_number,
                      case when store_valid_through =to_date('9999-12-31') and t2.store_id is not null then t1.store_valid_through else store_valid_from  end store_valid_from,
                     case when store_valid_through =to_date('9999-12-31') and t2.store_id is not null then to_date(current_timestamp) else t1.store_valid_through end store_valid_through
              from  sakila_dw.dim_store t1 left join (select * from  sakila.store st,
                                                                     (select nvl(max(store_last_update),to_date('1970-01-01')) max_last_update from dim_store) tmp
                                                      where st.last_update > max_last_update )  t2
                                                     on t1.store_id=t2.store_id
              union all
              select a.store_id ,b.address,d.country,b.district, c.city,b.postal_code,b.phone ,
                     a.manager_staff_id,e.first_name,e.last_name,current_timestamp,max_version_number +1,to_date(current_timestamp),to_date('9999-12-31')
              from sakila.store a left join  sakila.address b
                                             on a.address_id=b.address_id
                                  left join sakila.city c
                                            on b.city_id=c.city_id
                                  left join sakila.country d
                                            on c.country_id =d.country_id
                                  left join sakila.staff e
                                            on     a.manager_staff_id = e.staff_id
                                  join (select nvl(max(store_last_update),to_date('1970-01-01')) max_last_update ,nvl(max(store_version_number),0) max_version_number  from dim_store) tmp
                                       on 1=1
              where a.last_update > max_last_update )tt ;

--CREATE  fact_rental
CREATE TABLE if not exists fact_rental (
                                           rental_id int comment"租借id",
                                           customer_id int comment"客户id",
                                           staff_id int comment"职工id",
                                           film_id int comment"电影id",
                                           store_id int comment"店铺id",
                                           rental_date date comment"租借日期",
                                           return_date date comment"返还日期",
                                           rental_last_update timestamp comment"最后更新时间"
) comment"租借事实表" ;

insert overwrite table fact_rental
select  a.rental_id, a.customer_id ,a.staff_id, b.film_id , b.store_id , a.rental_date , a.return_date , current_timestamp
from sakila.rental a  left  join sakila.inventory b
             on a.inventory_id = b.inventory_id ;

--CREATE  fact_payment
CREATE TABLE if not exists fact_payment (
                                            payment_id int comment"支付id",
                                            customer_id int comment"客户id",
                                            staff_id int comment"职工id",
                                            film_id int comment"电影id",
                                            store_id int comment"店铺id",
                                            amount DECIMAL(5,2) comment "总额" ,
                                            payment_date date comment "付款日期" ,
                                            payment_last_update timestamp comment"最后更新时间"
) comment"支付事实表" ;
insert overwrite table fact_payment
select  a.payment_id , a.customer_id , a.staff_id, c.film_id , c.store_id ,a.amount,a.payment_date,current_timestamp
from  sakila.payment a left  join  sakila.rental  b
                                   on a.rental_id =b.rental_id
                       left  join sakila.inventory c
                                  on b.inventory_id = c.inventory_id ;
