use sakila;

# 1a
select first_name, last_name
from actor;

# 1b
alter table actor add column actor_name VARCHAR(50); # can only run this once or get error
set SQL_SAFE_UPDATES=0; #allows updates to be made to the table
update actor set actor_name = concat(first_name, ' ', last_name);
select actor_name from actor;

# 2a
select actor_id, first_name, last_name
	from actor where first_name = "Joe"; # answer --> #9 Joe Swank

# 2b
select actor_id, first_name, last_name
	from actor where last_name like "%Gen%"; # answer --> 4 actors id (14, 41, 107, 166)
    
# 2c
select actor_id, first_name, last_name
	from actor where last_name like "%Li%"
    order by last_name asc, first_name asc; # ten actors with Li in last name
    
# 2d 
select country_id, country
	from country
    where country in ('Afghanistan', 'Bangladesh', 'China');
    
# 3a
alter table actor add column description BLOB; 
select * from actor;

# 3b 
alter table actor drop column description;
select * from actor;

# 4a
select last_name, count(*) from actor group by last_name;

# 4b
select last_name, count(*) from actor group by last_name having count(*) > 1;

# 4c
update actor
set first_name = 'HARPO'
	where first_name = 'GROUCHO' and last_name = 'WILLIAMS';
SELECT UPPER(first_name) FROM actor # converts Harpo to all upper case...for some reason HARPO show up as Harpo
	where last_name = 'Williams';    

# 4d
update actor
set first_name = 'GROUCHO'
	where first_name = 'HARPO' and last_name = 'WILLIAMS';
select * from actor
	where last_name = 'Williams';
    
# 5a
drop table if exists address_new; # create address_new so that don't delete the address table
create table address_new (
    address_id smallint(5) unsigned not null auto_increment,
    address varchar(50) not null,
    address2 varchar(50),
	district varchar(20) not null,
	city_id smallint(5) unsigned not null,
    postal_code varchar(10),
	phone varchar(20) not null,
    location geometry not null,
    last_update timestamp not null,
    primary key (address_id),
    foreign key (city_id) references city(city_id) # note that city_id is foreign key in address table
);   

# 6a
select staff.first_name,  staff.last_name, address.address
from staff
left join address on staff.address_id=address.address_id; # choose left join to show all staff,
	# whether they have an address in address table or not

# 6b
select first_name, last_name, total_amount
from staff as s
join (select staff_id, sum(amount) as total_amount from payment
			where payment_date >='2005-08-01 00:00:00'
			and payment_date <'2005-09-01 00:00:00'
			group by staff_id) as p
on s.staff_id = p.staff_id;

# 6c
select film.film_id, title, nr_actors
from film
inner join (select film_id, count(actor_id) as nr_actors
	from film_actor
	group by film_id) as x
on film.film_id = x.film_id;

# 6d 
select count(inventory_id)
from inventory
where film_id = (select film_id from film where title = 'Hunchback Impossible'); # 6 copies

# 6e
select c.customer_id, first_name, last_name, total_paid
from customer as c
join (select customer_id, sum(amount) as total_paid
		from payment
        group by customer_id) as pd
on c.customer_id = pd.customer_id
order by last_name asc;

# 7a
select title, language_id from film where title like "K%" or title like "Q%" and
	(select language_id from language where name = 'English'); # 15 films...although all Ks and Qs are in English

# 7b
select actor_id, first_name, last_name from actor where actor_id in 
	(select actor_id from film_actor where film_id in
		(select film_id from film where title = 'Alone Trip'));
        
# 7c
select first_name, last_name, email # create final table with required info
	from customer as c
	join (select address_id # create a table with address_ids for all addresses in Canada
			from address as ad
			join (select city_id # create table with city_ids for cities in Canada
					from country as cy
					join city as ct
					on cy.country_id = ct.country_id
					where country = 'Canada') as cc
			on ad.city_id = cc.city_id) as cca
	on c.address_id = cca.address_id;

# 7d
select title from film where film_id in
	(select film_id from film_category where category_id in
		(select category_id from category where name = 'Family'));
        
# 7e
select f.film_id, title, rental_count
from film as f # this is the final join to add title to the table with rental_count and film_id
join (select sum(nr_rentals) as rental_count, film_id # this provides the count of rentals by film_id...
		from inventory as i
		join (select inventory_id, count(rental_id) as nr_rentals from rental
				group by inventory_id) as r # a list of the # time each inventory_id has been rented
		on i.inventory_id = r.inventory_id
		group by film_id) as z
on f.film_id = z.film_id
order by rental_count desc;

# 7f
select store_id, sum(staff_sales) as Total_sales
	from staff as sf
    join (select staff_id, sum(amount) as staff_sales from payment group by staff_id) as ps # calculate the $sales per sales staff person
	on sf.staff_id = ps.staff_id
    group by store_id;
    
# 7g
select store_id, city, country # join store_address_city & country info
from country as cry
join (select store_id, city, country_id # join store_address & city info
		from city as cy
		join (select store_id, city_id # join store & address table info
				from address as a
				join (select store_id, address_id from store group by store_id) as sid
				on a.address_id = sid.address_id) as sad
		on cy.city_id = sad.city_id) as sadc
on cry.country_id = sadc.country_id; 

# 7h
select name, sum(sales3) as Total_$ # create final table
	from (select sum(sales2) as sales3, category_id # create table with sales by category_id
			from (select sum(sales) as sales2, film_id # create table with sales by film_id
					from (select sum(amount) as sales, inventory_id # create table with sales by inventory_id
							from payment as p
							join rental as r
							on p.rental_id = r.rental_id
							group by inventory_id) as pr
					join inventory as i
					on pr.inventory_id = i.inventory_id
					group by film_id) as pri
			join film_category as fc
			on fc.film_id = pri.film_id
			group by category_id) as prif
	join category as cat
    on cat.category_id = prif.category_id
    group by name
    order by Total_$ desc
    limit 0, 5;  
    
# 8a
create view Top_5 as # creates a view called 'Top_5' from the previous sql
	select name, sum(sales3) as Total_$ # create final table
		from (select sum(sales2) as sales3, category_id # create table with sales by category_id
				from (select sum(sales) as sales2, film_id # create table with sales by film_id
						from (select sum(amount) as sales, inventory_id # create table with sales by inventory_id
								from payment as p
								join rental as r
								on p.rental_id = r.rental_id
								group by inventory_id) as pr
						join inventory as i
						on pr.inventory_id = i.inventory_id
						group by film_id) as pri
				join film_category as fc
				on fc.film_id = pri.film_id
				group by category_id) as prif
		join category as cat
		on cat.category_id = prif.category_id
		group by name
		order by Total_$ desc
		limit 0, 5;
        
# 8b display the Top_5 view
SELECT * FROM Top_5;

# 8c 
DROP VIEW Top_5;