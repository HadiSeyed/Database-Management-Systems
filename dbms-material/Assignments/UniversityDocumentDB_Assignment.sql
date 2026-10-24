/*
    SQL Server DocumentDB Assignment
    ===============================

    Instructions:
      1. Run UniversityDocumentDB_Setup.sql before beginning.
      2. Write your own SQL for each task below.
      3. Show the SQL and the result set for every task.
      4. For tasks that change the database state, include a before/after check.
      5. Explain the JSON path used in your query.
*/

USE UniversityDocumentDB;
GO

-- Task 1: List the university name, city, and state for every university.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(Document, '$.location.city') AS City,
    JSON_VALUE(Document, '$.location.state') AS State
FROM dbo.UniversityCollection
ORDER BY UniversityName ASC
-- -- DESC: sorts university names in (Z–A) or from the most to the fewest.
-- -- ASC: sorts university names in (A–Z) or from the fewest to the most.
-- -- ORDER BY: by defult it's going to be ascending.

-- -- Can we use the following? No, we need to define alias for Cross Apply.
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_VALUE(value, '$.city') AS City,
--     JSON_VALUE(value, '$.state') AS State
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.location')

-- -- We can use the following.
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_VALUE(d, '$.city') AS City,
--     JSON_VALUE(d, '$.state') AS State
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.location') d

-- Task 2: Find all universities located in California and show only the university name and city.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(Document, '$.location.city') AS City
FROM dbo.UniversityCollection
WHERE JSON_VALUE(Document, '$.location.state') = 'CA'
ORDER BY UniversityName ASC

-- Task 3: Retrieve the first college name for every university.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(Document, '$.colleges[0].collegeName') as CollegeName
FROM dbo.UniversityCollection
ORDER BY UniversityName ASC

-- -- We can use the Cross Apply, but if we delete the first one, it cannot 
-- -- finds that because no first college is there. 
-- SELECT
--     JSON_VALUE(value, '$.collegeName') as CollegeName
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges') 
-- WHERE JSON_VALUE(value, '$.collegeId') = '1'

-- -- Can we use the following? No, because colleges has too many subsets.
-- SELECT
--     JSON_VALUE(Document, '$.colleges.collegeName') AS CollegeName
-- FROM dbo.UniversityCollection
-- WHERE JSON_VALUE(Document, '$.colleges.collegeId') = '1'

-- Task 4: Show university name and collegename for every college name across all universities using a nested array query.(Requires CROSSAPPLY )
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(value, '$.collegeName') AS CollegeName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') 
ORDER BY UniversityName ASC

-- Task 5: Show University Name and count of how many colleges each university has and sort by the count descending.(Requires CROSSAPPLY )
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    COUNT(*) AS CollegeCount
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges')
GROUP BY JSON_VALUE(Document, '$.universityName')
ORDER BY CollegeCount DESC
-- -- COUNT(*): counts the colleges for each university.
-- -- GROUP BY: combines the rows for each university.
-- -- ORDER BY: sorts universities from the most colleges to the fewest.

-- -- The following query shows each college separately because I select 
-- -- CollegeId instead of counting the colleges for each university.
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_VALUE(value, '$.collegeId') AS CollegeId
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges')

-- Task 6: Display the names for all deans for a specific college (Requires CROSSAPPLY).
-- 6.1: a specific college:
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(value, '$.collegeName') AS CollegeName,
    JSON_VALUE(value, '$.deanName') AS DeanName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges')
WHERE JSON_VALUE(value, '$.collegeName') = 'College of Engineering'
ORDER BY UniversityName ASC

-- -- 6.2: a specific college and university
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_VALUE(value, '$.collegeName') AS CollegeName,
--     JSON_VALUE(value, '$.deanName') AS DeanName
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges')
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Bayside University' AND
--       JSON_VALUE(value, '$.collegeName') = 'College of Computer Science'
      
-- Task 7: List department names for a selected university and college. (Requires CROSSAPPLY )
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(c.value, '$.collegeName') AS CollegeName,
    JSON_VALUE(d.value, '$.departmentName') AS DepartmentName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c
CROSS APPLY OpenJson (c.value, '$.departments') AS d
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University' and
      JSON_VALUE(c.value, '$.collegeName') = 'College of Engineering'    
      
-- Task 8: Find the department chair for Willow University's Computer Science Deparment. (Requires CROSSAPPLY )
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(d.value, '$.departmentName') AS DepartmentName,
    JSON_VALUE(d.value, '$.chairName') AS ChairName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c
