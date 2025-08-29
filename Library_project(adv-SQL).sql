--- Advanced Problems

select * from books
select * from issue
select * from return_status
select * from members
select * from employees
select * from branch


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.


select * from books
select * from issue
select * from return_status
select * from members

select 
    m.member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    rst.return_date,
    dateadd(day,30,ist.issued_date) as due_date,
    datediff(day,dateadd(day,30,ist.issued_date),getdate()) as overdue_days
from issue as ist
join
members as m
on 
m.member_id = ist.issued_member_id
join
books as b
on b.isbn = ist.issued_book_isbn
left join -- to get all records because in return their are only 18 records
return_status as rst
on rst.issued_id = ist.issued_id
where rst.return_date is not null
    and dateadd(day,30,ist.issued_date) < getdate()
order by 
    member_id
    

---Task 14: Update Book Status on Return
---Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).


select * from issue
where issued_book_isbn = '978-0-06-025492-6'

select * from books
where isbn = '978-0-06-025492-6'

update books
set status = 'no'
where isbn = '978-0-06-025492-6'

select * from return_status
where issued_id = 'IS124'


---Insert into return table once the book is return

insert into return_status (return_id,issued_id,return_book_name,return_date,return_book_isbn)
values
('rs125','IS130','the mad fellow',getdate(),'null')
select * from return_status
where issued_id = 'IS130'

update books
set status = 'yes'
where isbn = '978-0-06-025492-6'

---Store Procedures

create or alter procedure add_return_records(
    @p_return_id varchar(20),
    @p_issued_id varchar(20)
)
as

begin
    set nocount on

    declare 
    @v_isbn varchar(20),
    @v_book_name varchar(60)
    

    insert into return_status (return_id,issued_id,return_book_name,return_date,return_book_isbn)
    values
    (@p_return_id,@p_issued_id,getdate(), @v_isbn,@v_book_name)

    SELECT 
        @v_isbn = issued_book_isbn,
        @v_book_name = issued_book_name
    FROM issue
    WHERE issued_id = @p_issued_id;


    update books
    set status = 'yes'
    where isbn = @v_isbn

    print 'Thank you for returning the book: ' + @v_book_name
end

EXEC add_return_records 'RS138','IS135'

SELECT * FROM BOOKS
WHERE isbn = '978-0-307-58837-1'


--- Task 15: Branch Performance Report
--- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

select * from branch

select * from issue

select * from employees

select * from books

select * from return_status

---

select
    br.branch_id,
    br.manager_id,
    count(ist.issued_id) as no_book_issued,
    count(r.return_id) as no_book_return,
    sum(b.rental_price) as total_revenue
    into branch_report
from issue as ist
join
employees as e
on e.emp_id = ist.issued_emp_id
join
branch as br
on br.branch_id = e.branch_id
left join
return_status as r
on r.issued_id = ist.issued_id
join
books as b
on b.isbn = ist.issued_book_isbn
group by
    br.branch_id,
    br.manager_id
    
select * from branch_report


---Task 16: CTAS: Create a Table of Active Members
---Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.


select 
    *
    into active_members
from [dbo].[members]

where member_id in (
                    select 
                        distinct issued_member_id
    
                    from issue
                    where issued_date >= dateadd(month,-24,getdate())
                    )
select * from active_members



---Task 17: Find Employees with the Most Book Issues Processed
---Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select * from employees

select top 3
    e.emp_name,
    ist.issued_emp_id,
    b.branch_id,
    count(ist.issued_emp_id) as no_of_books_issued
from issue as ist
join
employees as e
on e.emp_id = ist.issued_emp_id
join 
branch as b
on b.branch_id = e.branch_id
group by
    e.emp_name,
    ist.issued_emp_id,
    b.branch_id
order by 
    no_of_books_issued desc

    
---Task 19: Stored Procedure
---Objective: Create a stored procedure to manage the status of books in a library system.
    --Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    --If a book is issued, the status should change to 'no'.
    --If a book is returned, the status should change to 'yes'.

select * from books
select * from issue

create or alter procedure issue_book(
    @p_issued_id varchar(10),
    @p_member_id varchar(10),
    @p_issued_book_isbn varchar(20),
    @p_issed_emp_id varchar(10)
)
as

begin

    declare
    @v_status varchar(10),
    @v_issued_date date

    --- check if the book is available
    select
    @v_status = status 
    from books
    where isbn = @p_issued_book_isbn
   
   ---check for issued date
    select 
    @v_issued_date = issued_date
    from issue
    where issued_book_isbn = @p_issued_book_isbn

    if @v_status = 'yes'

    begin
        insert into issue(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
        values
        (@p_issued_id,@p_member_id,@v_issued_date,@p_issued_book_isbn,@p_issed_emp_id)

    update books
    set status = 'No'
    where isbn = @p_issued_book_isbn

        print 'Book records added successfully for book isbn : ' + @p_issued_book_isbn
    end
    else
    begin
        print 'Sorry to inform the book you requested is not available at moment'

    end 

end

select * from books
where isbn = '978-0-06-112008-4'--yes

select * from books
where isbn = '978-0-375-41398-8'--NO


select * from issue
where issued_book_isbn = '978-0-06-112008-4'--IS131

select * from issue
where issued_book_isbn = '978-0-375-41398-8'--IS134

exec issue_book
    'IS131',
    'C106',
    '978-0-06-112008-4',
    'E101'


---Task 20: Create Table As Select (CTAS)
--Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

---Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
--    The number of overdue books.
--    The total fines, with each day's fine calculated at $0.50.
--    The number of books issued by each member.
--    The resulting table should show:
--    Member ID
--    Number of overdue books
--    Total fines



select 
    m.member_id,
    ist.issued_book_name,
    count(case when r.return_date is not null and getdate() > dateadd(day,30,ist.issued_date) then 1 else 0 end) as number_of_overdue_books,
    sum(CASE WHEN r.return_date IS not NULL AND GETDATE() > DATEADD(day, 30, ist.issued_date) then datediff(day,dateadd(day,30,ist.issued_date),getdate()) * 0.50 else 0 end) as total_fine
    into Fine_for_over_books
from issue as ist
join
books as b
on b.isbn = ist.issued_book_isbn
join 
members as m
on m.member_id = ist.issued_member_id
left join
return_status as r
on r.issued_id = ist.issued_id
where return_date is not null
GROUP BY
    m.member_id,
    ist.issued_book_name

select * from Fine_for_over_books

----End of Project 