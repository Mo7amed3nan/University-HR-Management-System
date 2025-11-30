using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class Deduction
{
    public int DeductionId { get; set; }

    public int EmpId { get; set; }

    public DateOnly? Date { get; set; }

    public decimal? Amount { get; set; }

    public string? Type { get; set; }

    public string? Status { get; set; }

    public int? UnpaidId { get; set; }

    public int? AttendanceId { get; set; }

    public virtual Attendance? Attendance { get; set; }

    public virtual Employee Emp { get; set; } = null!;

    public virtual UnpaidLeave? Unpaid { get; set; }
}
