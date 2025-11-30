using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class Employee
{
    public int EmployeeId { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? Email { get; set; }

    public string? Password { get; set; }

    public string? Address { get; set; }

    public string? Gender { get; set; }

    public string? OfficialDayOff { get; set; }

    public int? YearsOfExperience { get; set; }

    public string? NationalId { get; set; }

    public string? EmploymentStatus { get; set; }

    public string? TypeOfContract { get; set; }

    public string? EmergencyContactName { get; set; }

    public string? EmergencyContactPhone { get; set; }

    public int? AnnualBalance { get; set; }

    public int? AccidentalBalance { get; set; }

    public decimal? Salary { get; set; }

    public DateOnly? HireDate { get; set; }

    public DateOnly? LastWorkingDate { get; set; }

    public string? DeptName { get; set; }

    public virtual ICollection<AccidentalLeave> AccidentalLeaves { get; set; } = new List<AccidentalLeave>();

    public virtual ICollection<AnnualLeave> AnnualLeaveEmps { get; set; } = new List<AnnualLeave>();

    public virtual ICollection<AnnualLeave> AnnualLeaveReplacementEmpNavigations { get; set; } = new List<AnnualLeave>();

    public virtual ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();

    public virtual ICollection<CompensationLeave> CompensationLeaveEmps { get; set; } = new List<CompensationLeave>();

    public virtual ICollection<CompensationLeave> CompensationLeaveReplacementEmpNavigations { get; set; } = new List<CompensationLeave>();

    public virtual ICollection<Deduction> Deductions { get; set; } = new List<Deduction>();

    public virtual Department? DeptNameNavigation { get; set; }

    public virtual ICollection<Document> Documents { get; set; } = new List<Document>();

    public virtual ICollection<EmployeeApproveLeave> EmployeeApproveLeaves { get; set; } = new List<EmployeeApproveLeave>();

    public virtual ICollection<EmployeePhone> EmployeePhones { get; set; } = new List<EmployeePhone>();

    public virtual ICollection<EmployeeReplaceEmployee> EmployeeReplaceEmployeeEmp1s { get; set; } = new List<EmployeeReplaceEmployee>();

    public virtual ICollection<EmployeeReplaceEmployee> EmployeeReplaceEmployeeEmp2s { get; set; } = new List<EmployeeReplaceEmployee>();

    public virtual ICollection<MedicalLeave> MedicalLeaves { get; set; } = new List<MedicalLeave>();

    public virtual ICollection<Payroll> Payrolls { get; set; } = new List<Payroll>();

    public virtual ICollection<Performance> Performances { get; set; } = new List<Performance>();

    public virtual ICollection<UnpaidLeave> UnpaidLeaves { get; set; } = new List<UnpaidLeave>();

    public virtual ICollection<Role> RoleNames { get; set; } = new List<Role>();
}
