using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class CompensationLeave
{
    public int RequestId { get; set; }

    public string? Reason { get; set; }

    public DateOnly? DateOfOriginalWorkday { get; set; }

    public int? EmpId { get; set; }

    public int? ReplacementEmp { get; set; }

    public virtual Employee? Emp { get; set; }

    public virtual Employee? ReplacementEmpNavigation { get; set; }

    public virtual Leave Request { get; set; } = null!;
}