CROSS APPLY OpenJson (c.value, '$.departments') AS d
WHERE JSON_VALUE(Document, '$.universityName') = 'Willow University' and
      JSON_VALUE(d.value, '$.departmentName') = 'Computer Science'

-- Task 9: Return all program names for Northland University.(Requires CROSSAPPLY )
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(p.value, '$.programName') AS ProgramName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c 
CROSS APPLY OpenJson (c.value, '$.departments') AS d
CROSS APPLY OpenJson (d.value, '$.programs') AS p 
WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University'
ORDER BY ProgramName ASC

-- Task 10: Display all course codes offered in the B.S. of Computer Science program at Northland University.(Requires CROSSAPPLY )
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(p.value, '$.programName') AS ProgramName,
    JSON_VALUE(co.value, '$.courseCode') AS CourseCode,
    JSON_VALUE(co.value, '$.courseName') AS CourseName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c 
CROSS APPLY OpenJson (c.value, '$.departments') AS d
CROSS APPLY OpenJson (d.value, '$.programs') AS p 
CROSS APPLY OpenJson (p.value, '$.courses') AS co 
WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University' and
      JSON_VALUE(p.value, '$.programName') = 'B.S. in Computer Science'

-- Task 11: List all universities that offer a program delivered by hybrid or online methods.(Requires CROSSAPPLY )
-- -- "DISTINCT": removes duplicate university names. Brings back only unique
-- -- values, so I'm going to get a list of all the possible that are there.
SELECT DISTINCT
    JSON_VALUE(Document, '$.universityName') AS UniversityName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c 
CROSS APPLY OpenJson (c.value, '$.departments') AS d
CROSS APPLY OpenJson (d.value, '$.programs') AS p 
WHERE JSON_VALUE(p.value, '$.deliveryMode') = 'Hybrid' OR
      JSON_VALUE(p.value, '$.deliveryMode') = 'Online'
      -- -- selects either delivery method.
      -- JSON_VALUE(p.value, '$.deliveryMode') IN ('Hybrid', 'Online')


-- -- I got 100 rows by showing the "DeliveryMode". 
-- SELECT DISTINCT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_VALUE(p.value, '$.deliveryMode') AS DeliveryMode
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges') AS c 
-- CROSS APPLY OpenJson (c.value, '$.departments') AS d
-- CROSS APPLY OpenJson (d.value, '$.programs') AS p 
-- WHERE JSON_VALUE(p.value, '$.deliveryMode') = 'Hybrid' OR
--       JSON_VALUE(p.value, '$.deliveryMode') = 'Online'


-- -- I got 457 rows because a university can have multiple programs that meet
-- -- the condition, so the same university may appear several times.
-- -- They want each university listed only once. Used "DISTINCT" above.
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_VALUE(p.value, '$.deliveryMode') AS DeliveryMode
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges') AS c 
-- CROSS APPLY OpenJson (c.value, '$.departments') AS d
-- CROSS APPLY OpenJson (d.value, '$.programs') AS p 
-- WHERE JSON_VALUE(p.value, '$.deliveryMode') = 'Hybrid' OR 
--       JSON_VALUE(p.value, '$.deliveryMode') = 'Online'

-- Task 12: Find universities founded before 1950.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(Document, '$.foundedYear') AS FoundedYear
FROM dbo.UniversityCollection
WHERE CAST(JSON_VALUE(Document, '$.foundedYear') AS INT) < 1950
ORDER BY FoundedYear DESC
-- WHERE JSON_VALUE(Document, '$.foundedYear') < 1950

-- Task 13: Find universities with more than 30,000 students.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(Document, '$.studentPopulation') AS StudentPopulation
FROM dbo.UniversityCollection
WHERE CAST(JSON_VALUE(Document, '$.studentPopulation') AS INT) > 30000
ORDER BY StudentPopulation DESC
-- WHERE JSON_VALUE(Document, '$.studentPopulation') > 30000

-- Task 14: Extract the complete college object for Northland University's College of Business.
SELECT JSON_QUERY(Document, '$.colleges[1]') AS CollegeObject
FROM dbo.UniversityCollection
WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University' AND
      JSON_VALUE(Document, '$.colleges[1].collegeName') = 'College of Business'


-- -- Exactly extract the complete college object using "Cross Apply".
-- SELECT value AS CollegeObject
-- FROM dbo.UniversityCollection
-- CROSS APPLY OPENJSON(Document, '$.colleges')
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University' AND
--       JSON_VALUE(value, '$.collegeName') = 'College of Business'


