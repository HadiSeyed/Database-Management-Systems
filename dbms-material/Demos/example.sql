

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
-- -- We cannot use the alias (e.name as EmployeeName) in "Where" because it 
-- -- happens before "Select". We're going to filter before there is a "Select".
-- -- It's not possible, but we can use the alias in "Order" because it 
-- -- happens after "Select".

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

-- -- check order of boolean operators not/and/or in "sql-statement-anatomy.md" file.