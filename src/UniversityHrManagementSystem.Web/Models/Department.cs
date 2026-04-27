using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class Department
{
    public string Name { get; set; } = null!;

    public string? BuildingLocation { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();

    public virtual ICollection<Role> RoleNames { get; set; } = new List<Role>();
}
