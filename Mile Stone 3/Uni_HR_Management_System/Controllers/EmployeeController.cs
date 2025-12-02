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

        //Employee PART 2:

        // ---------------------------------------------------------
        // REQ 8:Apply for Accedintal Leave
        // ---------------------------------------------------------
        [HttpGet]
        public IActionResult SubmitAccidentalLeave()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> SubmitAccidentalLeave(int replacementId, DateTime start, DateTime end)
        {
            int? empId = HttpContext.Session.GetInt32("EmpId");
            try
            {
                string sql = "EXEC Submit_accidental @employee_ID={0}, @start_date={1}, @end_date={2}";
                await _context.Database.ExecuteSqlRawAsync(sql, empId, start, end);
                TempData["Message"] = "Accidental Leave submitted successfully!";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error submitting leave: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
        // ---------------------------------------------------------
        // REQ 9:Apply for Medical Leave
        // ---------------------------------------------------------
        [HttpGet]
        public IActionResult SubmitMedicalLeave()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> SubmitMedicalLeave(DateTime start, DateTime end, string type, bool insuranceStatus, string disabilityDetails, string documentDescription, string fileName)
        {
            int? empId = HttpContext.Session.GetInt32("EmpId");
            try
            {
                string sql = "EXEC Submit_Medical @employee_ID={0}, @start_date={1}, @end_date={2},@medical_type={3},@insurance_status={4},@disability_details={5},@document_description={6},@file_name={7}";
                await _context.Database.ExecuteSqlRawAsync(sql, empId, start, end, type, insuranceStatus, disabilityDetails, documentDescription, fileName);
                TempData["Message"] = "Medical Leave submitted successfully!";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error submitting leave: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
        // ---------------------------------------------------------
        // REQ 10:Apply for Unpaid Leave
        // ---------------------------------------------------------
        [HttpGet]
        public IActionResult SubmitUnpaidLeave()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> SubmitUnpaidLeave(DateTime start, DateTime end, string documentDescription, string fileName)
        {
            int? empId = HttpContext.Session.GetInt32("EmpId");
            try
            {
                string sql = "EXEC Submit_Unpaid @employee_ID={0}, @start_date={1}, @end_date={2},@document_description={3},@file_name={4}";
                await _context.Database.ExecuteSqlRawAsync(sql, empId, start, end, documentDescription, fileName);
                TempData["Message"] = "Unpaid Leave submitted successfully!";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error submitting leave: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
        // ---------------------------------------------------------
        // REQ 10:Apply for Unpaid Leave
        // ---------------------------------------------------------
        [HttpGet]
        public IActionResult SubmitCompensationLeave()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> SubmitCompensationLeave(DateTime compensationDate, string reason, DateTime dateOfOriginalWorkday, int replacementId)
        {
            int? empId = HttpContext.Session.GetInt32("EmpId");
            try
            {
                string sql = "EXEC Submit_Compensation @employee_ID={0}, @compensation_date={1},@reason={2},@date_of_original_workday={3},@rep_emp_id={4}";
                await _context.Database.ExecuteSqlRawAsync(sql, empId, compensationDate, reason, dateOfOriginalWorkday, replacementId);
                TempData["Message"] = "Compensation Leave submitted successfully!";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error submitting leave: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
        [HttpGet]
        public IActionResult ApproveRejectUnpaid()
        {
            return View();
        }

        public async Task<IActionResult> ViewPendingUnpaidLeave()
        {
            var managerId = HttpContext.Session.GetInt32("EmpId");
            // 1. Start from the UNPAID LEAVE table.
            var pendingRequests = await _context.UnpaidLeaves
                // 2. Eagerly load the base Leave details (StartDate, EndDate, Status)
                .Include(u => u.Request)
                // 3. Eagerly load the Employee who submitted the request
                .Include(u => u.Emp)
                // 4. FILTER by: a) Pending status AND b) Manager authorization
                .Where(u => u.Request.FinalApprovalStatus == "Pending" &&
                            u.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == managerId))
                .ToListAsync();
            return View(pendingRequests);
        }
        [HttpPost]
        public async Task<IActionResult> ApproveUnpaidButton(int requestId)
        {
            int? upperboardId = HttpContext.Session.GetInt32("EmpId");

            string sql = "EXEC Upperboard_approve_unpaids @request_ID={0}, @upperboard_ID={1}";

            try
            {
                await _context.Database.ExecuteSqlRawAsync(sql, requestId, upperboardId);
                TempData["Message"] = $"Unpaid Leave Request {requestId} processed by Upperboard.";
            }
            catch (Exception ex)
            {
                // The SP contains logic that rejects the leave if certain conditions fail (e.g., Part-time contract, Dean/Vice-Dean on leave)
                TempData["Error"] = "Processing failed. Check the database constraints. Error: " + ex.Message;
            }

            return RedirectToAction(nameof(ViewPendingUnpaidLeave));
        }
        public async Task<IActionResult> ViewPendingAnnualLeave()
        {
            var managerId = HttpContext.Session.GetInt32("EmpId");
            var pendingRequests = await _context.AnnualLeaves
                .Include(u => u.Request)
                .Include(u => u.Emp)
                .Where(u => u.Request.FinalApprovalStatus == "Pending" &&
                            u.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == managerId))
                .ToListAsync();
            return View(pendingRequests);
        }
        [HttpPost]
        public async Task<IActionResult> ApproveAnnualButton(int requestId,int ReplacementEmp)
        {
            int? upperboardId = HttpContext.Session.GetInt32("EmpId");

            string sql = "EXEC Upperboard_approve_annual @request_ID={0}, @upperboard_ID={1},@replacement_ID={2}";

            try
            {
                await _context.Database.ExecuteSqlRawAsync(sql, requestId, upperboardId, ReplacementEmp);
                TempData["Message"] = $"Annual Leave Request {requestId} processed by Upperboard.";
            }
            catch (Exception ex)
            {
                // The SP contains logic that rejects the leave if certain conditions fail (e.g., Part-time contract, Dean/Vice-Dean on leave)
                TempData["Error"] = "Processing failed. Check the database constraints. Error: " + ex.Message;
            }

            return RedirectToAction(nameof(ViewPendingAnnualLeave));
        }
        [HttpGet]
        public IActionResult EvaluateEmployee()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> EvaluateEmployee(int empId, int rating, string comment, string semester)
        {
            try
            {
                var sql = "EXEC Dean_andHR_Evaluation @employee_ID={0},@rating={1},@comment={2},@semester={3}";
                await _context.Database.ExecuteSqlRawAsync(sql, empId, rating, comment, semester); // Uses the procedure name from final_implementation.sql
                TempData["Message"] = "Employee evaluated successfully!";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error evaluating employee: " + ex.Message;
                return RedirectToAction("Index");
            }
        }
    }
}
