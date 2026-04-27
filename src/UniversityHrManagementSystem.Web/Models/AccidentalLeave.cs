using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class AccidentalLeave
{
    public int RequestId { get; set; }

    public int? EmpId { get; set; }

    public virtual Employee? Emp { get; set; }

    public virtual Leave Request { get; set; } = null!;
}
