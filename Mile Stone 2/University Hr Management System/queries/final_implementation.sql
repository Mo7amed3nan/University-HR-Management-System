create DATABASE University_HR_ManagementSystem;
GO
USE University_HR_ManagementSystem;
GO


CREATE FUNCTION HRSalary_calculation
(@employee_ID int) 
Returns decimal(10,2)
AS
Begin
Declare @salary decimal(10,2)
Declare @base_salary decimal(10,2)
Declare @percentage_YOE decimal(10,2)
Declare @YOE int

SELECT @base_salary = base_salary, @percentage_YOE = percentage_YOE  ,@YOE= E.years_of_experience
FROM Employee_Role ER
INNER JOIN Role R
ON ER.role_name = R.role_name
INNER JOIN Employee E
ON E.employee_ID = ER.emp_ID
WHERE employee_ID = @employee_ID
Order by R.rank ASC
SET @salary = @base_salary + (@percentage_YOE/100) * @YOE * @base_salary
Return @salary
END

GO

CREATE PROC createAllTables
AS

	CREATE TABLE Department(
	name varchar(50) primary key,
	building_location varchar(50)
	);

	CREATE TABLE Employee(
	employee_id int primary key identity,
	first_name varchar(50),
	last_name varchar(50),
	email varchar(50),
	password varchar(50),
	address varchar(50),
	gender CHAR(1),
	official_day_off varchar(50),
	years_of_experience int,
	national_ID char(16),
	employment_status varchar(50) CHECK(employment_status IN ('active', 'onleave', 'notice_period','resigned')),
	type_of_contract varchar(50),CHECK(type_of_contract IN ('full_time','part_time')),
	emergency_contact_name varchar(50),
	emergency_contact_phone char(11),
	annual_balance int,
	accidental_balance int,
	salary AS dbo.HRSalary_calculation(employee_id),
	hire_date date,
	last_working_date date,
	dept_name varchar(50) foreign key references Department
	);

	CREATE TABLE Employee_Phone(
	emp_id int foreign key references Employee,
	phone_num char(11),
	primary key(emp_id, phone_num)
	);

	CREATE TABLE Role(
	role_name varchar (50) PRIMARY KEY,
	title varchar (50),
	description varchar (50),
	rank int, 
	base_salary decimal (10,2),
	percentage_YOE decimal (4,2),
	percentage_overtime decimal (4,2), 
	annual_balance int,
	accidental_balance int
	);

	CREATE TABLE Employee_Role(
	emp_ID int foreign key references Employee,
	role_name varchar(50) foreign key references Role,
	primary key(emp_ID, role_name)
	);




	CREATE TABLE Role_existsIn_Department(
	department_name varchar(50) FOREIGN KEY references Department,
	Role_name varchar(50) FOREIGN KEY references Role,
	PRIMARY KEY(department_name, role_name)
	);
	CREATE TABLE Leave (
	request_ID int PRIMARY KEY IDENTITY,
	date_of_request date,
	start_date date,
	end_date date,
	num_days AS DATEDIFF(day, start_date, end_date)+1,
	final_approval_status varchar(50) CHECK(final_approval_status IN('Approved', 'Pending', 'Rejected'))  DEFAULT('Pending')
	);


	CREATE TABLE Annual_Leave (
	request_ID int PRIMARY KEY FOREIGN KEY REFERENCES LEAVE,
	emp_ID  int FOREIGN KEY REFERENCES Employee,
	replacement_emp  int FOREIGN KEY REFERENCES Employee
	);

	CREATE TABLE Accidental_Leave (
	request_ID int PRIMARY KEY FOREIGN KEY REFERENCES LEAVE,
	emp_ID int FOREIGN KEY REFERENCES Employee
	);

	CREATE TABLE Medical_Leave(
	request_ID  int PRIMARY KEY FOREIGN KEY REFERENCES LEAVE,
	insurance_status BIT,
	disability_details varchar(50),
	type varchar(50) CHECK(type IN ('sick','maternity')),
	Emp_ID  int FOREIGN KEY REFERENCES Employee
	);

	CREATE TABLE Unpaid_Leave(
	request_ID  int PRIMARY KEY FOREIGN KEY REFERENCES LEAVE,
	Emp_ID  int FOREIGN KEY REFERENCES Employee
	);

	CREATE TABLE Compensation_Leave(
	request_ID  int PRIMARY KEY FOREIGN KEY REFERENCES LEAVE,
	reason varchar (50),
	date_of_original_workday date,
	emp_ID int FOREIGN KEY REFERENCES Employee,
	replacement_emp  int FOREIGN KEY REFERENCES Employee
	);

	CREATE TABLE Document (
	document_id int primary key IDENTITY,
	type varchar (50),
	description varchar (50),
	file_name varchar (50),
	creation_date date, 
	expiry_date date, 
	status varchar (50) CHECK(status in ('valid', 'expired')),
	emp_ID int FOREIGN KEY REFERENCES Employee, 
	medical_ID int FOREIGN KEY REFERENCES MEDICAL_LEAVE, 
	unpaid_ID INT FOREIGN KEY REFERENCES UNPAID_LEAVE
	);





	CREATE TABLE Payroll (
	ID int PRIMARY KEY IDENTITY,
	payment_date date,
	final_salary_amount decimal (10,1),
	from_date date,
	to_date date,
	comments varchar(150),
	bonus_amount decimal(10,2),
	deductions_amount decimal(10,2),
	emp_ID int FOREIGN KEY REFERENCES Employee
	);

	CREATE TABLE Attendance (
	attendance_ID int PRIMARY KEY IDENTITY,
	date date,
	check_in_time time, 
	check_out_time time, 
	total_duration as DATEDIFF(Minute, check_in_time,check_out_time),
	status varchar(50) CHECK(status IN ('Absent', 'Attended')) DEFAULT('Absent'),
	emp_ID int FOREIGN KEY REFERENCES Employee
	);

	CREATE TABLE Deduction (
	deduction_ID int IDENTITY,
	emp_ID INT FOREIGN KEY REFERENCES Employee,
	date date,
	amount decimal (10,2),
	type varchar (50) CHECK(type IN ('unpaid', 'missing_hours', 'missing_days')),
	status varchar (50) CHECK(status IN ('pending', 'finalized')) DEFAULT('pending'),
	unpaid_ID int FOREIGN KEY REFERENCES Unpaid_leave,
	attendance_ID int FOREIGN KEY REFERENCES Attendance,
	PRIMARY KEY(deduction_id, emp_ID)
	);


	CREATE TABLE Performance (
	performance_ID int PRIMARY KEY IDENTITY,
	rating int CHECK(rating>=1 AND rating<=5),
	comments varchar (50),
	semester CHAR(3),
	emp_ID int FOREIGN KEY REFERENCES Employee
	);




	CREATE TABLE Employee_Replace_Employee (
	table_id INT IDENTITY,
	Emp1_ID INT FOREIGN KEY REFERENCES EMPLOYEE
	,
	Emp2_ID INT FOREIGN KEY REFERENCES EMPLOYEE
	,
	from_date date,
	to_date date,
	PRIMARY KEY(table_id, Emp1_ID, Emp2_ID)
	 );

	CREATE TABLE Employee_Approve_Leave(
	Emp1_ID INT FOREIGN KEY REFERENCES EMPLOYEE,
	leave_ID INT FOREIGN KEY REFERENCES Leave,
	status varchar(50) CHECK(status IN('Approved', 'Pending', 'Rejected')) DEFAULT('Pending'),

	 PRIMARY KEY(Emp1_ID, leave_ID)
	);
GO


exec createAllTables

go


CREATE PROC dropAllTables
AS


DROP TABLE Employee_Phone;
DROP TABLE Employee_Role;
DROP TABLE Annual_Leave;
DROP TABLE Accidental_Leave;
DROP TABLE Document;
DROP TABLE Compensation_Leave;
DROP TABLE Role_existsIn_Department;
DROP TABLE Role;

DROP TABLE Performance;

DROP TABLE Employee_Replace_Employee;
DROP TABLE Employee_Approve_Leave;
DROP TABLE Medical_Leave;
DROP TABLE Deduction;
DROP TABLE Payroll;
DROP TABLE Unpaid_Leave;

DROP TABLE Attendance;
DROP TABLE Leave;

DROP TABLE Employee;
DROP TABLE Department;


GO



CREATE PROC clearAllTables
AS
TRUNCATE TABLE Employee_Phone;
TRUNCATE TABLE Employee_Role;
TRUNCATE TABLE Annual_Leave;
TRUNCATE TABLE Accidental_Leave;
TRUNCATE TABLE Compensation_Leave;
TRUNCATE TABLE Role_existsIn_Department;
TRUNCATE TABLE Performance;
TRUNCATE TABLE Employee_Replace_Employee;
TRUNCATE TABLE Employee_Approve_Leave;
TRUNCATE TABLE Deduction;
TRUNCATE TABLE Payroll;
TRUNCATE TABLE Document;
DELETE FROM  Attendance;
DELETE FROM Medical_Leave;
DELETE FROM  Unpaid_Leave;
DELETE FROM  Leave;
DELETE FROM  Employee;
DELETE FROM   Department;
DELETE FROM  Role;

