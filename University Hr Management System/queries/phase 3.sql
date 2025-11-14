USE University_HR_ManagementSystem_5;
GO

CREATE PROCEDURE Update_Employment_Status
    @employee_ID INT
AS
BEGIN
    DECLARE @today date = CAST(GETDATE() AS DATE);
    DECLARE @is_on_leave BIT = 0;
    DEclARE @current_status VARCHAR(50);
    
   
    select @is_on_leave = Is_On_Leave(@Employee_ID, @today, @today); 
    

    if (@is_on_leave = 1)
    begin
        UPDATE Employee
        SET employment_status = 'inactive'
        WHERE employee_ID = @Employee_ID;
    end

    ELSE 
        BEGIN
         UPDATE Employee
         SET employment_status = 'active'
         WHERE employee_ID = @Employee_ID;
    END
END;
GO

CREATE PROCEDURE Update_Status_Doc
AS
BEGIN
    UPDATE Document
    SET status = 'expired'
    WHERE expiry_date < CAST(GETDATE() AS DATE)
      AND status <> 'expired';
END;
GO

CREATE PROCEDURE Add_Holiday
    @holiday_name VARCHAR(50),
    @from_date DATE,
    @to_date DATE
AS
BEGIN
    INSERT INTO Holiday(name, from_date, to_date)
    VALUES (@holiday_name, @from_date, @to_date);
END;
GO



CREATE PROCEDURE Initiate_Attendance
AS
BEGIN
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    INSERT INTO Attendance (attendance_date, status, emp_ID)
    SELECT @Today,
        'Absent',
        e.employee_ID
        FROM Employee e
        WHERE e.lastworking is not null
END;
GO


CREATE PROCEDURE Remove_Holiday
AS
BEGIN
    DELETE A
    FROM Attendance A
    JOIN Holiday H
        ON A.date BETWEEN H.from_date AND H.to_date;
END;
GO


CREATE PROCEDURE Update_Attendance
    @emp_ID INT,
    @check_in_time time,
    @check_out_time time
    AS
BEGIN
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    UPDATE Attendance
    SET check_in_time = @check_in_time,
        check_out_time = @check_out_time,
        attendance_date = @Today, 
        status = CASE 
                WHEN  DATEDIFF(MINUTE, @check_in_time, @check_out_time) / 60.0 >= 8 
                THEN 'Attended'
                ELSE 'Absent'
                END 
     WHERE emp_ID = @emp_ID
       
END;
go


CREATE PROCEDURE Remove_DayOff
    @employee_ID INT
AS
BEGIN
    DECLARE  @Day_Off VARCHAR(55);

    SELECT @Day_Off = day_off
    from Employee
    WHERE employee_ID = @employee_ID;

    DELETE A
    from Attendance A
    WHERE DATENAME(WEEKDAY, A.date) = @Day_Off
      AND A.emp_ID = @employee_ID;
END 
go


CREATE PROCEDURE Replace_employee
    @Emp1_ID INT,
    @Emp2_ID INT,
    @from_date DATE,
    @to_date DATE
AS
BEGIN
    INSERT INTO Employee_Replace_Employee(Emp1_ID, Emp2_ID, from_date, to_date)
    VALUES(@Emp1_ID, @Emp2_ID, @from_date, @to_date);
END;
GO
    