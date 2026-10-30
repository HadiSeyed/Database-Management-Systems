
-- -- Lecture Oct 26, 2026
-- -- example copied from "SQL Server Stored Procedures Cheatsheet".

USE master;
GO

CREATE DATABASE StoredProcDB
GO

-- -- to remove database
-- DROP DATABASE StoredProcDB
-- GO

USE StoredProcDB
GO

-- -- 1. Example table
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
-- -- press f1 to see command pallet (what databases are available).


-- 2. Create a basic procedure
-- Use `CREATE OR ALTER PROCEDURE` to create a procedure the first time and 
-- update it on later runs: (create store procedure is like create a table)-
-- (store procedure is part of database's schema like a table)
CREATE OR ALTER PROCEDURE dbo.usp_GetStudents
AS
BEGIN
    SET NOCOUNT ON; -- do not bring back any counts.

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
-- -- Parameters let the caller provide values. Declare each parameter with a 
-- -- name and a SQL data type:
CREATE OR ALTER PROCEDURE dbo.usp_GetStudentsByMajor
    @Major NVARCHAR(100) -- name and data type (100: characters long) of the parameter.
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
-- -- N: treat this string as a uni code.
EXEC dbo.usp_GetStudentsByMajor N'Mathematics';
-- or
EXEC dbo.usp_GetStudentsByMajor @Major = N'Mathematics';
GO

-- -- 5. Use an optional parameter
-- -- Give a parameter a default value to make it optional. This example 
-- -- returns all students when `@Major` is omitted or set to `NULL`:
CREATE OR ALTER PROCEDURE dbo.usp_SearchStudents
    @Major NVARCHAR(100) = NULL
    -- @Major NVARCHAR(100) = N'Mathematics'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT StudentID, FirstName, LastName, Major
    FROM dbo.Students
    WHERE @Major IS NULL OR Major = @Major -- to evalute to true or false
    ORDER BY LastName, FirstName;
END;
GO


EXEC dbo.usp_SearchStudents; -- All majors
EXEC dbo.usp_SearchStudents @Major = NULL
EXEC dbo.usp_SearchStudents @Major = N'Mathematics';
GO

-- -- 6. Insert and update rows
-- -- An insert procedure can return the new row's identity value as a result set:
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
GO

EXEC dbo.usp_AddStudent
    @FirstName = 'Brandi',
    @LastName = 'Dietrick'
GO
-- -- SELECT CONVERT(INT, SCOPE_IDENTITY()):
-- -- convert whatever this data type (SCOPE_IDENTITY()) is here to an integer
-- -- because an integer is specifically the data type that the "Identity" is.


-- -- Lecture Oct 28, 2026
SELECT * FROM dbo.Students;
GO

-- -- to remove procedure (we created procedure in master database).
-- -- you would have to be in the database that the stored procedure is in 
-- -- that you're trying to delete. if you don't have it, you are in wrong DB.
-- DROP PROCEDURE dbo.usp_UpdateStudentMajor;
-- GO

-- -- Use a key in an update procedure's `WHERE` clause so the intended row 
-- -- is changed: we're doing an update. so, we're changing an existing record
-- -- to something else.
CREATE OR ALTER PROCEDURE dbo.usp_UpdateStudentMajor
    @StudentID INT,
    @Major NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Students
    SET Major = @Major
    WHERE StudentID = @StudentID;
END;
GO

EXEC dbo.usp_UpdateStudentMajor
    @StudentID = 1,
    @Major = N'Mathematics';
GO

-- -- 7. Return an output parameter
-- -- Use an `OUTPUT` parameter when the procedure needs to give back a single 
-- -- value in addition to any result sets:
CREATE OR ALTER PROCEDURE dbo.usp_GetStudentCount
    @StudentCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @StudentCount = COUNT(*)
    FROM dbo.Students;
END;
GO

-- -- Declare a variable to receive it. `OUTPUT` must appear in the call as well:
DECLARE @Count INT;

EXEC dbo.usp_GetStudentCount
    @StudentCount = @Count OUTPUT;

PRINT @Count
SELECT @Count AS StudentCount;
GO

-- -- this is a different way to retrieve a value or pass information out of a Stored Procedure.
-- -- Result sets, output parameters, and `RETURN`.
-- -- For example, capture an integer return status like this:
DECLARE @Status INT;

EXEC @Status = dbo.usp_GetStudents;

PRINT @Status
SELECT @Status AS ReturnStatus;
GO
-- -- right click on 'Stored Procedures' to see different functions of script.

-- -- 8. Change or remove a procedure
-- -- Run the `CREATE OR ALTER PROCEDURE` definition again to update the 
-- -- procedure. To remove it:
DROP PROCEDURE IF EXISTS dbo.usp_GetStudents;
GO

-- -- 9. Advanced topics
-- -- Error handling and transactions
-- -- Use a transaction when a group of changes must succeed or fail together.
-- -- `TRY...CATCH` handles an error, and `THROW` re-raises it so the caller 
-- -- knows the operation failed:

SELECT * FROM Students WHERE StudentID = 1
BEGIN TRANSACTION
UPDATE Students SET Major = 'Nursing' WHERE StudentID = 1
SELECT * FROM Students WHERE StudentID = 1
ROLLBACK TRANSACTION
-- COMMIT TRANSACTION
SELECT * FROM Students WHERE StudentID = 1;
GO

CREATE OR ALTER PROCEDURE dbo.usp_AddStudentWithTransaction
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Major NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Students (FirstName, LastName, Major)
        VALUES (@FirstName, @LastName, @Major);

        DECLARE @StudentID INT
        SET @StudentID = (SELECT CONVERT(INT, SCOPE_IDENTITY()))

        -- RAISERROR('Failed 123', 16, 1) 

        UPDATE Students
        SET FirstName = FirstName + ' is awesome'
        WHERE StudentID = @StudentID

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

EXEC usp_AddStudentWithTransaction
    @FirstName = "Maysun",
    @LastName = "Weeks",
    @Major = "Computer Science"
GO

EXEC usp_AddStudentWithTransaction
    @FirstName = "Erika",
    @LastName = "Macleman",
    @Major = "Software Engineering"
GO
-- -- Parameterized dynamic SQL
-- -- Most queries do not need dynamic SQL. If a query must be built at 
-- -- runtime, pass data values as parameters to `sys.sp_executesql`; do not 
-- -- concatenate user input into the SQL text:
CREATE OR ALTER PROCEDURE dbo.usp_SearchStudentsDynamic
    @Major NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sql NVARCHAR(MAX) =
        N'SELECT StudentID, FirstName, LastName, Major
          FROM dbo.Students
          WHERE Major = @Major;';

    EXEC sys.sp_executesql
        @Sql,
        N'@Major NVARCHAR(100)',
        @Major = @Major;
END;
GO

-- -- Limit who can execute a procedure
-- -- Grant only the permissions users need. Replace `[StudentReader]` with 
-- -- an existing database user or role:
GRANT EXECUTE ON OBJECT::dbo.usp_GetStudents TO [StudentReader];

-- -- 10. Common mistakes to avoid