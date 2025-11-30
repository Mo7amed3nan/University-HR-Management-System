using System;
using System.Collections.Generic;

namespace Uni_HR_Management_System.Models;

public partial class AllEmployeeAttendance
{
    public int AttendanceId { get; set; }

    public DateOnly? Date { get; set; }

    public TimeOnly? CheckInTime { get; set; }

    public TimeOnly? CheckOutTime { get; set; }

    public int? TotalDuration { get; set; }

    public string? Status { get; set; }

    public int? EmpId { get; set; }
}
