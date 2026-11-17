/*
    SQL Server Relational DB Best Practice Assignment
    ===============================

    Instructions:
      1. Run Assignments/UniversityRelationalDbBestPractice_Setup.sql before beginning.
      2. Assignments/UniversityRelationalDbBestPractice_ERD.md is provided for your convenience.
      2. Write your own SQL for each task below.
      3. Show the SQL and the result set for every task.
      4. For tasks that change the database state, include a before/after check.
      5. When working with sql that mutates the database, always reset your database to its initial state before running the assignment.

*/

USE UniversityRelationalDbBestPractice;
GO

-- Task 1: List the university name, city, and state for every university sorted by University Name, City.
SELECT u.UniversityName AS UniversityName, u.City, u.State
FROM Universities u 
ORDER BY UniversityName, u.City

-- -- Hadi
-- SELECT u.UniversityName, u.City, u.State
-- FROM Universities u 
-- ORDER BY u.UniversityName, u.City

-- Task 2: Find all universities located in California and list the university names and cities. 
SELECT u.UniversityName, u.City 
FROM Universities u  
WHERE u.State = 'CA'
ORDER BY u.UniversityName

-- -- we don't have 'CA' state in the tables.
-- UPDATE Universities
-- SET City = 'Los Angeles',
--     State = 'CA'
-- WHERE State = 'WA';

-- -- this give me the list of all the states that we have in the database.
-- SELECT DISTINCT u.State
-- FROM Universities u

-- Task 3: Retrieve one college name for every university.
SELECT u.UniversityName, c.CollegeName
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
-- WHERE c.CollegeName = 'College 001-01'
WHERE c.CollegeId = (SELECT Top 1 c2.CollegeId
                    FROM Colleges c2
                    INNER JOIN CollegeInUniversities ciu2
                      ON c2.CollegeId = ciu2.CollegeId
                    WHERE ciu2.UniversityId = u.UniversityId
                    ORDER BY c2.CollegeId DESC);

-- -- Hadi
-- SELECT u.UniversityName, c.CollegeName
-- FROM Universities u
--   INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
--   INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
-- -- WHERE c.CollegeName = 'College 001-01'
-- WHERE c.CollegeId = (SELECT Min(c2.CollegeId) -- bring back the smallest CollegeId for the SELECT statement.
--                     FROM Colleges c2
--                     INNER JOIN CollegeInUniversities ciu2
--                       ON c2.CollegeId = ciu2.CollegeId
--                     WHERE ciu2.UniversityId = u.UniversityId)
-- ORDER BY u.UniversityName
-- -- do we need to show UniversityName as well?

-- Task 4: Show university name and collegename for every college name across all universities -- using a nested array query.
SELECT u.UniversityName, c.CollegeName
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
ORDER BY u.UniversityName

-- Task 5: Show University Name and Count of how many colleges each university has and sort by the count descending.
SELECT u.UniversityName, count(2) as collegecount -- we can put any no. in "Count()"
-- count(c.CollegeName) as collegecount
FROM Universities u
    INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
    INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
GROUP BY u.UniversityName
ORDER BY collegecount DESC
-- -- "Count()" is an aggregate and we can't use an aggregate function unless
-- -- it's been defined in a "Group by" for the most part. 

-- Task 6: Display the names for all deans for all colleges in north carolina. 
SELECT u.UniversityName, c.CollegeName, c.DeanName, u.State
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
WHERE u.State = 'NC'
ORDER BY c.DeanName

-- Task 7: List department names for all colleges in Texas where the university student population is greater than 40,000 . 
SELECT u.UniversityName, c.CollegeName, d.DepartmentName, u.State, u.StudentPopulation
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
WHERE u.State = 'TX' AND
      u.StudentPopulation > 40000
ORDER BY u.UniversityName

-- Task 8: Find the department chair for Willow University's Computer Science Deparment. 
SELECT u.UniversityName, c.CollegeName, d.DepartmentName, d.ChairName
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
WHERE u.UniversityName = 'Willow University' AND
      d.DepartmentName = 'Computer Science'

-- UPDATE Departments
-- SET ChairName = 'Dr. Qin Ding',
--     DepartmentName = 'Computer Science'
-- WHERE DepartmentId = (SELECT d.DepartmentId
--                       FROM Universities u
--                       INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
--                       INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
--                       INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
--                       INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
--                       WHERE u.UniversityName = 'Willow University' AND
--                             d.DepartmentName = 'Department 002-01-02');

-- Task 9: Return all program names for Northland University.
SELECT u.UniversityName, c.CollegeName, d.DepartmentName, p.ProgramName
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN Programs p on pid.ProgramId = p.ProgramId
WHERE u.UniversityName = 'Northland University'

-- SELECT TOP 1 * FROM Programs

-- Task 10: Display all course codes offered in the B.S. of Computer Science program at Northland University.
SELECT u.UniversityName, c.CollegeName, d.DepartmentId, p.ProgramName, co.CourseName, co.CourseCode
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN Programs p on pid.ProgramId = p.ProgramId
  INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
  INNER JOIN Courses co on cip.CourseId = co.CourseId
