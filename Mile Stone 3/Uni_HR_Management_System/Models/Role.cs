using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class Role
{
    public string RoleName { get; set; } = null!;

    public string? Title { get; set; }

    public string? Description { get; set; }

    public int? Rank { get; set; }

    public decimal? BaseSalary { get; set; }

    public decimal? PercentageYoe { get; set; }

    public decimal? PercentageOvertime { get; set; }

    public int? AnnualBalance { get; set; }

    public int? AccidentalBalance { get; set; }

    public virtual ICollection<Department> DepartmentNames { get; set; } = new List<Department>();

    public virtual ICollection<Employee> Emps { get; set; } = new List<Employee>();
}