GO
--



CREATE OR ALTER PROC dropAllProceduresFunctionsViews
AS
DROP PROC createAllTables;
DROP PROC dropAllTables;
DROP PROC clearAllTables;
DROP VIEW  allEmployeeProfiles;
DROP VIEW allValidContracts;
DROP VIEW NoEmployeeDept;
DROP VIEW EmployeePayroll;
DROP VIEW allPerformance;
DROP VIEW allApprovedLeaves;
DROP VIEW allRejectedMedicals;
DROP VIEW allEmployeeAttendance;
DROP VIEW allDeductionUnpaid;
DROP VIEW allEmployeeRank;
DROP PROC New_Department;
DROP PROC New_Role;
DROP PROC Update_Status_Doc;
DROP PROC Remove_Deductions;
DROP PROC Delete_Doc_Employee;
DROP PROC Create_Holiday;
DROP PROC Add_holiday;
DROP PROC Intitiate_Attendance;
DROP PROC Update_attendance;
DROP PROC Remove_holiday;
DROP PROC Remove_dayOff;
DROP PROC Remove_Approved_Leaves;
DROP PROC Replace_employee;
DROP FUNCTION HRLoginValidation;
DROP PROC HR_approval_an_acc;
DROP PROC HR_approval_unpaid;
DROP PROC HR_approval_comp;
DROP PROC Deduction_hours;
DROP PROC Deduction_unpaid;
DROP FUNCTION Bonus_amount;
DROP PROC Add_payroll;
DROP FUNCTION HRSalary_calculation;
DROP FUNCTION EmployeeLoginValidation;
DROP FUNCTION Personal_info;
DROP FUNCTION MyPerformance;
DROP FUNCTION MyAttendance;
DROP FUNCTION Last_month_payroll;
DROP FUNCTION Deductions_Attendance;
DROP PROC MyResignation;
DROP FUNCTION Is_on_leave;
DROP PROC Submit_annual;
DROP FUNCTION status_leaves;
DROP PROC Dean_approve_annual;
DROP PROC Submit_Accidental;
DROP PROC Submit_Medical;
DROP PROC Submit_Unpaid;
DROP PROC Upperboard_approve_unpaids;
DROP PROC Submit_compensation;
DROP PROC DeanandHR_Evaluation;
DROP PROC Medical_approval;
GO



---------------------------------- 2.2 ---------------------------------------
-- a)
CREATE VIEW allEmployeeProfiles
AS
SELECT employee_ID, first_name, last_name, gender, email, address,years_of_experience, official_day_off,type_of_contract,employment_status,
annual_balance, accidental_balance 
FROM Employee;
GO


-- b)
Create View NoEmployeeDept
AS

select dept_name as 'Department',count(employee_id) 
as 'Number of Employees'from Employee
WHERE dept_name IS NOT NULL  
group by dept_name

GO 


-- c)
CREATE VIEW allPerformance
AS
SELECT P.*
FROM Performance P
INNER JOIN Employee E
ON p.emp_id = E.employee_ID
WHERE P.SEMESTER LIKE 'W%';
GO


-- d) 
CREATE VIEW allRejectedMedicals
AS
select M.*
FROM medical_Leave M  INNER JOIN leave 
ON M.request_ID = leave.request_ID
where leave.final_approval_status='rejected';


GO
-- e)
CREATE OR ALTER VIEW allEmployeeAttendance
AS
SELECT * 
FROM Attendance
WHERE Date=CAST(DATEADD(day, -1, GETDATE()) AS date);
GO


---------------------------- 2.3 ------------------------------
--------------2.3 a ----------
CREATE PROC Update_Status_Doc
AS
UPDATE Document
SET status='expired'
WHERE expiry_date IS NOT NULL AND CURRENT_TIMESTAMP> expiry_date;


GO

--------------2.3 b ----------
CREATE PROC Remove_Deductions
AS
DELETE FROM Deduction
WHERE emp_ID = ANY(
SELECT employee_id
FROM Employee
WHERE last_working_date< CURRENT_TIMESTAMP AND employment_status= 'resigned');

GO

-- 2.3 c) Update the employee’s employment_status daily based on whether the employee is on leave or active.

CREATE or alter PROC Update_Employment_Status @Employee_ID int
AS 
declare @onleave bit =dbo.Is_On_Leave ( @Employee_ID, 
CAST(CURRENT_TIMESTAMP AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))
IF @onleave =1
begin 
update Employee
set employment_status='onleave'
where employee_id=@Employee_ID
end
else IF @onleave =0
begin 
update Employee
set employment_status='active'
where employee_id=@Employee_ID
end

GO 


-- 2.3 d)
CREATE PROC Create_Holiday
AS
CREATE TABLE Holiday(
holiday_ID int IDENTITY,
holiday_name varchar(50),
from_date date,
to_date date
);
GO


CREATE OR ALTER PROCEDURE Add_Holiday
    @holiday_name VARCHAR(50),
    @from_date DATE,
    @to_date   DATE
AS
BEGIN
    -- Added Basic Input validation
    IF @holiday_name IS NULL OR @holiday_name= '' OR @from_date IS NULL OR @to_date IS NULL OR @from_date > @to_date
    BEGIN
        PRINT 'holiday_data must not be NULL or empty and the date_range entered must be correct.'
    END
	IF EXISTS (
            SELECT 1 FROM Holiday h
            WHERE holiday_name = @holiday_name
              AND NOT (h.to_date < @from_date OR h.from_date > @to_date)
        )
        BEGIN
		PRINT 'Holiday date range overlaps an existing holiday for the same name.'
		END 
	ELSE 
	BEGIN
		INSERT INTO Holiday (holiday_name, from_date, to_date)
		VALUES (@holiday_name, @from_date, @to_date);
	END
END;

GO



CREATE OR ALTER PROCEDURE Initiate_Attendance
AS
BEGIN
    DECLARE @today DATE = CAST(GETDATE() AS DATE);
	-- Insert attendance records for all employees who don't already have a record for today
	INSERT INTO Attendance ([date], emp_ID)
	SELECT @today, e.employee_id
	FROM dbo.Employee AS e
	WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.Attendance AS a
		WHERE a.emp_ID = e.employee_id
		  AND a.[date] = @today
	);
END;
GO


--------------2.3 g ----------
CREATE OR ALTER PROCEDURE Update_Attendance
    @Employee_id    INT,
    @check_in_time  TIME = NULL,
    @check_out_time TIME = NULL
AS
BEGIN
    DECLARE @today DATE = CAST(GETDATE() AS DATE);
    DECLARE @status VARCHAR(10);
    -- Determine status based on presence of check-in/check-out times
    IF @check_in_time IS NULL OR @check_out_time IS NULL
        SET @status = 'Absent';
    ELSE
        SET @status = 'Attended';

    -- Ensure the attendance record for today exists
	IF NOT EXISTS (
		SELECT 1
		FROM Attendance
		WHERE emp_ID = @Employee_id
		  AND [date] = @today
	)
	BEGIN
		PRINT 'No attendance record found for this employee today.'
	END
	ELSE 
	BEGIN
		UPDATE Attendance
		SET check_in_time  = @check_in_time,
			check_out_time = @check_out_time,
			status         = @status
		WHERE emp_ID = @Employee_id
		  AND [date] = @today;
	END
END;
GO
----------- 2.3 h -------------

CREATE OR ALTER PROCEDURE Remove_Holiday
AS
BEGIN
	-- Delete any attendance record whose date falls within any holiday range
	DELETE A
	FROM Attendance AS A
	WHERE EXISTS (
		SELECT 1
		FROM dbo.Holiday AS H
		WHERE A.[date] BETWEEN H.from_date AND H.to_date
	);
END;
GO

----------- 2.3 i -------------

CREATE OR ALTER PROCEDURE dbo.Remove_DayOff
    @employee_ID INT
