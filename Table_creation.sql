CREATE DATABASE MUSIC_STORE_DATA;

USE MUSIC_STORE_DATA;

CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY,
    Last_Name NVARCHAR(50),
    First_Name NVARCHAR(50),
    Title NVARCHAR(50),
    Reports_To INT,
    Birthdate DATE,
    Hire_Date DATE,
    Address NVARCHAR(100),
    City NVARCHAR(50),
    State NVARCHAR(50),
    Country NVARCHAR(50),
    Postal_Code NVARCHAR(20),
    Phone NVARCHAR(30),
    Fax NVARCHAR(30),
    Email NVARCHAR(100),
    FOREIGN KEY (Reports_To) REFERENCES Employee(Employee_ID)
);

CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    First_Name NVARCHAR(50),
    Last_Name NVARCHAR(50),
    Company NVARCHAR(100),
    Address NVARCHAR(100),
    City NVARCHAR(50),
    State NVARCHAR(50),
    Country NVARCHAR(50),
    Postal_Code NVARCHAR(20),
    Phone NVARCHAR(30),
    Fax NVARCHAR(30),
    Email NVARCHAR(100),
    Support_Rep_ID INT,
    FOREIGN KEY (Support_Rep_ID) REFERENCES Employee(Employee_ID)
);

CREATE TABLE Invoice (
    Invoice_ID INT PRIMARY KEY,
    Customer_ID INT,
    Invoice_Date DATE,
    Billing_Address NVARCHAR(100),
    Billing_City NVARCHAR(50),
    Billing_Country NVARCHAR(50),
    Billing_Postal_Code NVARCHAR(20),
    Total DECIMAL(10, 2),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE Invoice_Line (
    Invoice_Line_ID INT PRIMARY KEY,
    Invoice_ID INT,
    Track_ID INT,
    Unit_Price DECIMAL(10, 2),
    Quantity INT,
    FOREIGN KEY (Invoice_ID) REFERENCES Invoice(Invoice_ID),
    FOREIGN KEY (Track_ID) REFERENCES Track(Track_ID)
);

CREATE TABLE Track (
    Track_ID INT PRIMARY KEY,
    Name NVARCHAR(200),
    Album_ID INT,
    Media_Type_ID INT,
    Genre_ID INT,
    Composer NVARCHAR(220),
    Milliseconds INT,
    Bytes INT,
    Unit_Price DECIMAL(10, 2),
    FOREIGN KEY (Album_ID) REFERENCES Album(Album_ID),
    FOREIGN KEY (Media_Type_ID) REFERENCES Media(Media_Type_ID),
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID)
);

CREATE TABLE Playlist (
    Playlist_ID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE Artist (
    Artist_ID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE Playlist_Track (
    Playlist_ID INT,
    Track_ID INT,
    PRIMARY KEY (Playlist_ID, Track_ID),
    FOREIGN KEY (Playlist_ID) REFERENCES Playlist(Playlist_ID),
    FOREIGN KEY (Track_ID) REFERENCES Track(Track_ID)
);

CREATE TABLE Album (
    Album_ID INT PRIMARY KEY,
    Title NVARCHAR(160),
    Artist_ID INT,
    FOREIGN KEY (Artist_ID) REFERENCES Artist(Artist_ID)
);

CREATE TABLE Media_type (
    Media_Type_ID INT PRIMARY KEY,
    Name NVARCHAR(120)
);

CREATE TABLE Genre (
    Genre_ID INT PRIMARY KEY,
    Name NVARCHAR(120)
);
