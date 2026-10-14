

SELECT u.UniversityName, c.CollegeName 
FROM
    dbo.Universities u
    INNER JOIN CollegeInUniversities cin on cin.UniversityId = u.UniversityId
    INNER JOIN Colleges c on cin.CollegeId = c.CollegeId
WHERE u.UniversityId = 42


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
-- -- We cannot use the alias in "Where" because it happens before "Select",
-- -- but we can use it in "Order" because it happens after "Select".

-- WHERE u.UniversityId = 42 AND
--       d.DepartmentId = 2