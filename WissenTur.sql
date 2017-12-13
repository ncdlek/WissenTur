-- otobüs firmasina ait bir otomasyon sisteminin database'i tasarlanacak
-- en az bir stored procedure, function ve trigger kullanilmali
-- her ilisli tipinden en az bir tane olmali (1-1, 1-X, X-X, self)
-- en az 7 tablo olmali
 
-- bütün yapilacaklar script ile yapilmali
-- database gerektigi kadar veri içermeli:
-- örnegin 1-x iliskili bir kategoriler ve ürünler tablolari için kategorilerde en az 5, ürünlerde en az 17-25 arasi kayit olmali
 
-- not:
-- (otobüslerin ara duraklari göz ardi edilebilir)
 
-- sorgular
-- 1- her sehirden kaç bilet satilmistir
-- 2- herhangi bir sehire en çok seyehat eden müsteri ve ziyaret sayisi
-- 3- 2. sorgudaki kisinin 1 aylik süreç içerisindeki yolculuk sikligi
-- 4- 2 haftalik süreç içerisinde yolculuk etmis olan kadin yolcularin erkek yolculara orani
-- 5- indirimli bilet almis olan yolcularin sayisi
-- 6- 1 haftadaki seferlerin satis potansiyelinin gerçek satisa orani
-- 7- 1 hafta içerisinde kaç farkli yolcu ... sehire yolculuk etmistir
-- 8- 1 hafta içerisinde iptal edilmis sefer sayisi nedir
-- 9- sehirlere göre iptal edilmis sefer sayisi (hangi sehire en fazla sefer iptal edilmistir) (aylara göre)
-- 10- 3 haftalik süre içerisindeki ortalama kazancin, içerisinde bulunulan haftada edinilmis kazanca orani (+- yüzde)
-- 11- sefer tarihi degistirilmis olanlara yapilan indirim verilen hafta içerisinde ne kadar zarara mal oldu
-- 12- 1 ay içerisinde seferler esnasinda ugramis oldugunuz ekstra zararlar ne kadardir
-- 13- ön gördügümüz varis saati ile gerçekten olan varis saati arasindaki ortalama farki
-- 14- en az üç ara durakta duran otobüslerin sayisi nedir
-- 15- verilen herhangi bir sefer için bir fis içerisinde birden fazla koltuk satilan kaç fis vardir
 
--create database WissenTurDB;
 
use WissenTurDB;
 
create table Employees
(
    Id int primary key identity(1,1),
    Name nvarchar(50),
    IdentityNo nvarchar(11) unique not null,
    Role nvarchar(10) not null
);
 
create table Busses
(
    Id int primary key identity(1,1),
    LicensePlate nvarchar(12),
    SeatCount tinyint,
    isAvailable bit
);
 
create table Destinations
(
    Id int primary key identity(1,1),
    Name nvarchar(50),
);
 
create table Voyages
(
    Id int primary key identity(1,1),
    BusId int foreign key references Busses(Id),
    Departure int foreign key references Destinations(Id),
    Arrival int foreign key references Destinations(Id),
    Driver int foreign key references Employees(Id),
    Assistant int foreign key references Employees(Id),
    Price money,
    DepartDate Datetime2(2),
    EstimatedArrivalDate Datetime2(2),
    ArrivalDate Datetime2(2),
    isCanceled bit default 0, -- 0 hayir, 1 evet
    ReasonOfCancel nvarchar(50),
    CanceledVoyageId int foreign key references Voyages(Id)
);
 
create table Customers
(
    Id int primary key identity(1,1),
    Name nvarchar(50),
    Surname nvarchar(50),
    Gender tinyint, -- kadin 1, erkek 2
    IdentityNo nvarchar(11) not null,
    PhoneNumber nvarchar(15)
);
 
create table Bookings
(
    Id int primary key identity(1,1),
    VoyageId int foreign key references Voyages(Id),
    BookingDate Datetime2(2),
);
 
create table Booking_Details
(
    BookingId int foreign key references Bookings(Id),
    SeatNumber int,
    CustomerId int foreign key references Customers(Id),
    Price money,
    Discount tinyint

	primary key(BookingId, SeatNumber)
);
 
create table UPDATED_VOYAGES
(
    VoyageId int,
    ChangeDate datetime2(2),
    OldPrice money,
    NewPrice money,
    OldDepartDate Datetime2(2),
    NewDepartDate Datetime2(2),
    OldEstimatedArrivalDate Datetime2(2),
    NewEstimatedArrivalDate Datetime2(2),
    OldArrivalDate Datetime2(2),
    NewArrivalDate Datetime2(2)
);
 
-- ################
-- END OF TABLES
 
-- PROCEDURE, FUNCTION, TRIGGER
 
go -- Voyage tablosuna otobüs, söför ve muavin bilgilerinin eklenmesi. uygun olmayan alanlar için hata döndürür
create procedure sp_AddVoyage
    @bussId int,
    @departure int,
    @arrival int,
    @driver int,
    @assistant int,
    @price money,
    @departdate datetime2(2),
    @arrivaldate datetime2(2)
as
    begin
        if not exists (select * from Voyages
                        where BusId = @bussId and
                                (DepartDate between @departdate and @arrivaldate or
                                EstimatedArrivalDate between @departdate and @arrivaldate))
            if not exists (select * from Voyages
                            where Driver = @driver and
                                (DepartDate between @departdate and @arrivaldate or
                                EstimatedArrivalDate between @departdate and @arrivaldate))
                if not exists (select * from Voyages
                            where Assistant = @assistant and
                                (DepartDate between @departdate and @arrivaldate or
                                EstimatedArrivalDate between @departdate and @arrivaldate))
                    begin
                    insert into Voyages (BusId, Departure, Arrival, Driver, Assistant, Price, DepartDate, EstimatedArrivalDate)
                    values (@bussId, @departure, @arrival, @driver, @assistant, @price, @departdate, @arrivaldate)
                    end
				else
					print 'Assistant is not available';
			else
				print 'Driver is not available';
		else
			print 'Bus is not available';
    end
 
 
