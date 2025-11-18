CREATE PROCEDURE Submit_annual
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID) RETURN;
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @replacement_emp) RETURN;
    IF @employee_ID = @replacement_emp RETURN;

    IF EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time') RETURN;

    INSERT INTO [Leave](date_of_request, start_date, end_date, final_approval_status)
    VALUES (GETDATE(), @start_date, @end_date, 'pending');

    DECLARE @request_ID INT = SCOPE_IDENTITY();

    INSERT INTO Annual_Leave(request_ID, emp_ID, replacement_emp)
    VALUES (@request_ID, @employee_ID, @replacement_emp);

    DECLARE @role VARCHAR(50), @dept VARCHAR(50), @approver INT;
    
    SELECT @dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;

    SELECT TOP 1 @role = r.role_name
    FROM Employee_Role er
    JOIN Role r ON er.role_name = r.role_name
    WHERE er.emp_ID = @employee_ID
    ORDER BY r.rank ASC; 

    IF @role IS NULL RETURN; 

    IF @role IN ('Dean','Vice Dean') 
    BEGIN
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'President');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');

        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NULL
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
    END
    ELSE
    BEGIN
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = @dept AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'Dean');
        IF @approver IS NULL
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = @dept AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'Vice Dean');

        IF @approver IS NOT NULL AND dbo.Is_On_Leave(@approver, @start_date, @end_date) = 1
        BEGIN
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = @dept AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'Vice Dean');
        END

        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');

        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NULL
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
    END
END;
GO


CREATE PROCEDURE Submit_accidental
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID) RETURN;

    INSERT INTO [Leave](date_of_request, start_date, end_date, final_approval_status)
    VALUES (GETDATE(), @start_date, @start_date, 'pending');

    DECLARE @request_ID INT = SCOPE_IDENTITY();

    INSERT INTO Accidental_Leave(request_ID, emp_ID)
    VALUES (@request_ID, @employee_ID);

    DECLARE @approver INT;
    SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
    IF @approver IS NULL
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');

    IF @approver IS NOT NULL
        INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
END;
GO


CREATE PROCEDURE Submit_medical
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type VARCHAR(50),
    @insurance_status BIT,
    @disability_details VARCHAR(50),
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID) RETURN;

    IF LOWER(@type) = 'maternity'
    BEGIN
        IF EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time') RETURN;
    END

    INSERT INTO [Leave](date_of_request, start_date, end_date, final_approval_status)
    VALUES (GETDATE(), @start_date, @end_date, 'pending');

    DECLARE @request_ID INT = SCOPE_IDENTITY();

    INSERT INTO Medical_Leave(request_ID, insurance_status, disability_details, type, Emp_ID)
    VALUES (@request_ID, @insurance_status, @disability_details, @type, @employee_ID);

    IF @document_description IS NOT NULL OR @file_name IS NOT NULL
    BEGIN
        INSERT INTO Document([type], description, file_name, creation_date, expiry_date, status, emp_ID, medical_ID, unpaid_ID)
        VALUES ('medical', @document_description, @file_name, GETDATE(), NULL, 'valid', @employee_ID, @request_ID, NULL);
    END

    DECLARE @approver INT;
    SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
    IF @approver IS NULL
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');

    IF @approver IS NOT NULL
        INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
END;
GO


CREATE PROCEDURE Submit_unpaid
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID) RETURN;

    IF EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time') RETURN;

    IF DATEDIFF(day, @start_date, @end_date) + 1 > 30 RETURN;

    IF EXISTS (
        SELECT 1
        FROM Unpaid_Leave u JOIN [Leave] l ON u.request_ID = l.request_ID
        WHERE u.Emp_ID = @employee_ID AND l.final_approval_status = 'approved'
          AND YEAR(l.start_date) = YEAR(@start_date)
    ) RETURN;

    INSERT INTO [Leave](date_of_request, start_date, end_date, final_approval_status)
    VALUES (GETDATE(), @start_date, @end_date, 'pending');

    DECLARE @request_ID INT = SCOPE_IDENTITY();

    INSERT INTO Unpaid_Leave(request_ID, Emp_ID) VALUES(@request_ID, @employee_ID);

    INSERT INTO Document([type], description, file_name, creation_date, expiry_date, status, emp_ID, medical_ID, unpaid_ID)
    VALUES ('memo', @document_description, @file_name, GETDATE(), NULL, 'valid', @employee_ID, NULL, @request_ID);

    DECLARE @role VARCHAR(50), @dept VARCHAR(50), @approver INT;
    
    SELECT @dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;

    SELECT TOP 1 @role = r.role_name
    FROM Employee_Role er
    JOIN Role r ON er.role_name = r.role_name
    WHERE er.emp_ID = @employee_ID
    ORDER BY r.rank ASC;

    IF @role IS NULL RETURN;

    IF @role IN ('Dean','Vice Dean')
    BEGIN
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'President');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');

        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NULL
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
    END
    ELSE IF @role LIKE 'HR%' 
    BEGIN
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'President');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');

        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Manager');
        IF @approver IS NULL
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Manager');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
    END
    ELSE
    BEGIN
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = @dept AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'Dean');
        IF @approver IS NULL
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = @dept AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'Vice Dean');

        IF @approver IS NOT NULL AND dbo.Is_On_Leave(@approver, @start_date, @end_date) = 1
        BEGIN
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = @dept AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'Vice Dean');
        END

        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');

        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NULL
            SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
        IF @approver IS NOT NULL
            INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
    END
