-- Create the RestaurantDB database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RestaurantDB')
BEGIN
    CREATE DATABASE RestaurantDB;
END
GO

-- Use the RestaurantDB database
USE RestaurantDB;
GO

-- Create the Bookings table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Bookings')
BEGIN
    CREATE TABLE Bookings (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) NOT NULL,
        dateTime DATETIME NOT NULL,
        people INT NOT NULL,
        specialRequest NVARCHAR(MAX),
        bookingDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- Create an index on dateTime for faster queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Bookings_DateTime')
BEGIN
    CREATE INDEX IX_Bookings_DateTime ON Bookings(dateTime);
END
GO

-- Create a stored procedure for inserting bookings
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_InsertBooking')
BEGIN
    DROP PROCEDURE sp_InsertBooking;
END
GO

CREATE PROCEDURE sp_InsertBooking
    @name NVARCHAR(100),
    @email NVARCHAR(100),
    @dateTime DATETIME,
    @people INT,
    @specialRequest NVARCHAR(MAX) = NULL
AS
BEGIN
    INSERT INTO Bookings (name, email, dateTime, people, specialRequest)
    VALUES (@name, @email, @dateTime, @people, @specialRequest);
    
    SELECT SCOPE_IDENTITY() AS bookingId;
END
GO

-- Create a stored procedure for getting all bookings
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetAllBookings')
BEGIN
    DROP PROCEDURE sp_GetAllBookings;
END
GO

CREATE PROCEDURE sp_GetAllBookings
AS
BEGIN
    SELECT 
        id,
        name,
        email,
        dateTime,
        people,
        specialRequest,
        bookingDate
    FROM Bookings
    ORDER BY dateTime DESC;
END
GO

-- Create a view for recent bookings
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_RecentBookings')
BEGIN
    DROP VIEW vw_RecentBookings;
END
GO

CREATE VIEW vw_RecentBookings AS
SELECT TOP 10
    id,
    name,
    email,
    dateTime,
    people,
    specialRequest,
    bookingDate
FROM Bookings
ORDER BY dateTime DESC;
GO

-- Insert some sample data
INSERT INTO Bookings (name, email, dateTime, people, specialRequest)
VALUES 
    ('John Doe', 'john@example.com', DATEADD(DAY, 1, GETDATE()), 2, 'Window seat preferred'),
    ('Jane Smith', 'jane@example.com', DATEADD(DAY, 2, GETDATE()), 4, 'Birthday celebration'),
    ('Mike Johnson', 'mike@example.com', DATEADD(DAY, 3, GETDATE()), 3, NULL);
GO 