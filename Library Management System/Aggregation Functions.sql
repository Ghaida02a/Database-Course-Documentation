use library_db;

--1. COUNT:
--o Total number of borrowings per member
SELECT m.Name ,COUNT (b.Borrow_ID) AS number_borrowings
	FROM Borrow b
	JOIN Member m ON m.Member_ID = b.Member_ID
	GROUP BY m.Name;

--o Number of books per category
SELECT c.Category_Name, COUNT (bc.Book_ID) AS Total_Book
	FROM Category c
	LEFT JOIN BookCategories bc ON bc.Category_ID = c.Category_ID
	GROUP BY c.Category_Name;

--o Count of overdue books per branch
SELECT br.Branch_Name, COUNT (b.Borrow_ID) AS Total_OverdueBooks
	FROM Borrow b
	JOIN Branch br ON br.Branch_ID = b.Branch_ID
	WHERE b.Status = 'Overdue'
	GROUP BY br.Branch_Name;

--2. SUM:
--o Total fines collected per month
SELECT MONTH(b.Return_Date) AS MONTH,
	SUM(f.Paid_Amount) AS Total_Fines_collected
	FROM Borrow b, Fines f
	WHERE b.Status = 'Returned'
	GROUP BY MONTH(b.Return_Date);

--o Total pending fines per member
SELECT m.Name,
	SUM (f.Fine_Amount- f.Paid_Amount) AS Total_Pending_Fines
	FROM Fines f
	JOIN Borrow b ON b.Fine_ID = f.Fine_ID
	JOIN Member m ON b.Member_ID = m.Member_ID
	WHERE f.Fine_Amount > f.Paid_Amount
	GROUP BY m.Name;

--o Sum of available copies per publisher
SELECT p.Name,
	SUM (b.Available_Copies) AS Total_Available_Copies
	FROM Book b
	JOIN Publisher P ON B.Publisher_ID = P.Publisher_ID
	GROUP BY p.Name;

--3. AVG:
--o Average number of days books are borrowed
SELECT b.Title,
	AVG (DATEDIFF(DAY, bo.Borrow_Date, bo.Return_Date)) AS Avg_Borrow_Days
	FROM Borrow bo
	JOIN Book b ON bo.Book_ID = b.Book_ID
	WHERE bo.Return_Date IS NOT NULL
	GROUP BY b.Title;

--o Average fine amount per member
SELECT m.Name,
	AVG (f.Fine_Amount) AS Avg_Fine_Amount
	FROM Fines f
	JOIN Borrow b ON f.Fine_ID = b.Fine_ID
	JOIN Member m ON m.Member_ID = b.Member_ID
	GROUP BY m.Name;

--o Average books borrowed per branch
SELECT br.Branch_Name, 
	COUNT (bo.Borrow_ID) / COUNT (DISTINCT br.Branch_ID) AS Avg_Borrowed_Books
	FROM Branch br
	JOIN Borrow bo ON bo.Branch_ID = br.Branch_ID
	GROUP BY br.Branch_Name;


--4. MIN/MAX:
--o Find the oldest and newest publications in the library
SELECT 
    MIN(Publication_Year) AS Oldest_Publication,
    MAX(Publication_Year) AS Newest_Publication
	FROM Book;

--o Member with maximum and minimum borrowings
--maximum
SELECT TOP 1 
    m.Name AS Member_Name,
    COUNT(bo.Borrow_ID) AS Total_Borrowings
	FROM Member m
	JOIN Borrow bo ON m.Member_ID = bo.Member_ID
	GROUP BY m.Name
	ORDER BY Total_Borrowings DESC;

--minimum
SELECT TOP 1 
    m.Name AS Member_Name,
    COUNT(bo.Borrow_ID) AS Total_Borrowings
	FROM Member m
	JOIN Borrow bo ON m.Member_ID = bo.Member_ID
	GROUP BY m.Name
	ORDER BY Total_Borrowings ASC;


--o Highest fine amount ever charged
SELECT 
	MAX (f.Fine_Amount) AS Highest_Fine
	FROM Fines f;

--5. Complex Aggregations with HAVING:
--o Show categories with more than 5 books
SELECT c.Category_Name,
	COUNT(bc.Book_ID) AS Total_Books
	FROM Category c
	JOIN BookCategories bc ON c.Category_ID = bc.Category_ID
	GROUP BY c.Category_Name
	HAVING COUNT(bc.Book_ID) > 5;

--o Find members who borrowed more than 3 books in last month
SELECT m.Name, COUNT(bo.Borrow_ID) AS Total_Borrowed_Books
	FROM Member m
	JOIN Borrow bo ON bo.Member_ID = m.Member_ID
	GROUP BY m.Name
	HAVING COUNT(bo.Borrow_ID) > 3;

--o List authors with more than 2 books in the library
SELECT a.Name, COUNT (ba.Book_ID) AS Total_Books
	FROM Author a
	JOIN BookAuthors ba ON a.Author_ID = ba.Author_ID
	GROUP BY a.Name
	HAVING COUNT (ba.Book_ID) > 2;

--o Show branches with total pending fines > $100
SELECT br.Branch_Name, SUM (f.Fine_Amount - f.Paid_Amount) AS Total_Pending_Fines
	FROM Borrow bo
	JOIN Branch br ON bo.Branch_ID = br.Branch_ID
	JOIN Fines f ON bo.Fine_ID = f.Fine_ID
	GROUP BY br.Branch_Name
	HAVING SUM(f.Fine_Amount - f.Paid_Amount) > 100;

--6. GROUP BY with Multiple Columns:
--o Total borrowings per branch per month
SELECT 
    br.Branch_Name,
    YEAR(b.Borrow_Date) AS Year_Borrowed,
    MONTH(b.Borrow_Date) AS Month_Borrowed,
    COUNT(b.Borrow_ID) AS Total_Borrowings
	FROM Borrow b
	JOIN Branch br ON b.Branch_ID = br.Branch_ID
	GROUP BY br.Branch_Name, YEAR(b.Borrow_Date), MONTH(b.Borrow_Date)

--o Fine collection per member per yearSELECT m.Name AS Member_Name, YEAR(bo.Return_Date) AS YEAR,	SUM (f.Paid_Amount) AS Total_Fine_Collected	FROM Borrow bo	JOIN Member m ON bo.Member_ID = m.Member_ID	JOIN Fines f ON bo.Fine_ID = f.Fine_ID	GROUP BY m.Name, YEAR (bo.Return_Date);