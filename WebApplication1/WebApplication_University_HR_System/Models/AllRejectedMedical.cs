using System;
using System.Collections.Generic;

namespace WebApplication_University_HR_System.Models;

public partial class AllRejectedMedical
{
    public int request_ID { get; set; }
    public int emp_ID { get; set; }
    public DateTime date_of_request { get; set; }
    public DateTime start_date { get; set; }
    public DateTime end_date { get; set; }
    public int num_days { get; set; }
    public string final_approval_status { get; set; }
    public bool insurance_status { get; set; } // SQL 'BIT' maps to C# 'bool'
    public string disability_details { get; set; }
    public string type { get; set; }
}
