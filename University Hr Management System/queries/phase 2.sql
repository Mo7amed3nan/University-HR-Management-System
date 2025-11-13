USE University_HR_ManagementSystem_5;
GO

CREATE PROCEDURE Create_Holiday
AS
BEGIN
CREATE TABLE Holiday (
        Holiday_id INT PRIMARY KEY IDENTITY(1,1),
        name varchar(50),
        from_date DATE,
        to_date DATE,
    );
END;
GO

CREATE FUNCTION Is_On_Leave (
    @employee_ID INT,
    @from_date DATE,
    @to_date DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @on_leave BIT = 0;

    -- Check for any overlapping leave
    IF EXISTS (
        SELECT *
        FROM Leave L
        -- We must join with all leave types to find the emp_ID
        LEFT JOIN Annual_Leave AL ON L.request_ID = AL.request_ID
        LEFT JOIN Accidental_Leave ACL ON L.request_ID = ACL.request_ID
        LEFT JOIN Medical_Leave ML ON L.request_ID = ML.request_ID
        LEFT JOIN Unpaid_Leave UL ON L.request_ID = UL.request_ID
        LEFT JOIN Compensation_Leave CL ON L.request_ID = CL.request_ID
        
        WHERE 
            -- Find the correct employee
            (
                AL.emp_ID = @employee_ID OR
                ACL.emp_ID = @employee_ID OR
                ML.Emp_ID = @employee_ID OR
                UL.Emp_ID = @employee_ID OR
                CL.emp_ID = @employee_ID
            )
            -- Check the approval status (CRITICAL CONSTRAINT)
            AND (L.final_approval_status = 'approved' OR L.final_approval_status = 'pending')
            
            -- This is the overlap logic:
            AND (L.start_date <= @to AND L.end_date >= @from)
    )
    BEGIN
        SET @on_leave = 1;
    END;

    RETURN @on_leave;
END;
GO


CREATE FUNCTION Bonus_amount (
    @employee_ID INT,
    @from_date DATE,
    @to_date DATE
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @employee_salary DECIMAL(10, 2);
    DECLARE @rate_per_hour DECIMAL(10, 4);
    DECLARE @overtime_factor DECIMAL(4, 2);
    DECLARE @total_extra_hours INT; -- Total extra hours are summed
    DECLARE @bonus_amount DECIMAL(10, 2) = 0;

    -- === 2. GET EMPLOYEE SALARY ===
    SELECT @employee_salary = salary
    FROM Employee
    WHERE employee_ID = @employee_ID;

    -- If no salary, no bonus.
    IF @employee_salary IS NULL OR @employee_salary = 0
        RETURN 0;

    -- === 3. CALCULATE RATE PER HOUR  ===
    -- Rate per hour = (employee_salary / 22 days) / 8 hours
    SET @rate_per_hour = (@employee_salary / 22.0) / 8.0;

    -- === 4. GET OVERTIME FACTOR (HANDLING HIGHER RANK) ===
    -- "If an employee has more than one role, the overtime factor...
    --  of the higher rank will be used." [cite: 183]
    -- (Assuming Rank 1 is "higher" than Rank 5) [cite: 214]
    
    SELECT TOP 1 @overtime_factor = R.percentage_overtime
    FROM Employee_Role ER
    JOIN Role R ON ER.role_name = R.role_name
    WHERE ER.emp_ID = @employee_ID
    ORDER BY R.rank ASC; -- Get the percentage from the "highest" rank (lowest number)

    -- If no overtime factor, no bonus.
    IF @overtime_factor IS NULL OR @overtime_factor = 0
        RETURN 0;

    -- === 5. CALCULATE TOTAL EXTRA HOURS ===
    -- We must sum all hours worked *above* 8 for each 'attended' day.
    
    SELECT @total_extra_hours = ISNULL(SUM(
        CASE
            WHEN DATEDIFF(HOUR, check_in_time, check_out_time) > 8
            -- Only sum the "extra" part
            THEN DATEDIFF(HOUR, check_in_time, check_out_time) - 8
            ELSE 0
        END
    ), 0) -- ISNULL to return 0 if no records are found, not NULL
    FROM Attendance att
    WHERE emp_ID = @employee_ID
      AND att.date BETWEEN @from_date AND @to_date
      AND att.status = 'attended'; -- Only count "attended" days [cite: 173]


    -- If no extra hours, no bonus.
    IF @total_extra_hours = 0
        RETURN 0;

    -- === 6. CALCULATE FINAL BONUS AMOUNT  ===
    -- Overtime amount = rate per hour * ([overtime factor * extra hours] / 100)
    
    SET @bonus_amount = @rate_per_hour * ((@overtime_factor * @total_extra_hours) / 100.0);

    -- === 7. RETURN FINAL VALUE ===
    RETURN @bonus_amount;

END;
GO

CREATE FUNCTION HRLogin_Validation (
    @employee_ID INT,
    @password VARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @success BIT = 0;

    -- Check if the employee exists with the correct password AND is an HR employee
    IF EXISTS (
        SELECT *
        FROM Employee E
        -- Join with Employee_Role and Role if you want to be strictly role-based
        -- However, checking the department is often sufficient based on the schema guidelines
        WHERE E.employee_ID = @employee_ID 
          AND E.password = @password
          AND E.dept_name = 'HR Department' -- Checks if they belong to HR Dept
    )
    BEGIN
        SET @success = 1;
    END

    RETURN @success;
END;
GO

CREATE FUNCTION EmployeeLogin_Validation (
    @employee_ID INT,
    @password VARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @success BIT = 0;

    -- Simple check for credentials
    IF EXISTS (
        SELECT *
        FROM Employee
        WHERE employee_ID = @employee_ID 
          AND password = @password
    )
    BEGIN
        SET @success = 1;
    END

    RETURN @success;
END;
GO