AS
BEGIN
    DECLARE @official_day_off VARCHAR(50);
    DECLARE @current_year  INT = YEAR(GETDATE());
    DECLARE @current_month INT = MONTH(GETDATE());

	-- Validate employee and read official day off
	SELECT @official_day_off = official_day_off
	FROM dbo.Employee
	WHERE employee_id = @employee_ID;
	IF @official_day_off IS NULL
	BEGIN
	   PRINT 'Employee not found or official_day_off is NULL for the specified employee.';
	END
	-- Perform delete:
	-- remove rows for the employee in the current month/year
	-- where weekday matches the employee's official day off (case-insensitive)
	-- AND (status = 'Absent' OR (check_in_time IS NULL AND check_out_time IS NULL))
	DELETE A
	FROM dbo.Attendance AS A
	WHERE A.emp_ID = @employee_ID
	  AND YEAR(A.[date]) = @current_year
	  AND MONTH(A.[date]) = @current_month
	  AND UPPER(DATENAME(WEEKDAY, A.[date])) = UPPER(@official_day_off)
	  AND (
			-- prefer explicit status check if column exists / used
			(A.status IS NOT NULL AND UPPER(A.status) = 'ABSENT')
			OR
			(A.check_in_time IS NULL AND A.check_out_time IS NULL)
		  );


END;
GO

----------- 2.3 j -------------

CREATE OR ALTER PROCEDURE dbo.Remove_Approved_Leaves
    @employee_id INT
AS
BEGIN
    IF @employee_id IS NULL
    BEGIN
        PRINT 'employee_id must not be NULL.';
    END;
	ELSE
	BEGIN
		/*
		 Delete any attendance row for the given employee where:
		 - the attendance date falls BETWEEN start_date AND end_date of any Approved leave for that employee
		 - AND (status = 'Absent' OR (check_in_time IS NULL AND check_out_time IS NULL))
		 The logic uses EXISTS against each leave-subtype table so any matching approved leave will qualify the row for deletion.
		*/
		DELETE A
		FROM dbo.Attendance AS A
		WHERE A.emp_ID = @employee_id
		  AND (
				-- row date falls within an approved Annual_Leave for this employee
				EXISTS (
					SELECT 1
					FROM dbo.Leave      AS L
					INNER JOIN dbo.Annual_Leave AS AL ON AL.request_ID = L.request_ID
					WHERE AL.emp_ID = @employee_id
					  AND L.final_approval_status = 'Approved'
					  AND A.[date] BETWEEN L.start_date AND L.end_date
				)
				OR
				-- accidental leave
				EXISTS (
					SELECT 1
					FROM dbo.Leave      AS L
					INNER JOIN dbo.Accidental_Leave AS ACL ON ACL.request_ID = L.request_ID
					WHERE ACL.emp_ID = @employee_id
					  AND L.final_approval_status = 'Approved'
					  AND A.[date] BETWEEN L.start_date AND L.end_date
				)
				OR
				-- compensation leave
				EXISTS (
					SELECT 1
					FROM dbo.Leave      AS L
					INNER JOIN dbo.Compensation_Leave AS CL ON CL.request_ID = L.request_ID
					WHERE CL.emp_ID = @employee_id
					  AND L.final_approval_status = 'Approved'
					  AND A.[date] BETWEEN L.start_date AND L.end_date
				)
				OR
				-- medical leave
				EXISTS (
					SELECT 1
					FROM dbo.Leave      AS L
					INNER JOIN dbo.Medical_Leave     AS ML ON ML.request_ID = L.request_ID
					WHERE ML.Emp_ID = @employee_id
					  AND L.final_approval_status = 'Approved'
					  AND A.[date] BETWEEN L.start_date AND L.end_date
				)
				OR
				-- unpaid leave
				EXISTS (
					SELECT 1
					FROM dbo.Leave      AS L
					INNER JOIN dbo.Unpaid_Leave     AS UL ON UL.request_ID = L.request_ID
					WHERE UL.Emp_ID = @employee_id
					  AND L.final_approval_status = 'Approved'
					  AND A.[date] BETWEEN L.start_date AND L.end_date
				)
			  )
		  -- only delete unattended/absent rows as requested
		  AND (
				(A.status IS NOT NULL AND UPPER(A.status) = 'ABSENT')
				OR
				(A.check_in_time IS NULL AND A.check_out_time IS NULL)
			  );
    END
END;
GO

GO
------------2.3 k ---------

CREATE OR ALTER PROCEDURE dbo.Replace_employee
    @Emp1_ID   INT,               -- employee being replaced
    @Emp2_ID   INT,               -- replacement employee
    @from_date DATE,
    @to_date   DATE
AS
BEGIN
    DECLARE @Emp1Exists BIT = 0;
    DECLARE @Emp2Exists BIT = 0;
    -- Basic validation
    IF @Emp1_ID IS NULL OR @Emp2_ID IS NULL BEGIN PRINT 'Emp1_ID and Emp2_ID must not be NULL.';RETURN;END
    IF @from_date IS NULL OR @to_date IS NULL BEGIN PRINT 'from_date and to_date must not be NULL.';RETURN;END
    IF @from_date > @to_date BEGIN PRINT 'from_date must be less than or equal to to_date.';RETURN; END
    IF @Emp1_ID = @Emp2_ID BEGIN PRINT 'Emp1_ID and Emp2_ID cannot be the same.';RETURN;END
    -- Verify employees exist
    IF EXISTS (SELECT 1 FROM Employee WHERE employee_id = @Emp1_ID) SET @Emp1Exists = 1;
    IF EXISTS (SELECT 1 FROM Employee WHERE employee_id = @Emp2_ID) SET @Emp2Exists = 1;
    IF @Emp1Exists = 0 BEGIN PRINT 'Employee with Emp1_ID not found.'; RETURN;END
    IF @Emp2Exists = 0 BEGIN PRINT 'Employee with Emp2_ID not found.'; RETURN;END
    --overlap check: prevent Emp2 double-assignment
    IF EXISTS (
        SELECT 1
        FROM dbo.Employee_Replace_Employee r
        WHERE r.Emp2_ID = @Emp2_ID
          AND NOT (r.to_date < @from_date OR r.from_date > @to_date)
    )
    BEGIN
        PRINT 'Replacement employee (Emp2) already has an overlapping replacement period.';
        RETURN;
    END
    -- Perform the insertion
    INSERT INTO dbo.Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date)
    VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);
END;
GO





---------------------------------------------------- 2.4 ----------------------------------------
------------------------------------------- a) ---------------------------------------------------
CREATE FUNCTION HRLoginValidation
(@employee_ID int,
@password varchar(50)) 
Returns BIT
AS
Begin
Declare @success BIT
IF EXISTS (
	SELECT 1 FROM Employee E WHERE employee_id=@employee_ID AND password=@password
    and dept_name = 'HR')
   SET @success =1
ELSE
   SET @success =0;
Return @success
END
go


----------------------------------------------------- b) --------------------------------

CREATE or alter PROC HR_approval_an_acc
@request_ID int, 
@HR_ID int
AS
--declare variables
declare @emp_ID int
DECLARE @num_days INT
DECLARE @current_status VARCHAR(50)
DECLARE @annual_balance INT
DECLARE @accidental_balance INT
declare @start_date_acc date
declare  @end_date_acc date
declare @date_of_request date
--declare @difference_between_date_start_date int
----------------------- Annual Leave -------------------------------------------
--- check if the balance is greater than 0 and the leave is annual leave -------
if exists(select 1 from Annual_Leave where request_ID = @request_ID)
begin
-- get the employee_ID of the requester
    
    select @emp_ID = emp_ID
    from Annual_Leave
    where request_ID = @request_ID
-- get total number of days and current status
    
    
    SELECT @num_days = num_days, @current_status = final_approval_status,@start_date_acc=start_date,@end_date_acc=end_date
    FROM Leave 
    WHERE request_ID = @request_ID;
--get employee annual balance
    
    SELECT @annual_balance = annual_balance 
    FROM Employee 
    WHERE employee_id = @emp_ID;
-- check if it is not already pending, print error message
    IF @current_status <> 'Pending'
    BEGIN
        PRINT 'Error: Leave request has already been processed.';
        RETURN;
    END

-- check balance and Approve/reject
    if @annual_balance >= @num_days
    begin
        -- update the table approve
        update Employee_Approve_Leave
        set status = 'Approved'
        where Emp1_ID = @HR_ID and leave_ID=@request_ID
        -- update the final status
        update Leave
        set final_approval_status = 'Approved'
        where request_ID = @request_ID
        -- deduct from Annual balance of Employee
        UPDATE Employee 
        SET annual_balance = annual_balance - @num_days 
        WHERE employee_id = @emp_ID;
        -------------------------------------CHANGES-------------------
        --if approved we need to update the employee replace employee table
       
-- needs replacementID , which I can get it from annual Leave
declare @replacement_id int 
select @replacement_id=replacement_emp  from Annual_Leave where request_ID=@request_ID
-- insert into employee replace employee
insert into Employee_Replace_Employee (Emp1_ID,Emp2_ID,from_date, to_date) values  (@emp_ID,@replacement_id,@start_date_acc,@end_date_acc)

        -------------------------------------------------------------------
    end
    else
    begin
        --reject the leave
        UPDATE Employee_Approve_Leave 
        SET status = 'Rejected' 
        WHERE leave_ID = @request_ID AND Emp1_ID = @HR_ID;


        UPDATE Leave 
        SET final_approval_status = 'Rejected' 
        WHERE request_ID = @request_ID;
    end

