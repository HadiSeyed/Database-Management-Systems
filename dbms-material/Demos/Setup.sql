-- Lecture Sep 30

-- Copied from "1_join-types-cheatsheet.md" file.

-- # Setup for examples

-- ## 1) Same schema as the examples


USE master;
GO

IF DB_ID('JoinTypeExamples') IS NOT NULL
BEGIN
    ALTER DATABASE JoinTypeExamples SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE JoinTypeExamples;
END
GO

CREATE DATABASE JoinTypeExamples;
GO

USE JoinTypeExamples;
GO

CREATE TABLE dbo.Departments (
    id int NOT NULL PRIMARY KEY,
    department_name varchar(50) NOT NULL
);

CREATE TABLE dbo.Employees (
    id int NOT NULL PRIMARY KEY,
    name varchar(100) NOT NULL,
    department_id int NULL,
    manager_id int NULL,
    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (department_id) REFERENCES dbo.Departments(id)
);

CREATE TABLE dbo.Projects (
    id int NOT NULL PRIMARY KEY,
    project_name varchar(100) NOT NULL,
    department_id int NULL,
    CONSTRAINT FK_Projects_Departments
        FOREIGN KEY (department_id) REFERENCES dbo.Departments(id)
);

INSERT INTO dbo.Departments (id, department_name) VALUES
(1, 'Engineering'),
(2, 'Sales'),
(3, 'Human Resources'),
(4, 'Finance'),
(5, 'Marketing'),
(6, 'Operations'),
(7, 'Customer Support'),
(8, 'IT Infrastructure'),
(9, 'Research & Development'),
(10, 'Administration');

