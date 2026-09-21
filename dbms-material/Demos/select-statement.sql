
-- Lecture Sep 16

-- There are three ways that give your valuable a value 
-- by declare @name, select @result, and set @name.

-- Create a variable in SQL using a declare. It's the keyword.
-- The variables have to be prefixed with an at symbol (@).
declare @result int;
-- Select data from another table and then based off the data
-- in the other table, you end up with assigning the value based Off
-- of data that's in other tables.
select @result = (5 + 3); 
-- Showing it's truly did evaluate this, assign it to the variable
print @result


declare @name varchar(50) = 'Brian Dietrick';

set @name = 'Brian Dietrick';


select * 
from University;
GO

-- Write "from" command first to see all columns in your table 
-- when you write a query in "select" command. 
-- Dot gives you a list of available columns.
select u.UniversityName
from University u;
GO

select u.UniversityName, u.City
from University u;
GO

select UniversityName, City, State
from University u

select UniversityName, (City + ', ' + [State])
from University u

-- Makes it easier to read, use parenthesis and do rename by "as" command.
select UniversityName as University, (City + ', ' + [State]) as CityState
from University u

select 5 + 5

select 'a' + 'b'

-- This is not a table. It is a defined view that is made up of tables or 
-- made up of columns from lots of different tables. It's all the columns 
-- of all tables.
select * from  sys.all_columns

select name from  sys.all_columns
select name, column_id from  sys.all_columns

select count(*)
from University

select count(UniversityId)
from University

select count(1)
from University