end
---------------------------------- Accidental Leave -------------------------
ELSE IF EXISTS (SELECT 1 FROM Accidental_Leave WHERE request_ID = @request_ID)
BEGIN
    --get requester_ID
    SELECT @emp_ID = emp_ID 
    FROM Accidental_Leave 
    WHERE request_ID = @request_ID;
    
    --get num_days and current_status
    SELECT @num_days = num_days, @current_status = final_approval_status
    FROM Leave 
    WHERE request_ID = @request_ID;

    -- get accidental balance
    SELECT @accidental_balance = accidental_balance 
    FROM Employee 
    WHERE employee_id = @emp_ID;

    -- Check if leave is already processed, print error message
    IF @current_status <> 'Pending'
    BEGIN
        PRINT 'Error: Leave request has already been processed.';
        RETURN;
    END

    -- check if it is submitted after maximum 2 days -------------------
    select @date_of_request = date_of_request, @start_date_acc = start_date
    from Leave
    where request_ID = @request_ID

    -- -- Check balance and num_days is 1 then approve/reject
        IF @accidental_balance >= @num_days and @num_days = 1 and DATEDIFF(DAY, @start_date_acc, @date_of_request) <= 2 and @date_of_request > @start_date_acc
        BEGIN
            
            -- Update HR approval status
            UPDATE Employee_Approve_Leave 
            SET status = 'Approved' 
            WHERE leave_ID = @request_ID AND Emp1_ID = @HR_ID;


            -- update the final status
            UPDATE Leave 
            SET final_approval_status = 'Approved' 
            WHERE request_ID = @request_ID;
            
            
            -- Deduct from employee's accidental balance
            UPDATE Employee 
            SET accidental_balance = accidental_balance - @num_days 
            WHERE employee_id = @emp_ID;
        end
        else
        begin
            -- Update HR approval status
            UPDATE Employee_Approve_Leave 
            SET status = 'Rejected' 
            WHERE leave_ID = @request_ID AND Emp1_ID = @HR_ID;


             -- Reject the leave
            UPDATE Leave 
            SET final_approval_status = 'Rejected' 
            WHERE request_ID = @request_ID;
        end
end

GO


----------------------------------------------- c) --------------------------------------------------
CREATE or alter PROC HR_approval_Unpaid
@request_ID int, 
@HR_ID int
as
-- Declare variables
DECLARE @emp_ID INT
DECLARE @num_days INT
DECLARE @current_status VARCHAR(50)
DECLARE @start_date DATE
DECLARE @end_date DATE
DECLARE @approved_unpaid_count_days INT

IF EXISTS (SELECT 1 FROM Unpaid_Leave WHERE request_ID = @request_ID)
BEGIN
    -- Get the employee_ID of the requester
        SELECT @emp_ID = emp_ID
        FROM Unpaid_Leave
        WHERE request_ID = @request_ID;

		----check that annual balance is zero 
		declare @annual_balance int 
		select @annual_balance = annual_balance from Employee 
		where employee_id = @emp_ID 
        
        -- Get number of days, current status, and dates
        SELECT @num_days = num_days, 
               @current_status = final_approval_status,
               @start_date = start_date,
               @end_date = end_date
        FROM Leave 
        WHERE request_ID = @request_ID;

        -- Check if leave is already processed
        IF @current_status <> 'Pending'
        BEGIN
            PRINT 'Error: Leave request has already been processed.';
            RETURN;
        END


        -- Check if any employee in the approval hierarchy rejected the leave
        IF EXISTS 
        (SELECT 1 FROM Employee_Approve_Leave 
         WHERE leave_ID = @request_ID AND status = 'Rejected')
        BEGIN
            -- Update HR approval record
            UPDATE Employee_Approve_Leave
            SET status = 'Rejected'
            WHERE Emp1_ID = @HR_ID AND leave_ID = @request_ID;
            
            -- Update the final status in leave table
            UPDATE Leave
            SET final_approval_status = 'Rejected'
            WHERE request_ID = @request_ID;
            RETURN;
        END
		else if (@annual_balance<>0)
		begin 
		UPDATE Employee_Approve_Leave
            SET status = 'Rejected'
            WHERE Emp1_ID = @HR_ID AND leave_ID = @request_ID;
            
            -- Update the final status in leave table
            UPDATE Leave
            SET final_approval_status = 'Rejected'
            WHERE request_ID = @request_ID;

			PRINT 'Error: You have annual balance';
			RETURN;
		end 
        -- Check if duration exceeds 30 days
   else IF (@num_days > 30)
        BEGIN
            -- Reject the leave
            UPDATE Employee_Approve_Leave 
            SET status = 'Rejected' 
            WHERE leave_ID = @request_ID AND Emp1_ID = @HR_ID;

            UPDATE Leave 
            SET final_approval_status = 'Rejected' 
            WHERE request_ID = @request_ID;
            RETURN;
        END

       --if already has 1 unpaid leave in same year approved reject

         else IF(exists(select * FROM Unpaid_Leave un
            inner join Leave l 
            ON l.request_ID = un.request_ID
            WHERE un.Emp_ID = @emp_ID and
            year(l.start_date) = year(current_timestamp) and final_approval_status = 'approved'
            ))
            BEGIN
            UPDATE Employee_Approve_Leave
            SET status = 'rejected'
            where leave_ID = @request_ID and Emp1_ID = @HR_ID

            UPDATE Leave
            SET final_approval_status = 'rejected'
            WHERE request_ID = @request_ID 
            END



        -- All checks passed - Approve the leave
        -- Update HR approval record
        else 
        begin
        UPDATE Employee_Approve_Leave
        SET status = 'Approved'
        WHERE Emp1_ID = @HR_ID AND leave_ID = @request_ID;
        
        -- Update the final status
        UPDATE Leave
        SET final_approval_status = 'Approved'
        WHERE request_ID = @request_ID;
        end
end
GO


------------------------------------------------ d) -----------------------------------------------------
CREATE or alter PROC HR_approval_comp
@request_ID int, 
@HR_ID int
AS	
DECLARE @check_in time
DECLARE @check_out time
DECLARE @instead_of_day date
DECLARE @emp_id int

IF EXISTS(
select 1 from Compensation_Leave
where request_ID = @request_ID 
)
begin
declare @current_status varchar(50)
SELECT @current_status = final_approval_status FROM Leave 
        WHERE request_ID = @request_ID;

        -- Check if leave is already processed
        IF @current_status <> 'Pending'
        BEGIN
            PRINT 'Error: Leave request has already been processed.';
            RETURN;
        END

------------------ get the original work day and the ID of the requester ----------
	select @instead_of_day = date_of_original_workday, @emp_id = emp_ID
	from Compensation_Leave
	where request_ID = @request_ID
	---- check if the original work day is the dayoff ------------
	if EXISTS (
		select 1 from Employee
		where employee_id = @emp_id and official_day_off = DATENAME(WEEKDAY, @instead_of_day)
	)
	begin
	-------------------- check 8 hours in this day and the replacement is not on leave -----------------------

		declare @replacement_ID int
		select @replacement_ID = replacement_emp
		from Compensation_Leave
		where emp_ID = @emp_id and request_ID = @request_ID
		------------- check on leave -----------------------------
		if EXISTS(
			select 1 from Employee
			where employee_id = @replacement_ID and employment_status <> 'onleave'
		)
		begin
		-------------------------- check 8 hours and in the same month ------------------------------
			SELECT @check_in=check_in_time, @check_out= check_out_time
			FROM Attendance
			WHERE date= @instead_of_day AND emp_ID=@emp_id


			IF( DATEDIFF(HOUR,@check_in, @check_out)>=8) and exists(
                select 1 from Leave l
                inner join Compensation_Leave cl
                on l.request_ID = cl.request_ID
                where month(l.date_of_request) = month(cl.date_of_original_workday) and year(l.date_of_request) = year(cl.date_of_original_workday) and l.request_ID = @request_ID
            )
			begin
				---------- approve the leave -----------------
				UPDATE Employee_Approve_Leave
				SET status = 'Approved' 
				WHERE leave_ID = @request_ID AND Emp1_ID = @HR_ID

				UPDATE LEAVE
				SET final_approval_status = 'Approved' 
				WHERE request_ID = @request_ID

				return
			end
		end
		
		
	end

end
GO
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------- e) --------------------------------------------------

create or alter proc Deduction_hours
@employee_ID int
as
--calculate all missing hours
--get count of days the employee attended
declare @total_duration int, @required_minutes Decimal(10,2), @days_num int
---get number of days the employee attended in the month
select @days_num = count(attendance_ID) from Attendance
where status = 'attended' and 
date >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  AND date <= CAST(GETDATE() AS DATE)
  AND emp_ID = @employee_ID;