-- -- It returns more information than necessary (entire university document).
-- SELECT * 
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges') as c
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University' and 
--       JSON_VALUE(c.value, '$.collegeName') = 'College of Business'
      

-- -- Wrong way:
-- SELECT
--     JSON_VALUE(Document, '$.colleges') AS CollegeObject
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges')  
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University' and 
--       JSON_VALUE(value, '$.collegeName') = 'College of Business'


-- -- Wrong way:
-- SELECT COUNT(*) AS CollegeObject
-- FROM dbo.UniversityCollection
-- CROSS APPLY OpenJson (Document, '$.colleges')  
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University' and 
--       JSON_VALUE(value, '$.collegeName') = 'College of Business'


-- -- Wrong way:
-- declare @JsonDocument JSON
-- set @JsonDocument = (select Document from dbo.UniversityCollection)
-- select *
-- from OpenJson (@JsonDocument, '$.colleges')
-- where 'universityName' = 'Northland University' and 
--       'collegeName' = 'College of Business'

-- Task 15: Show all programs for a Northland University's Business Administration department.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(d.value, '$.departmentName') AS DepartmentName,
    JSON_VALUE(p.value, '$.programName') AS ProgramName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c
CROSS APPLY OpenJson (c.value, '$.departments') AS d
CROSS APPLY OpenJson (d.value, '$.programs') AS p 
WHERE JSON_VALUE(Document, '$.universityName') = 'Northland University' AND 
      JSON_VALUE(d.value, '$.departmentName') = 'Business Administration'
ORDER BY ProgramName ASC

-- Task 16: Check whether course code NUR23 exists anywhere in the collection. (Requires CROSSAPPLY )
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName
    -- JSON_VALUE(co.value, '$.courseCode') AS CourseCode
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c 
CROSS APPLY OpenJson (c.value, '$.departments') AS d
CROSS APPLY OpenJson (d.value, '$.programs') AS p 
CROSS APPLY OpenJson (p.value, '$.courses') AS co 
WHERE JSON_VALUE(co.value, '$.courseCode') = 'NUR23'
GROUP BY JSON_VALUE(Document, '$.universityName')

-- Task 17: Add a new college to a university document and show the before/after state.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(value, '$.collegeName') AS CollegeName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') 
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'

-- -- Second way(1):
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     '[' + STRING_AGG(
--         '"' + STRING_ESCAPE(JSON_VALUE(value, '$.collegeName'), 'json') + '"',
--         ','
--     ) + ']' AS CollegeNames
-- FROM dbo.UniversityCollection
-- CROSS APPLY OPENJSON(Document, '$.colleges')
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'
-- GROUP BY JSON_VALUE(Document, '$.universityName')

-- -- Second way(2):
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_QUERY(Document, '$.colleges') AS CollegeNames
-- FROM dbo.UniversityCollection
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'

-- -- Second way:
-- SELECT Document
-- FROM dbo.UniversityCollection
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'

-- -- Second way:
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_QUERY(Document, '$.colleges') AS Colleges
-- FROM dbo.UniversityCollection
-- WHERE JSON_VALUE(Document, '$.universityId') = '1001'

UPDATE dbo.UniversityCollection
SET Document = JSON_MODIFY(
    Document,
    'append $.colleges',
    JSON_QUERY('{
        "collegeId": 3,
        "collegeName": "College of Education"
            }')
)
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'

-- -- Can I use "Insert Into" to add sth?
-- INSERT INTO dbo.UniversityCollection (Document) VALUES 
-- ('collegeId:10', 'collegeName:College of Education')

-- Task 18: Update the website URL for one university and show the before/after state.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(Document, '$.website') AS Website
FROM dbo.UniversityCollection
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'


UPDATE dbo.UniversityCollection
SET Document = JSON_MODIFY(
    Document,
    '$.website',
    'https://www.riveruni.edu'
)
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'

-- Task 19: Add a new course to an existing program and show the before/after state.
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(p.value, '$.programName') AS ProgramName,
    JSON_VALUE(co.value, '$.courseCode') AS CourseCode,
    JSON_VALUE(co.value, '$.courseName') AS CourseName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c 
CROSS APPLY OpenJson (c.value, '$.departments') AS d
CROSS APPLY OpenJson (d.value, '$.programs') AS p 
CROSS APPLY OpenJson (p.value, '$.courses') AS co 
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University' AND
      JSON_VALUE(p.value, '$.programId') = '660'

