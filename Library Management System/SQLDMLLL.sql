use library_db;

--CREATE all tables with: 
--1.Branch Table
CREATE TABLE Branch (
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
        CHECK (Status IN ('Borrowed','Returned','Overdue')),
	FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID)
        ON DELETE NO ACTION
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

--Alter tables
-- Add last_login to Member table
ALTER TABLE Member
	ADD last_login DATETIME NULL;

-- Add rating to Book table
ALTER TABLE Book
	ADD rating INT CHECK (rating BETWEEN 1 AND 5);

--SQL & DML
INSERT INTO Branch (Branch_Name, Address, Phone, Manager_Name, Opening_Date)
	VALUES
	('Central Library', '123 Main St', '123-456-7890', 'Alice Smith', '2010-01-15'),
	('North Branch', '456 North Rd', '234-567-8901', 'Bob Johnson', '2012-06-01'),
	('East Branch', '789 East Ave', '345-678-9012', 'Cathy Lee', '2015-09-20'),
	('South Branch', '321 South Blvd', '456-789-0123', 'David Kim', '2018-03-12'),
	('West Branch', '654 West St', '567-890-1234', 'Eva Brown', '2020-11-05');

INSERT INTO Member (Name, Email, Phone, Address, Membership_Type, Join_Date, Expiry_Date, Status, last_login)
	VALUES
	('John Doe','john@example.com','111-111-1111','101 First St','Standard','2024-01-01','2025-01-01','Active','2025-10-28 09:00:00'),
	('Jane Smith','jane@example.com','222-222-2222','102 Second St','Premium','2023-06-15','2024-06-15','Expired','2024-06-14 15:30:00'),
	('Mike Brown','mike@example.com','333-333-3333','103 Third St','Standard','2023-09-10','2024-09-10','Active','2025-09-15 10:20:00'),
	('Lucy Green','lucy@example.com','444-444-4444','104 Fourth St','Premium','2024-02-20','2025-02-20','Active','2025-10-01 08:45:00'),
	('Tom White','tom@example.com','555-555-5555','105 Fifth St','Standard','2022-12-01','2023-12-01','Expired','2023-11-30 14:00:00'),
	('Sara Black','sara@example.com','666-666-6666','106 Sixth St','Premium','2025-10-20','2026-10-20','Active',NULL),  -- new member
	('Peter Hall','peter@example.com','777-777-7777','107 Seventh St','Standard','2025-10-25','2026-10-25','Active',NULL),  -- new member
	('Emma King','emma@example.com','888-888-8888','108 Eighth St','Premium','2023-08-15','2024-08-15','Expired','2024-08-14 11:00:00'),
	('Ryan Scott','ryan@example.com','999-999-9999','109 Ninth St','Standard','2024-06-10','2025-06-10','Active','2025-10-25 16:45:00'),
	('Olivia Adams','olivia@example.com','101-010-1010','110 Tenth St','Premium','2023-11-20','2024-11-20','Expired','2024-11-19 10:00:00'),
	('Liam Turner','liam@example.com','121-212-1212','111 Eleventh St','Standard','2024-07-01','2025-07-01','Active','2025-10-29 14:20:00'),
	('Sophia Baker','sophia@example.com','131-313-1313','112 Twelfth St','Premium','2024-10-28','2025-10-28','Active',NULL),  -- new member
	('Noah Davis','noah@example.com','141-414-1414','113 Thirteenth St','Standard','2024-08-15','2025-08-15','Active','2025-10-26 13:10:00'),
	('Ava Wilson','ava@example.com','151-515-1515','114 Fourteenth St','Premium','2024-10-29','2025-10-29','Active',NULL),  -- new member
	('Ethan Moore','ethan@example.com','161-616-1616','115 Fifteenth St','Standard','2024-09-10','2025-09-10','Active','2025-10-27 11:05:00'),
	('Mia Taylor','mia@example.com','171-717-1717','116 Sixteenth St','Premium','2023-07-15','2024-07-15','Expired','2024-07-14 15:00:00'),
	('Alexander Lee','alex@example.com','181-818-1818','117 Seventeenth St','Standard','2024-04-25','2025-04-25','Active','2025-10-28 08:55:00'),
	('Isabella Clark','isabella@example.com','191-919-1919','118 Eighteenth St','Premium','2023-09-30','2024-09-30','Expired','2024-09-29 12:30:00'),
	('James Lewis','james@example.com','202-202-2020','119 Nineteenth St','Standard','2024-05-12','2025-05-12','Active','2025-10-27 17:20:00'),
	('Charlotte Young','charlotte@example.com','212-121-2121','120 Twentieth St','Premium','2025-10-30','2026-10-30','Active',NULL);  -- new member