--get required hours
set @required_minutes = 8 * @days_num *60.0

---get total hours attended
SELECT @total_duration =  SUM(total_duration)--DATEDIFF(MINUTE, 0, total_duration)) --/ 3600.0 
FROM Attendance
WHERE date >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  AND date <= CAST(GETDATE() AS DATE)
  AND emp_ID = @employee_ID AND 
  check_in_time IS NOT NULL AND check_out_time IS NOT NULL;

--if has missing minutes
if(@total_duration < @required_minutes)
begin
--get id of first attendance that caused missing hours
declare @attendance_id int 
select top 1 @attendance_id = attendance_ID from Attendance
where status = 'attended' and  (total_duration/60.0) < 8 
and date >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  AND date <= CAST(GETDATE() AS DATE)
  AND emp_ID = @employee_ID;

----calculate amount 
  declare @missing_minutes decimal(10,2) 
  set @missing_minutes = @required_minutes - @total_duration
  declare @missing_hours decimal(10,2) 
  set @missing_hours = @missing_minutes/60.0
		DECLARE @salary decimal(10,2);
		SELECT @salary=salary
		FROM Employee
		WHERE employee_id = @employee_id;

		DECLARE @rate_per_hour decimal(10,2);
		SET @rate_per_hour = (@salary/22)/8;
		DECLARE @amount decimal(10,2);
		SET @amount = @rate_per_hour * @missing_hours;
-- add deduction with the amount calculated 
		INSERT INTO Deduction(emp_ID, date, amount, type, status, attendance_ID)
		VALUES(@employee_id, CAST(CURRENT_TIMESTAMP AS DATE),@amount, 'missing_hours','pending',@attendance_id);
        
	END
GO



-------------------------------------------------------- f) ------------------------------------------------
CREATE or alter PROC Deduction_days
@employee_id int
AS
--get number of missing days
DECLARE @days_missing int
SELECT @days_missing=count(*)
FROM Attendance
WHERE emp_ID=@employee_id AND month(date) = month(current_timestamp) AND year(date)=year(current_timestamp)
AND check_in_time IS NULL AND check_out_time IS NULL and status = 'absent';


if(@days_missing >0)
	BEGIN

		DECLARE @salary decimal(10,2);
		SELECT @salary=salary
		FROM Employee
		WHERE employee_id = @employee_id;
		DECLARE @rate_per_day decimal(10,2);
		SET @rate_per_day = @salary/30;
	

		INSERT INTO Deduction (emp_ID, date, amount, type, status, attendance_ID)
		SELECT @employee_id, CURRENT_TIMESTAMP, @rate_per_day, 'missing_days', 'pending',
		attendance_id
		FROM attendance
		WHERE emp_ID = @employee_id
		  AND MONTH(date) = MONTH(CURRENT_TIMESTAMP)
		  AND YEAR(date) = YEAR(CURRENT_TIMESTAMP)
		  AND check_in_time IS NULL
		  AND check_out_time IS NULL;



	END
GO

-------------------------- g) -------------------------------------

create or alter proc Deduction_unpaid
@employee_ID int
as
if(exists(select l.request_id from Unpaid_Leave un
inner join Leave l
on l.request_ID = un.request_ID
where un.Emp_ID = @employee_ID
and l.final_approval_status = 'approved' 
and month(l.start_date) = month(current_timestamp) and year(l.start_date) = year(current_timestamp)
))
begin

DECLARE @start_date DATE,@end_date DATE , @request_id int, @emp_salary decimal(10,2)
--get leave id

select @request_id = l.request_ID from Unpaid_Leave un
inner join Leave l
on l.request_ID = un.request_ID
where un.Emp_ID = @employee_ID
and l.final_approval_status = 'approved' 
and month(l.start_date) = month(current_timestamp) and year(l.start_date) = year(current_timestamp)

--get start and end dates of leave
select @start_date = l.start_date from Unpaid_Leave un
inner join Leave l
on l.request_ID = un.request_ID
where un.Emp_ID = @employee_ID
and l.final_approval_status = 'approved' 
and month(l.start_date) = month(current_timestamp) and year(l.start_date) = year(current_timestamp)

select @end_date = l.end_date from Unpaid_Leave un
inner join Leave l
on l.request_ID = un.request_ID
where un.Emp_ID = @employee_ID
and l.final_approval_status = 'approved' 
and month(l.start_date) = month(current_timestamp) and year(l.start_date) = year(current_timestamp)



-- Get first day of next month
DECLARE @first_day_next_month DATE = DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));

-- Days that fall within the current month
DECLARE @days_in_current_month INT =
    CASE 
        WHEN @end_date < @first_day_next_month 
            THEN DATEDIFF(DAY, @start_date, @end_date) + 1
        ELSE DATEDIFF(DAY, @start_date, DATEADD(DAY, -1, @first_day_next_month)) + 1
    END;
   
-- Days that fall in the next month (if any)
DECLARE @days_in_next_month INT =
    CASE 
        WHEN @end_date < @first_day_next_month 
            THEN 0
        ELSE DATEDIFF(DAY, @first_day_next_month, @end_date) + 1
    END
--calculate amount per month:
--get salary 
select @emp_salary =  salary from Employee
where employee_id = @employee_ID

--amount = rate per day * nb of days 
declare  @amount_month1 decimal(10,2), @amount_month2 decimal(10,2)
set @amount_month1 = (@emp_salary/22) * @days_in_current_month

set @amount_month2 = (@emp_salary/22) * @days_in_next_month



-----insert deductions:
--first month
insert into deduction(emp_ID,date,amount,type,unpaid_ID)
values(@employee_ID,CAST(CURRENT_TIMESTAMP AS DATE),@amount_month1,'unpaid',@request_id)

--check if spans 2nd month add deduction for it:

if(@days_in_next_month>0)
begin
insert into deduction(emp_ID,date,amount,type,unpaid_ID)
values(@employee_ID,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0),@amount_month2,'unpaid',@request_id)
end

end
GO


--------------------------------------- h) ---------------------------------------------------
/*
create or alter function Bonus_amount(@employee_ID int)
returns decimal(10,2)
AS
BEGIN 
   declare @employee_id INT
   SET @employee_ID=1;
declare @employeeSalary decimal(10,2)
declare @ratePerHour decimal(10,2)
declare @percentage_overtime decimal (4,2)
declare @countRecords int
declare @duration int
declare @overtimeHours time
declare @bonus decimal(10,2) =0
--getting the salary of the employee
select @employeeSalary =salary from Employee where employee_id=@employee_ID

--Rate per hour employee salary /22 days / 8 hours
set @ratePerHour=(@employeeSalary/22)/8

--getting Overtime Factor based on role , Role (can have more than 1 role)
select top 1 @percentage_overtime=r.percentage_overtime from Employee_Role er join role r on r.role_name=er.role_name where emp_ID=@employee_ID order by r.rank 
--calculating Extra Hours + Required Hours = (no of attended sessions * hours per day )
select @countRecords=count(attendance_ID), 
@duration= ISNULL(SUM(CAST(DATEDIFF(SECOND, '00:00:00', total_duration) AS BIGINT)), 0)  --added seconds 
from Attendance where  emp_ID=@employee_ID and status='attended' and month(date)=month(current_timestamp) and 
year(date)=year(current_timestamp) 

-- calculate @requiredHours --in seconds
declare @requiredHours int = @countRecords* 8* 3600
print @duration
print @requiredHours
--check if overtime
if @duration > @requiredHours
begin 
--get the difference between these two 
declare @diffSeconds int
set @diffSeconds= @duration-@requiredHours
--convert it to time format
declare @diff_hours DECIMAL(18,6) = 0
set @diff_hours = CAST(@diffSeconds AS DECIMAL(18,6)) / 3600
set @bonus= 
@ratePerHour * ((@percentage_overtime * (@diff_hours))/100)
end
return @bonus
END
*/
GO

--------------------------------------------------------------------------

create or alter function Bonus_amount(@employee_ID int)
returns decimal(10,2)
AS
BEGIN 

declare @employeeSalary decimal(10,2)
declare @ratePerHour decimal(10,2)
declare @percentage_overtime decimal (4,2)
declare @countRecords int
declare @duration int
declare @overtimeHours time
declare @bonus decimal(10,2) =0
--getting the salary of the employee
select @employeeSalary =salary from Employee where employee_id=@employee_ID

--Rate per hour employee salary /22 days / 8 hours
set @ratePerHour=(@employeeSalary/22)/8

