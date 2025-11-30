using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class EmployeeReplaceEmployee
{
    public int TableId { get; set; }

    public int Emp1Id { get; set; }

    public int Emp2Id { get; set; }

    public DateOnly? FromDate { get; set; }

    public DateOnly? ToDate { get; set; }

    public virtual Employee Emp1 { get; set; } = null!;

    public virtual Employee Emp2 { get; set; } = null!;
}
