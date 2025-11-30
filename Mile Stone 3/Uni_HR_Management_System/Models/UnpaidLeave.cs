using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class UnpaidLeave
{
    public int RequestId { get; set; }

    public int? EmpId { get; set; }

    public virtual ICollection<Deduction> Deductions { get; set; } = new List<Deduction>();

    public virtual ICollection<Document> Documents { get; set; } = new List<Document>();

    public virtual Employee? Emp { get; set; }

    public virtual Leave Request { get; set; } = null!;
}