END;
GO


CREATE PROCEDURE Submit_compensation
    @employee_ID INT,
    @compensation_date DATE,
    @reason VARCHAR(50),
    @date_of_original_workday DATE,
    @replacement_emp INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID) RETURN;

    IF @reason IS NULL OR LTRIM(RTRIM(@reason)) = '' RETURN;

    IF MONTH(@compensation_date) <> MONTH(@date_of_original_workday) OR YEAR(@compensation_date) <> YEAR(@date_of_original_workday) RETURN;

    IF NOT EXISTS (
        SELECT 1 FROM Attendance
        WHERE emp_ID = @employee_ID
          AND [date] = @date_of_original_workday
          AND total_duration >= 480 
    ) RETURN;

    IF @replacement_emp IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @replacement_emp) RETURN;

    INSERT INTO [Leave](date_of_request, start_date, end_date, final_approval_status)
    VALUES (GETDATE(), @compensation_date, @compensation_date, 'pending');

    DECLARE @request_ID INT = SCOPE_IDENTITY();

    INSERT INTO Compensation_Leave(request_ID, reason, date_of_original_workday, emp_ID, replacement_emp)
    VALUES (@request_ID, @reason, @date_of_original_workday, @employee_ID, @replacement_emp);

    DECLARE @approver INT;
    SELECT TOP 1 @approver = employee_ID FROM Employee WHERE dept_name = 'HR' AND employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
    IF @approver IS NULL
        SELECT TOP 1 @approver = employee_ID FROM Employee WHERE employee_ID IN (SELECT emp_ID FROM Employee_Role WHERE role_name = 'HR Representative');
    IF @approver IS NOT NULL
        INSERT INTO Employee_Approve_Leave(Emp1_ID, Leave_ID, status) VALUES(@approver, @request_ID, 'pending');
END;
GO


CREATE PROCEDURE Upperboard_approve_annual
    @request_ID INT,
    @Upperboard_ID INT,
    @replacement_ID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [Leave] WHERE request_ID = @request_ID AND final_approval_status = 'pending') RETURN;
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @Upperboard_ID) RETURN;
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @replacement_ID) RETURN;

    IF NOT EXISTS (SELECT 1 FROM Employee_Approve_Leave WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID AND status = 'pending') RETURN;

    DECLARE @start DATE = (SELECT start_date FROM [Leave] WHERE request_ID = @request_ID);
    DECLARE @end DATE   = (SELECT end_date FROM [Leave] WHERE request_ID = @request_ID);
    DECLARE @emp_ID INT = (SELECT emp_ID FROM Annual_Leave WHERE request_ID = @request_ID);
    
    DECLARE @ok BIT = 1;
    DECLARE @ApprovalStatus VARCHAR(50) = 'approved';

    IF NOT EXISTS (
        SELECT 1 FROM Employee e1 JOIN Employee e2 ON e1.dept_name = e2.dept_name
        WHERE e1.employee_ID = @emp_ID AND e2.employee_ID = @replacement_ID
    )
    BEGIN
        SET @ok = 0;
    END

    IF dbo.Is_On_Leave(@replacement_ID, @start, @end) = 1
    BEGIN
        SET @ok = 0;
    END

    IF @ok = 0
    BEGIN
        SET @ApprovalStatus = 'rejected';
    END

    UPDATE Employee_Approve_Leave 
    SET status = @ApprovalStatus 
    WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID;

    
    IF EXISTS (SELECT 1 FROM Employee_Approve_Leave WHERE Leave_ID = @request_ID AND status = 'rejected')
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Employee_Approve_Leave WHERE Leave_ID = @request_ID AND status = 'pending')
    BEGIN
        RETURN;
    END

    UPDATE [Leave] SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
END;
GO


CREATE PROCEDURE Upperboard_approve_unpaids
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Unpaid_Leave WHERE request_ID = @request_ID) RETURN;
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @Upperboard_ID) RETURN;
    IF NOT EXISTS (SELECT 1 FROM [Leave] WHERE request_ID = @request_ID AND final_approval_status = 'pending') RETURN;

    IF NOT EXISTS (SELECT 1 FROM Employee_Approve_Leave WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID AND status = 'pending') RETURN;

    DECLARE @ApprovalStatus VARCHAR(50) = 'approved';

    IF NOT EXISTS (
        SELECT 1 FROM Document
        WHERE unpaid_ID = @request_ID
          AND description IS NOT NULL
          AND LTRIM(RTRIM(description)) <> ''
    )
    BEGIN
        SET @ApprovalStatus = 'rejected';
    END

    UPDATE Employee_Approve_Leave 
    SET status = @ApprovalStatus 
    WHERE Leave_ID = @request_ID AND Emp1_ID = @Upperboard_ID;

    IF EXISTS (SELECT 1 FROM Employee_Approve_Leave WHERE Leave_ID = @request_ID AND status = 'rejected')
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Employee_Approve_Leave WHERE Leave_ID = @request_ID AND status = 'pending') RETURN;

    UPDATE [Leave] SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
END;
GO


CREATE PROCEDURE Dean_andHR_Evaluation
    @employee_ID INT,
    @rating INT,
    @comment VARCHAR(50),
    @semester CHAR(3)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID) RETURN;
    
    IF @rating < 1 OR @rating > 5 RETURN;

    INSERT INTO Performance(rating, comments, semester, emp_ID)
    VALUES (@rating, @comment, @semester, @employee_ID);
END;
GO