WHERE u.UniversityName = 'Northland University' AND
      p.ProgramName = 'BS of Computer Science'

-- Task 11: List all universities that offer a program delivered by hybrid or online methods.
SELECT u.UniversityName, p.ProgramName, p.DeliveryMode
FROM Universities u
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN Programs p on pid.ProgramId = p.ProgramId
-- WHERE p.DeliveryMode = 'Hybrid' OR
--       p.DeliveryMode = 'Online'
WHERE p.DeliveryMode in ('Online','Hybrid')

-- -- check where is the data
-- SELECT top 1 * FROM Courses;
-- -- check what is the data
-- SELECT DISTINCT DeliveryMode FROM Programs;

-- Task 12: Find universities founded before 1950.
SELECT u.UniversityName, u.FoundedYear
FROM Universities u
WHERE u.FoundedYear < 1950
ORDER BY u.FoundedYear ASC

-- Task 13: Find universities with more than 30,000 students.
SELECT u.UniversityName, u.StudentPopulation
FROM Universities u
WHERE u.StudentPopulation > 30000
ORDER BY u.StudentPopulation ASC

-- Task 14: Extract the complete college object for Northland University's College of Business.
-- SELECT u.*, co.*
-- SELECT * 
-- SELECT c.CollegeName, c.CollegeId, c.CollegeCode, c.DeanName
SELECT c.CollegeName, co.*
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN Programs p on pid.ProgramId = p.ProgramId
  INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
  INNER JOIN Courses co on cip.CourseId = co.CourseId
WHERE u.UniversityName = 'Northland University' AND
      c.CollegeName = 'College of Business'

-- Task 15: Show all programs for a Northland University's Business Administration department.
SELECT u.UniversityName, c.CollegeName, d.DepartmentName, p.ProgramName
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN Programs p on pid.ProgramId = p.ProgramId
WHERE u.UniversityName = 'Northland University' AND
      d.DepartmentName = 'Business Administration'

-- UPDATE Departments
-- SET DepartmentName = 'Business Administration'
-- where DepartmentName = 'Department 005-02-01'

-- Task 16: Check whether course code NUR23 exists anywhere in the Courses table. 
-- Professor
SELECT * FROM Courses WHERE CourseCode = 'NUR23'

-- -- Hadi
-- SELECT u.UniversityName, co.CourseCode
-- FROM Universities u
--   INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
--   INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
--   INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
--   INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
--   INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
--   INNER JOIN Programs p on pid.ProgramId = p.ProgramId
--   INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
--   INNER JOIN Courses co on cip.CourseId = co.CourseId
-- WHERE co.CourseCode = 'NUR23'



-- Task 17: Add a new college to a university document and show the before/after state.
-- Professsor
SELECT * FROM Colleges WHERE CollegeName = 'My New College';
INSERT INTO Colleges(CollegeCode, CollegeName, DeanName)
VALUES('mnc','My New College','Charlie Brown');
SELECT * FROM Colleges WHERE CollegeName = 'My New College';

-- why we didn't insert into "CollegeInUniversities" like que 19, and didn't
-- use the scoped identifier?

-- -- Hadi
-- SELECT u.UniversityName, u.UniversityId, c.CollegeName, c.CollegeId, c.CollegeCode, c.DeanName
-- FROM Universities u
--   INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
--   INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
-- WHERE u.UniversityName = 'Northland University'

-- -- SET IDENTITY_INSERT colleges ON
-- INSERT INTO dbo.CollegeInUniversities (CollegeId, UniversityId)
-- VALUES (18, 5)

-- SET IDENTITY_INSERT colleges ON (SET IDENTITY_INSERT colleges OFF)
-- INSERT INTO dbo.Colleges (CollegeId, CollegeCode, CollegeName, DeanName) 
-- VALUES (18, 'COL-005-04', 'College of Art', 'Dean 005-04')

-- Task 18: Update the website URL for one university and show the before/after state.
SELECT u.UniversityName, u.Website
FROM Universities u
WHERE u.UniversityName = 'Northland University'

UPDATE dbo.Universities
SET Website = 'https://www.northalanduniversity.edu'
WHERE UniversityName = 'Northland University'

SELECT u.UniversityName, u.Website
FROM Universities u
WHERE u.UniversityName = 'Northland University'

-- Task 19: Add a new course to an existing program and show the before/after state.
-- professor
SELECT u.UniversityName, c.CollegeName, d.DepartmentId, p.ProgramName, co.CourseName, co.CourseCode
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN programs p on pid.ProgramId = p.ProgramId
  INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
  INNER JOIN Courses co on cip.CourseId = co.CourseId
WHERE u.UniversityName = 'Northland University' AND
      p.ProgramName = 'BS of Computer Science'

DECLARE @program_id INT
SET @program_id = (select top 1 p.ProgramId
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN programs p on pid.ProgramId = p.ProgramId
  INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
  INNER JOIN Courses co on cip.CourseId = co.CourseId
WHERE u.UniversityName = 'Northland University' AND
      p.ProgramName = 'BS of Computer Science'
)