go -- Müsteri ekler, tckimlik numarasi zaten varsa, varolan müsterinin Id'sini döndürür
create procedure sp_AddCustomer
    @name nvarchar(50),
    @surname nvarchar(50),
    @gender bit,
    @identityNo nvarchar(11),
    @phoneNumber nvarchar(15)
as
    begin
        if not exists (select *
                       from Customers
                       where IdentityNo = @identityNo)
            begin
                insert into Customers (Name, Surname, Gender, IdentityNo, PhoneNumber)
                values (@name, @surname, @gender, @identityNo, @phoneNumber)
 
                print 'Success';
                return @@identity;
            end
        else
            begin
                print 'Existing User';
                return select Id from Customers where IdentityNo = @identityNo;
            end
    end



go -- sefer ve koltuk numarasi verilerek, bitisik koltukta oturan yolcunun cinsiyetini döndürür
create function FindConnectedSeatGender (@seatNumber int, @voyageId int)
returns int
as
    begin
        if (@seatNumber % 2 = 0)
            set @seatNumber -= 1;
        else
            set @seatNumber += 1;
 
        if exists (select *
                    from
                        Bookings b,
                        Booking_Details bd
                    where
                        b.Id = bd.BookingId and
                        b.VoyageId = @voyageId and
                        bd.SeatNumber = @seatNumber)
            return (select c.Gender
                        from
                            Bookings b,
                            Booking_Details bd,
                            Customers c
                        where
                            b.Id = bd.BookingId and
                            c.Id = bd.CustomerId and
                            b.VoyageId = @voyageId and
                            bd.SeatNumber = @seatNumber)
        return 0;
    end



go
create procedure sp_AddBooking
	@customerId int,
	@voyageId int,
	@seatNumber tinyint,
	@discount tinyint
as
	begin
		if not exists (select * from Booking_Details bd, Bookings b
								where b.Id = bd.BookingId and
										bd.SeatNumber = @seatNumber and
										b.VoyageId = @voyageId)
			begin
				declare @gender int;
				exec @gender = FindConnectedSeatGender @seatNumber, @voyageId;
				if (@gender = (select gender from Customers where Id = @customerId) or @gender = 0)
					begin
						insert into Bookings (VoyageId, BookingDate)
						values (@voyageId, GETDATE());

						declare @bookingId int;
						set @bookingId = @@IDENTITY;

						declare @price int;
						set @price = (select price from Voyages where Id = @voyageId)

						insert into Booking_Details (BookingId, CustomerId, Discount, Price, SeatNumber)
						values(@bookingId, @customerId, @discount, @price, @seatNumber)
					end
				else
					print 'The Customer in connected Seat is not a same gender';
			end
		else
			print 'Seat taken';
		end
 


go -- güncellenen fiyat bilgilerini yeni tabloya ekler
create trigger trg_Save_Voyage_Changes
	on Voyages
	for update
as
    begin
        declare @voyageId int;
        declare @oldPrice money;
        declare @newPrice money;
        declare @oldDepartDate datetime2(2);
        declare @newDepartDate datetime2(2);
        declare @oldEstimatedArrivalDate datetime2(2);
        declare @newEstimatedArrivalDate datetime2(2);
        declare @oldArrivalDate datetime2(2);
        declare @newArrivalDate datetime2(2);
 
        select @voyageId = Id from inserted;
        select @oldPrice = Price from deleted;
        select @newPrice = Price from inserted;
        select @oldDepartDate = DepartDate from deleted;
        select @newDepartDate = DepartDate from inserted;
        select @oldEstimatedArrivalDate = EstimatedArrivalDate from deleted;
        select @newEstimatedArrivalDate = EstimatedArrivalDate from inserted;
        select @oldArrivalDate = ArrivalDate from deleted;
        select @newArrivalDate = ArrivalDate from inserted;
 
 
        insert into UPDATED_VOYAGES (VoyageId, ChangeDate, OldPrice, NewPrice, OldDepartDate, NewDepartDate, OldEstimatedArrivalDate, NewEstimatedArrivalDate, OldArrivalDate, NewArrivalDate)
        values (@voyageId, GETDATE(), @oldPrice, @newPrice, @oldDepartDate, @newDepartDate, @oldEstimatedArrivalDate, @newEstimatedArrivalDate, @oldArrivalDate, @newArrivalDate)
    end
 
go
create trigger trg_Copy_Booking_Details_On_Cancel
	on Voyages
	after insert
as
    begin
		declare @voyageId int;
		declare @canceledVoyageId int = null;

		select @voyageId = Id from inserted;
		select @canceledVoyageId = CanceledVoyageId from inserted;

        if @canceledvoyageid is not null
		begin
			update Bookings
			set VoyageId = @voyageId
			where VoyageId = @canceledVoyageId;

			update Booking_Details
			set Price *= 0.9,
				Discount = 10
			where BookingId in (select BookingId
								from Bookings b, Booking_Details bd
								where b.Id = bd.BookingId and
										b.VoyageId = @canceledVoyageId)
		end
     end
 
-- ################
-- END OF TRIGGER, SP, UDF