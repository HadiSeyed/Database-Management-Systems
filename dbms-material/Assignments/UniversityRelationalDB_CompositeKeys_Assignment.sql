/*
    SQL Server Relational DB with Composite Keys Assignment
    ===============================

    Instructions:
      1. Run Assignments/UniversityRelationalDbCompositeKeys_Setup.sql before beginning.
      2. Assignments/UniversityRelationalDbCompositeKeys_ERD.md is provided for your convenience.
      2. Write your own SQL for each task below.
      3. Show the SQL and the result set for every task.
      4. For tasks that change the database state, include a before/after check.
      5. When working with sql that mutates the database, always reset your database to its initial state before running the assignment.

       
*/



USE UniversityRelationalDbCompositeKeys;
GO

-- Task 1: List all course codes across all universities.  Include university name and course name in the result.  Sort by university name and course name. 
-- SELECT u.UniversityName, co.CourseName, co.CourseCode, co.CourseType
SELECT u.UniversityName AS UniversityName, co.CourseName AS CourseName, co.CourseCode AS CourseCode, co.CourseType AS CourseType
FROM University u
  INNER JOIN College c on u.UniversityId = c.UniversityId
  INNER JOIN Department d on c.CollegeId = d.CollegeId AND
                             d.UniversityId = u.UniversityId
  INNER JOIN Program p on d.DepartmentId = p.DepartmentId AND
                          p.CollegeId = c.CollegeId AND
                          p.UniversityId = u.UniversityId
  INNER JOIN Course co on p.ProgramId = co.ProgramId AND
                          co.DepartmentId = d.DepartmentId AND
                          co.CollegeId = c.CollegeId AND
                          co.UniversityId = u.UniversityId
ORDER BY UniversityName, CourseName

-- -- sanity check         
SELECT * FROM Course WHERE CourseCode = 'EDU24' ORDER BY CourseName

-- Task 2: Add a new college to a university and show the before/after state.
-- Professor
DECLARE @UniversityId INT
SET @UniversityId = (SELECT TOP 1 UniversityId FROM University WHERE UniversityName = 'Riverside University')

DECLARE @NewCollegeId INT
SET @NewCollegeId = (
  SELECT (MAX(c.CollegeId) + 1)
  FROM University u
  INNER JOIN College c on u.UniversityId = c.UniversityId
  WHERE u.UniversityName = 'Riverside University'
)

SELECT * FROM College WHERE UniversityId = @UniversityId AND CollegeId = @NewCollegeId

INSERT INTO College (UniversityId, CollegeId, CollegeName, DeanName)
VALUES (@UniversityId, @NewCollegeId, 'MyNewCollegeName', 'Phil Lewis')

SELECT * FROM College WHERE UniversityId = @UniversityId AND CollegeId = @NewCollegeId

-- -- Hadi
-- SELECT u.UniversityName, u.UniversityId, c.CollegeName, c.CollegeId, c.DeanName
-- FROM University u
-- INNER JOIN College c on u.UniversityId = c.UniversityId
-- WHERE u.UniversityName = 'Riverside University'

-- INSERT INTO dbo.College (UniversityId, CollegeId, CollegeName, DeanName) 
-- VALUES (1001, 3, 'College of Education', 'Dr. Jack Morgan')

-- Task 3: Update the website URL for one university and show the before/after state.
-- Professor:
SELECT u.UniversityId, c.CollegeId, c.CollegeName, d.DepartmentId, d.DepartmentName, p.ProgramId, p.ProgramName
FROM University u
  INNER JOIN College c on u.UniversityId = c.UniversityId
  INNER JOIN Department d on c.CollegeId = d.CollegeId AND
                             d.UniversityId = u.UniversityId
  INNER JOIN Program p on d.DepartmentId = p.DepartmentId AND
                          p.CollegeId = c.CollegeId AND
                          p.UniversityId = u.UniversityId
WHERE UniversityName = 'Riverside University'

-- or ********************

SELECT * FROM University WHERE UniversityName = 'Riverside University'
GO

DECLARE @UniversityId INT
SET @UniversityId = (SELECT TOP 1 UniversityId FROM University WHERE UniversityName = 'Riverside University')

UPDATE University
SET Website = 'https://www.riversideuniversity2.edu'
WHERE UniversityId = @UniversityId

SELECT * FROM University WHERE UniversityName = 'Riverside University'

-- -- Hadi
-- SELECT u.UniversityName, u.Website
-- FROM University u
-- WHERE u.UniversityName = 'Riverside University'

