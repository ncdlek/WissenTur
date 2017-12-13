use WissenTurDB;

-- seyehat ekleme
exec sp_AddVoyage 1, 1, 2, 1, 5, 30, '2017.10.01 08:00:00', '2017.10.03 18:00:00';
exec sp_AddVoyage 3, 1, 5, 3, 7, 60, '2017.10.03 09:00:00', '2017.10.03 19:00:00';
exec sp_AddVoyage 2, 2, 1, 1, 5, 30, '2017.10.03 09:00:00', '2017.10.03 19:00:00';
exec sp_AddVoyage 4, 6, 3, 4, 8, 50, '2017.11.03 09:00:00', '2017.11.03 09:00:00';
exec sp_AddVoyage 5, 6, 3, 3, 5, 50, '2017.11.03 09:00:00', '2017.11.03 09:00:00';

-- rezervasyon ekleme
exec sp_AddBooking 1, 1, 1, 0;
exec sp_AddBooking 2, 1, 2, 0;

exec sp_AddBooking 3, 1, 3, 0;
exec sp_AddBooking 4, 1, 4, 0;

select * from customers

select * from Bookings
select * from Booking_Details


select * from Voyages


-- 1- her sehirden kaç bilet satilmistir
select
    v.Departure, COUNT(*)
from
    Voyages v,
    Bookings b,
    Booking_Details bd
where
    v.Id = b.VoyageId and
    b.Id = bd.BookingId
group by
    v.Departure
 
-- 2- herhangi bir sehire en çok seyehat eden müsteri ve ziyaret sayisi
select
    bd.CustomerId, COUNT(v.Arrival) as total
from
    Bookings b,
    Booking_Details bd,
    Voyages v
where
    b.Id = bd.BookingId and
    v.Id = b.VoyageId
group by
    v.Arrival,
    bd.CustomerId
order by
    total desc
 
-- 3- 2. sorgudaki kisinin 1 aylik süreç içerisindeki yolculuk sikligi
select
    bd.CustomerId, COUNT(v.Arrival)
from
    Bookings b,
    Booking_Details bd,
    Voyages v
where
    b.Id = bd.BookingId and
    v.Id = b.VoyageId
group by
    v.Arrival,
    bd.CustomerId

