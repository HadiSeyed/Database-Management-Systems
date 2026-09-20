
declare @result int;

select @result = (5 + 3);

print @result


declare @name varchar(50) = 'Brian Dietrick';

set @name = 'Brian Dietrick';


select * 
from University;
GO

-- Write "from" command first to see all columns in your table when you write a query in "select" command 
select u.UniversityName
from University u;
GO

select u.UniversityName, u.City
from University u;
GO

select UniversityName , City, State
from University u

select UniversityName as University, (City + ', ' + [State]) as CityState
from University u

select 5 + 5

select 'a' + 'b'

select name from  sys.all_columns

select count(*)
from University

select count(UniversityId)
from University

select count(1)
from University