INSERT INTO Author (Name, Biography, Birth_Year, Nationality)
	VALUES
	('J.K. Rowling', 'British author, best known for the Harry Potter series.', 1965, 'UK'),
	('George R.R. Martin', 'American novelist and short story writer, known for A Song of Ice and Fire.', 1948, 'USA'),
	('Agatha Christie', 'English writer famous for detective novels.', 1890, 'UK'),
	('Stephen King', 'American author of horror, supernatural fiction, suspense.', 1947, 'USA'),
	('Isabel Allende', 'Chilean writer known for novels such as The House of the Spirits.', 1942, 'Chile'),
	('Haruki Murakami', 'Japanese writer of contemporary fiction and magical realism.', 1949, 'Japan'),
	('Paulo Coelho', 'Brazilian lyricist and novelist, author of The Alchemist.', 1947, 'Brazil'),
	('Chimamanda Ngozi Adichie', 'Nigerian writer of novels, short stories and essays.', 1977, 'Nigeria'),
	('Neil Gaiman', 'English author of short fiction, novels, comic books, and films.', 1960, 'UK'),
	('Margaret Atwood', 'Canadian poet, novelist, literary critic, and essayist.', 1939, 'Canada');

INSERT INTO Publisher (Name, Country, Contact_Email, Established_Year)
	VALUES
	('Penguin Random House', 'USA', 'contact@penguinrandomhouse.com', 1927),
	('HarperCollins', 'UK', 'info@harpercollins.co.uk', 1817),
	('Macmillan Publishers', 'USA', 'support@macmillan.com', 1843),
	('Hachette Livre', 'France', 'contact@hachette.fr', 1826),
	('Simon & Schuster', 'USA', 'info@simonandschuster.com', 1924);

INSERT INTO Category (Category_Name, Description)
	VALUES
	('Fiction', 'Novels and fictional stories'),
	('Non-Fiction', 'Informative books based on facts'),
	('Science', 'Books about science, experiments, and discoveries'),
	('History', 'Books covering historical events and biographies'),
	('Biography', 'Life stories of famous personalities'),
	('Technology', 'Books on computing, engineering, and technology'),
	('Art', 'Books on painting, sculpture, and visual arts'),
	('Children', 'Books intended for children and young readers');

