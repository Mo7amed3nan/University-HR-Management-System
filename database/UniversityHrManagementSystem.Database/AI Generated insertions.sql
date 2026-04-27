USE University_HR_ManagementSystem_5;
GO

-- 1. CLEANUP
EXEC clearAllTables;
GO

-- RESET IDENTITY COUNTERS
DBCC CHECKIDENT ('Employee', RESEED, 0);
DBCC CHECKIDENT ('Leave', RESEED, 0);
DBCC CHECKIDENT ('Attendance', RESEED, 0);
DBCC CHECKIDENT ('Deduction', RESEED, 0);
DBCC CHECKIDENT ('Performance', RESEED, 0);
DBCC CHECKIDENT ('Payroll', RESEED, 0);
DBCC CHECKIDENT ('Document', RESEED, 0);
-- Handle Holiday table if it exists
IF OBJECT_ID('Holiday', 'U') IS NOT NULL 
   DBCC CHECKIDENT ('Holiday', RESEED, 0);
GO

-- 2. DEPARTMENTS
INSERT INTO Department (name, building_location) VALUES 
('Upper Board', 'Admin Bldg'), ('HR', 'Bldg A'), ('Medical', 'Clinic'),
('MET', 'Bldg C'), ('IET', 'Bldg C'), ('Architecture', 'Bldg D'), ('BI', 'Bldg B');

-- 3. ROLES
INSERT INTO Role (role_name, title, description, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance) VALUES
('President', 'President', 'Top', 1, 90000, 20, 25, 30, 7),
('Dean', 'Dean', 'Head', 3, 50000, 10, 15, 30, 7),
('HR Manager', 'Manager', 'HR Head', 3, 45000, 10, 15, 30, 7),
('Vice Dean', 'Vice Dean', 'Assistant', 4, 35000, 10, 15, 25, 7),
('Lecturer', 'Dr.', 'Prof', 5, 25000, 5, 10, 21, 7),
('Teaching Assistant', 'TA', 'Junior', 6, 10000, 2, 10, 15, 5),
('Medical Doctor', 'Dr.', 'Clinic', 6, 18000, 5, 10, 21, 7);

-- 4. EMPLOYEES (Using Explicit Columns to avoid Computed Column Error)
-- We insert 15 diverse employees
INSERT INTO Employee (first_name, last_name, email, password, address, gender, official_day_off, years_of_experience, national_ID, employment_status, type_of_contract, annual_balance, accidental_balance, hire_date, dept_name) VALUES
('Ziad', 'Admin', 'ziad@guc.edu.eg', '123', 'Cairo', 'M', 'Friday', 20, '1000000000000001', 'active', 'full_time', 30, 7, '2010-01-01', 'Upper Board'),
('Sarah', 'Resigned', 'sarah@guc.edu.eg', '123', 'Giza', 'F', 'Saturday', 5, '1000000000000002', 'resigned', 'full_time', 0, 0, '2018-01-01', 'MET'),
('Ahmed', 'Sick', 'ahmed@guc.edu.eg', '123', 'Cairo', 'M', 'Sunday', 3, '1000000000000003', 'active', 'full_time', 21, 5, '2020-01-01', 'IET'),
('Mona', 'Vacation', 'mona@guc.edu.eg', '123', 'Alex', 'F', 'Thursday', 8, '1000000000000004', 'onleave', 'full_time', 10, 2, '2015-01-01', 'MET'),
('Kareem', 'DayOff', 'kareem@guc.edu.eg', '123', 'Cairo', 'M', DATENAME(WEEKDAY, GETDATE()), 4, '1000000000000005', 'active', 'full_time', 15, 5, '2019-01-01', 'Architecture'),
('Hassan', 'Dean', 'h@g.com', '123', 'C', 'M', 'Friday', 10, '111', 'active', 'full_time', 30, 7, '2010-01-01', 'MET'),
('Rania', 'Lecturer', 'r@g.com', '123', 'C', 'F', 'Saturday', 5, '222', 'active', 'full_time', 21, 5, '2015-01-01', 'MET'),
('Ali', 'TA', 'a@g.com', '123', 'C', 'M', 'Sunday', 2, '333', 'active', 'full_time', 15, 3, '2022-01-01', 'MET'),
('Salma', 'HR', 's@g.com', '123', 'C', 'F', 'Monday', 4, '444', 'active', 'full_time', 21, 5, '2018-01-01', 'HR'),
('Khaled', 'Doc', 'k@g.com', '123', 'C', 'M', 'Tuesday', 10, '555', 'active', 'full_time', 30, 7, '2012-01-01', 'Medical'),
('Yara', 'Arch', 'y@g.com', '123', 'C', 'F', 'Wednesday', 6, '666', 'active', 'full_time', 21, 5, '2017-01-01', 'Architecture'),
('Omar', 'BI', 'o@g.com', '123', 'C', 'M', 'Thursday', 3, '777', 'active', 'full_time', 15, 3, '2021-01-01', 'BI'),
('Lina', 'IET', 'l@g.com', '123', 'C', 'F', 'Friday', 2, '888', 'active', 'full_time', 15, 3, '2023-01-01', 'IET'),
('Tarek', 'Pres', 't@g.com', '123', 'C', 'M', 'Saturday', 20, '999', 'active', 'full_time', 30, 7, '2005-01-01', 'Upper Board'),
('Noha', 'VP', 'n@g.com', '123', 'C', 'F', 'Sunday', 15, '000', 'active', 'full_time', 30, 7, '2008-01-01', 'Upper Board');