--getting Overtime Factor based on role , Role (can have more than 1 role)
select top 1 @percentage_overtime=r.percentage_overtime from Employee_Role er join role r on r.role_name=er.role_name where emp_ID=@employee_ID order by r.rank 
--calculating Extra Hours + Required Hours = (no of attended sessions * hours per day )
select @countRecords=count(attendance_ID), 
@duration= SUM( total_duration)  --added seconds 
from Attendance where  emp_ID=@employee_ID and status='attended' and month(date)=month(current_timestamp) and 
year(date)=year(current_timestamp) AND check_in_time IS NOT NULL AND check_out_time IS NOT NULL

-- calculate @requiredHours --in seconds
declare @requiredHours int = @countRecords* 8* 60
--check if overtime
if @duration > @requiredHours
begin 
--get the difference between these two 
declare @diffMinutes int
set @diffMinutes= @duration-@requiredHours
declare @diffHours decimal(10,2)
set @diffHours= (@duration-@requiredHours)/60.0
set @bonus= 
@ratePerHour * ((@percentage_overtime * (@diffHours))/100.0)
end
return @bonus
END
GO



------------------------------------ i) ------------------------------------------
CREATE or alter PROC Add_Payroll @employee_ID int, @from date, @to date 
AS
declare @bonus decimal(10,2) = dbo.Bonus_amount(@employee_ID) --Bonus 
declare @total_deduction decimal (10,2) =0
select @total_deduction=ISNULL(SUM(amount), 0)
from Deduction 
where emp_ID=@employee_ID and month(date) =MONTH(current_timestamp) and year(date) =year(current_timestamp)
--getting the salary of the employee
declare @salary decimal(10,2)
select @salary=salary from Employee where employee_id=@employee_ID
-- add the bonus to it if any
declare @final_Salary  decimal(10,2) =0
set @final_Salary=@salary+@bonus -@total_deduction
---comments in payroll 
declare @comments varchar(50)
if @total_deduction <>0 and  @bonus <>0 
set @comments ='deductions and Bonus'
else if @total_deduction <>0 
set @comments ='deductions'
else if @bonus <>0 
set @comments ='bonus'
else set @comments ='None'
---Insert into payroll
insert into Payroll (payment_date,final_salary_amount,from_date,to_date,comments,bonus_amount,deductions_amount,emp_ID)
values (getdate(),@final_Salary,@from,@to,@comments,@bonus,@total_deduction,@employee_ID)
--Finalize Deductions
IF (@total_deduction <>0)
BEGIN
update Deduction
set status='Finalized'
where emp_ID=@employee_ID and month(date)= month(CURRENT_TIMESTAMP) and  year(date)= year(CURRENT_TIMESTAMP)
END

GO

----------------------------------------------------------------------- 2.5 ------------------------------------------------------------

------------------------ a) --------------------------
CREATE FUNCTION EmployeeLoginValidation
(@employee_ID int,
@password varchar(50)) 
Returns BIT
AS
Begin
Declare @success BIT
IF EXISTS (
	SELECT 1 FROM Employee E WHERE employee_id=@employee_ID AND password=@password and dept_name <> 'HR')
   SET @success =1
ELSE
   SET @success =0;
Return @success
END

GO

------------2.5 b MyPerformance ---------
CREATE or alter FUNCTION MyPerformance
(@employee_ID int,
@period char(3)
)
RETURNS table
AS
Return ( SELECT
*
FROM Performance
WHERE emp_id = @employee_ID AND semester=@period
)


GO


--------------2.5.c MyAttendance
--drop function MyAttendance
GO
CREATE or alter FUNCTION MyAttendance
(@employee_ID int
)
RETURNS table
AS
Return ( SELECT
A.*
FROM Attendance A
Inner join Employee E
ON A.emp_ID = E.employee_id
WHERE A.emp_id = @employee_ID AND month(A.date)=month(current_timestamp) AND year(A.date) = year(current_timestamp)
AND  ((DATENAME(WEEKDAY, A.date)<> E.official_day_off AND status='Attended') OR (DATENAME(WEEKDAY, A.date)= E.official_day_off AND status='Attended'))

)

GO



-----------------------------------------------
-------------------------2.5 d Last_month_payroll
GO
create or alter function Last_month_payroll(@employee_ID int)
returns table 
as
return (
select *
from Payroll
where emp_ID=@employee_ID and dATEDIFF(month,payment_date,current_timestamp)=1 
)
GO


-------------------2.5.e Deductions_Attendance

GO
CREATE or alter FUNCTION Deductions_Attendance
(@employee_ID int, 
@month int
)
RETURNS table
AS
Return ( SELECT
*
FROM Deduction  
WHERE attendance_id IS NOT NULL AND month(date) = @month and emp_ID = @employee_ID
)


GO


------------------------------------------------------
----------------------2.5 g Submit_annual
GO
CREATE or alter proc Submit_annual 
@employee_ID int, @replacement_emp int, @start_date date, @end_date date
AS 
declare @HR_Representative_id int
declare @mang_id int
declare @repl_id int 
declare @president_id int
declare @Vicedean_id int
declare @dean_id int
--Insert into leave Table 
Insert into Leave (date_of_request,start_date,end_date)
values (CAST(CURRENT_TIMESTAMP AS DATE), @start_date, @end_date)
--get the id to insert it into annual leave 
declare @req_id int
select @req_id=request_ID
from leave 
where start_date=@start_date and end_date=@end_date
--Insert into Annual Leave 
insert into Annual_Leave values (@req_id,@employee_ID,@replacement_emp)

-- insert into approval table
-- 1- need to know his department for HR reprenstative -- from table employee
declare @dept_name varchar(50)
select @dept_name=dept_name from Employee where @employee_ID=employee_id
--2 get to know who is submitting the leave  -- Role (can have more than 1 role)
declare @role_name varchar(50)
select top 1 @role_name=r.role_name from Employee_Role er join role r on r.role_name=er.role_name where emp_ID=@employee_ID order by r.rank 

--a) HR from role_name in employee_role table [needs approval from HR manager]
-- get HR manager ID 

if @role_name like'HR_Representative_%' 
begin
select @mang_id=emp_ID from Employee_Role where role_name='HR Manager'
insert into Employee_Approve_Leave (Emp1_ID, leave_ID ) values (@mang_id,@req_id)  return  --@mang_id
end
-- if any other option i need HR_Representative_ ID 

select @HR_Representative_id=emp_ID from Employee_Role where role_name='HR_Representative_'+ @dept_name     
-- need to check if he is onleave 
declare @onleave bit =dbo.Is_On_Leave ( @HR_Representative_id, CAST(CURRENT_TIMESTAMP AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))
-- if 0 search for the replacement_id from table employee replace employee
if @onleave =1 
begin
print (@onleave)

select @repl_id= emp2_id from Employee_Replace_Employee where Emp1_ID=@HR_Representative_id and CAST(CURRENT_TIMESTAMP AS DATE) between from_date and to_date
insert into Employee_Approve_Leave (Emp1_ID, leave_ID ) values (@repl_id,@req_id)--@repl_id
end
else 
insert into Employee_Approve_Leave (Emp1_ID, leave_ID ) values (@HR_Representative_id,@req_id)--@HR_Representative_id

--b) dean/vice-dean from role_name in employee_role table [needs approval from president too ]
-- insert ID of president 
if @role_name = 'Dean' or @role_name ='Vice Dean' 
begin 
select @president_id =emp_ID from Employee_Role where role_name ='President' 
 insert into Employee_Approve_Leave (Emp1_ID, leave_ID ) values (@president_id,@req_id)  --@president_id
end
--else not dean/vice/ hr representative , so need approval from dean/vice dean based on who is active
else
begin
-- search for emp_id of dean in the same department as the employee applying for this leave
select @dean_id=e.employee_id
from employee e join Employee_Role er on e.employee_id=er.emp_ID
where er.role_name ='Dean' and e.dept_name=@dept_name
-- check if dean is on a leave 
declare @dean_onleave bit =dbo.Is_On_Leave ( @dean_id, CAST(CURRENT_TIMESTAMP AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))
-- if yes
if @dean_onleave =1 
-- search for emp_id of vice dean in the same department as the employee applying for this leave
begin
select @Vicedean_id=e.employee_id
from employee e join Employee_Role er on e.employee_id=er.emp_ID
where er.role_name ='Vice Dean' and e.dept_name=@dept_name
insert into Employee_Approve_Leave (Emp1_ID, leave_ID ) values (@Vicedean_id,@req_id)-- @Vicedean_id --1
end 
else 
insert into Employee_Approve_Leave(Emp1_ID, leave_ID )  values (@dean_id,@req_id)-- @dean_id
end
GO


------------- 2.5 h --------------

