
-- -- Lecture Nov 2, 2026


-- -- Lecture Nov 4, 2026
-- -- example copied from "Advanced SQL Server Stored Procedures Cheatsheet (advanced-sp-cheatseet.md)"

-- -- 1. Procedure contracts and input validation
USE UniversityAdvancedSPBestPractice;
Go

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

SELECT * FROM Students WHERE StudentID = 1;
EXEC dbo.usp_UpdateStudentMajor @studentID = 1, @Major = 'Physics', @ChangedBy = 'Admin'
EXEC dbo.usp_UpdateStudentMajor
GO

EXEC dbo.usp_UpdateStudentMajor @StudentID = 1; 
EXEC dbo.usp_UpdateStudentMajor @StudentID = 1;
EXEC dbo.usp_UpdateStudentMajor @StudentID = 1;
EXEC dbo.usp_UpdateStudentMajor @StudentID = 99;
GO

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

        UPDATE dbo.Students
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

SELECT * FROM StudentsOfAdvisors 


GO

EXEC dbo.usp_TransferAdvisor @FromAdvisorID = 
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
        VALUES (@Semester, @CourseID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        SET @ResultCode = ERROR_NUMBER();
        SET @ResultMessage = ERROR_MESSAGE();
        THROW;
    END CATCH;
END;
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
        INNER JOIN dbo.StudentsInDepartments AS sid s.StudentID = sid.StudentID
        INNER JOIN dbo.Departments AS d on sid.DepartmentID = d.DepartmentID
    WHERE d.DepartmentID = @DepartmentID
    ORDER BY s.LastName, s.FirstName;
END;
GO

GRANT EXECUTE ON OBJECT::dbo.usp_GetDepartmentRoster TO [AppReaderRole];



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
