
-- Lecture Sep 14
select UniversityName, CollegeName, DepartmentName

from University u
    inner join College col on u.UniversityId = col.UniversityId
    inner join Department d on col.CollegeId = d.CollegeId
    inner join Program p on d.DepartmentId = p.DepartmentId
    inner join Course c on p.ProgramId = c.ProgramId

-- Lecture Sep 23