go
CREATE or alter FUNCTION status_leaves
(@employee_ID int)
RETURNS TABLE
AS
RETURN (
SELECT L.request_ID,  L.date_of_request,L.final_approval_status
FROM Leave L 
left outer JOIN Annual_Leave An
ON  L.request_ID=An.request_ID 
where  An.emp_ID=@employee_ID	and MONTH(CURRENT_TIMESTAMP) = MONTH(L.date_of_request)
and YEAR(CURRENT_TIMESTAMP) = YEAR(L.date_of_request)

Union
SELECT L.request_ID,  L.date_of_request,L.final_approval_status
FROM Leave L 
left outer JOIN Accidental_Leave Ac
ON  L.request_ID=Ac.request_ID 
where  Ac.emp_ID=@employee_ID	and MONTH(CURRENT_TIMESTAMP) = MONTH(L.date_of_request)
and YEAR(CURRENT_TIMESTAMP) = YEAR(L.date_of_request))
GO


 ----------------------------------------
-- helper function 3----
GO
CREATE FUNCTION getCorrespondingHR
(@emp_id int)
RETURNS INT
AS
BEGIN

DECLARE @HR_ID int

SELECT @HR_ID= E2.employee_ID
FROM Employee E2
INNER JOIN Employee_Role ER
ON E2.employee_id = ER.emp_ID
INNER JOIN Employee E1
ON  ER.role_name like '%'+E1.dept_name+'%' 
WHERE E1.employee_id = @emp_id AND E2.dept_name like '%HR%' AND E1.employee_id <> E2.employee_id
AND ER.role_name like '%'+E1.dept_name+'%' 
AND  E1.employee_id=@emp_id --repeated??
--check if on leave get replacement 
--print @HR_ID
declare @on_leave_HR bit =
dbo.Is_On_Leave ( @HR_ID, 
CAST(CURRENT_TIMESTAMP AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))
--if on leave 
--print @on_leave_HR
if(@on_leave_HR = 1)
begin
declare @replacement_id int
select @replacement_id =  Emp2_ID  from Employee_Replace_Employee 
where CAST(CURRENT_TIMESTAMP AS DATE) between from_date and to_date
and Emp1_ID = @HR_ID

set @HR_ID = @replacement_id
end  

RETURN @HR_ID
END

------------------------------------------------------------
go
--helper 4 
---------
go
CREATE FUNCTION getCorrespondingHR_Manager()
RETURNS INT
AS
BEGIN
declare @HR_Manager_ID int
Select @HR_Manager_ID=emp_ID
from Employee_Role where role_name like '%HR%Manager%'

return @HR_Manager_ID
END
GO
---------------------------------------------------------------------------------------------------


--------------------------------------------------- 2.5 i
create or alter PROC Upperboard_approve_annual
@request_ID int,
@Upperboard_ID int, 
@replacement_ID int

AS
DECLARE @start_date date
DECLARE @end_date date
declare @contract varchar(50)
declare @empid int

SELECT @start_date=start_date, @end_date=end_date,@empid=al.emp_ID
FROM Leave l join Annual_Leave al on l.request_ID=al.request_ID
WHERE l.request_ID =@request_ID;

declare @current_status varchar(50)
SELECT @current_status = final_approval_status FROM Leave 
        WHERE request_ID = @request_ID;

        -- Check if leave is already processed
        IF @current_status <> 'Pending'
        BEGIN
            PRINT 'Error: Leave request has already been processed.';
            RETURN;
        END



SELECT @contract=type_of_contract  from Employee where employee_id=@empid
--handle if an employee is a part-timer
if @contract='part_time'
begin 
update Employee_Approve_Leave
set status='Rejected'
where leave_ID=@request_ID 
--update final status of Leave 
update leave
set final_approval_status='Rejected'
where request_ID=@request_ID 
return 
end

IF(dbo.Is_On_Leave(@replacement_ID, @start_date, @end_date) =0)
	BEGIN
		IF(--	works in the same department
			EXISTS(
			SELECT *
			FROM  Annual_Leave L
			INNER JOIN Employee E1
			ON E1.employee_id = L.emp_ID
			INNER JOIN Employee E2
			ON E2.dept_name = E1.dept_name			
			WHERE E2.employee_id = @replacement_ID AND L.request_ID=@request_ID and e1.employee_id <>e2.employee_id  --comment e1.employee_id <>e2.employee_id
			)
	)
	BEGIN
		UPDATE Employee_Approve_Leave
		SET status='Approved'
		where leave_ID=@request_ID and Emp1_ID=@Upperboard_ID 
		 
	return  -- instead of the missing else
	END
		--- else ????
	
	END
		UPDATE Employee_Approve_Leave
		SET status='Rejected'
		WHERE leave_ID=@request_ID		

		UPDATE Leave
		SET final_approval_status='Rejected'
		WHERE  request_ID=@request_ID


GO



----------------------------------------------------------------------------------------------
--2.5 J
create or ALTER PROC Submit_accidental
@employee_ID int,
@start_date date, 
@end_date date
AS
DECLARE @approval_emp_ID int

INSERT INTO Leave(date_of_request,start_date,end_date)
VALUES(CURRENT_TIMESTAMP, @start_date, @end_date)

DECLARE @req_id int
SELECT @req_id =SCOPE_IDENTITY();

INSERT INTO Accidental_Leave(request_ID,emp_ID)
VALUES(@req_id, @employee_ID)

--check if the person applying is HR_employee  or not
if(exists(select * from Employee E inner join Employee_Role ER ON E.employee_id=ER.emp_ID
where E.employee_id=@employee_ID and ER.role_name like '%HR%' ))
begin
SET @approval_emp_ID = dbo.getCorrespondingHR_Manager()

INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@approval_emp_ID, @req_id);


end 
else 
begin
-- get the HR employee for the same department

SET @approval_emp_ID = dbo.getCorrespondingHR(@employee_ID)

--they should be added to the approvals table
INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@approval_emp_ID, @req_id);
end
---------------------------------------------------------------
GO 




------------- 2.5 k --------------

CREATE or alter PROC Submit_medical
@employee_ID int,
@start_date date, 
@end_date date,
@medical_type varchar(50),
@insurance_status bit,
@disability_details varchar(50),
--@document_type varchar(50),
@document_description varchar(50),
@file_name varchar(50)
AS

INSERT INTO Leave(date_of_request,start_date,end_date)
VALUES(CURRENT_TIMESTAMP, @start_date, @end_date)

DECLARE @req_id int
SELECT @req_id =SCOPE_IDENTITY();

INSERT INTO Medical_Leave(request_ID,insurance_status, disability_details,type, Emp_ID)
VALUES(@req_id, @insurance_status, @disability_details, @medical_type ,@employee_ID)

INSERT INTO Document(type, description, file_name, creation_date,emp_ID,medical_ID)
VALUES('Medical', @document_description, @file_name, CURRENT_TIMESTAMP,@employee_ID,@req_id);

-- get the medical employee  ID 
DECLARE @approval_emp_ID1 int
--SET @approval_emp_ID1 = dbo.getCorrespondingMedical() (no helper function created)
select @approval_emp_ID1 = emp_ID from Employee_Role
where role_name = 'Medical Doctor'


--get the HR employee ID 
--in case employee is HR 
if(exists(select * from Employee E inner join Employee_Role ER ON E.employee_id=ER.emp_ID
where E.employee_id=@employee_ID and ER.role_name like '%HR%' ))
begin
DECLARE @approval_emp_ID int
SET @approval_emp_ID = dbo.getCorrespondingHR_Manager()

INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@approval_emp_ID, @req_id);

INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@approval_emp_ID1, @req_id);

end
--in case employee not HR
else
begin
DECLARE @approval_emp_ID2 int
SET @approval_emp_ID2 = dbo.getCorrespondingHR(@employee_ID)

--they should be added to the approvals table
INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@approval_emp_ID1, @req_id);

INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@approval_emp_ID2, @req_id);
end

GO

----helper
GO

CREATE FUNCTION getHigherRankEmployee
(@employee_id int)
returns int 
as
begin
declare @id int, @emp_role varchar(50), @employee_dept varchar(50),
@dean_id int, @vice_dean_id int,  @Dean_or_vice_id int 

select top 1 @emp_role = er.role_name from Employee_Role er
inner join Role r 
on er.role_name = r.role_name
where er.emp_ID = @employee_id 
order by r.rank asc
--print @emp_role

--get id of Dean/Vice dean (who is available)  if employee is not dean/vice dean 

if(@emp_role = 'Lecturer' or @emp_role = 'Teaching Assistant')
begin 
--first get dept of employee
select @employee_dept = dept_name from Employee
where employee_id = @employee_ID

--get id of dean first and check if on leave if yes get id of vice if not use his id
select @dean_id = employee_id from Employee e
inner join Employee_Role er
on e.employee_id = er.emp_ID
where er.role_name = 'Dean' and e.dept_name = @employee_dept

--check if on leave today
declare @onleave bit =
dbo.Is_On_Leave ( @dean_id, 
CAST(CURRENT_TIMESTAMP AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))
--if on leave 
if(@onleave = 1)
begin
select @vice_dean_id = employee_id from Employee e
inner join Employee_Role er
on e.employee_id = er.emp_ID
where er.role_name = 'Vice Dean' and e.dept_name = @employee_dept

