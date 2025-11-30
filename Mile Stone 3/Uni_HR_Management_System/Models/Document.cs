using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class Document
{
    public int DocumentId { get; set; }

    public string? Type { get; set; }

    public string? Description { get; set; }

    public string? FileName { get; set; }

    public DateOnly? CreationDate { get; set; }

    public DateOnly? ExpiryDate { get; set; }

    public string? Status { get; set; }

    public int? EmpId { get; set; }

    public int? MedicalId { get; set; }

    public int? UnpaidId { get; set; }

    public virtual Employee? Emp { get; set; }

    public virtual MedicalLeave? Medical { get; set; }

    public virtual UnpaidLeave? Unpaid { get; set; }
}
