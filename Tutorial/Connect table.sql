
-- Lecture Sep 14: RelationalDB
select UniversityName, CollegeName, DepartmentName
-- select top 10 UniversityName, CollegeName, DepartmentName

-- use "from" to pull data out of a table.
from University u 
    inner join College col on u.UniversityId = col.UniversityId
    inner join Department d on col.CollegeId = d.CollegeId
    inner join Program p on d.DepartmentId = p.DepartmentId
    inner join Course c on p.ProgramId = c.ProgramId

-- inner join (connect) the University table with another table.
-- whenever you do a join, you have to specify what you're joinning on. what
-- column in Colleges are you relating to in the some column in University.

-- I'm joinning col (College table) to ("on") the u (University table) and then 
-- what I want to join University and College with (UniversityId). It has to 
-- exist in both tables.

-- If you have the same data in two different tables, that column should be
-- that same name. So, if you have a UniversityId in the University table,
-- and then you have UniversityId in a column in another (College) table. that
-- column should also be called UniversityId. It should be the same name
-- everywhere it is in the database. 

-- what do we have right now? we're saying I want to pull data out of University
-- table and the College table. But based on this relationship, I'm saying 
-- inner join between these two tables on where this equals. So, anywhere that
-- a College has the same UniversityId as one universities, they're going to
-- show up on the same line. So, if a University has five colleges, all five
-- of those colleges will have the appropriate UniversityId and then so they'll
-- have five records. That UniversityName that associated with UniversityId
-- and the five college names that would belong to that university.
-- because we're doing an "inner join" there should not be like a cartisal
-- product where we got a 100 rows in University and then we got a 100 rows
-- in College. If we didn't have an "inner join" that says only when they're 
-- equals, then we would get back something like 10,000 records. we should 
-- only got back 100 records because there is only a total of 100 colleges. So 
-- that's why it's important that we have the "inner join" to get only the 
-- data that we want no duplicated, no cartisianal products or whatever where 
-- it's like a every possible combination of every record and every row.   




-- Lecture Sep 23: RelationalDB
select UniversityName, CollegeName, DepartmentName

from University u
    inner join College col on u.UniversityId = col.UniversityId
    inner join Department d on col.CollegeId = d.CollegeId
    inner join Program p on d.DepartmentId = p.DepartmentId
    inner join Course c on p.ProgramId = c.ProgramId 