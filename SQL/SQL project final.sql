use orders;
-- 1. Write a query to display customer full name with their title (Mr/Ms), both first 
-- name and last name are in upper case, customer email id, customer creation date 
-- and display customer’s category after applying below categorization rules: i) IF 
-- customer creation date Year <2005 Then Category A ii) IF customer creation date 
-- Year >=2005 and <2011 Then Category B iii)IF customer creation date Year>= 2011 
-- Then Category C Hint: Use CASE statement, no permanent change in table 
-- required. [NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE]
SELECT oc.customer_id, CONCAT (
  (CASE WHEN oc.customer_gender ='M' then  'Mr. 'else 'Ms. ' end), 
  CONCAT(" ", UPPER(oc.customer_fname)," ", UPPER(oc.customer_lname))) 
  AS Name, oc.customer_email, Year(oc.customer_creation_date) as 
  Creation_Year,  
  CASE 
		when YEAR(oc.customer_creation_date) < 2005 THEN 'A' 
        when YEAR(oc.customer_creation_date) < 2011 THEN 'B' 
        else 'C' END AS Category from online_customer oc; 

#2.    Write a query to display the following information for the products, which have 
	-- not been sold: product_id, product_desc, product_quantity_avail, product_price, 
	-- inventory values (product_quantity_avail*product_price), New_Price after applying 
	-- discount as per below criteria. Sort the output with respect to decreasing value of 
	-- Inventory_Value. i) IF Product Price > 20,000 then apply 20% discount ii) IF Product 
	-- Price > 10,000 then apply 15% discount iii) IF Product Price =< 10,000 then apply 
	-- 10% discount # Hint: Use CASE statement, no permanent change in table required. 
	-- [NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
    
    SELECT p.product_id,p.product_desc, p.product_quantity_avail, 
    p.product_price, 
    (p.product_price*p.product_quantity_avail) as Inventory_Value, 
    CASE p.PRODUCT_PRICE 
		WHEN p.PRODUCT_PRICE > 200000 THEN p.PRODUCT_PRICE *0.8 
		WHEN p.PRODUCT_PRICE > 100000 THEN p.PRODUCT_PRICE *0.85 
		Else  p.PRODUCT_PRICE *0.9 
    end as New_Price 
    from Product p 
    where p.product_id NOT IN (select oi.Product_ID from ORDER_ITEMS oi) 
    ORDER BY Inventory_Value Desc; 

    #3. Write a query to display Product_class_code, Product_class_description, Count of 
    -- Product type in each productclass, Inventory Value 
    -- (product_quantity_avail*product_price). Information should be displayed for only 
    -- those product_class_code which have more than 1,00,000. Inventory Value. Sort 
    -- the output with respect to decreasing value of Inventory_Value. 
    -- [NOTE: TABLES to be used - PRODUCT_CLASS, PRODUCT_CLASS_CODE]
    
    
    SELECT pc.product_class_code,pc.product_class_desc,count(product_id) AS 
    count_product_types,  
    sum(p.product_quantity_avail*p.product_price) as inventory_value 
    from product_class pc  
    INNER JOIN product p 
    on pc.product_class_code=p.product_class_code 
    group by pc.product_class_code,pc.product_class_desc 
    having sum(p.PRODUCT_quantity_avail*p.product_price) >100000 
    ORDER BY inventory_value DESC; 
    
    #4. Write a query to display customer_id, full name, customer_email, 
   -- customer_phone and country of customers who have cancelled all the orders 
   -- placed by them (USE SUB-QUERY)[NOTE: TABLES to 
   -- be used - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
   
   SELECT customer_id, Full_name,  customer_email, customer_phone, country from  
		(SELECT oh.customer_id, concat(customer_fname,' ',customer_lname) as Full_name, oc.customer_email,  
		oc.customer_phone, a.country from order_header oh left join online_customer oc on oh.customer_id = oc.customer_id  
		left join address a on oc.address_id=a.address_id where oh.order_status = 'Cancelled') s  
		where customer_id not in (Select oh.customer_id from order_header oh where oh.order_status != 'Cancelled');
        
	#5. Write a query to display Shipper name, City to which it is catering, num of 
    -- customer catered by the shipper in the city and number of consignments delivered 
    -- to that city for Shipper DHL [NOTE: TABLES to be used - 
    -- SHIPPER,ONLINE_CUSTOMER, ADDRESSS, ORDER_ITEMS]
    
    select sp.Shipper_name, a.city, count(Distinct(oc.customer_id)) as 
    No_Cusotomer_Catered_to,  
    count((oc.customer_id)) as No_Consignments_Catered from Shipper sp   
    inner join ORDER_Header oh 
    ON oh.shipper_ID = sp.shipper_ID 
    inner join online_customer oc 
    ON oc.customer_id= oh.customer_id 
    inner join address a 
    ON oc.address_id= a.address_id 
    where sp.shipper_name in('DHL') 
    group by a.city 
    order by sp.Shipper_name; 

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
        
        SELECT product_id,product_desc,tot_qty as Qty_Sold,product_quantity_avail, 
        CASE 
			WHEN product_class_desc in ('Electronics','Computer') THEN 
            CASE 
				WHEN (product_quantity_avail/S.tot_qty) <0.1 THEN "Low inventory, need to add inventory" 
                WHEN (product_quantity_avail/S.tot_qty) <0.5 THEN "Medium inventory, need to add some inventory" 
                WHEN S.tot_qty is NULL THEN "No Sales in past, give discount to reduce inventory" 
                ELSE "Sufficient inventory" 
                END 
                WHEN product_class_desc in ('Mobiles','Watches') THEN 
                CASE 
					WHEN (product_quantity_avail/S.tot_qty) <0.2 then "Low inventory, need to add inventory" 
                    WHEN (product_quantity_avail/S.tot_qty) <0.6 then "Medium inventory, need to add some inventory" 
                    WHEN S.tot_qty is null then "No Sales in past, give discount to reduce inventory" 
                    ELSE "Sufficient inventory" 
					END 
				ELSE 
                    CASE 
						WHEN (product_quantity_avail/S.tot_qty) <0.3 then "Low inventory, need to add inventory" 
                        WHEN (product_quantity_avail/S.tot_qty) <0.7 then "Medium inventory, need to add some inventory" 
                        WHEN S.tot_qty is null then "No Sales in past, give discount to reduce inventory" 
					ELSE "Sufficient inventory" 
                    END 
				End AS Inventory_Status 
                FROM (SELECT p.product_id, p.product_desc, pc.product_class_desc,p.product_quantity_avail, SUM(oi.product_quantity)  
                AS tot_qty FROM Product p left join order_items oi on oi.product_id = p.product_id left join product_class pc 
                on p.product_class_code = pc.product_class_code GROUP BY p.product_id, p.product_desc) S;    
         
	# 7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10
	-- [NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
        
        Select order_id, volume from (SELECT oi.order_id, (len * width * height * 
        product_quantity) as Volume 
        FROM Order_Items oi INNER JOIN Product p 
        ON oi.product_id = p.product_id 
        group by oi.order_id)tab where Volume <= (Select (len * width * height) AS 
        carton_vol 
        FROM Carton WHERE carton_id=10)  
        order by volume desc 
        Limit 1; 

	  #8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped
			-- where mode of payment is Cash and customer last name starts with 'G'
            -- [NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
            
            SELECT oc.customer_id, 
            CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS Fullname, 
            SUM(oi.product_quantity) AS Tot_qty, 
            SUM(oi.product_quantity*p.product_price) AS Value  
            FROM online_customer oc 
            INNER JOIN order_header oh 
            ON oc.customer_id = oh.customer_id 
            INNER JOIN order_items oi 
            ON oh.order_id = oi.order_id 
            INNER JOIN product p 
            ON oi.product_id = p.product_id 
            WHERE oh.payment_mode = 'Cash' AND oh.order_status = 'Shipped' 
            AND (oc.customer_lname) LIKE 'G%' 
            GROUP BY oc.customer_id,  fullname; 

	#9. Write a query to display product_id, product_desc and total quantity of products which are sold together with product id 201
		-- and are not shipped to city Bangalore and New Delhi.
		-- Display the output in descending order with respect to the tot_qty.
		-- (USE SUB-QUERY)
		-- [NOTE: TABLES to be used - order_items, product,order_head, online_customer, address] 
        
        SELECT s.product_id, s.product_desc, s.tot_qty  
        FROM(SELECT oi.order_id, p.product_id, p.product_desc, 
        SUM(product_quantity) AS tot_qty 
        FROM Order_Items oi  
        INNER JOIN Product p 
        where oi.product_id = p.product_id  
        AND order_id IN (SELECT order_id FROM Order_Items    
								WHERE product_id = 201) 
		AND p.product_id != 201 
        GROUP BY p.product_id, product_desc)s  
        INNER JOIN order_header oh on oh.order_id=s.order_id 
        INNER JOIN online_customer oc on oh.customer_id=oc.customer_id 
        INNER JOIN address a on a.address_id=oc.address_id 
        WHERE a.city not in ('Bangalore', 'New Delhi') and oh.order_status='Shipped' 
        ORDER BY tot_qty DESC; 


	#10. Write a query to display the order_id,customer_id and customer fullname,
		-- total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5"
		-- [NOTE: TABLES to be used - online_customer,Order_header, order_items,address]
        
        SELECT oh.order_id,oc.customer_id,  .
        CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS fullname, 
        SUM(oi.product_quantity) AS tot_qty 
        FROM online_customer oc 
        INNER JOIN order_header oh 
        ON oc.customer_id = oh.customer_id 
        INNER JOIN order_items oi 
        ON oh.order_id = oi.order_id 
        INNER JOIN address a 
        ON a.address_id = oc.address_id 
        WHERE mod(oh.order_id,2) = 0 
        AND oh.order_status = 'Shipped' 
        AND a.pincode NOT LIKE "5%" 
        GROUP BY oh.order_id, oc.customer_id, fullname; 

