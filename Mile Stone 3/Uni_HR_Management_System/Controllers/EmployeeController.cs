using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Uni_HR_Management_System.Filters;
using Uni_HR_Management_System.Models;

namespace Uni_HR_Management_System.Controllers
{
  [AcademicAuth] // Protects all actions
  public class EmployeeController : Controller
  {
    private readonly UniversityHrManagementSystemContext _context;

    public EmployeeController(UniversityHrManagementSystemContext context)
    {
      _context = context;
    }

    public IActionResult Index()
    {
      return View();
    }

    // ---------------------------------------------------------
    // REQ 2: Retrieve my performance for a certain semester
    // ---------------------------------------------------------
    [HttpGet]
    public IActionResult ViewPerformance()
    {
      return View(new List<Performance>());
    }

    [HttpPost]
    public async Task<IActionResult> ViewPerformance(string semester)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");

      var list = await _context.Performances
          .FromSqlRaw("SELECT * FROM dbo.MyPerformance({0}, {1})", empId, semester)
          .ToListAsync();

      return View(list);
    }

    // ---------------------------------------------------------
    // REQ 3: Retrieve attendance records (Current Month)
    // ---------------------------------------------------------
    public async Task<IActionResult> ViewAttendance()
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");

      var list = await _context.Attendances
          .FromSqlRaw("SELECT * FROM dbo.MyAttendance({0})", empId)
          .ToListAsync();

      return View(list);
    }

    // ---------------------------------------------------------
    // REQ 4: Retrieve last month's payroll
    // ---------------------------------------------------------
    public async Task<IActionResult> ViewPayroll()
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");

      var list = await _context.Payrolls
          .FromSqlRaw("SELECT * FROM dbo.Last_month_payroll({0})", empId)
          .ToListAsync();

      return View(list);
    }

    // ---------------------------------------------------------
    // REQ 5: Fetch deductions (attendance issues)
    // ---------------------------------------------------------
    [HttpGet]
    public IActionResult ViewDeductions()
    {
      return View(new List<Deduction>());
    }

    [HttpPost]
    public async Task<IActionResult> ViewDeductions(int month)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");

      var list = await _context.Deductions
          .FromSqlRaw("SELECT * FROM dbo.Deductions_Attendance({0}, {1})", empId, month)
          .ToListAsync();

      return View(list);
    }

    // ---------------------------------------------------------
    // REQ 6: Apply for Annual Leave
    // ---------------------------------------------------------
    [HttpGet]
    public IActionResult SubmitAnnualLeave()
    {
      return View();
    }

    [HttpPost]
    public async Task<IActionResult> SubmitAnnualLeave(int replacementId, DateTime start, DateTime end)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");

      try
      {
        string sql = "EXEC Submit_annual @employee_ID={0}, @replacement_emp={1}, @start_date={2}, @end_date={3}";
        await _context.Database.ExecuteSqlRawAsync(sql, empId, replacementId, start, end);

        TempData["Message"] = "Annual Leave submitted successfully!";
      }
      catch (Exception ex)
      {
        TempData["Error"] = "Error submitting leave: " + ex.Message;
      }

      return RedirectToAction("Index");
    }

    // ---------------------------------------------------------
    // REQ 7: Retrieve status of submitted leaves
    // ---------------------------------------------------------
    public async Task<IActionResult> ViewLeaveStatus()
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");

      var list = await _context.Leaves
          .FromSqlRaw("SELECT * FROM dbo.status_leaves({0})", empId)
          .ToListAsync();

      return View(list);
    }
  }
}
