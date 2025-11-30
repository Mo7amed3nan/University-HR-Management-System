using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class Leave
{
    public int RequestId { get; set; }

    public DateOnly? DateOfRequest { get; set; }

    public DateOnly? StartDate { get; set; }

    public DateOnly? EndDate { get; set; }

    public int? NumDays { get; set; }

    public string? FinalApprovalStatus { get; set; }

    public virtual AccidentalLeave? AccidentalLeave { get; set; }

    public virtual AnnualLeave? AnnualLeave { get; set; }

    public virtual CompensationLeave? CompensationLeave { get; set; }

    public virtual ICollection<EmployeeApproveLeave> EmployeeApproveLeaves { get; set; } = new List<EmployeeApproveLeave>();

    public virtual MedicalLeave? MedicalLeave { get; set; }

    public virtual UnpaidLeave? UnpaidLeave { get; set; }
}
