using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class AllEmployeeProfile
{
    public int EmployeeId { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? Gender { get; set; }

    public string? Email { get; set; }

    public string? Address { get; set; }

    public int? YearsOfExperience { get; set; }

    public string? OfficialDayOff { get; set; }

    public string? TypeOfContract { get; set; }

    public string? EmploymentStatus { get; set; }

    public int? AnnualBalance { get; set; }

    public int? AccidentalBalance { get; set; }
}
