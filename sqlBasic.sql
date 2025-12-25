Create table products(
	product_id SERIAL PRIMARY KEY,
  	name VARCHAR(100) NOT NULL,
  	sku_code CHAR(8) UNIQUE NOT NULL check (char_length(sku_code) = 8),
  	price NUMERIC(10,2) default 0 CHECK (price > 0),
  	stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
  	is_available BOOLEAN DEFAULT TRUE,
  	category TEXT NOT NULL,
  	adden_on DATE DEFAULT CURRENT_DATE,
  	last_update TIMESTAMP DEFAULT NOW()
);

insert into products (name, sku_code, price , stock_quantity , is_available, category)
values
('Wireless Mouse', 'WM123456', 699.99, 50, TRUE, 'Electronics'),
('Bluetooth Speaker', 'BS234567', 1499.00, 30, TRUE, 'Electronics'),
('Laptop Stand', 'LS345678', 799.50, 20, TRUE, 'Accessories'),
('USB-C Hub', 'UC456789', 1299.99, 15, TRUE, 'Accessories'),
('Notebook', 'NB567890', 99.99, 100, TRUE, 'Stationery'),
('Pen Set', 'PS678901', 199.00, 200, FALSE, 'Stationery'),
('Coffee Mug', 'CM789012', 299.00, 75, TRUE, 'Home & Kitchen'),
('LED Desk Lamp', 'DL890123', 899.00, 40, TRUE, 'Home & Kitchen'),
('Yoga Mat', 'YM901234', 499.00, 25, TRUE, 'Fitness'),
('Water Bottle', 'WB012345', 349.00, 60, TRUE, 'Fitness');

select * from products;


select name , price
from products
where price = (select min (price) from products)
;

select round(avg(price),2)
from products
where category in ('Fitness','Home & Kitchen');

select name , stock_quantity
from products
where is_available = True and stock_quantity > 50 and price != 299.00
;

select category , max(price) as Max_price
from products
group by category
;

select distinct upper(category) as upper_category
from products
order by upper_category desc;


select upper(name) 
from products;

select sku_code , length(sku_code) as length
from products;

select name, substring(sku_code,1,2)
from products;


select concat_ws(' : ',name,category) 
from products;

select concat_ws(' : ',name,category,sku_code) 
from products;