-- UPDATE dbo.University
-- SET Website = 'https://www.river-uni.edu'
-- WHERE UniversityName = 'Riverside University'

-- Task 4: Add a new course to an existing program and show the before/after state.
-- Professor
declare @UniversityId int
set @UniversityId = (select top 1 UniversityId from University where UniversityName = 'Riverside University')

declare @CollegeId INT
set @CollegeId = (select top 1 CollegeId 
                  from University u
                    inner join College c on c.UniversityId = u.UniversityId 
                  where UniversityName = 'Riverside University' 
                    and CollegeName = 'College of Engineering')

declare @DepartmentId INT
set @DepartmentId = (select top 1 DepartmentId 
                  from University u
                    inner join College c on c.UniversityId = u.UniversityId 
                      inner join Department d on d.CollegeId = c.CollegeId 
                                  and d.UniversityId = u.UniversityId
                  where UniversityName = 'Riverside University' 
                    and CollegeName = 'College of Engineering'
                    and DepartmentName = 'Computer Science')

declare @ProgramId INT
set @ProgramId = (select top 1 ProgramId 
                  from University u
                    inner join College c on c.UniversityId = u.UniversityId 
                    inner join Department d on d.CollegeId = c.CollegeId 
                              and d.UniversityId = u.UniversityId
                    inner join Program p on p.DepartmentId = d.DepartmentId 
                              and p.CollegeId = c.CollegeId
                              and p.UniversityId = u.UniversityId
                  where UniversityName = 'Riverside University' 
                    and CollegeName = 'College of Engineering'
                    and DepartmentName = 'Computer Science'
                    and ProgramName = 'M.S. in Finance')

declare @CourseCode Varchar(20) = 'CSCI6565'

select Co.* 
from university u
  inner join college c on u.UniversityId = c.UniversityId
  inner join Department d on d.CollegeId = c.CollegeId 
            and d.UniversityId = u.UniversityId
  inner join Program p on p.DepartmentId = d.DepartmentId 
            and p.CollegeId = c.CollegeId
            and p.UniversityId = u.UniversityId
  inner join Course co on co.ProgramId = p.ProgramId
            and co.DepartmentId = d.DepartmentId
            and co.CollegeId = c.CollegeId
            and co.UniversityId = u.UniversityId
  where UniversityName = 'Riverside University' 
    and CollegeName = 'College of Engineering'
    and DepartmentName = 'Computer Science'
    and ProgramName = 'M.S. in Finance'

insert into Course (UniversityId, CollegeId, DepartmentId, ProgramId, CourseCode, CourseName, Credits, CourseType)
values(@UniversityId, @CollegeId,@DepartmentId, @ProgramId,@CourseCode,'Database Management Systems', 3, 'Elective')

select Co.* 
from university u
  inner join college c on u.UniversityId = c.UniversityId
  inner join Department d on d.CollegeId = c.CollegeId 
            and d.UniversityId = u.UniversityId
  inner join Program p on p.DepartmentId = d.DepartmentId 
            and p.CollegeId = c.CollegeId
            and p.UniversityId = u.UniversityId
  inner join Course co on co.ProgramId = p.ProgramId
            and co.DepartmentId = d.DepartmentId
            and co.CollegeId = c.CollegeId
            and co.UniversityId = u.UniversityId
  where UniversityName = 'Riverside University' 
    and CollegeName = 'College of Engineering'
    and DepartmentName = 'Computer Science'
    and ProgramName = 'M.S. in Finance'

-- -- Hadi
-- SELECT u.UniversityName, p.ProgramName, co.CourseName, co.CourseCode, c.CollegeId, d.DepartmentId, p.ProgramId, co.CourseType
-- FROM university u
--   INNER JOIN College c on u.UniversityId = c.UniversityId
--   INNER JOIN Department d on c.CollegeId = d.CollegeId
--   INNER JOIN Program p on d.DepartmentId = p.DepartmentId
--   INNER JOIN Course co on p.ProgramId = co.ProgramId
-- WHERE u.UniversityName = 'Riverside University' AND
--       co.CourseCode = 'COM11'

-- INSERT INTO dbo.Course (
--   UniversityId,
--   CollegeId,
--   DepartmentId,
--   ProgramId,
--   CourseCode, 
--   CourseName, 
--   Credits, 
--   CourseType)
-- VALUES (1001, 1, 110, 660, 'SQL20', 'DBMS', 6, 'Elective')

-- Task 5: Remove a department or course from a university and show the before/after state.
-- Professor
declare @UniversityId int
set @UniversityId = (select top 1 UniversityId from University where UniversityName = 'Riverside University')

