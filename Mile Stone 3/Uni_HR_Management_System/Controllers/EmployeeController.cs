using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Uni_HR_Management_System.Filters;
using Uni_HR_Management_System.Models;

namespace Uni_HR_Management_System.Controllers
{
  [AcademicAuth] // LEVEL 1 SECURITY: Only Academic Employees allowed
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

    // =========================================================
    // PART 1: VIEW DATA (My Info)
    // =========================================================

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

    public async Task<IActionResult> ViewAttendance()
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      var list = await _context.Attendances
          .FromSqlRaw("SELECT * FROM dbo.MyAttendance({0})", empId)
          .ToListAsync();
      return View(list);
    }

    public async Task<IActionResult> ViewPayroll()
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      var list = await _context.Payrolls
          .FromSqlRaw("SELECT * FROM dbo.Last_month_payroll({0})", empId)
          .ToListAsync();
      return View(list);
    }

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

    public async Task<IActionResult> ViewLeaveStatus()
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      var list = await _context.Leaves
          .FromSqlRaw("SELECT * FROM dbo.status_leaves({0})", empId)
          .ToListAsync();
      return View(list);
    }

    // =========================================================
    // PART 2: APPLY FOR LEAVES
    // =========================================================

    // 1. Annual Leave
    [HttpGet]
    public IActionResult SubmitAnnualLeave() { return View(); }

    [HttpPost]
    public async Task<IActionResult> SubmitAnnualLeave(int replacementId, DateTime start, DateTime end)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      string sql = "EXEC Submit_annual @employee_ID={0}, @replacement_emp={1}, @start_date={2}, @end_date={3}";
      try { await _context.Database.ExecuteSqlRawAsync(sql, empId, replacementId, start, end); TempData["Message"] = "Submitted successfully."; }
      catch (Exception ex) { TempData["Error"] = "Error: " + ex.Message; }
      return RedirectToAction("Index");
    }

    // 2. Accidental Leave
    [HttpGet]
    public IActionResult SubmitAccidentalLeave() { return View(); }

    [HttpPost]
    public async Task<IActionResult> SubmitAccidentalLeave(DateTime start, DateTime end)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      string sql = "EXEC Submit_accidental @employee_ID={0}, @start_date={1}, @end_date={2}";
      try { await _context.Database.ExecuteSqlRawAsync(sql, empId, start, end); TempData["Message"] = "Submitted successfully."; }
      catch (Exception ex) { TempData["Error"] = "Error: " + ex.Message; }
      return RedirectToAction("Index");
    }

    // 3. Medical Leave
    [HttpGet]
    public IActionResult SubmitMedicalLeave() { return View(); }

    [HttpPost]
    public async Task<IActionResult> SubmitMedicalLeave(DateTime start, DateTime end, string type, bool insurance, string disability, string description, string filename)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      string sql = "EXEC Submit_medical @employee_ID={0}, @start_date={1}, @end_date={2}, @medical_type={3}, @insurance_status={4}, @disability_details={5}, @document_description={6}, @file_name={7}";
      try { await _context.Database.ExecuteSqlRawAsync(sql, empId, start, end, type, insurance, disability, description, filename); TempData["Message"] = "Submitted successfully."; }
      catch (Exception ex) { TempData["Error"] = "Error: " + ex.Message; }
      return RedirectToAction("Index");
    }

    // 4. Unpaid Leave
    [HttpGet]
    public IActionResult SubmitUnpaidLeave() { return View(); }

    [HttpPost]
    public async Task<IActionResult> SubmitUnpaidLeave(DateTime start, DateTime end, string description, string filename)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      string sql = "EXEC Submit_unpaid @employee_ID={0}, @start_date={1}, @end_date={2}, @document_description={3}, @file_name={4}";
      try { await _context.Database.ExecuteSqlRawAsync(sql, empId, start, end, description, filename); TempData["Message"] = "Submitted successfully."; }
      catch (Exception ex) { TempData["Error"] = "Error: " + ex.Message; }
      return RedirectToAction("Index");
    }

    // 5. Compensation Leave
    [HttpGet]
    public IActionResult SubmitCompensationLeave() { return View(); }

    [HttpPost]
    public async Task<IActionResult> SubmitCompensationLeave(DateTime compDate, string reason, DateTime originalDate, int replacementId)
    {
      int? empId = HttpContext.Session.GetInt32("EmpId");
      string sql = "EXEC Submit_compensation @employee_ID={0}, @compensation_date={1}, @reason={2}, @date_of_original_workday={3}, @rep_emp_id={4}";
      try { await _context.Database.ExecuteSqlRawAsync(sql, empId, compDate, reason, originalDate, replacementId); TempData["Message"] = "Submitted successfully."; }
      catch (Exception ex) { TempData["Error"] = "Error: " + ex.Message; }
      return RedirectToAction("Index");
    }

    // =========================================================
    // PART 2: DEAN / UPPER BOARD ACTIONS (With Level 2 Security)
    // =========================================================

    [HttpGet]
    public async Task<IActionResult> ViewPendingUnpaidLeave()
    {
      var managerId = HttpContext.Session.GetInt32("EmpId");
      if (managerId == null) return RedirectToAction("Login", "Account");

      // --- SECURITY CHECK ---
      if (!IsUpperBoard(managerId.Value))
      {
        TempData["Error"] = "Access Denied: You are not authorized to view this page.";
        return RedirectToAction("Index");
      }

      var pendingRequests = await _context.UnpaidLeaves
          .Include(u => u.Request)
              .ThenInclude(r => r.EmployeeApproveLeaves)
          .Include(u => u.Emp)
          .Where(u => u.Request.FinalApprovalStatus == "Pending" &&
                      u.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == managerId && e.Status == "Pending"))
          .ToListAsync();

      return View(pendingRequests);
    }

    [HttpPost]
    public async Task<IActionResult> ApproveUnpaidButton(int requestId)
    {
      int? upperboardId = HttpContext.Session.GetInt32("EmpId");
      if (upperboardId == null) return RedirectToAction("Login", "Account");

      if (!IsUpperBoard(upperboardId.Value))
      {
        TempData["Error"] = "Access Denied.";
        return RedirectToAction("Index");
      }

      string sql = "EXEC Upperboard_approve_unpaids @request_ID={0}, @upperboard_ID={1}";

      try
      {
        await _context.Database.ExecuteSqlRawAsync(sql, requestId, upperboardId);
        TempData["Message"] = $"Unpaid Leave Request {requestId} processed.";
      }
      catch (Exception ex)
      {
        TempData["Error"] = "Processing failed: " + ex.Message;
      }

      return RedirectToAction(nameof(ViewPendingUnpaidLeave));
    }

    // ---------------------------------------------------------
    // 2. View & Approve Annual Leaves
    // ---------------------------------------------------------
    [HttpGet]
    public async Task<IActionResult> ViewPendingAnnualLeave()
    {
      var managerId = HttpContext.Session.GetInt32("EmpId");
      if (managerId == null) return RedirectToAction("Login", "Account");

      // --- SECURITY CHECK ---
      if (!IsUpperBoard(managerId.Value))
      {
        TempData["Error"] = "Access Denied.";
        return RedirectToAction("Index");
      }

      var pendingRequests = await _context.AnnualLeaves
          .Include(u => u.Request)
              .ThenInclude(r => r.EmployeeApproveLeaves)
          .Include(u => u.Emp)
          .Where(u => u.Request.FinalApprovalStatus == "Pending" &&
                      u.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == managerId && e.Status == "Pending"))
          .ToListAsync();

      return View(pendingRequests);
    }

    [HttpPost]
    public async Task<IActionResult> ApproveAnnualButton(int requestId, int ReplacementEmp)
    {
      int? upperboardId = HttpContext.Session.GetInt32("EmpId");
      if (upperboardId == null) return RedirectToAction("Login", "Account");

      if (!IsUpperBoard(upperboardId.Value))
      {
        TempData["Error"] = "Access Denied.";
        return RedirectToAction("Index");
      }

      string sql = "EXEC Upperboard_approve_annual @request_ID={0}, @Upperboard_ID={1}, @replacement_ID={2}";

      try
      {
        await _context.Database.ExecuteSqlRawAsync(sql, requestId, upperboardId, ReplacementEmp);
        TempData["Message"] = $"Annual Leave Request {requestId} processed.";
      }
      catch (Exception ex)
      {
        TempData["Error"] = "Processing failed: " + ex.Message;
      }

      return RedirectToAction(nameof(ViewPendingAnnualLeave));
    }

    // ---------------------------------------------------------
    // 3. Evaluate Employee
    // ---------------------------------------------------------
    [HttpGet]
    public IActionResult EvaluateEmployee()
    {
      int? myId = HttpContext.Session.GetInt32("EmpId");
      if (myId == null) return RedirectToAction("Login", "Account");

      if (!IsDean(myId.Value))
      {
        TempData["Error"] = "Access Denied: Only Deans can evaluate.";
        return RedirectToAction("Index");
      }
      return View();
    }

    [HttpPost]
    public async Task<IActionResult> EvaluateEmployee(int empId, int rating, string comment, string semester)
    {
      int? myId = HttpContext.Session.GetInt32("EmpId");
      if (myId == null || !IsDean(myId.Value)) return RedirectToAction("Index");

      try
      {
        string sql = "EXEC Dean_andHR_Evaluation @employee_ID={0}, @rating={1}, @comment={2}, @semester={3}";
        await _context.Database.ExecuteSqlRawAsync(sql, empId, rating, comment, semester);
        TempData["Message"] = "Employee evaluated successfully!";
      }
      catch (Exception ex)
      {
        TempData["Error"] = "Error evaluating: " + ex.Message;
      }
      return RedirectToAction(nameof(EvaluateEmployee));
    }

    // =========================================================
    // HELPERS
    // =========================================================
    private bool IsUpperBoard(int empId)
    {
      var employee = _context.Employees
          .Include(e => e.RoleNames)
          .FirstOrDefault(e => e.EmployeeId == empId);

      if (employee == null) return false;

      return employee.RoleNames.Any(r =>
          r.RoleName == "Dean" ||
          r.RoleName == "Vice Dean" ||
          r.RoleName == "President" ||
          r.RoleName == "Vice President");
    }

    private bool IsDean(int empId)
    {
      var employee = _context.Employees
          .Include(e => e.RoleNames)
          .FirstOrDefault(e => e.EmployeeId == empId);

      if (employee == null) return false;

      return employee.RoleNames.Any(r => r.RoleName == "Dean");
    }
  }
}