-- when we do insert, we need to be able to retrieve it. so, we use the 
-- "scoped identifier" technique.
INSERT INTO dbo.Courses (CourseCode, CourseName, CourseType, Credits)
VALUES ('MyCourseCode','MyCourseName','Core',3)

DECLARE @course_id INT
SET @course_id = (select CONVERT(INT, SCOPE_IDENTITY()))

INSERT INTO dbo.CourseInPrograms (CourseId, ProgramId)
VALUES (@course_id, @program_id)

SELECT u.UniversityName, c.CollegeName, d.DepartmentId, p.ProgramName, co.CourseName, co.CourseCode
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN programs p on pid.ProgramId = p.ProgramId
  INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
  INNER JOIN Courses co on cip.CourseId = co.CourseId
WHERE u.UniversityName = 'Northland University' AND
      p.ProgramName = 'BS of Computer Science'

-- -- Hadi
-- SELECT u.UniversityName, p.ProgramName, co.CourseName, p.ProgramId, co.CourseId, co.CourseCode, co.Credits, co.CourseType
-- FROM Universities u 
--   INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
--   INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
--   INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
--   INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
--   INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
--   INNER JOIN programs p on pid.ProgramId = p.ProgramId
--   INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
--   INNER JOIN Courses co on cip.CourseId = co.CourseId
-- WHERE u.UniversityName = 'Northland University' AND
--       p.ProgramName = 'BS of Computer Science'

-- -- SET IDENTITY_INSERT Courses ON
-- INSERT INTO dbo.CourseInPrograms (CourseId, ProgramId)
-- VALUES (484, 121)

-- SET IDENTITY_INSERT Courses ON
-- INSERT INTO dbo.Courses (CourseId, CourseCode, CourseName, Credits, CourseType)
-- VALUES (484, 'CRS-005-01-01-01-06', 'Course 005-01-01-01-06', 5, 'Thesis')

-- Task 20: Remove a department or course from a university document and show the before/after state.
-- professor
SELECT u.UniversityName, c.CollegeName, d.DepartmentId, p.ProgramName, co.CourseName, co.CourseCode
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN programs p on pid.ProgramId = p.ProgramId
  INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
  INNER JOIN Courses co on cip.CourseId = co.CourseId
WHERE u.UniversityName = 'Northland University' AND
      d.DepartmentId = 50

-- Remove a department
-- delete all the dependencies in reverse order. we can't delete "programs" first
-- because "programs" has "courses" underneath of them that are dependent on it.
-- so, start at the thing that has no dependencies and then start working your
-- way back and remove it at all.
DELETE FROM Courses WHERE CourseId IN (
SELECT co.CourseId
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN programs p on pid.ProgramId = p.ProgramId
  INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
  INNER JOIN Courses co on cip.CourseId = co.CourseId
WHERE u.UniversityName = 'Northland University' AND
      d.DepartmentId = 50
)

DELETE FROM Programs WHERE ProgramId IN (
SELECT p.ProgramId
FROM Universities u 
  INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
  INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
  INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
  INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
  INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
  INNER JOIN programs p on pid.ProgramId = p.ProgramId
WHERE u.UniversityName = 'Northland University' AND
      d.DepartmentId = 50  
)

DELETE FROM Departments WHERE DepartmentId = 50

-- Remove a course? like me?


-- -- -- Hadi
-- -- -- 20.1: Remove a department
-- SELECT u.UniversityName, d.DepartmentName, d.DepartmentId
-- FROM Universities u 
--   INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
--   INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
--   INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
--   INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
-- WHERE u.UniversityName = 'Northland University'
      
-- DELETE FROM dbo.Departments
-- WHERE DepartmentId = 49
-- -- -- sanity check:
-- -- select * from DepartmentInColleges where DepartmentId = 49

-- -- -- To keep the document but remove the department link (setting it to NULL):
-- -- UPDATE dbo.Departments
-- -- SET DepartmentId = Null
-- -- WHERE DepartmentId = 49

-- -- -- 20.2: Remove a course
-- SELECT u.UniversityName, co.CourseName, co.CourseId
-- FROM Universities u 
--   INNER JOIN CollegeInUniversities ciu on u.UniversityId = ciu.UniversityId
--   INNER JOIN Colleges c on ciu.CollegeId = c.CollegeId
--   INNER JOIN DepartmentInColleges dic on c.CollegeId = dic.CollegeId
--   INNER JOIN Departments d on dic.DepartmentId = d.DepartmentId
--   INNER JOIN ProgramInDepartments pid on d.DepartmentId = pid.DepartmentId
--   INNER JOIN programs p on pid.ProgramId = p.ProgramId
--   INNER JOIN CourseInPrograms cip on p.ProgramId = cip.ProgramId
--   INNER JOIN Courses co on cip.CourseId = co.CourseId
-- WHERE u.UniversityName = 'Northland University'
      
-- DELETE FROM dbo.Courses
-- WHERE CourseId = 487

-- -- -- To keep the document but remove the course link (setting it to NULL):
-- -- UPDATE dbo.Courses
-- -- SET CourseId = Null
-- -- WHERE CourseId = 487


