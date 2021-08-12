/*

Hotel Bookings Cleaning and Exploration

*/

-- Looking at the data set imported from excel
select *
from portfolio..hotelbookings

-- Data Cleaning

-- changing 0 and 1s to yes or no for is_canceled column
select is_canceled,
case
	when is_canceled = 0 then 'No'
	else 'Yes'
end as Canceled
from portfolio..hotelbookings

alter table hotelbookings
add Canceled nvarchar(10);

--select *
--from portfolio..hotelbookings

update portfolio..hotelbookings
set Canceled = case
	when is_canceled = 0 then 'No'
	else 'Yes'
	end

alter table portfolio..hotelbookings
drop column is_canceled

-- doing the same as above for the is_repeated_guest column
select distinct(is_repeated_guest), count(is_repeated_guest)
from portfolio..HotelBookings
group by is_repeated_guest

select is_repeated_guest,
case
	when is_repeated_guest = 0 then 'No'
	else 'Yes'
end as RepeatedGuest
from portfolio..hotelbookings

alter table portfolio..hotelbookings
add RepeatedGuest nvarchar(10);

--select *
--from portfolio..hotelbookings

update portfolio..hotelbookings
set RepeatedGuest = case
	when is_repeated_guest=0 then 'No'
	else 'Yes'
	end

alter table portfolio..hotelbookings
drop column is_repeated_guest

select *
from portfolio..hotelbookings

--Combining the day, month, and year into one column for arrival date
select arrival_date_month,
case
	when arrival_date_month = 'January' then '1'
	when arrival_date_month = 'February' then '2'
	when arrival_date_month = 'March' then '3'
	when arrival_date_month = 'April' then '4'
	when arrival_date_month = 'May' then '5'
	when arrival_date_month = 'June' then '6'
	when arrival_date_month = 'July' then '7'
	when arrival_date_month = 'August' then '8'
	when arrival_date_month = 'September' then '9'
	when arrival_date_month = 'October' then '10'
	when arrival_date_month = 'November' then '11'
	when arrival_date_month = 'December' then '12'
end as monthnum
from portfolio..hotelbookings

alter table portfolio..hotelbookings
add ArrivalMonth nvarchar(100);

update portfolio..hotelbookings
set ArrivalMonth = case
	when arrival_date_month = 'January' then '1'
	when arrival_date_month = 'February' then '2'
	when arrival_date_month = 'March' then '3'
	when arrival_date_month = 'April' then '4'
	when arrival_date_month = 'May' then '5'
	when arrival_date_month = 'June' then '6'
	when arrival_date_month = 'July' then '7'
	when arrival_date_month = 'August' then '8'
	when arrival_date_month = 'September' then '9'
	when arrival_date_month = 'October' then '10'
	when arrival_date_month = 'November' then '11'
	when arrival_date_month = 'December' then '12'
end

select ArrivalMonth + '-' + cast(cast(arrival_date_day_of_month as int) as nvarchar(2)) + '-' +
	 cast(cast(arrival_date_year as int) as nvarchar(4)) as ArrivalDate
from portfolio..hotelbookings

alter table portfolio..hotelbookings
add DateArrived nvarchar(100);

update portfolio..hotelbookings
set DateArrived = ArrivalMonth + '-' + cast(cast(arrival_date_day_of_month as int) as nvarchar(2)) + '-' +
	 cast(cast(arrival_date_year as int) as nvarchar(4))

Select DateArrived, CONVERT(Date,DateArrived)
from portfolio..HotelBookings

Update portfolio..hotelbookings
set DateArrived = CONVERT(Date,DateArrived)

alter table portfolio..hotelbookings
drop column arrival_date_year, arrival_date_month, arrival_date_day_of_month

--Changing meals with undefined and sc to be combined since they both mean no meal package
select distinct(meal), count(meal)
from portfolio..HotelBookings
group by meal

select meal,
case
	when meal = 'SC' then 'NM'
	when meal = 'Undefined' then 'NM'
	else meal
end as MealPlan
from portfolio..hotelbookings

Update portfolio..hotelbookings
set meal = case
	when meal = 'SC' then 'NM'
	when meal = 'Undefined' then 'NM'
	else meal
end

-- Removing Company column due to majority of it being null and unhelpful
Alter Table portfolio..hotelbookings
Drop Column company


--Some data exploration

--Using temp table to find cancellation rates for both hotel types
Drop Table if exists #HotelCancellations
Create Table #HotelCancellations
(
hotel nvarchar(255),
ArrivalDate date,
Canceled nvarchar(255),
TotalReservations numeric,
)

Insert into #HotelCancellations
select hotel, arrivaldate, canceled,
	COUNT(hotel) over (partition by hotel order by hotel) as TotalReservations
from portfolio..hotelbookings


select hotel, COUNT(canceled)/MAX(TotalReservations)*100 as CancellationRate
from #HotelCancellations
where canceled = 'Yes'
group by hotel

--Seeing the average amount of special requests between each hotel
select hotel, avg(total_of_special_requests) as AvgRequests
from portfolio..hotelbookings
group by hotel

select *
from portfolio..hotelbookings

--Looking at the total amount of days each guest stayed
select stays_in_weekend_nights + stays_in_week_nights as TotalNightStays
from portfolio..hotelbookings

-- Looking at what months have the most bookings
select arrival_date_month, COUNT(arrival_date_month) as TotalReservations
from portfolio..hotelbookings
group by arrival_date_month
order by TotalReservations desc