using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Uni_HR_Management_System.Filters;
using Uni_HR_Management_System.Models;


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
    public IActionResult Index()
    {
      return View();
    }

    // -------------------------------------------------------------
    // REQUIREMENT 2: View details for all employee profiles
    // -------------------------------------------------------------
    public async Task<IActionResult> ListEmployees()
    {
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

        // ==========================================
        // REQUIREMENT 6: Update Attendance Record
        // ==========================================
        [HttpGet]
        public IActionResult UpdateAttendance()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> UpdateAttendance(int empId, TimeSpan? check_in, TimeSpan? check_out)
        {
            
            string sql = "EXEC Update_Attendance @Employee_id={0}, @check_in_time={1}, @check_out_time={2}";

            await _context.Database.ExecuteSqlRawAsync(sql, empId, check_in, check_out);

            TempData["Message"] = $"Attendance updated for Employee ID: {empId}";
            return RedirectToAction(nameof(Index));
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




        // =============================================================
        // ADMIN COMPONENT PART 2
        // =============================================================

        // -------------------------------------------------------------
        // REQUIREMENT 1: Fetch attendance records for yesterday
        // -------------------------------------------------------------
        public async Task<IActionResult> ViewAttendanceYesterday()
        {
            var attendanceList = await _context.AllEmployeeAttendances
                .FromSqlRaw("SELECT * FROM allEmployeeAttendance")
                .ToListAsync();

            return View(attendanceList);
        }

        // -------------------------------------------------------------
        // REQUIREMENT 2: Fetch performance for all employees (Winter)
        // -------------------------------------------------------------
        public async Task<IActionResult> ViewPerformance()
        {
            var performanceList = await _context.AllPerformances
                .FromSqlRaw("SELECT * FROM allPerformance")
                .ToListAsync();

            return View(performanceList);
        }

        // -------------------------------------------------------------
        // REQUIREMENT 3: Remove attendance on official holidays
        // -------------------------------------------------------------
        [HttpPost]
        public async Task<IActionResult> RemoveHolidayAttendance()
        {
            await _context.Database.ExecuteSqlRawAsync("EXEC Remove_Holiday");

            TempData["Message"] = "Attendance records on official holidays have been removed.";
            return RedirectToAction(nameof(Index));
        }

        // -------------------------------------------------------------
        // REQUIREMENT 4: Remove unattended day-offs
        // -------------------------------------------------------------
        [HttpGet]
        public IActionResult RemoveDayOff()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> RemoveDayOff(int empId)
        {
            string sql = "EXEC Remove_DayOff @Employee_id={0}";
            await _context.Database.ExecuteSqlRawAsync(sql, empId);

            TempData["Message"] = $"Unattended day-offs removed for Employee {empId}.";
            return RedirectToAction(nameof(Index));
        }

        // -------------------------------------------------------------
        // REQUIREMENT 5: Remove approved leaves from attendance
        // -------------------------------------------------------------
        [HttpGet]
        public IActionResult RemoveApprovedLeaves()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> RemoveApprovedLeaves(int empId)
        {
            string sql = "EXEC Remove_Approved_Leaves @employee_id={0}";
            await _context.Database.ExecuteSqlRawAsync(sql, empId);

            TempData["Message"] = $"Approved leave attendance records removed for Employee {empId}.";
            return RedirectToAction(nameof(Index));
        }

        // -------------------------------------------------------------
        // REQUIREMENT 6: Replace Employee
        // -------------------------------------------------------------
        [HttpGet]
        public IActionResult ReplaceEmployee()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> ReplaceEmployee(int emp1, int emp2, DateTime from, DateTime to)
        {
            string sql = "EXEC Replace_employee @Emp1_ID={0}, @Emp2_ID={1}, @from_date={2}, @to_date={3}";
            await _context.Database.ExecuteSqlRawAsync(sql, emp1, emp2, from, to);

            TempData["Message"] = $"Employee {emp1} replaced by {emp2} successfully.";
            return RedirectToAction(nameof(Index));
        }

        // -------------------------------------------------------------
        // REQUIREMENT 7: Update Employment Status
        // -------------------------------------------------------------
        [HttpGet]
        public IActionResult UpdateStatus()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> UpdateStatus(int empId)
        {
            string sql = "EXEC Update_Employment_Status @Employee_ID={0}";
            await _context.Database.ExecuteSqlRawAsync(sql, empId);

            TempData["Message"] = $"Employment status updated for Employee {empId}.";
            return RedirectToAction(nameof(Index));
        }


    }
}
