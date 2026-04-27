using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class AllRejectedMedical
{
    public int RequestId { get; set; }

    public bool? InsuranceStatus { get; set; }

    public string? DisabilityDetails { get; set; }

    public string? Type { get; set; }

    public int? EmpId { get; set; }
}
