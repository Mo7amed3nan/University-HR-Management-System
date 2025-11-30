using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Uni_HR_Management_System.Models;
using Uni_HR_Management_System.Filters;


namespace Uni_HR_Management_System.Controllers
{

    [AdminAuth]
    public class AdminController : Controller
  {

    private readonly UniversityHrManagementSystemContext _context;

    public AdminController(UniversityHrManagementSystemContext context)
    {
      _context = context;
    }


    // -------------------------------------------------------------
    // REQUIREMENT 1: Login (Handled in AccountController)
    // -------------------------------------------------------------

    // Dashboard (Index)
    public IActionResult Index()
    {
      //if (HttpContext.Session.GetString("Role") != "Admin") return RedirectToAction("Login", "Account");
      return View();
    }

    // -------------------------------------------------------------
    // REQUIREMENT 2: View details for all employee profiles
    // -------------------------------------------------------------
    public async Task<IActionResult> ListEmployees()
    {
            if (HttpContext.Session.GetString("Role") != "Admin") return RedirectToAction("Login", "Account");

      var profiles = await _context.AllEmployeeProfiles
          .FromSqlRaw("SELECT * FROM allEmployeeProfiles")
          .ToListAsync();

      return View(profiles);
    }

    // -------------------------------------------------------------
    // REQUIREMENT 3: Fetch the number of employees per department
    // -------------------------------------------------------------
    public async Task<IActionResult> DepartmentStats()
    {

      var stats = await _context.NoEmployeeDepts
          .FromSqlRaw("SELECT * FROM NoEmployeeDept")
          .ToListAsync();

      return View(stats);
    }

    // -------------------------------------------------------------
    // REQUIREMENT 4: Fetch details of all rejected medical leaves
    // -------------------------------------------------------------
    public async Task<IActionResult> RejectedLeaves()
    {

      var leaves = await _context.AllRejectedMedicals
          .FromSqlRaw("SELECT * FROM allRejectedMedicals")
          .ToListAsync();

      return View(leaves);
    }

    // -------------------------------------------------------------
    // REQUIREMENT 5: Remove deductions of resigned employees
    // -------------------------------------------------------------
    [HttpPost]
    public async Task<IActionResult> ClearResignedDeductions()
    {

      await _context.Database.ExecuteSqlRawAsync("EXEC Remove_Deductions");

      TempData["Message"] = "Deductions for resigned employees have been cleared.";
      return RedirectToAction(nameof(Index));
    }

    // -------------------------------------------------------------
    // REQUIREMENT 6: Update Attendance Record
    // -------------------------------------------------------------
    [HttpGet]
    public IActionResult UpdateAttendance()
    {
      return View();
    }

    [HttpPost]
    public async Task<IActionResult> UpdateAttendance(int empId, DateTime date, TimeSpan inTime, TimeSpan outTime)
    {
      string sql = "EXEC Update_Attendance @Employee_id={0}, @check_in_time={1}, @check_out_time={2}";
      await _context.Database.ExecuteSqlRawAsync(sql, empId, inTime, outTime);

      TempData["Message"] = $"Attendance updated for Employee {empId}.";
      return RedirectToAction(nameof(Index)); // as RedirectToAction("Index") but using nameof for refactoring safety
    }

    // -------------------------------------------------------------
    // REQUIREMENT 7: Add a new official holiday
    // -------------------------------------------------------------
    [HttpGet]
    public IActionResult AddHoliday()
    {
      return View();
    }

    [HttpPost]
    public async Task<IActionResult> AddHoliday(string name, DateTime start, DateTime end)
    {

      string sql = "EXEC Add_Holiday @holiday_name={0}, @from_date={1}, @to_date={2}";
      await _context.Database.ExecuteSqlRawAsync(sql, name, start, end);

      TempData["Message"] = $"Holiday '{name}' added successfully.";
      return RedirectToAction(nameof(Index));
    }

    // -------------------------------------------------------------
    // REQUIREMENT 8: Initiate attendance records for the current day
    // -------------------------------------------------------------
    [HttpPost]
    public async Task<IActionResult> StartDay()
    {

      await _context.Database.ExecuteSqlRawAsync("EXEC Initiate_Attendance");

      TempData["Message"] = "Attendance records initiated for today.";
      return RedirectToAction(nameof(Index));
    }


  }
}