;WITH nums AS (
    SELECT TOP (50) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Employees (id, name, department_id, manager_id)
SELECT
    n.id,
    CONCAT('Employee ', RIGHT('00' + CAST(n.id AS varchar(2)), 2)),
    ((n.id - 1) % 10) + 1,
    CASE
        WHEN (n.id - 1) % 5 = 0 THEN NULL
        ELSE (((n.id - 1) / 5) * 5) + 1
    END AS manager_id
FROM nums n
ORDER BY n.id;

INSERT INTO dbo.Projects (id, project_name, department_id) VALUES
(1, 'Apollo Portal', 1),
(2, 'Northwind CRM', 2),
(3, 'Operations Dashboard', 6);
GO

SELECT *
FROM Employees e 

SELECT *
FROM Departments d

update Employees
set department_id = null
where id in (7,14, 21, 28, 34);

SELECT e.name, d.department_name
FROM Employees e  
INNER JOIN Departments d  
    ON e.department_id = d.id;

SELECT e.name, d.department_name
FROM Employees e  
LEFT JOIN Departments d  
    ON e.department_id = d.id;

SELECT e.name, d.department_name
-- SELECT e.id, d.department_name
-- SELECT e.name, d.department_name
FROM Employees e  
RIGHT JOIN Departments d  
    ON e.department_id = d.id -- and e.name is null 
WHERE e.name is null 
-- WHERE e.id is null 
-- WHERE e.id is null 

SELECT d.department_name as DepartmentName
FROM Departments d
ORDER BY DepartmentName

INSERT INTO dbo.Departments (id, department_name) VALUES
(11, 'Entertainment')

-- This version matches the join examples: employees belong to a department, 
-- and the project table adds a third dataset for multi-table examples.


-- ## 2) Many-to-many relationship setup

USE master;
GO

IF DB_ID('JoinTypeExamples_ManyToMany') IS NOT NULL
BEGIN
    ALTER DATABASE JoinTypeExamples_ManyToMany SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE JoinTypeExamples_ManyToMany;
END
GO

CREATE DATABASE JoinTypeExamples_ManyToMany;
GO

USE JoinTypeExamples_ManyToMany;
GO

CREATE TABLE dbo.Departments (
    id int NOT NULL PRIMARY KEY,
    department_name varchar(50) NOT NULL
);

CREATE TABLE dbo.Employees (
    id int NOT NULL PRIMARY KEY,
    name varchar(100) NOT NULL,
    manager_id int NULL,
    CONSTRAINT FK_Employees_Manager
        FOREIGN KEY (manager_id) REFERENCES dbo.Employees(id)
);

CREATE TABLE dbo.Projects (
    id int NOT NULL PRIMARY KEY,
    project_name varchar(100) NOT NULL,
    department_id int NULL,
    CONSTRAINT FK_Projects_Departments
        FOREIGN KEY (department_id) REFERENCES dbo.Departments(id)
);

CREATE TABLE dbo.EmployeeDepartment (
    employee_id int NOT NULL,
    department_id int NOT NULL,
    is_primary bit NOT NULL DEFAULT (0),
    PRIMARY KEY (employee_id, department_id),
    CONSTRAINT FK_EmployeeDepartment_Employees
        FOREIGN KEY (employee_id) REFERENCES dbo.Employees(id),
    CONSTRAINT FK_EmployeeDepartment_Departments
        FOREIGN KEY (department_id) REFERENCES dbo.Departments(id)
);

CREATE TABLE dbo.EmployeeProject (
    employee_id int NOT NULL,
    project_id int NOT NULL,
    role_name varchar(50) NOT NULL,
    PRIMARY KEY (employee_id, project_id),
    CONSTRAINT FK_EmployeeProject_Employees
        FOREIGN KEY (employee_id) REFERENCES dbo.Employees(id),
    CONSTRAINT FK_EmployeeProject_Projects
        FOREIGN KEY (project_id) REFERENCES dbo.Projects(id)
);

INSERT INTO dbo.Departments (id, department_name) VALUES
(1, 'Engineering'),
(2, 'Sales'),
(3, 'Human Resources'),
(4, 'Finance'),
(5, 'Marketing'),
(6, 'Operations'),
(7, 'Customer Support'),
(8, 'IT Infrastructure'),
(9, 'Research & Development'),
(10, 'Administration');

;WITH nums AS (
    SELECT TOP (50) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Employees (id, name, manager_id)
SELECT
    n.id,
    CONCAT('Employee ', RIGHT('00' + CAST(n.id AS varchar(2)), 2)),
    CASE
        WHEN (n.id - 1) % 5 = 0 THEN NULL
        ELSE (((n.id - 1) / 5) * 5) + 1
    END AS manager_id
FROM nums n
ORDER BY n.id;

INSERT INTO dbo.Projects (id, project_name, department_id) VALUES
(1, 'Apollo Portal', 1),
(2, 'Northwind CRM', 2),
(3, 'Operations Dashboard', 6);

;WITH employee_dept AS (
    SELECT
        e.id AS employee_id,
        ((e.id - 1) % 10) + 1 AS primary_department,
        CASE
            WHEN ((e.id - 1) % 10) + 1 = 10 THEN 1
            ELSE (((e.id - 1) % 10) + 2)
        END AS secondary_department
    FROM dbo.Employees e
)
INSERT INTO dbo.EmployeeDepartment (employee_id, department_id, is_primary)
SELECT employee_id, primary_department, 1
FROM employee_dept
UNION ALL
SELECT employee_id, secondary_department, 0
FROM employee_dept
WHERE secondary_department <> primary_department;

;WITH employee_project_seed AS (
    SELECT
        e.id AS employee_id,
        CASE
            WHEN e.id % 3 = 1 THEN 1
            WHEN e.id % 3 = 2 THEN 2
            ELSE 3
        END AS project_id,
        CASE
            WHEN e.id % 5 = 0 THEN 'Reviewer'
            ELSE 'Contributor'
        END AS role_name
    FROM dbo.Employees e
)
INSERT INTO dbo.EmployeeProject (employee_id, project_id, role_name)
SELECT employee_id, project_id, role_name
FROM employee_project_seed
UNION ALL
SELECT employee_id,
       CASE project_id
           WHEN 1 THEN 2
           WHEN 2 THEN 3
           ELSE 1
       END,
       'Reviewer'
FROM employee_project_seed
WHERE employee_id % 5 = 0;
GO


-- This version uses bridge tables for both employee-to-department and 
-- employee-to-project relationships, which makes it a clear example of 
-- many-to-many joins in SQL.