using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class AccidentalLeave
{
    public int RequestId { get; set; }

    public int? EmpId { get; set; }

    public virtual Employee? Emp { get; set; }

    public virtual Leave Request { get; set; } = null!;
}
