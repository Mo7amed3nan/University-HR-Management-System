using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class EmployeePhone
{
    public int EmpId { get; set; }

    public string PhoneNum { get; set; } = null!;

    public virtual Employee Emp { get; set; } = null!;
}