INSERT INTO Book (ISBN, Title, Edition, Publication_Year, Total_Copies, Available_Copies, Shelf_Location, Book_Condition, Publisher_ID, rating)
	VALUES
	('978-001','The Great Adventure',1,2010,5,3,'A1','Good',1,4),
	('978-002','Mystery of the Old House',2,2012,3,1,'A2','Fair',2,5),
	('978-003','Science Wonders',1,2015,4,4,'B1','Good',3,3),
	('978-004','World History 101',1,2018,2,0,'B2','Good',4,5),
	('978-005','Life of a Genius',3,2020,6,6,'C1','New',5,4),
	('978-006','Modern Technology',1,2011,4,2,'C2','Good',1,5),
	('978-007','Art and Culture',2,2013,3,1,'D1','Fair',2,4),
	('978-008','Children Tales',1,2016,5,5,'D2','New',3,5),
	('978-009','Mystery Island',1,2019,2,2,'E1','Good',4,3),
	('978-010','Space Explorers',1,2021,4,3,'E2','New',5,5),
	('978-011','Gardening Tips',1,2010,5,5,'A1','Good',1,4),
	('978-012','Advanced Mathematics',2,2012,3,0,'A2','Fair',2,3),
	('978-013','Physics for Everyone',1,2015,4,4,'B1','Good',3,4),
	('978-014','Chemistry Basics',1,2018,2,1,'B2','Damaged',4,2),
	('978-015','Famous Biographies',3,2020,6,6,'C1','New',5,5),
	('978-016','World Geography',1,2011,4,2,'C2','Good',1,3),
	('978-017','Modern Art',2,2013,3,1,'D1','Fair',2,4),
	('978-018','Computer Programming',1,2016,5,5,'D2','New',3,5),
	('978-019','Ancient Civilizations',1,2019,2,2,'E1','Good',4,3),
	('978-020','The Ocean World',1,2021,4,3,'E2','New',5,4),
	('978-021','Poetry Collection',1,2010,5,5,'A1','Good',1,4),
	('978-022','Mystery Chronicles',2,2012,3,0,'A2','Fair',2,5),
	('978-023','Engineering Basics',1,2015,4,4,'B1','Good',3,3),
	('978-024','Digital Photography',1,2018,2,1,'B2','Damaged',4,4),
	('978-025','Fictional Worlds',3,2020,6,6,'C1','New',5,5),
	('978-026','Travel Diaries',1,2011,4,2,'C2','Good',1,3),
	('978-027','Science Experiments',2,2013,3,1,'D1','Fair',2,4),
	('978-028','History of Art',1,2016,5,5,'D2','New',3,5),
	('978-029','Fantasy Tales',1,2019,2,2,'E1','Good',4,3),
	('978-030','Robotics Guide',1,2021,4,3,'E2','New',5,4);

INSERT INTO BookAuthors (Book_ID, Author_ID)
	VALUES
	(1, 1),   -- The Great Adventure by J.K. Rowling
	(2, 2),   -- Mystery of the Old House by George R.R. Martin
	(3, 3),   -- Science Wonders by Agatha Christie
	(4, 4),   -- World History 101 by Stephen King
	(5, 5),   -- Life of a Genius by Isabel Allende
	(6, 6),   -- Modern Technology by Haruki Murakami
	(7, 7),   -- Art and Culture by Paulo Coelho
	(8, 8),   -- Children Tales by Chimamanda Ngozi Adichie
	(9, 9),   -- Mystery Island by Neil Gaiman
	(10, 10), -- Space Explorers by Margaret Atwood
	(11, 1),  -- Gardening Tips by J.K. Rowling
	(12, 2),  -- Advanced Mathematics by George R.R. Martin
	(13, 3),  -- Physics for Everyone by Agatha Christie
	(14, 4),  -- Chemistry Basics by Stephen King
	(15, 5),  -- Famous Biographies by Isabel Allende
	(16, 6),  -- World Geography by Haruki Murakami
	(17, 7),  -- Modern Art by Paulo Coelho
	(18, 8),  -- Computer Programming by Chimamanda Ngozi Adichie
	(19, 9),  -- Ancient Civilizations by Neil Gaiman
	(20, 10), -- The Ocean World by Margaret Atwood

	-- Books with multiple authors
	(21, 1), (21, 2),       -- Poetry Collection by J.K. Rowling & George R.R. Martin
	(22, 2), (22, 3),       -- Mystery Chronicles by George R.R. Martin & Agatha Christie
	(23, 3), (23, 4),       -- Engineering Basics by Agatha Christie & Stephen King
	(24, 4), (24, 5),       -- Digital Photography by Stephen King & Isabel Allende
	(25, 5), (25, 6),       -- Fictional Worlds by Isabel Allende & Haruki Murakami
	(26, 6), (26, 7),       -- Travel Diaries by Haruki Murakami & Paulo Coelho
	(27, 7), (27, 8),       -- Science Experiments by Paulo Coelho & Chimamanda Ngozi Adichie
	(28, 8), (28, 9),       -- History of Art by Chimamanda Ngozi Adichie & Neil Gaiman
	(29, 9), (29, 10),      -- Fantasy Tales by Neil Gaiman & Margaret Atwood
	(30, 10),				-- Robotics Guide by Margaret Atwood & J.K. Rowling
	(30, 1);            -- Robotics Guide by Margaret Atwood & J.K. Rowling

