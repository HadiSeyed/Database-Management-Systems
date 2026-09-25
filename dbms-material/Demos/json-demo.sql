
-- Lecture Sep 21

-- -- Change the database (location):
-- 1. change database totally: 
-- use the button at the top right or in the bottom right to switch it.
-- 2. change only in that script:
-- use YourDatabaseName;
-- Go

use UniversityDocumentDB;
Go


select * from dbo.UniversityCollection where Id = 1

-- confirm the concept of what the open JSON does and what the cross apply does.
-- create a variable.
declare @JsonDocument JSON
-- set that variable to a value.
-- Tip: we can't assign "select *" to JsonDocument. we neet to put "select Document".
set @JsonDocument = (select Document from dbo.UniversityCollection where Id = 1)

-- what does OpenJson function do? it what they're calling shredding the Json,
-- but it only does one level.
-- Openjson brings back a key, a value and a type and entire thing broken apart.
select *
from OpenJson (@JsonDocument, '$.colleges')

-- pulling data back/out from university.
select c.value
from dbo.UniversityCollection u
-- I want a list of all colleges for all universities. In order to do that, we
-- can use the cross apply on the OpenJson.
CROSS APPLY OpenJson (u.Document, '$.colleges') as c

-- convert the list of college JSON objects. harvest out the college name on 
-- each instead of the JSON college objects. it's actual data not Json.
select JSON_VALUE(c.value, '$.collegeName') 
from dbo.UniversityCollection u
CROSS APPLY OpenJson (u.Document, '$.colleges') as c

-- how to drill down into nested arrays that we have in our Json documents. 
-- I need that every one of fields that I'm going to return, 
-- put a comma between them.
select 
    JSON_VALUE(u.Document, '$.universityName') as UniversityName,
    JSON_VALUE(c.value, '$.collegeName') as CollegeName,
    JSON_VALUE(d.value, '$.departmentName') as DepartmentName,
    JSON_VALUE(p.value, '$.programName') as ProgramName
from dbo.UniversityCollection u
-- from the university the whole document, we pulled out the colleges.
CROSS APPLY OpenJson (u.Document, '$.colleges') as c
-- c.value to get to the college object. on this college object, ($ refers to the
-- root of the college), give us the path is going to be the department's property. 
CROSS APPLY OpenJson (c.value, '$.departments') as d
-- from each department object, shred the program's property which is a list of 
-- programs on each department object.
CROSS APPLY OpenJson (d.value, '$.programs') as p
-- pick something randomly out. I want to only see the programs at the 
-- Riverside university. this will return the actual university name of the
-- specific document.
where JSON_VALUE(u.Document, '$.universityName') = 'Riverside University'