-- 5. ASSIGN ROLES
INSERT INTO Employee_Role (emp_ID, role_name) VALUES
(1, 'President'), (2, 'Teaching Assistant'), (3, 'Lecturer'), (4, 'Lecturer'), (5, 'Teaching Assistant'),
(6, 'Dean'), (7, 'Lecturer'), (8, 'Teaching Assistant'), (9, 'HR Manager'), (10, 'Medical Doctor'),
(11, 'Lecturer'), (12, 'Teaching Assistant'), (13, 'Teaching Assistant'), (14, 'President'), (15, 'Vice Dean');

INSERT INTO Role_existsIn_Department VALUES ('MET', 'Dean'), ('MET', 'Lecturer'), ('MET', 'Teaching Assistant');

-- 6. ATTENDANCE (For Dashboard Charts)
-- Yesterday
DECLARE @Yest DATE = CAST(DATEADD(day, -1, GETDATE()) AS DATE);
INSERT INTO Attendance ([date], check_in_time, check_out_time, status, emp_ID) VALUES
(@Yest, '09:00', '17:00', 'Attended', 1),
(@Yest, '08:30', '16:30', 'Attended', 3),
(@Yest, NULL, NULL, 'Absent', 6);

-- Today
DECLARE @Today DATE = CAST(GETDATE() AS DATE);
INSERT INTO Attendance ([date], check_in_time, check_out_time, status, emp_ID) VALUES
(@Today, '08:00', NULL, 'Absent', 1), -- Checked in, not out
(@Today, NULL, NULL, 'Absent', 5);    -- Day Off

-- 7. LEAVES
-- Rejected Medical (ID 3)
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) 
VALUES (DATEADD(day, -5, GETDATE()), DATEADD(day, -2, GETDATE()), DATEADD(day, -1, GETDATE()), 'Rejected');
INSERT INTO Medical_Leave (request_ID, insurance_status, disability_details, type, Emp_ID)
VALUES (SCOPE_IDENTITY(), 1, 'Severe Flu', 'sick', 3);

-- Approved Annual (ID 4)
INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) 
VALUES (DATEADD(day, -10, GETDATE()), DATEADD(day, -1, GETDATE()), DATEADD(day, 1, GETDATE()), 'Approved');
INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp) 
VALUES (SCOPE_IDENTITY(), 4, 6);

-- 8. PERFORMANCE (Winter)
INSERT INTO Performance (rating, comments, semester, emp_ID) VALUES
(5, 'Excellent', 'W24', 1),
(4, 'Good job', 'W24', 2),
(2, 'Poor attendance', 'S24', 3);

-- 9. DEDUCTIONS (Resigned Employee 2)
INSERT INTO Deduction (emp_ID, [date], amount, type, status) 
VALUES (2, DATEADD(day, -20, GETDATE()), 500, 'missing_days', 'pending');

GO