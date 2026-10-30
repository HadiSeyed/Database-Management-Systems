
-- -- Lecture Oct 14, 2026
SELECT u.UniversityName, c.CollegeName 
FROM
    dbo.Universities u
    INNER JOIN CollegeInUniversities cin on cin.UniversityId = u.UniversityId
    INNER JOIN Colleges c on cin.CollegeId = c.CollegeId
WHERE u.UniversityId = 42
-- -- What colleges belong to university 42.


SELECT u.UniversityName as University, d.DepartmentId, d.DepartmentName, p.ProgramName, co.CourseName 
FROM
    dbo.Universities u
    INNER JOIN CollegeInUniversities cin on cin.UniversityId = u.UniversityId
    INNER JOIN Colleges c on cin.CollegeId = c.CollegeId
    INNER JOIN DepartmentInColleges dic on dic.CollegeId = c.CollegeId
    INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
    INNER JOIN ProgramInDepartments pid on pid.DepartmentId = d.DepartmentId
    INNER JOIN Programs p on pid.ProgramId = p.ProgramId
    INNER JOIN CourseInPrograms cip on cip.ProgramId = p.ProgramId
    INNER JOIN Courses co on cip.CourseId = co.CourseId 
WHERE u.UniversityName = 'University 042' AND
      d.DepartmentName = 'Department 042-01-03' AND
      p.programName = 'Program 042-01-03-02'
ORDER BY University
-- -- We cannot use the alias (e.name as EmployeeName) in "Where" and "Having"
-- -- because it happens before "Select". We're going to filter before there 
-- -- is a "Select". It's not possible, but we can use the alias in "Order" 
-- -- because it happens after "Select".

-- WHERE u.UniversityId = 42 AND
--       d.DepartmentId = 2


-- -- Tip: 
-- -- Based on "sql-statement-anatomy.md" file, we have to use SQL statements
-- -- in order not out of order because it won't parse, it's wrong SQL.
-- -- This is the order you write and read: SELECT, FROM, JOIN...ON, WHERE, 
-- -- GROUP BY, HAVING, ORDER BY, TOP/OFSET-FETCH.
-- -- SQL Server conceptually processes a SELECT statement in this order:
-- -- FROM, ON, JOIN, WHERE, GROUP BY, HAVING, SELECT, ORDER BY.
-- -- This is how we describe how the data that we want.

-- -- check order of three boolean operators not/and/or in "sql-statement-anatomy.md" file.



-- -- Lecture Oct 19, 2026, don't run it.
SELECT d.DepartmentName, d.ChairName
FROM Departments d  

select u.UniversityName, count(c.CollegeId) as college_count
From Universities U 
    inner join CollegeInUniversities ciu on ciu.UniversityId = u.UniversityId
    inner join Colleges c on ciu.CollegeId = c.CollegeId 
-- -- we cannot use "count" inside the "where".
-- where count(c.CollegeId) > 4
Group By u.UniversityName
Having count(c.CollegeId) > 4
-- -- we cannot use alias in "having" like "Where" because it happens before "select"
-- Having college_count

CREATE TABLE BadExampleTable (
    "my id" int, 
    "tom & jerry" varchar(50)
)

CREATE TABLE BadExampleTable2 (
    "my id" int, 
    "tom & jerry" varchar(50),
    "select" varchar(50)
)

insert into BadExampleTable ([my id]) values (123)

select [my id] as my_id, ('brian' + ' ' + 'dietrick') as full_name
from BadExampleTable
where [my id]  = 123

select [select] 
from BadExampleTable2


-- -- Lecture Oct 21, 2026

-- -- use a database inside another one: (no switch database):
-- For instance, we are in "master" database. In the following example, it uses 
-- "UniversityRelationalDbBestPractice" database inside the "master" database.
-- SELECT
--       [CourseCode]
--       ,[CourseName]
--   FROM [UniversityRelationalDbBestPractice].[dbo].[Courses]

-- dbo: this is the schema that the Courses table belongs to. 
-- we are in the default schema. if we want to create this table in a 
-- different schema that we're trying to isolate it, protect it, whatever, 
-- then absolutely we'd have to specify it. but otherwise this is optional.

-- -- Change the database (location): (switch databases):
-- 1. change database totally: 
-- use the button at the top left or at the bottom right to switch it.
-- 2. change only in that script, run the following:
-- use YourDatabaseName;
-- Go