INSERT INTO BookCategories (Book_ID, Category_ID)
	VALUES
	(1, 1),   -- The Great Adventure → Fiction
	(2, 1),   -- Mystery of the Old House → Fiction
	(3, 3),   -- Science Wonders → Science
	(4, 4),   -- World History 101 → History
	(5, 5),   -- Life of a Genius → Biography
	(6, 6),   -- Modern Technology → Technology
	(7, 7),   -- Art and Culture → Art
	(8, 8),   -- Children Tales → Children
	(9, 1),   -- Mystery Island → Fiction
	(10, 3),  -- Space Explorers → Science
	(11, 5),  -- Gardening Tips → Biography
	(12, 3),  -- Advanced Mathematics → Science
	(13, 3),  -- Physics for Everyone → Science
	(14, 3),  -- Chemistry Basics → Science
	(15, 5),  -- Famous Biographies → Biography
	(16, 4),  -- World Geography → History
	(17, 7),  -- Modern Art → Art
	(18, 6),  -- Computer Programming → Technology
	(19, 4),  -- Ancient Civilizations → History
	(20, 3),  -- The Ocean World → Science
	(21, 1),  -- Poetry Collection → Fiction
	(22, 1),  -- Mystery Chronicles → Fiction
	(23, 6),  -- Engineering Basics → Technology
	(24, 7),  -- Digital Photography → Art
	(25, 1),  -- Fictional Worlds → Fiction
	(26, 1),  -- Travel Diaries → Fiction
	(27, 3),  -- Science Experiments → Science
	(28, 7),  -- History of Art → Art
	(29, 1),  -- Fantasy Tales → Fiction
	(30, 6);  -- Robotics Guide → Technology

INSERT INTO Fines (Fine_Amount, Paid_Amount, Payment_Date, Status)
	VALUES
	(5.00, 5.00, '2025-10-10', 'Paid'),
	(7.50, 0.00, NULL, 'Pending'),
	(10.00, 0.00, NULL, 'Pending'),
	(3.00, 3.00, '2025-10-12', 'Paid'),
	(12.50, 0.00, NULL, 'Pending'),
	(8.00, 8.00, '2025-10-15', 'Paid'),
	(6.00, 0.00, NULL, 'Pending'),
	(4.50, 0.00, NULL, 'Pending');

INSERT INTO Borrow (Member_ID, Book_ID, Branch_ID, Fine_ID, Borrow_Date, Due_Date, Return_Date, Status)
	VALUES
	(21, 1, 1, NULL, '2025-10-01', '2025-10-15', NULL, 'Borrowed'),
	(22, 3, 2, NULL, '2025-10-05', '2025-10-20', NULL, 'Borrowed'),
	(23, 5, 3, NULL, '2025-10-10', '2025-10-24', NULL, 'Borrowed'),
	(24, 7, 4, NULL, '2025-10-12', '2025-10-26', NULL, 'Borrowed'),
	(25, 9, 5, NULL, '2025-10-15', '2025-10-29', NULL, 'Borrowed'),
	(26, 2, 1, NULL, '2025-09-01', '2025-09-15', '2025-09-14', 'Returned'),
	(27, 4, 2, NULL, '2025-09-05', '2025-09-19', '2025-09-18', 'Returned'),
	(28, 6, 3, NULL, '2025-09-10', '2025-09-24', '2025-09-23', 'Returned'),
	(29, 8, 4, NULL, '2025-09-12', '2025-09-26', '2025-09-25', 'Returned'),
	(30, 10, 5, NULL, '2025-09-15', '2025-09-29', '2025-09-28', 'Returned'),
	(31, 11, 1, 1, '2025-09-20', '2025-10-04', NULL, 'Overdue'),
	(32, 12, 2, 2, '2025-09-22', '2025-10-06', NULL, 'Overdue'),
	(33, 13, 3, 3, '2025-09-25', '2025-10-09', NULL, 'Overdue'),
	(34, 14, 4, 4, '2025-09-28', '2025-10-12', NULL, 'Overdue'),
	(35, 15, 5, 5, '2025-10-01', '2025-10-15', NULL, 'Overdue'),
	(36, 16, 1, 6, '2025-10-03', '2025-10-17', '2025-10-16', 'Returned'),
	(37, 17, 2, NULL, '2025-10-05', '2025-10-19', NULL, 'Borrowed'),
	(38, 18, 3, NULL, '2025-10-07', '2025-10-21', NULL, 'Borrowed'),
	(39, 19, 4, 7, '2025-09-30', '2025-10-14', NULL, 'Overdue'),
	(40, 20, 5, 8, '2025-09-28', '2025-10-12', '2025-10-11', 'Returned'),
	(21, 21, 1, NULL, '2025-10-10', '2025-10-24', NULL, 'Borrowed'),
	(22, 22, 2, NULL, '2025-10-01', '2025-10-15', NULL, 'Borrowed'),
	(23, 23, 3, 3, '2025-09-20', '2025-10-04', NULL, 'Overdue'),
	(24, 24, 4, 4, '2025-10-05', '2025-10-19', '2025-10-18', 'Returned'),
	(25, 25, 5, NULL, '2025-10-12', '2025-10-26', NULL, 'Borrowed');