-- -- Second way without Cross Apply:
-- SELECT
--     JSON_VALUE(Document, '$.universityName') AS UniversityName,
--     JSON_VALUE(Document, '$.colleges[0].departments[0].programs[0].programName') AS ProgramName,
--     JSON_QUERY(Document, '$.colleges[0].departments[0].programs[0].courses') AS Courses
-- FROM dbo.UniversityCollection
-- WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University' AND
--       JSON_VALUE(Document, '$.colleges[0].departments[0].programs[0].programId') = '660';

UPDATE dbo.UniversityCollection
SET Document = JSON_MODIFY(
    Document,
    'append $.colleges[0].departments[0].programs[0].courses',
    JSON_QUERY('{
        "courseCode": "COM13",
        "courseName": "Database Management System",
        "credits": 3,
        "courseType": "Thesis"
            }')
)
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University' AND
      JSON_VALUE(Document, '$.colleges[0].departments[0].programs[0].programId') = '660'


-- -- Second way:
-- UPDATE u
-- SET Document = JSON_MODIFY(
--     u.Document,
--     'append $.colleges[' + CAST(c.[key] AS varchar(10)) +
--     '].departments[' + CAST(d.[key] AS varchar(10)) +
--     '].programs[' + CAST(p.[key] AS varchar(10)) + '].courses',
--     JSON_QUERY('{
--         "courseCode": "COM13",
--         "courseName": "Database Management System",
--         "credits": 3,
--         "courseType": "Thesis"
--     }')
-- )
-- FROM dbo.UniversityCollection AS u
-- CROSS APPLY OPENJSON(u.Document, '$.colleges') AS c
-- CROSS APPLY OPENJSON(c.value, '$.departments') AS d
-- CROSS APPLY OPENJSON(d.value, '$.programs') AS p
-- WHERE JSON_VALUE(u.Document, '$.universityName') = 'Riverside University' and
--       JSON_VALUE(p.value, '$.programId') = '660';

-- Task 20: Remove a department or course from a university document and show the before/after state.
-- -- 20.1: Remove a department
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(d.value, '$.departmentId') AS DepartmentId,
    JSON_VALUE(d.value, '$.departmentName') AS DepartmentName
FROM dbo.UniversityCollection
CROSS APPLY OpenJson (Document, '$.colleges') AS c
CROSS APPLY OpenJson (c.value, '$.departments') AS d
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'


-- -- Wrong way:
-- UPDATE u
-- SET Document = JSON_MODIFY(
--     u.Document,
--     'delete $.colleges[' + CAST(c.[key] AS varchar(10)) +
--     '].departments[' + CAST(d.[key] AS varchar(10)) + ']'
-- )
-- FROM dbo.UniversityCollection AS u
-- CROSS APPLY OPENJSON(u.Document, '$.colleges') AS c
-- CROSS APPLY OPENJSON(c.value, '$.departments') AS d
-- WHERE JSON_VALUE(u.Document, '$.universityName') = 'Riverside University' and
--       JSON_VALUE(d.value, '$.departmentName') = 'Psychology'


-- -- Return "Null" rather than removing a row completely.
-- UPDATE u
-- SET Document = JSON_MODIFY(
--     u.Document,
--     CONCAT(
--         '$.colleges[',
--         c.[key],
--         '].departments[',
--         d.[key],
--         ']'
--     ),
--     NULL
-- )
-- FROM dbo.UniversityCollection AS u
-- CROSS APPLY OPENJSON(u.Document, '$.colleges') AS c
-- CROSS APPLY OPENJSON(c.value, '$.departments') AS d
-- WHERE JSON_VALUE(u.Document, '$.universityName') = 'Riverside University' AND
--       JSON_VALUE(d.value, '$.departmentName') = 'Psychology'


-- -- Update function, first way by myself:
UPDATE u
SET Document = JSON_MODIFY(
    u.Document,
    CONCAT('$.colleges[', c.[key], '].departments'),
    JSON_QUERY(
        '[' + COALESCE(
            (
                SELECT STRING_AGG(d2.value, ',')
                FROM OPENJSON(c.value, '$.departments') AS d2
                WHERE JSON_VALUE(d2.value, '$.departmentName') <> 'Psychology'
            ),
            ''
        ) + ']'
    )
)
FROM dbo.UniversityCollection AS u
CROSS APPLY OPENJSON(u.Document, '$.colleges') AS c
WHERE JSON_VALUE(u.Document, '$.universityName') = 'Riverside University'
  AND EXISTS (
      SELECT 1
      FROM OPENJSON(c.value, '$.departments') AS d
      WHERE JSON_VALUE(d.value, '$.departmentName') = 'Psychology'
  );