set @Dean_or_vice_id = @vice_dean_id
end
else
begin 
set @Dean_or_vice_id = @dean_id
end 

set @id = @Dean_or_vice_id
end
return @id 
end
GO



------------- 2.5 l --------------
GO
CREATE or alter PROC Submit_unpaid
@employee_ID int,
@start_date date, 
@end_date date,
@document_description varchar(50),
@file_name varchar(50)
AS

INSERT INTO Leave(date_of_request,start_date,end_date)
VALUES(CURRENT_TIMESTAMP, @start_date, @end_date)

DECLARE @req_id int
SELECT @req_id =SCOPE_IDENTITY();

INSERT INTO Unpaid_Leave(request_ID, Emp_ID)
VALUES(@req_id, @employee_ID)

INSERT INTO Document(type, description, file_name, creation_date, emp_ID,unpaid_ID)
VALUES('Memo', @document_description, @file_name, CURRENT_TIMESTAMP,@employee_ID,@req_id);

-- get the higher rank employee  ID 
DECLARE @approval_emp_ID int
SET @approval_emp_ID = dbo.getHigherRankEmployee(@employee_ID)
IF(@approval_emp_ID IS NOT NULL)
	--they should be added to the approvals table
	INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
	VALUES(@approval_emp_ID, @req_id);

-- get the upperboard  employee  ID (vice president or president)
--insert predient id directly we do not need to check if president is on leave or not 
--(we do not handle their leaves)
declare @president_id int 
select @president_id = emp_ID from Employee_Role
where role_name = 'President'

INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@president_id, @req_id);



-- get the HR representative employee  ID 
--in case employee is HR 
if(exists(select * from Employee E inner join Employee_Role ER ON E.employee_id=ER.emp_ID
where E.employee_id=@employee_ID and ER.role_name like '%HR%' ))
begin
DECLARE @HR_Manager int
SET @HR_Manager = dbo.getCorrespondingHR_Manager()

INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
VALUES(@HR_Manager, @req_id);

end
--in case employee not HR
else 
begin
DECLARE @hr_emp_ID int
SET @hr_emp_ID = dbo.getCorrespondingHR(@employee_ID)
IF(@hr_emp_ID IS NOT NULL)
	--they should be added to the approvals table
	INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
	VALUES(@hr_emp_ID, @req_id);
end
GO


------------- 2.5 m --------------

CREATE or alter PROC Upperboard_approve_unpaids
@request_ID int,
@upperboard_ID int
AS
------ to check if the employee who submitted the leave is the dean and if so check if
--vice dean is on leave or not if yes reject the dean's request 
--same applies if vice dean is the one who requested the leave

declare @current_status varchar(50)
SELECT @current_status = final_approval_status FROM Leave 
        WHERE request_ID = @request_ID;

        -- Check if leave is already processed
        IF @current_status <> 'Pending'
        BEGIN
            PRINT 'Error: Leave request has already been processed.';
            RETURN;
        END


declare @employee_id int 
select @employee_id =  e.employee_id  from Employee e
inner join Unpaid_Leave un
on un.Emp_ID = e.employee_id
where un.request_ID = @request_ID

declare @dean_vice_dean_on_leave bit 
set @dean_vice_dean_on_leave = 0
declare @role varchar(50)

select top 1 @role = er.role_name from Employee_Role er
inner join Role r 
on er.role_name = r.role_name
where er.emp_ID = @employee_id 
order by r.rank asc


print @role
if (@role = 'Dean' or @role = 'Vice Dean' )
begin
declare @start date, @end date 
select @start= start_date,@end = end_date from Leave 
where request_ID = @request_ID

declare @employee_dept varchar(50) 

select @employee_dept = dept_name from Employee
where employee_id = @employee_ID

declare @vice_dean_id int , @dean_id int

if(@role = 'dean')
begin
print 'entered'
select @vice_dean_id = employee_id from Employee e
inner join Employee_Role er
on e.employee_id = er.emp_ID
where er.role_name = 'Vice Dean' and e.dept_name = @employee_dept
print @vice_dean_id
---check if the other is on leave 
declare @is_on_leave bit 
set @is_on_leave = dbo.Is_On_Leave(@vice_dean_id,@start,@end)
print @is_on_leave
if(dbo.Is_On_Leave(@vice_dean_id,@start,@end)=1)
set @dean_vice_dean_on_leave = 1
else
set @dean_vice_dean_on_leave = 0
end
else if (@role = 'Vice dean')
begin
select @dean_id = employee_id from Employee e
inner join Employee_Role er
on e.employee_id = er.emp_ID
where er.role_name = 'Dean' and e.dept_name = @employee_dept

if(dbo.Is_On_Leave(@dean_id,@start,@end)=1)
set @dean_vice_dean_on_leave = 1
else
set @dean_vice_dean_on_leave = 0
end
end 
print @dean_vice_dean_on_leave
if (EXISTS(
	SELECT *
	FROM Document
	WHERE unpaid_ID=@request_ID AND type='Memo'
	) and 
	not exists(select * from Unpaid_Leave U inner join Employee E on U.Emp_ID=E.employee_id
	where E.type_of_contract='Part_time' and u.request_ID = @request_ID ) and (@dean_vice_dean_on_leave <>1))
	UPDATE Employee_Approve_Leave
	SET status = 'Approved'
	WHERE leave_id = @request_ID and Emp1_ID= @upperboard_ID
    else
	begin
	UPDATE Employee_Approve_Leave
	SET status = 'Rejected'
	WHERE leave_id = @request_ID
	update leave 
    set final_approval_status = 'rejected'
    where request_ID = @request_ID
	end
GO



------------------------------------------------------2.5 n ----------------------------------- 
create or alter PROC Submit_compensation
@employee_ID int, 
@compensation_date date,
@reason varchar(50), 
@date_of_original_workday date,
@rep_emp_id int
AS
DECLARE @dept_name varchar(50)
INSERT INTO Leave(date_of_request, start_date, end_date)
VALUES(CURRENT_TIMESTAMP, @compensation_date, @compensation_date);

DECLARE @req_id int
SELECT @req_id =SCOPE_IDENTITY();

INSERT INTO Compensation_Leave(request_ID, reason, date_of_original_workday, emp_ID, replacement_emp)
VALUES(@req_id, @reason, @date_of_original_workday, @employee_ID, @rep_emp_id);
------------------------------------------------- CHANGES--------------------------------
-- check if the employee works in the HR department, then we should submitted the leave to the manager 
select @dept_name=dept_name from Employee where @employee_ID=employee_id
--case 1 HR submits to HR manager
if @dept_name = 'HR' 
begin
DECLARE @mang_id INT
select @mang_id=emp_ID from Employee_Role where role_name='HR Manager'
insert into Employee_Approve_Leave (Emp1_ID, leave_ID ) values (@mang_id,@req_id)  return  --@mang_id
end

--------------------------------------------------------------------------------------------------------
-- get the HR representative employee  ID 
DECLARE @hr_emp_ID int
SET @hr_emp_ID = dbo.getCorrespondingHR(@employee_ID)
IF(@hr_emp_ID IS NOT NULL)
	--they should be added to the approvals table
	INSERT INTO Employee_Approve_Leave(Emp1_ID, leave_ID)
	VALUES(@hr_emp_ID, @req_id);

--------------------------------------------------------------------------------------------------
GO

--i) Verify whether the employee will be on leave 

create or alter function Is_On_Leave ( @employee_ID int, @from date, @to date)
returns bit 
as
begin 
if exists (select 1
from leave l full join Annual_Leave  al on l.request_ID=al.request_ID
full join Accidental_Leave acc on acc.request_ID=l.request_ID
full join Medical_Leave ml on ml.request_ID=l.request_ID
full join Unpaid_Leave ul on l.request_ID=ul.request_ID
full join Compensation_Leave cl on l.request_ID=cl.request_ID
WHERE ((@from <=l.start_date and @to>=l.end_date) or (@from <=l.start_date and @to  between l.start_date and l.end_date) or (@to >=l.end_date and @from 
between l.start_date and l.end_date )OR (@from between l.start_date and l.end_date) or  (@to between l.start_date and l.end_date))
and l.final_approval_status in ('Approved','Pending')
and @employee_ID in (al.emp_ID, ml.Emp_ID,acc.emp_ID,cl.emp_ID,ul.Emp_ID)

) return 1 
return 0
end

GO 





---2.5 o ----------------
go
CREATE or alter PROC Dean_andHR_Evaluation
@employee_ID int,
@rating int, 
@comment varchar(50),
@semester char(3)
AS
	INSERT INTO Performance (rating, comments,emp_ID, semester)
	VALUES(@rating, @comment, @employee_ID, @semester)



GO