declare @CollegeId INT
set @CollegeId = (select top 1 CollegeId 
                  from University u
                    inner join College c on c.UniversityId = u.UniversityId 
                  where UniversityName = 'Riverside University' 
                    and CollegeName = 'College of Engineering')

declare @DepartmentId INT
set @DepartmentId = (select top 1 DepartmentId 
                  from University u
                    inner join College c on c.UniversityId = u.UniversityId 
                      inner join Department d on d.CollegeId = c.CollegeId 
                                  and d.UniversityId = u.UniversityId
                  where UniversityName = 'Riverside University' 
                    and CollegeName = 'College of Engineering'
                    and DepartmentName = 'Computer Science')

declare @ProgramId INT
set @ProgramId = (select top 1 ProgramId 
                  from University u
                    inner join College c on c.UniversityId = u.UniversityId 
                    inner join Department d on d.CollegeId = c.CollegeId 
                              and d.UniversityId = u.UniversityId
                    inner join Program p on p.DepartmentId = d.DepartmentId 
                              and p.CollegeId = c.CollegeId
                              and p.UniversityId = u.UniversityId
                  where UniversityName = 'Riverside University' 
                    and CollegeName = 'College of Engineering'
                    and DepartmentName = 'Computer Science'
                    and ProgramName = 'M.S. in Finance')

declare @CourseCode Varchar(20) = 'CSCI6565'

select Co.* 
from university u
  inner join college c on u.UniversityId = c.UniversityId
  inner join Department d on d.CollegeId = c.CollegeId 
            and d.UniversityId = u.UniversityId
  inner join Program p on p.DepartmentId = d.DepartmentId 
            and p.CollegeId = c.CollegeId
            and p.UniversityId = u.UniversityId
  inner join Course co on co.ProgramId = p.ProgramId
            and co.DepartmentId = d.DepartmentId
            and co.CollegeId = c.CollegeId
            and co.UniversityId = u.UniversityId
  where UniversityName = 'Riverside University' 
    and CollegeName = 'College of Engineering'
    and DepartmentName = 'Computer Science'
    and ProgramName = 'M.S. in Finance'

delete from Course
where UniversityId = @UniversityId
  and CollegeId = @CollegeId
  and DepartmentId = @DepartmentId
  and ProgramId = @ProgramId
  and CourseCode = 'CSCI6565'

select Co.* 
from university u
  inner join college c on u.UniversityId = c.UniversityId
  inner join Department d on d.CollegeId = c.CollegeId 
            and d.UniversityId = u.UniversityId
  inner join Program p on p.DepartmentId = d.DepartmentId 
            and p.CollegeId = c.CollegeId
            and p.UniversityId = u.UniversityId
  inner join Course co on co.ProgramId = p.ProgramId
            and co.DepartmentId = d.DepartmentId
            and co.CollegeId = c.CollegeId
            and co.UniversityId = u.UniversityId
  where UniversityName = 'Riverside University' 
    and CollegeName = 'College of Engineering'
    and DepartmentName = 'Computer Science'
    and ProgramName = 'M.S. in Finance'

-- -- -- Hadi
-- -- -- 5.1: Remove a department
-- SELECT u.UniversityName, d.DepartmentName, d.DepartmentId
-- FROM University u 
--   INNER JOIN College c on u.UniversityId = c.UniversityId
--   INNER JOIN Department d on c.CollegeId = d.CollegeId
-- WHERE u.UniversityName = 'Riverside University'
      
-- DELETE FROM dbo.Department
-- WHERE DepartmentId = 110

-- -- -- To keep the document but remove the department link (setting it to NULL):
-- -- UPDATE dbo.Department
-- -- SET DepartmentId = Null
-- -- WHERE DepartmentId = 110

-- -- -- 5.2: Remove a course
-- SELECT u.UniversityName, co.CourseName, co.CourseCode
-- FROM University u 
--   INNER JOIN College c on u.UniversityId = c.UniversityId
--   INNER JOIN Department d on c.CollegeId = d.CollegeId
--   INNER JOIN Program p on d.DepartmentId = p.DepartmentId
--   INNER JOIN Course co on p.ProgramId = co.ProgramId
-- WHERE u.UniversityName = 'Riverside University'
      
-- DELETE FROM dbo.Course
-- WHERE CourseCode = 'BIO11'

-- -- -- To keep the document but remove the course link (setting it to NULL):
-- -- UPDATE dbo.Course
-- -- SET CourseId = Null
-- -- WHERE CourseCode = 'BIO11'
