-- Create Data set 
create table Rooms (
  room_id int primary key, 
  room_type varchar(255) not null, 
  status varchar(20) not null check (status in ('available', 'occupied'))
);

create table Reservations (
  reservation_id int primary key,
  room_id int, 
  customer_id int not null, 
  check_in_date date not null, 
  check_out_date date not null, 
  amount_paid decimal(10, 2) not null, 
  foreign key (room_id) references Rooms(room_id)
);

-- Inserting data into the Rooms table
insert into Rooms (room_id, room_type, status) values
(1, 'Deluxe', 'available'),
(2, 'Deluxe', 'available'),
(3, 'Executive Suite', 'available'),
(4, 'Presidential Suite', 'available'),
(5, 'Deluxe', 'occupied'),
(6, 'Presidential Suite', 'occupied'),
(7, 'Executive Suite', 'occupied'),
(8, 'Deluxe', 'available'),
(9, 'Presidential Suite', 'available');

-- Insert data into the Reservation table 
insert into Reservations (reservation_id, room_id, customer_id, check_in_date, check_out_date, amount_paid) values
(1, 1, 101, '2024-02-01', '2024-02-05', 500),
(2, 2, 102, '2024-02-02', '2024-02-07', 800),
(3, 3, 103, '2024-02-03', '2024-02-10', 1200),
(4, 4, 104, '2024-02-04', '2024-02-06', 1000),
(5, 5, 105, '2024-02-05', '2024-02-09', 1500),
(6, 6, 106, '2024-02-06', '2024-02-08', 2000),
(7, 7, 107, '2024-02-07', '2024-02-11', 1800),
(8, 8, 108, '2024-02-08', '2024-02-12', 1600),
(9, 9, 109, '2024-02-09', '2024-02-13', 1400);

-- Check data
.print \n Rooms table
.mode box
select * from Rooms limit 5;

.print \n Reservations table
.mode box
select * from Reservations limit 5;


-- Analysis processing 
-- 1. Find room types at hotels and the number of rooms available ?
.print \n room_types_at_hotels_and_the_number_of_rooms_available 
select 
    count(*) available_room, 
    room_type, 
    status
from Rooms
where status = 'available'
group by room_type;

-- 2. Calculate the average price that customers paid per each ?
.print \n Average_price_for_customer_paid 
select 
  avg(amount_paid) Average_Price
from Reservations;

-- 3. Find the highest spending customers of all time and how many times customer has reseved a room ?
.print \n booking_count_of_the_week
select
  case 
  when strftime('%w', check_in_date) = '0' then 'Sunday' 
  when strftime('%w', check_in_date) = '1' then 'Monday'
  when strftime('%w', check_in_date) = '2' then 'Tuesday'
  when strftime('%w', check_in_date) = '3' then 'Wednesday'
  when strftime('%w', check_in_date) = '4' then 'Thursday'
  when strftime('%w', check_in_date) = '5' then 'Friday'
  when strftime('%w', check_in_date) = '6' then 'Saturday'
  end as day_of_week, 
  count(*) booking_count
from Reservations
group by day_of_week
order by booking_count desc
limit 1;

-- 4. Find which day have the highest number of reservations ? 
.print \n the_highest_number_of_reserve
select 
  customer_id, 
  max(total_amount_paid) max_paid_amount, 
  count(*) booking_count
from 
  (
  select 
    customer_id, 
    sum(amount_paid) total_amount_paid
  from Reservations
  group by customer_id
) customer_payments 
group by customer_id
order by max_paid_amount desc
limit 1;

-- 5. Calculate the room occupancy rate 
-- room occupancy rate  = (occupied rooms / available rooms)*100 
.print \n occ_rate_room is
select
  coalesce(
  (sum(case when 
      status = 'occupied' then 1 else 0 end) * 100.0) / nullif(count(*), 0), 0
) AS occupancy_rate
from Rooms;
