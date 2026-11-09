
-- -- Lecture Nov 4, 2026
-- -- example copied from "Advanced SQL Server Stored Procedures Cheatsheet (advanced-sp-cheatseet.md)"

USE UniversityAdvancedSPBestPractice;
Go

-- -- 1. Procedure contracts and input validation
CREATE OR ALTER PROCEDURE dbo.usp_UpdateStudentMajor
    @StudentID INT,
    @Major NVARCHAR(100),
    @ChangedBy SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    IF @StudentID IS NULL OR @StudentID <= 0
        THROW 50001, 'StudentID must be a positive integer.', 1;

    IF @Major IS NULL OR LEN(LTRIM(RTRIM(@Major))) = 0
        THROW 50002, 'Major is required.', 1;

    IF @ChangedBy IS NULL OR LEN(LTRIM(RTRIM(@ChangedBy))) = 0
        THROW 50003, 'ChangedBy is required.', 1;

    UPDATE dbo.Students
    SET Major = @Major
    WHERE StudentID = @StudentID;

    IF @@ROWCOUNT = 0
        THROW 50004, 'Student not found.', 1;
END;
GO

Select * from Students where StudentID = 1;
EXEC dbo.usp_UpdateStudentMajor @StudentID = 1, @Major = 'Physics', @ChangedBy = 'Admin';
Select * from Students where StudentID = 1;

EXEC dbo.usp_UpdateStudentMajor @StudentID = null, @Major = 'Physics', @ChangedBy = 'Admin';
EXEC dbo.usp_UpdateStudentMajor @StudentID = 0, @Major = 'Physics', @ChangedBy = 'Admin';
EXEC dbo.usp_UpdateStudentMajor @StudentID = 1, @Major = '  ', @ChangedBy = 'Admin';
EXEC dbo.usp_UpdateStudentMajor @StudentID = 1, @Major = null, @ChangedBy = 'Admin';
EXEC dbo.usp_UpdateStudentMajor @StudentID = 1, @Major = 'Physics', @ChangedBy = null;
EXEC dbo.usp_UpdateStudentMajor @StudentID = 99, @Major = 'Physics', @ChangedBy = 'Admin';
GO
-- -- white space '  ' means that it's either a true a space on a keyboard space
-- -- or it could be a tab or carriage return line feed. All of that stuff is 
-- -- considered whites space. and so a trim either a right or left trim will 
-- -- remove all that from what's there.

-- -- 2. Transaction ownership patterns
CREATE OR ALTER PROCEDURE dbo.usp_TransferAdvisor
    @FromAdvisorID INT,
    @ToAdvisorID INT,
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE StudentsOfAdvisors
        SET AdvisorID = @ToAdvisorID
        WHERE StudentID = @StudentID
          AND AdvisorID = @FromAdvisorID;

        IF @@ROWCOUNT = 0
            THROW 50101, 'Transfer preconditions failed.', 1;

        INSERT INTO dbo.StudentAudit (StudentID, ActionType, ChangedAtUtc)
        VALUES (@StudentID, N'AdvisorTransfer', SYSUTCDATETIME());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

select * from StudentsOfAdvisors where StudentID = 1;
EXEC dbo.usp_TransferAdvisor @FromAdvisorID = 1, @ToAdvisorID = 2, @StudentID = 1;
select * from StudentsOfAdvisors where StudentID = 1;


EXEC dbo.usp_TransferAdvisor @FromAdvisorID = 999, @ToAdvisorID = 2, @StudentID = 1;
GO

-- -- 3. Error handling contracts
CREATE OR ALTER PROCEDURE dbo.usp_EnrollStudent
    @Semester NVARCHAR(50),
    @StudentID INT,
    @CourseID INT,
    @ResultCode INT OUTPUT,
    @ResultMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @ResultCode = 0;
    SET @ResultMessage = N'OK';

    BEGIN TRY
        IF @StudentID IS NULL OR @CourseID IS NULL
            THROW 50201, 'StudentID and CourseID are required.', 1;

        INSERT INTO dbo.Enrollments (Semester, StudentID, CourseID, EnrolledAtUtc)
        VALUES (@Semester, @StudentID, @CourseID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        SET @ResultCode = ERROR_NUMBER();
        SET @ResultMessage = ERROR_MESSAGE();
        THROW;
    END CATCH;
END;
GO

DECLARE @ResultCode INT;
DECLARE @ResultMessage NVARCHAR(4000);

EXEC dbo.usp_EnrollStudent @Semester = 'Fall 2024', @StudentID = 1, @CourseID = 1, @ResultCode = @ResultCode OUTPUT, @ResultMessage = @ResultMessage OUTPUT;
SELECT @ResultCode AS ResultCode, @ResultMessage AS ResultMessage;

EXEC dbo.usp_EnrollStudent @Semester = null, @StudentID = 1, @CourseID = 1, @ResultCode = @ResultCode OUTPUT, @ResultMessage = @ResultMessage OUTPUT;
SELECT @ResultCode AS ResultCode, @ResultMessage AS ResultMessage;
GO

-- -- 4. Security context and permission boundaries
CREATE OR ALTER PROCEDURE dbo.usp_GetDepartmentRoster
    @DepartmentID INT
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.StudentID, s.FirstName, s.LastName
    FROM dbo.Students AS s
        INNER JOIN dbo.StudentsInDepartments AS sid ON s.StudentID = sid.StudentID
        INNER JOIN dbo.Departments AS d ON sid.DepartmentID = d.DepartmentID
    -- WHERE sid.DepartmentID = @DepartmentID
    WHERE d.DepartmentID = @DepartmentID
    ORDER BY s.LastName, s.FirstName;
END;
GO

GRANT EXECUTE ON OBJECT::dbo.usp_GetDepartmentRoster TO [AppReaderRole];


EXEC dbo.usp_GetDepartmentRoster @DepartmentID = 1;
EXEC dbo.usp_GetDepartmentRoster @DepartmentID = 2;
GO

-- -- 5. Performance stability patterns
CREATE OR ALTER PROCEDURE dbo.usp_SearchStudents
    @Major NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Major IS NULL
    BEGIN
        SELECT StudentID, FirstName, LastName, Major
        FROM dbo.Students
        ORDER BY LastName, FirstName;
        RETURN;
    END;

    SELECT StudentID, FirstName, LastName, Major
    FROM dbo.Students
    WHERE Major = @Major
    ORDER BY LastName, FirstName
    OPTION (RECOMPILE);
END;
GO
