using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class MedicalLeave
{
    public int RequestId { get; set; }

    public bool? InsuranceStatus { get; set; }

    public string? DisabilityDetails { get; set; }

    public string? Type { get; set; }

    public int? EmpId { get; set; }

    public virtual ICollection<Document> Documents { get; set; } = new List<Document>();

    public virtual Employee? Emp { get; set; }

    public virtual Leave Request { get; set; } = null!;
}
