CREATE DATABASE University_HR_ManagementSystem_5;
GO

USE University_HR_ManagementSystem_5;
GO

CREATE PROCEDURE createAllTables
AS
BEGIN
    CREATE TABLE Department (
        name VARCHAR(50) PRIMARY KEY,
        building_location VARCHAR(50)
    );

    CREATE TABLE Employee (
        employee_ID INT PRIMARY KEY IDENTITY(1,1),
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(50),
        password VARCHAR(50),
        address VARCHAR(50),
        gender CHAR(1),
        official_day_off VARCHAR(50),
        years_of_experience INT,
        national_ID CHAR(16),
        employment_status VARCHAR(50) CHECK (employment_status IN ('active', 'onleave', 'notice_period', 'resigned')),
        type_of_contract VARCHAR(50) CHECK (type_of_contract IN ('full_time', 'part_time')),
        emergency_contact_name VARCHAR(50),
        emergency_contact_phone CHAR(11),
        annual_balance INT,
        accidental_balance INT,
        salary DECIMAL(10,2),
        hire_date DATE,
        last_working_date DATE,
        dept_name VARCHAR(50),
        FOREIGN KEY (dept_name) REFERENCES Department(name)
    );

    CREATE TABLE Employee_Phone (
        emp_ID INT,
        phone_num CHAR(11),
        PRIMARY KEY (emp_ID, phone_num),
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Role (
        role_name VARCHAR(50) PRIMARY KEY,
        title VARCHAR(50),
        description VARCHAR(50),
        rank INT,
        base_salary DECIMAL(10,2),
        percentage_YOE DECIMAL(4,2),
        percentage_overtime DECIMAL(4,2),
        annual_balance INT,
        accidental_balance INT
    );

    CREATE TABLE Employee_Role (
        emp_ID INT,
        role_name VARCHAR(50),
        PRIMARY KEY (emp_ID, role_name),
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (role_name) REFERENCES Role(role_name)
    );

    CREATE TABLE Role_existsIn_Department (
        department_name VARCHAR(50),
        role_name VARCHAR(50),
        PRIMARY KEY (department_name, role_name),
        FOREIGN KEY (department_name) REFERENCES Department(name),
        FOREIGN KEY (role_name) REFERENCES Role(role_name)
    );

    CREATE TABLE Leave (
        request_ID INT PRIMARY KEY IDENTITY(1,1),
        date_of_request DATE,
        start_date DATE,
        end_date DATE,
        num_days AS (DATEDIFF(DAY, start_date, end_date)),
        final_approval_status VARCHAR(50)
            DEFAULT 'pending'
            CHECK (final_approval_status IN ('approved', 'rejected', 'pending'))
    );

    CREATE TABLE Annual_Leave (
        request_ID INT PRIMARY KEY,
        emp_ID INT,
        replacement_emp INT,
        FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (replacement_emp) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Accidental_Leave (
        request_ID INT PRIMARY KEY,
        emp_ID INT,
        FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Medical_Leave (
        request_ID INT PRIMARY KEY,
        insurance_status BIT,
        disability_details VARCHAR(50),
        type VARCHAR(50) CHECK (type IN ('sick', 'maternity')),
        emp_ID INT,
        FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Unpaid_Leave (
        request_ID INT PRIMARY KEY,
        emp_ID INT,
        FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Compensation_Leave (
        request_ID INT PRIMARY KEY,
        reason VARCHAR(50),
        date_of_original_workday DATE,
        emp_ID INT,
        replacement_emp INT,
        FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (replacement_emp) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Document (
        document_ID INT PRIMARY KEY IDENTITY(1,1),
        type VARCHAR(50),
        description VARCHAR(50),
        file_name VARCHAR(50),
        creation_date DATE,
        expiry_date DATE,
        status VARCHAR(50) CHECK (status IN ('valid', 'expired')),
        emp_ID INT,
        medical_ID INT,
        unpaid_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (medical_ID) REFERENCES Medical_Leave(request_ID),
        FOREIGN KEY (unpaid_ID) REFERENCES Unpaid_Leave(request_ID)
    );

    CREATE TABLE Payroll (
        ID INT PRIMARY KEY IDENTITY(1,1),
        payment_date DATE,
        final_salary_amount DECIMAL(10,1),
        from_date DATE,
        to_date DATE,
        comments VARCHAR(150),
        bonus_amount DECIMAL(10,2),
        deductions_amount DECIMAL(10,2),
        emp_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Attendance (
        attendance_ID INT PRIMARY KEY IDENTITY(1,1),
        date DATE,
        check_in_time TIME,
        check_out_time TIME,
        total_duration AS DATEDIFF(MINUTE, check_in_time, check_out_time),
        status VARCHAR(50)
            DEFAULT 'Absent'
            CHECK (status IN ('Absent', 'Attended')),
        emp_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Deduction (
        deduction_ID INT PRIMARY KEY IDENTITY(1,1),
        emp_ID INT,
        date DATE,
        amount DECIMAL(10,2),
        type VARCHAR(50) CHECK (type IN ('unpaid', 'missing_hours', 'missing_days')),
        status VARCHAR(50)
            DEFAULT 'pending'
            CHECK (status IN ('pending', 'finalized')),
        unpaid_ID INT,
        attendance_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (unpaid_ID) REFERENCES Unpaid_Leave(request_ID),
        FOREIGN KEY (attendance_ID) REFERENCES Attendance(attendance_ID)
    );

    CREATE TABLE Performance (
        performance_ID INT PRIMARY KEY IDENTITY(1,1),
        rating INT CHECK (rating BETWEEN 1 AND 5),
        comments VARCHAR(50),
        semester CHAR(3),
        emp_ID INT,
        FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Employee_Replace_Employee (
        Emp1_ID INT,
        Emp2_ID INT,
        from_date DATE,
        to_date DATE,
        PRIMARY KEY (Emp1_ID, Emp2_ID, from_date),
        FOREIGN KEY (Emp1_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (Emp2_ID) REFERENCES Employee(employee_ID)
    );

    CREATE TABLE Employee_Approve_Leave (
        Emp1_ID INT,
        Leave_ID INT,
        status VARCHAR(50)
            DEFAULT 'pending'
            CHECK (status IN ('approved', 'rejected', 'pending')),
        PRIMARY KEY (Emp1_ID, Leave_ID),
        FOREIGN KEY (Emp1_ID) REFERENCES Employee(employee_ID),
        FOREIGN KEY (Leave_ID) REFERENCES Leave(request_ID)
    );
END;
GO


CREATE PROCEDURE dropAllTables
AS
BEGIN
    DROP TABLE Deduction;
    DROP TABLE Document;
    DROP TABLE Employee_Phone;
    DROP TABLE Employee_Role;
    DROP TABLE Role_existsIn_Department;
    DROP TABLE Employee_Approve_Leave;
    DROP TABLE Employee_Replace_Employee;
    DROP TABLE Payroll;
    DROP TABLE Performance;
    DROP TABLE Annual_Leave;
    DROP TABLE Accidental_Leave;
    DROP TABLE Compensation_Leave;
    DROP TABLE Medical_Leave;
    DROP TABLE Unpaid_Leave;
    DROP TABLE Attendance;
    DROP TABLE Employee;
    DROP TABLE Leave;
    DROP TABLE Department;
    DROP TABLE Role;
END;
GO

CREATE PROCEDURE clearAllTables
AS
BEGIN
    DELETE FROM Deduction;
    DELETE FROM Document;
    DELETE FROM Employee_Phone;
    DELETE FROM Employee_Role;
    DELETE FROM Role_existsIn_Department;
    DELETE FROM Employee_Approve_Leave;
    DELETE FROM Employee_Replace_Employee;
    DELETE FROM Payroll;
    DELETE FROM Performance;
    DELETE FROM Annual_Leave;
    DELETE FROM Accidental_Leave;
    DELETE FROM Compensation_Leave;
    DELETE FROM Medical_Leave;
    DELETE FROM Unpaid_Leave;
    DELETE FROM Attendance;
    DELETE FROM Employee;
    DELETE FROM Leave;
    DELETE FROM Department;
    DELETE FROM Role;
END;
GO


CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    DROP PROCEDURE createAllTables;
    DROP PROCEDURE dropAllTables;
    DROP PROCEDURE clearAllTables;

    -- Add the rest of your implemented procedures here

    -- Example:

    -- DROP PROCEDURE procedureName1;

    -- DROP FUNCTION functionName1;
  
    -- DROP VIEW viewName1;
END;
GO