
-- Lecture Sep 14: RelationalDB

-- select top 10 UniversityName, CollegeName, DepartmentName
select UniversityName, CollegeName, DepartmentName

from University u 
    inner join College col on u.UniversityId = col.UniversityId
    inner join Department d on col.CollegeId = d.CollegeId
    inner join Program p on d.DepartmentId = p.DepartmentId
    inner join Course c on p.ProgramId = c.ProgramId

-- use "from" to pull data out of a table.

-- inner join (connect) the University table with another table.
-- whenever you do a join, you have to specify what you're joinning on. what
-- column in Colleges are you relating to in the some column in University.

-- I'm joinning (connecting) col (College table) to ("on") the u (University 
-- table) and then what I want to join University and College with 
-- UniversityId. It has to exist in both tables.

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

-- select u.UniversityName, p.ProgramName

-- from University u
--     inner join College c on u.UniversityId = c.UniversityId
--     inner join Program p on u.UniversityId = p.UniversityId


declare @UniversityName varchar(50) = 'Northland University'

select u.UniversityName, c.CollegeName, d.DepartmentName, p.ProgramName

from University u
    inner join College c on u.UniversityId = c.UniversityId
    inner join Department d on c.CollegeId = d.CollegeId and
    -- because we are relating a Department to the College and University,
    -- we have to do both of these joins.
                               u.UniversityId = d.UniversityId
    inner join Program p on d.DepartmentId = p.DepartmentId and
                            c.CollegeId = p.CollegeId and
                            u.UniversityId = p.UniversityId
    -- inner join Course co on p.ProgramId = co.ProgramId and 
    --                         d.DepartmentId = co.DepartmentId and 
    --                         c.CollegeId = co.CollegeId and 
    --                         u.UniversityId = co.DepartmentId
    -- use "where" for filtering out the data that you interested in or not
    -- in "inner join". 
    where u.UniversityName = @UniversityName
    -- where u.UniversityName = 'Northland University' (use this without declare).


-- even though I'm only bring back UniversityName in my query, every College
-- here that has a valid UniversityId associated with it. 

-- INNER JOIN:
-- how do we pull data out of the Program table that is somehow related
-- to all the other tables that we have and so that we get essentially 
-- correct data without any duplication, any weirdness.
-- inner join is only going to give us data when that value existed on both sides.

-- in order to get the data out in same rows as before, we need to include 
-- all of those "inner joins" respectively. the true relationship is that 
-- University is related to College, College is related to Department,
-- Department is related to Program, and Program is related to Course. We
-- have to include all the tables that are in the "inner joins", and then 
-- you also need to make sure that you're joining from every table to every
-- table the way that it's set up. 
 

-- Sanity check: 
-- I just want to know how many records that are in College table.
-- I don't want to do a bunch of unnecessary pulling data back and stuff
-- that it's not necessary (use "count(1)"). So, there is no extra memory
-- or data movement or anything. 
select count(1) from College;

-- How many programs are there?
select count(1) from Program;




-- Lecture Sep 28: RelationalDB
select u.UniversityName, c.CollegeName

from University u
    left join College c on u.UniversityId = c.UniversityId 
    -- use "and" rather than "where" for filtering out the data that you 
    -- interested in or not in "left join".
                        and u.UniversityName = 'Northland University' 


-- Filtiring ON (AND) vs WHERE:
-- 1.In DocumentDB we're using; 
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University' AND/OR/NOT
--       JSON_VALUE(Document, '$.collegeName') = 'College of Engineering'

-- 2.In RelationalDB;
-- A.Inner Join;
-- WHERE UniversityName = 'Northland University' AND/OR/NOT
-- WHERE collegeName = 'College of Education'
-- B.Left/Right Join; we need to do the filtering on the Left/Right Join 
-- itself not using WHERE clause. 
-- LEFT JOIN Departments d
--    ON e.department_id = d.id
--    AND d.department_name = 'Engineering';
--    AND d.program_name = 'Data Science'


