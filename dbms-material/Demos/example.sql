

SELECT u.UniversityName, c.CollegeName 
FROM
    dbo.Universities u
    INNER JOIN CollegeInUniversities cin on cin.UniversityId = u.UniversityId
    INNER JOIN Colleges c on cin.CollegeId = c.CollegeId
WHERE u.UniversityId = 42


SELECT u.UniversityName, c.CollegeName 
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
WHERE u.UniversityId = 42