-- -- Update function, second way by professor:
UPDATE dbo.UniversityCollection
SET Document = JSON_MODIFY(Document, '$.colleges[1].departments',
    (
    SELECT *
    FROM OPENJSON(Document,'$.colleges[1].departments')
    WITH (
        departmentId INT '$.departmentId',
        departmentName NVARCHAR(MAX) '$.departmentName',
        chairName NVARCHAR(MAX) '$.chairName',
        programs NVARCHAR(MAX) '$.programs' AS JSON
    )
    WHERE departmentName <> 'Psychology'
    FOR JSON PATH

    )
)
WHERE JSON_VALUE(Document, '$.universityId') = 1001;
GO


-- -- 20.2: Remove a course
SELECT
    JSON_VALUE(Document, '$.universityName') AS UniversityName,
    JSON_VALUE(co.value, '$.courseCode') AS CourseCode,
    JSON_VALUE(co.value, '$.courseName') AS CourseName
FROM dbo.UniversityCollection AS u
CROSS APPLY OPENJSON(Document, '$.colleges') AS c
CROSS APPLY OPENJSON(c.value, '$.departments') AS d
CROSS APPLY OPENJSON(d.value, '$.programs') AS p
CROSS APPLY OpenJson (p.value, '$.courses') AS co 
WHERE JSON_VALUE(Document, '$.universityName') = 'Riverside University'


-- -- Return "Null" rather than removing a row completely.
-- UPDATE u
-- SET Document = JSON_MODIFY(
--     u.Document,
--     CONCAT(
--         '$.colleges[',
--         c.[key],
--         '].departments[',
--         d.[key],
--         '].programs[',
--         p.[key],
--         '].courses[',
--         co.[key],
--         ']'
--     ),
--     NULL
-- )
-- FROM dbo.UniversityCollection AS u
-- CROSS APPLY OPENJSON(u.Document, '$.colleges') AS c
-- CROSS APPLY OPENJSON(c.value, '$.departments') AS d
-- CROSS APPLY OPENJSON(d.value, '$.programs') AS p
-- CROSS APPLY OPENJSON(p.value, '$.courses') AS co
-- WHERE JSON_VALUE(u.Document, '$.universityName') = 'Riverside University' and
--       JSON_VALUE(co.value, '$.courseCode') = 'COM11'


-- -- Update function, first way by myself:
UPDATE u
SET Document = JSON_MODIFY(
    u.Document,
    CONCAT('$.colleges[', c.[key], '].departments[', d.[key],
           '].programs[', p.[key], '].courses'),
    JSON_QUERY(
        '[' + COALESCE(
            (   SELECT STRING_AGG(co.value, ',')
                FROM OPENJSON(p.value, '$.courses') AS co
                WHERE JSON_VALUE(co.value, '$.courseName') <> 'Introduction to Programming'
            ),
            ''
        ) + ']'
    ))
FROM dbo.UniversityCollection AS u
CROSS APPLY OPENJSON(u.Document, '$.colleges') AS c
CROSS APPLY OPENJSON(c.value, '$.departments') AS d
CROSS APPLY OPENJSON(d.value, '$.programs') AS p
WHERE JSON_VALUE(u.Document, '$.universityName') = 'Riverside University'
  AND EXISTS (
      SELECT 1
      FROM OPENJSON(p.value, '$.courses') AS co
      WHERE JSON_VALUE(co.value, '$.courseName') = 'Introduction to Programming');


-- -- Update function, second way by professor:
UPDATE dbo.UniversityCollection
SET Document = JSON_MODIFY(
    Document,
    '$.colleges[0].departments[0].programs[0].courses',
    --JSON_QUERY
    ((
        SELECT *
        FROM OPENJSON(
            Document,
            '$.colleges[0].departments[0].programs[0].courses'
        )
        WITH (
            courseCode NVARCHAR(50) '$.courseCode',
            courseName NVARCHAR(MAX) '$.courseName',
            credits INT '$.credits',
            courseType NVARCHAR(50) '$.courseType'
        )
        WHERE courseName <> 'Introduction to Programming'
        FOR JSON PATH
    ))
)
WHERE JSON_VALUE(Document, '$.universityId') = 1001;
GO
