using Azure.Core;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using Uni_HR_Management_System.Models;

namespace Uni_HR_Management_System.Controllers
{
    public class HRController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
        private readonly UniversityHrManagementSystemContext _context;

        public HRController(UniversityHrManagementSystemContext context)
        {
            _context = context;
        }
        //HR Proccess Annual Accumulated Leave
        [HttpGet]
        public async Task<IActionResult> HRProccessAnnualAccLeave()
        {
            int? HR_ID = HttpContext.Session.GetInt32("EmpId");
            var annualRequests = _context.AnnualLeaves
         .Include(a => a.Request)
         .Include(a => a.Emp)
         .Where(a => a.Request.FinalApprovalStatus == "Pending" &&
                     a.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == HR_ID))
            .Select(a => new ConsolidatedLeaveViewModel
            {
                RequestId = a.RequestId,
                StartDate = a.Request.StartDate,
                EndDate = a.Request.EndDate,
                Type = "Annual Leave"
            });
            var accRequests = _context.AccidentalLeaves
        .Include(a => a.Request)
        .Include(a => a.Emp)
        .Where(a => a.Request.FinalApprovalStatus == "Pending" &&
                    a.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == HR_ID))
           .Select(a => new ConsolidatedLeaveViewModel
           {
               RequestId = a.RequestId,
               StartDate = a.Request.StartDate,
               EndDate = a.Request.EndDate,
               Type = "Accidental Leave"
           });
            var consolidatedRequests = await annualRequests
                .Union(accRequests)
                .ToListAsync();
            return View(consolidatedRequests);
        }

        [HttpPost]
        public async Task<IActionResult> HRProccessAnnualAccLeave(int requestID)
        {
            int? Hr_Id = HttpContext.Session.GetInt32("EmpId");

            try
            {
                var sql = "EXEC HR_approval_an_acc @request_ID={0},@HR_ID={1}";
                await _context.Database.ExecuteSqlRawAsync(sql, requestID, Hr_Id);
                TempData["Message"] = "Leave request with ID : "+requestID+" Processed successfully";
                return RedirectToAction("HRProccessAnnualAccLeave");
            }
            catch(Exception ex)
            {
                TempData["Error"] = "Error proccessing leave: " + ex.Message;
                return View("index");
            }
        }
        //////////////////////////////////////////////////////////////////////
        //HR Proccess Unpaid Leave
        /////////////////////////////////////////////////////////////////////
        [HttpGet]
        public async Task<IActionResult> HRProccessUnpaidLeave()
        {
            int? HR_ID = HttpContext.Session.GetInt32("EmpId");
            var unpaidRequests = _context.UnpaidLeaves
            .Include(u => u.Request)
            .Include(u => u.Emp)
            .Where(u => u.Request.FinalApprovalStatus == "Pending" &&
                        u.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == HR_ID))
            .Select(u => new ConsolidatedLeaveViewModel
            {
            RequestId = u.RequestId,
            StartDate = u.Request.StartDate,
            EndDate = u.Request.EndDate,
            Type = "Unpaid Leave"
        });

            var consolidatedRequests = await unpaidRequests.ToListAsync();
            return View(consolidatedRequests);
        }

        [HttpPost]
        public async Task<IActionResult> HRProccessUnpaidLeave(int requestID)
        {
            int? Hr_Id = HttpContext.Session.GetInt32("EmpId");

            try
            {
                var sql = "EXEC HR_approval_Unpaid @request_ID={0},@HR_ID={1}";
                await _context.Database.ExecuteSqlRawAsync(sql, requestID, Hr_Id);
                TempData["Message"] = "Leave request with ID : " + requestID + " Processed successfully";
                return RedirectToAction("HRProccessUnpaidLeave");
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error proccessing leave: " + ex.Message;
                return View("index");
            }
        }
        //////////////////////////////////////////////////////////////////////
        //HR Proccess Compensation Leave
        /////////////////////////////////////////////////////////////////////
        [HttpGet]
        public async Task<IActionResult> HRProccessCompensationLeave()
        {
            int? HR_ID = HttpContext.Session.GetInt32("EmpId");
            var compensationRequests = _context.CompensationLeaves
            .Include(u => u.Request)
            .Include(u => u.Emp)
            .Where(u => u.Request.FinalApprovalStatus == "Pending" &&
                        u.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == HR_ID))
            .Select(u => new ConsolidatedLeaveViewModel
            {
                RequestId = u.RequestId,
                StartDate = u.Request.StartDate,
                EndDate = u.Request.EndDate,
                Type = "Compensation Leave"
            });

            var consolidatedRequests = await compensationRequests.ToListAsync();
            return View(consolidatedRequests);
        }

        [HttpPost]
        public async Task<IActionResult> HRProccessCompensationLeave(int requestID)
        {
            int? Hr_Id = HttpContext.Session.GetInt32("EmpId");

            try
            {
                var sql = "EXEC HR_approval_comp @request_ID={0},@HR_ID={1}";
                await _context.Database.ExecuteSqlRawAsync(sql, requestID, Hr_Id);
                TempData["Message"] = "Leave request with ID : " + requestID + " Processed successfully";
                return RedirectToAction("HRProccessCompensationLeave");
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error proccessing leave: " + ex.Message;
                return View("index");
            }
        }
        [HttpGet]
        public IActionResult HRDeductionHours()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> HRDeductionHours(int empID)
        {
            var sql = "EXEC Deduction_hours @employee_ID={0}";
            try
            {
                await _context.Database.ExecuteSqlRawAsync(sql, empID);
                TempData["Message"] = "Deduction for missing Hours for Employee ID : " + empID + " Processed successfully";

                return View("HRDeductionHours");
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error proccessing deductions: " + ex.Message;
                return View("index");
            }
        }
        [HttpGet]
        public IActionResult HRDeductionDays()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> HRDeductionDays(int empID)
        {
            var sql = "EXEC Deduction_days @employee_ID={0}";
            try
            {
                await _context.Database.ExecuteSqlRawAsync(sql, empID);
                TempData["Message"] = "Deduction for missing days for Employee ID : " + empID + " Processed successfully";

                return View("HRDeductionDays");
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error proccessing deductions: " + ex.Message;
                return View("index");
            }
        }
        [HttpGet]
        public IActionResult HRDeductionUnpaid()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> HRDeductionUnpaid(int empID)
        {
            var sql = "EXEC Deduction_unpaid @employee_ID={0}";
            try
            {
                await _context.Database.ExecuteSqlRawAsync(sql, empID);
                TempData["Message"] = "Deduction for unpaid leaves for Employee ID : " + empID + " Processed successfully";

                return View("HRDeductionUnpaid");
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error proccessing deductions: " + ex.Message;
                return View("index");
            }
        }
        [HttpGet]
        public IActionResult HRGeneratePayroll()
        {
            return View();
        }
        [HttpPost]
        public async Task<IActionResult> HRGeneratePayroll(int empID,DateTime start,DateTime end)
        {
            var sql = "EXEC Add_Payroll  @employee_ID={0},@from={1}, @to={2}";
            try
            {
                await _context.Database.ExecuteSqlRawAsync(sql, empID,start,end);
                TempData["Message"] = "Generate payroll for Employee ID : " + empID + " Processed successfully";

                return View("Index");
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error generating payroll: " + ex.Message;
                return View("index");
            }
        }
    }
}
