using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class Payroll
{
    public int Id { get; set; }

    public DateOnly? PaymentDate { get; set; }

    public decimal? FinalSalaryAmount { get; set; }

    public DateOnly? FromDate { get; set; }

    public DateOnly? ToDate { get; set; }

    public string? Comments { get; set; }

    public decimal? BonusAmount { get; set; }

    public decimal? DeductionsAmount { get; set; }

    public int? EmpId { get; set; }

    public virtual Employee? Emp { get; set; }
}