INSERT INTO Reservation (Member_ID, Book_ID, Reservation_Date, Expiry_Date, Status)
	VALUES
	(21, 3, '2025-10-20', '2025-10-27', 'Active'),
	(22, 5, '2025-10-18', '2025-10-25', 'Fulfilled'),
	(23, 7, '2025-10-19', '2025-10-26', 'Active'),
	(24, 2, '2025-10-15', '2025-10-20', 'Expired'),
	(25, 9, '2025-10-21', '2025-10-28', 'Active');


--UPDATE scenarios
--1. Update a member's membership from Standard to Premium
UPDATE Member
	SET Membership_Type = 'Premium'
	WHERE Membership_Type = 'Standard'
	AND Member_ID = 21;

--2. Mark books as returned and update available copies
UPDATE Borrow
SET Status = 'Returned',
    Return_Date = GETDATE()
	WHERE Borrow_ID = 48;

UPDATE Book
SET Available_Copies = Available_Copies + 1
WHERE Book_ID IN (
    SELECT Book_ID
    FROM Borrow
    WHERE Borrow_ID = 48
);

--3. Update fine status to 'Paid' and set payment date
UPDATE Fines
SET Status = 'Paid',
    Payment_Date = GETDATE()
	WHERE Fine_ID = 2; 


--DELETE scenarios
--1. Delete a reservation that expired
DELETE FROM Reservation
	WHERE Status = 'Expired';

--2. Attempt to delete a member who has active borrowings (should fail due to FK constraint)
DELETE FROM Member
WHERE Member_ID = (
    SELECT TOP 1 Member_ID
    FROM Borrow
    WHERE Status = 'Borrowed' OR Status = 'Overdue'
);


	select * from Member;
	select * from Borrow;
	select * from Reservation; 


		SET IDENTITY_INSERT Member ON;

INSERT INTO Member (Member_ID, Name, Email, Phone, Address, Membership_Type, Join_Date, Expiry_Date, Status, last_login)
VALUES 
(22, 'Jane Smith', 'jane@example.com', '222-222-2222', '102 Second St', 'Premium', '2023-06-15', '2024-06-15', 'Expired', '2024-06-14 15:30:00');

SET IDENTITY_INSERT Member OFF;

SET IDENTITY_INSERT Borrow ON;

INSERT INTO Borrow (Borrow_ID, Member_ID, Book_ID, Branch_ID, Fine_ID, Borrow_Date, Due_Date, Return_Date, Status)
VALUES
(22, 22, 2, 2, NULL, '2025-10-01', '2025-10-15', NULL, 'Borrowed'),
(32, 22, 3, 2, 2, '2025-09-22', '2025-10-06', NULL, 'Overdue');  -- example from earlier data

SET IDENTITY_INSERT Borrow OFF;

SET IDENTITY_INSERT Reservation ON;

INSERT INTO Reservation (Reservation_ID, Member_ID, Book_ID, Reservation_Date, Expiry_Date, Status)
VALUES
	(7, 22, 5, '2025-10-18', '2025-10-25', 'Fulfilled');

SET IDENTITY_INSERT Reservation OFF;



delete from Reservation where Reservation_ID = 22;


