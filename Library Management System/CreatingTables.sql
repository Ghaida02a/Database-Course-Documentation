use library_db;--CREATE all tables with: --1.Branch TableCREATE TABLE Branch (
    Branch_ID INT IDENTITY(1,1) PRIMARY KEY,
    Branch_Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Phone VARCHAR(20),
    Manager_Name VARCHAR(100),
    Opening_Date DATE
);

--2.Publisher Table
CREATE TABLE Publisher (
    Publisher_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    Contact_Email VARCHAR(100),
    Established_Year INT CHECK (Established_Year >= 1800)
);

--3.Author Table
CREATE TABLE Author (
    Author_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Biography VARCHAR(100),
    Birth_Year INT CHECK (Birth_Year >= 1000),
    Nationality VARCHAR(50)
);

--4.Category Table
CREATE TABLE Category (
    Category_ID INT IDENTITY(1,1) PRIMARY KEY,
    Category_Name VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

--5.Fines Table
CREATE TABLE Fines (
    Fine_ID INT IDENTITY(1,1) PRIMARY KEY,
    Fine_Amount DECIMAL(8,2) NOT NULL CHECK (Fine_Amount >= 0),
    Paid_Amount DECIMAL(8,2) DEFAULT 0 CHECK (Paid_Amount >= 0),
    Payment_Date DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (Status IN ('Pending','Paid','Waived'))
);

--6.Book Table
CREATE TABLE Book (
    Book_ID INT IDENTITY(1,1) PRIMARY KEY,
    ISBN VARCHAR(20) UNIQUE,
    Title VARCHAR(150) NOT NULL,
    Edition INT CHECK (Edition >= 1),
    Publication_Year INT CHECK (Publication_Year >= 1800),
    Total_Copies INT NOT NULL CHECK (Total_Copies >= 0),
    Available_Copies INT NOT NULL CHECK (Available_Copies >= 0),
    Shelf_Location VARCHAR(50),
    Book_Condition VARCHAR(20) DEFAULT 'Good'
        CHECK (Book_Condition IN ('New','Good','Fair','Damaged')),
    Publisher_ID INT,
    FOREIGN KEY (Publisher_ID) REFERENCES Publisher(Publisher_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CHECK (Available_Copies <= Total_Copies)
);

--7.BookAuthors Table
CREATE TABLE BookAuthors (
    Book_ID INT NOT NULL,
    Author_ID INT NOT NULL,
    PRIMARY KEY (Book_ID, Author_ID),
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

--8.BookCategories Table
CREATE TABLE BookCategories (
    Book_ID INT NOT NULL,
    Category_ID INT NOT NULL,
    PRIMARY KEY (Book_ID, Category_ID),
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

--9.Member Table 
CREATE TABLE Member (
	Member_ID INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    Membership_Type VARCHAR(20) NOT NULL DEFAULT 'Standard'
        CHECK (Membership_Type IN ('Standard', 'Premium')),
    Join_Date DATE DEFAULT (GETDATE()),
    Expiry_Date DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Active'
        CHECK (Status IN ('Active','Expired','Suspended'))
);

--10.Borrow Table
CREATE TABLE Borrow (
    Borrow_ID INT IDENTITY(1,1) PRIMARY KEY,
    Member_ID INT NOT NULL,
    Book_ID INT NOT NULL,
    Branch_ID INT NOT NULL,
    Fine_ID INT,
    Borrow_Date DATE NOT NULL DEFAULT (GETDATE()),
    Due_Date DATE NOT NULL,
    Return_Date DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Borrowed'
        CHECK (Status IN ('Borrowed','Returned','Overdue')),    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Fine_ID) REFERENCES Fines(Fine_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CHECK (Due_Date >= Borrow_Date)
);

--11.Reservation Table
CREATE TABLE Reservation (
    Reservation_ID INT IDENTITY(1,1) PRIMARY KEY,
    Member_ID INT NOT NULL,
    Book_ID INT NOT NULL,
    Reservation_Date DATE DEFAULT (GETDATE()),
    Expiry_Date DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Active'
        CHECK (Status IN ('Active','Fulfilled','Expired')),
		FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (Expiry_Date IS NULL OR Expiry_Date >= Reservation_Date)
);

--Creating indexes for FK
CREATE INDEX idx_book_publisher ON Book(Publisher_ID);

CREATE INDEX idx_bookauthors_book ON BookAuthors(Book_ID);
CREATE INDEX idx_bookauthors_author ON BookAuthors(Author_ID);

CREATE INDEX idx_BookCategories_book ON BookCategories(Book_ID);
CREATE INDEX idx_BookCategories_category ON BookCategories(Category_ID);

CREATE INDEX idx_borrow_member ON Borrow(Member_ID);
CREATE INDEX idx_borrow_book ON Borrow(Book_ID);
CREATE INDEX idx_borrow_branch ON Borrow(Branch_ID);
CREATE INDEX idx_borrow_fine ON Borrow(Fine_ID);

CREATE INDEX idx_reservation_member ON Reservation(Member_ID);
CREATE INDEX idx_reservation_book ON Reservation(Book_ID);

--Creating indexes for Search fields
CREATE INDEX idx_book_title ON Book(Title);      -- searching books by title
CREATE INDEX idx_member_name ON Member(Name);    -- searching members by name

--Creating indexes for Date fields
CREATE INDEX idx_borrow_date ON Borrow(Borrow_Date);
CREATE INDEX idx_borrow_due ON Borrow(Due_Date);
CREATE INDEX idx_borrow_return ON Borrow(Return_Date);
CREATE INDEX idx_reservation_date ON Reservation(Reservation_Date);
CREATE INDEX idx_reservation_expiry ON Reservation(Expiry_Date);
CREATE INDEX idx_member_join ON Member(Join_Date);
CREATE INDEX idx_member_expiry ON Member(Expiry_Date);
CREATE INDEX idx_fines_payment ON Fines(Payment_Date);