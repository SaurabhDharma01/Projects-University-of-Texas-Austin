use orders;
-- 1. 	Write a query to display customer full name with their title (Mr/Ms), both first name and last name are in upper case, 
		-- customer email id, customer creation date and display customer’s category after applying below categorization rules:
			-- i) IF customer creation date Year <2005 Then Category A 
			-- ii) IF customer creation date Year >=2005 and <2011 Then Category B 
			-- iii)IF customer creation date Year>= 2011 Then Category C 
        -- Hint: Use CASE statement, no permanent change in table required.
		-- [NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE]
	
-- drop view question_1_view;		
       create view question_1_view as
		select 	concat(
				case
				when customer_gender = 'F' then 'Ms'
				when customer_gender = 'M' then 'Mr'
				else 'Not Known'
				end ,
				' ',
			 upper(customer_fname),
			 ' ',
			 upper(customer_lname)) as fullname,
			 customer_email,
			 customer_creation_date,
			case
				when customer_creation_date < '2005-01-01' then 'A'
				when customer_creation_date >= '2011-01-01' then 'C'
				else 'B'
				end as Customer_Category
		 from online_customer;
		  
		 select * from question_1_view; 

-- 2. 	Write a query to display the following information for the products, which have not been sold:
		-- product_id, product_desc, product_quantity_avail, product_price,
        -- inventory values (product_quantity_avail*product_price),
		-- New_Price after applying discount as per below criteria.
		-- Sort the output with respect to decreasing value of Inventory_Value.
		-- i) IF Product Price > 20,000 then apply 20% discount
		-- ii) IF Product Price > 10,000 then apply 15% discount
		-- iii) IF Product Price =< 10,000 then apply 10% discount
		-- Hint: Use CASE statement, no permanent change in table required.
		-- [NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
 -- drop view question_2_view;
 create view question_2_view as
 select product_id,
		product_desc,
        product_quantity_avail,
        product_price,
        product_quantity_avail * product_price as 'Inventory Value',
			case
				when product_price > 20000 then Product_price - (Product_price * 0.2)
                when product_price <= 10000 then Product_price - (Product_price * 0.1)
                else Product_price - (Product_price * 0.15)
				end as New_Price
		from product
			where product_id not in ( select product_id from order_items)
            order by 'Inventory Value' desc;
 
 select * from question_2_view;
 
 
-- 3. 	Write a query to display Product_class_code, Product_class_description, Count of Product type in each productclass,
		-- Inventory Value (product_quantity_avail*product_price).
		-- Information should be displayed for only those product_class_code which have more than 1,00,000 inventory value
		-- Sort the output with respect to decreasing value of Inventory_Value.
		-- [NOTE: TABLES to be used - PRODUCT_CLASS, PRODUCT_CLASS_CODE]
 -- drop view question_3_view;
		 create view question_3_view as
		  select p.product_class_code,
				 pc.product_class_desc,
				 count(p.product_id) as No_of_Products_in_Product_Class,
				 sum(p.product_price * p.product_quantity_avail) as Inventory_Value_of_Total_Product_Class
			  from product p
				join product_class pc
					on p.product_class_code = pc.product_class_code
				group by p.product_class_code, pc.product_class_desc 
				having Inventory_Value_of_Total_Product_Class > 100000 
				order by Inventory_Value_of_Total_Product_Class desc;
				
		select * from question_3_view;
 
      
-- 4. 	Write a query to display customer_id, full name, customer_email,
		-- customer_phone and country of customers who have cancelled all the orders placed by them (USE SUB-QUERY)
		-- [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
  -- drop view question_4_view;
			  create view question_4_view as
				select c.customer_id ,
						   concat(upper(c.customer_fname),' ',upper(c.customer_lname)) as full_name,
						   c.customer_email,
						   c.customer_phone,
						   a.country,
						   oh.order_status
					from online_customer c 
						join address a 
							on c.address_id = a.address_id
						join order_header oh
							on c.customer_id = oh.customer_id
								where oh.order_id in (select order_id from order_header where order_status = 'cancelled');
				
			select * from question_4_view;
        
                
-- 5. 	Write a query to display Shipper name, City to which it is catering,
		-- num of customer catered by the shipper in the city and number of consignments delivered to that city for Shipper DHL
		-- [NOTE: TABLES to be used - SHIPPER,ONLINE_CUSTOMER, ADDRESSS, ORDER_ITEMS]
        
-- drop view question_5_view;       
			create view question_5_view as	       
				select s.shipper_name,
					   a.city ,
                       count(oh.customer_id) as Count_of_Customers,
					   sum(oi.product_quantity) as No_of_Consignments
					from shipper s 
						join address a 
							on s.shipper_address = a.address_id
						join order_header oh
							on s.shipper_id = oh.shipper_id
						join order_items oi
							on oh.order_id = oi.order_id
						where s.shipper_name = 'DHL';
				
		   select * from question_5_view;    	

-- 6.  Write a query to display product_id, product_desc, product_quantity_avail, 
	    -- quantity sold and show inventory Status of products as below as per below condition:
		-- a. For Electronics and Computer categories,
			-- if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory',
			-- if inventory quantity is less than 10% of quantity sold,show 'Low inventory, need to add inventory',
			-- if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
			-- if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory'
		-- b. For Mobiles and Watches categories,
			-- if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory',
			-- if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory',
			-- if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory',
			-- if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory'
		-- c. Rest of the categories,
			-- if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory',
			-- if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory',
			-- if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
			-- if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
		-- (USE SUB-QUERY)
		-- [NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]

-- drop view question_6_view;
		create view question_6_view as
		select p.product_id,
			   p.product_desc,
			   p.product_quantity_avail,
			   sum(oi.product_quantity) as Quantity_Sold,
			   pc.product_class_desc,
					case
					when sum(oi.product_quantity) is null then 'No Sales in past, give discount to reduce inventory'
								when sum(oi.product_quantity) is not null 
								and product_class_desc in ('Electronics','Computer')
								and product_quantity_avail < sum(oi.product_quantity)*.1 then 'Low inventory, need to add inventory'
								when sum(oi.product_quantity) is not null 
								and product_class_desc in ('Electronics','Computer')
								and product_quantity_avail < sum(oi.product_quantity)*.5 then 'Medium inventory, need to add some inventory'
								when sum(oi.product_quantity) is not null 
								and product_class_desc in ('Electronics','Computer')
								and product_quantity_avail >= sum(oi.product_quantity)*.5 then 'Sufficient Inventory'
					when sum(oi.product_quantity) is not null 
					and product_class_desc in ('Mobiles','Watches')
					and product_quantity_avail < sum(oi.product_quantity)*.2 then 'Low inventory, need to add inventory'
					when sum(oi.product_quantity) is not null 
					and product_class_desc in ('Mobiles','Watches')
					and product_quantity_avail < sum(oi.product_quantity)*.6 then 'Medium inventory, need to add some inventory'
					when sum(oi.product_quantity) is not null 
					and product_class_desc in ('Mobiles','Watches')
					and product_quantity_avail >= sum(oi.product_quantity)*.6 then 'Sufficient Inventory'
								when sum(oi.product_quantity) is not null 
								and product_class_desc not in ('Electronics','Computer','Mobiles','Watches')
								and product_quantity_avail < sum(oi.product_quantity)*.3 then 'Low inventory, need to add inventory'
								when sum(oi.product_quantity) is not null 
								and product_class_desc not in ('Electronics','Computer','Mobiles','Watches')
								and product_quantity_avail < sum(oi.product_quantity)*.7 then 'Medium inventory, need to add some inventory'
								when sum(oi.product_quantity) is not null 
								and product_class_desc not in ('Electronics','Computer','Mobiles','Watches')
								and product_quantity_avail >= sum(oi.product_quantity)*.7 then 'Sufficient Inventory'
								end as Inventory_Status
		from product p 
			  left join order_items oi 
				on p.product_id = oi.product_id
			  join product_class pc
				on p.product_class_code = pc.product_class_code
				group by p.product_id, p.product_desc;

		 select * from question_6_view;     
       
       

-- 7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10
			-- [NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
      
-- drop view question_7_view;
		create view question_7_view as
		select oi.order_id,
			   p.len*p.width*p.height*oi.product_quantity as total_order_vol ,     -- ascertain the total volume of the order by multiplying unit product volume * order qty
			   p.len*p.width*p.height*oi.product_quantity/                         -- total order vol. divided by vol.of carton_id_10 should be less than 1, to fit in 1 carton 
			   (select len*width*height as volume_carton from carton where carton_id =10) as carton_10_fitment_test
		from product p
			join order_items oi
				on p.product_id=oi.product_id
					having carton_10_fitment_test < 1
					order by carton_10_fitment_test desc
					limit 2;  

		select * from question_7_view;



-- 8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped
			-- where mode of payment is Cash and customer last name starts with 'G'
            -- [NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
            
-- drop view question_8_view;
     create view question_8_view as 
         select c.customer_id,
			concat(c.customer_fname,' ',c.customer_lname) as customer_full_name,
			sum(oi.product_quantity) as total_quantity,
			sum(oi.product_quantity * p.product_price) as total_value,
			oh.payment_mode
        from online_customer c 
			join order_header oh
				on c.customer_id=oh.customer_id
			join order_items oi	
				on oh.order_id = oi.order_id
			join product p 
				on oi.product_id = p.product_id
        where c.customer_lname like 'G%' and oh.payment_mode = 'cash'
        group by c.customer_id, customer_full_name;

select * from question_8_view;

-- 9. Write a query to display product_id, product_desc and total quantity of products which are sold together with product id 201
		-- and are not shipped to city Bangalore and New Delhi.
		-- Display the output in descending order with respect to the tot_qty.
		-- (USE SUB-QUERY)
		-- [NOTE: TABLES to be used - order_items, product,order_head, online_customer, address] 
        
-- drop view question_9_view;
		create view question_9_view as	        
		select p.product_id,
			   p.product_desc,
			   oi.product_quantity as 'Total Qty sold',
			   a.city 
			from product p 
			   join order_items oi
					on p.product_id = oi.product_id
			   join order_header oh
					on oi.order_id = oh.order_id
			   join online_customer c 
					on oh.customer_id = c.customer_id
			   join address a 
					on c.address_id = a.address_id
						where a.city not in ('Bangalore','New Delhi')
						and
						oi.order_id in (select order_id from order_items where product_id = 201)
					 order by oi.product_quantity desc; 
		 
		 select * from question_9_view;
             
-- 10. Write a query to display the order_id,customer_id and customer fullname,
		-- total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5"
		-- [NOTE: TABLES to be used - online_customer,Order_header, order_items,address]
        
-- drop view question_10_view;
		create view  question_10_view as
		select oh.order_id ,
			   c.customer_id,
			   concat(c.customer_fname , ' ' , c.customer_lname) as fullname,
			   oi.product_quantity,
			   a.pincode 
		 from order_header oh
			join online_customer c
				on oh.customer_id = c.customer_id
			join order_items oi
				on oh.order_id = oi.order_id
			join address a 
				on c.address_id = a.address_id
					where a.pincode not like '5%'
					and
					(oi.order_id % 2) = 0
			group by c.customer_id;   
			
		 select * from question_10_view ;        
            
           select * from question_1_view ;   
           select * from question_2_view ;   
           select * from question_3_view ;   
           select * from question_4_view ;   
           select * from question_5_view ;   
           select * from question_6_view ;   
           select * from question_7_view ;   
           select * from question_8_view ;   
           select * from question_9_view ;  
           select * from question_10_view ;   
           
            
            