--1. List all books published after 2020
SELECT * FROM Book b
	WHERE b.Publication_Year > 2020;

--2. Find all members whose membership expires in the next 30 days
SELECT *
	FROM Member m
	WHERE m.Expiry_Date >= CAST(GETDATE() AS DATE)
	AND m.Expiry_Date <= CAST(DATEADD(DAY, 30, GETDATE()) AS DATE);

--3. Show all overdue borrowings (return_date IS NULL AND due_date < CURDATE())
SELECT *
	FROM Borrow
	WHERE Return_Date IS NULL
	  AND Status = 'Overdue'
	  AND Due_Date < CAST(GETDATE() AS DATE);

--4. List books that have never been borrowed
SELECT * 
	FROM Book
	WHERE Book_ID NOT IN 
	(SELECT Book_ID FROM Borrow);

--5. Find members with pending fines greater than $10
SELECT 
    m.Name AS Member_Name, f.Fine_Amount, f.Status
	FROM Member m
	JOIN Borrow bo ON m.Member_ID = bo.Member_ID
	JOIN Fines f ON bo.Fine_ID = f.Fine_ID
	WHERE f.Status = 'Pending' 
	  AND f.Fine_Amount > 10;


--6. Show all books in 'Fiction' category
SELECT *
	FROM Book
	JOIN BookCategories bc ON bc.Book_ID = bc.Book_ID
	JOIN Category c ON bc.Category_ID = c.Category_ID
	WHERE c.Category_Name = 'Fiction';

--7. Display books with less than 2 available copies
SELECT *
	FROM Book b
	WHERE b.Available_Copies < 2;

--8. List all authors from 'USA' or 'UK'
SELECT *
	FROM Author a
	WHERE a.Nationality = 'USA' 
	OR a.Nationality = 'UK';

--9. Find books published by 'Penguin Random House'
SELECT *
	FROM Book b
	JOIN Publisher p ON b.Publisher_ID = p.Publisher_ID
	WHERE p.Name = 'Penguin Random House';

--10. Show borrowings from last month using BETWEEN
SELECT *
	FROM Borrow
	WHERE Borrow_Date >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
	AND Borrow_Date < DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);


--INNER JOIN:
--1. List all borrowed books with member names and book titles
SELECT M.Name, b.Title, br.Borrow_Date
	FROM Borrow br
	INNER JOIN Member m ON br.Member_ID = m.Member_ID
	INNER JOIN Book b ON br.Book_ID = b.Book_ID
	WHERE br.Return_Date IS NULL; 

--2. Show all books with their author names (handle multiple authors)
SELECT b.Title, a.Name 
	FROM Book b
	INNER JOIN BookAuthors ba ON b.Book_ID = ba.Book_ID
	INNER JOIN Author a ON ba.Author_ID = a.Author_ID

--3. Display current borrowings with branch information
SELECT m.Name, bo.Title, br.Branch_Name, b.Status
	FROM Borrow b
	INNER JOIN Member m ON b.Member_ID = m.Member_ID
	INNER JOIN Book bo ON b.Book_ID = bo.Book_ID
	INNER JOIN Branch br ON b.Branch_ID = br.Branch_ID

--LEFT JOIN:
--4. List ALL books and show if they're currently borrowed (include books not borrowed)
SELECT b.Title, bo.Borrow_ID, bo.Member_ID
	FROM Book b
	LEFT JOIN Borrow bo ON b.Book_ID = bo.Book_ID
	AND bo.Return_Date IS null; 

--5. Show ALL members and their active borrowings (include members with no borrowings)
SELECT m.Name,b.Title, bo.Borrow_Date
	FROM Member m
	LEFT JOIN Borrow bo ON m.Member_ID = bo.Member_ID 
	AND bo.Return_Date IS NULL
	LEFT JOIN Book b ON bo.Book_ID = b.Book_ID

--RIGHT JOIN / FULL OUTER JOIN (if supported):
--6. Show all categories and count of books (include categories with no books)
SELECT c.Category_Name, COUNT(bc.Book_ID) AS Book_Count
	FROM Category c
	FULL OUTER JOIN BookCategories bc ON bc.Category_ID = c.Category_ID
	GROUP BY c.Category_Name;

