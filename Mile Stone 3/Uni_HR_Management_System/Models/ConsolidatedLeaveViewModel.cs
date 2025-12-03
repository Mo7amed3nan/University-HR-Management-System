using Microsoft.AspNetCore.Mvc;

namespace Uni_HR_Management_System.Models
{
    public class ConsolidatedLeaveViewModel
    {
        public int RequestId { get; set; }
        public string EmployeeName { get; set; }
        public DateOnly? StartDate { get; set; }
        public DateOnly? EndDate { get; set; }
        public string Type { get; set; }
    }
}
