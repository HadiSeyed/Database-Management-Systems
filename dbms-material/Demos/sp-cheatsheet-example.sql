
-- -- Lecture Oct 26, 2026
-- -- example copied from "SQL Server Stored Procedures Cheatsheet".

-- -- 1. Example table
CREATE DATABASE StoredProcDB
GO

USE StoredProcDB
GO

CREATE TABLE dbo.Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Major NVARCHAR(100) NULL
);
GO

INSERT INTO dbo.Students (FirstName, LastName, Major)
VALUES
    (N'Ada', N'Lovelace', N'Computer Science'),
    (N'Grace', N'Hopper', N'Computer Science'),
    (N'Katherine', N'Johnson', N'Mathematics');
GO
-- -- press f1 to see databases.


-- 2. Create a basic procedure
CREATE OR ALTER PROCEDURE dbo.usp_GetStudents
AS
BEGIN
    SET NOCOUNT ON;

    SELECT StudentID, FirstName, LastName, Major
    FROM dbo.Students
    ORDER BY LastName, FirstName;
END;
GO


-- -- 3. Run a procedure
-- EXECUTE 
EXEC usp_GetStudents
Go

-- -- 4. Add input parameters
CREATE OR ALTER PROCEDURE dbo.usp_GetStudentsByMajor
    @Major NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Major: ' + @Major
    SELECT StudentID, FirstName, LastName, Major
    FROM dbo.Students
    WHERE Major = @Major
    ORDER BY LastName, FirstName;
END;
GO


EXEC dbo.usp_GetStudentsByMajor 'Computer Science';
-- or
EXEC dbo.usp_GetStudentsByMajor @Major = N'Computer Science';

EXEC dbo.usp_GetStudentsByMajor N'Mathematics';
-- or
EXEC dbo.usp_GetStudentsByMajor @Major = N'Mathematics';
GO

-- -- 5. Use an optional parameter
CREATE OR ALTER PROCEDURE dbo.usp_SearchStudents
    @Major NVARCHAR(100) = NULL
    -- @Major NVARCHAR(100) = N'Mathematics'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT StudentID, FirstName, LastName, Major
    FROM dbo.Students
    WHERE @Major IS NULL OR Major = @Major
    ORDER BY LastName, FirstName;
END;
GO


EXEC dbo.usp_SearchStudents; -- All majors
EXEC dbo.usp_SearchStudents @Major = NULL
EXEC dbo.usp_SearchStudents @Major = N'Mathematics';
GO

-- -- 6. Insert and update rows
CREATE OR ALTER PROCEDURE dbo.usp_AddStudent
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Major NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Students (FirstName, LastName, Major)
    VALUES (@FirstName, @LastName, @Major);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS StudentID;
END;
GO

-- SELECT SCOPE_IDENTITY()
EXEC dbo.usp_AddStudent
    @FirstName = N'Barbara',
    @LastName = N'Liskov',
    @Major = N'Computer Science';