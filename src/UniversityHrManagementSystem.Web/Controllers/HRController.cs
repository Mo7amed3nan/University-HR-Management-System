using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using System;
using Uni_HR_Management_System.Filters;
using Uni_HR_Management_System.Models;

namespace Uni_HR_Management_System.Controllers
{
    [HRAuth] // Protects the Controller
    public class HRController : Controller
    {
        private readonly UniversityHrManagementSystemContext _context;

        public HRController(UniversityHrManagementSystemContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            return View();
        }

        // =========================================================================
        // REQUIREMENT 2: Approve/Reject Annual & Accidental Leaves
        // =========================================================================
        [HttpGet]
        public async Task<IActionResult> ProcessAnnualAccidentalLeaves()
        {
            int? hrId = HttpContext.Session.GetInt32("EmpId");

            // 1. Fetch Annual Leaves assigned to this HR
            var annual = await _context.AnnualLeaves
                .Include(a => a.Request)
                .Where(a => a.Request.FinalApprovalStatus == "Pending" &&
                            a.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == hrId && e.Status == "Pending"))
                .Select(a => new ConsolidatedLeaveViewModel
                {
                    RequestId = a.RequestId,
                    Type = "Annual Leave",
                    StartDate = a.Request.StartDate,
                    EndDate = a.Request.EndDate
                }).ToListAsync();

            // 2. Fetch Accidental Leaves assigned to this HR
            var accidental = await _context.AccidentalLeaves
                .Include(a => a.Request)
                .Where(a => a.Request.FinalApprovalStatus == "Pending" &&
                            a.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == hrId && e.Status == "Pending"))
                .Select(a => new ConsolidatedLeaveViewModel
                {
                    RequestId = a.RequestId,
                    Type = "Accidental Leave",
                    StartDate = a.Request.StartDate,
                    EndDate = a.Request.EndDate
                }).ToListAsync();

            // 3. Combine them
            var combinedList = annual.Concat(accidental).ToList();

            return View(combinedList);
        }

        [HttpPost]
        public async Task<IActionResult> ProcessAnnualAccidentalLeaves(int requestId)
        {
            int? hrId = HttpContext.Session.GetInt32("EmpId");
            try
            {
                // SP: HR_approval_an_acc
                string sql = "EXEC HR_approval_an_acc @request_ID={0}, @HR_ID={1}";
                await _context.Database.ExecuteSqlRawAsync(sql, requestId, hrId);
                TempData["Message"] = $"Leave {requestId} processed successfully.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error processing leave: " + ex.Message;
            }
            return RedirectToAction(nameof(ProcessAnnualAccidentalLeaves));
        }

        // =========================================================================
        // REQUIREMENT 3: Approve/Reject Unpaid Leaves
        // =========================================================================
        [HttpGet]
        public async Task<IActionResult> ProcessUnpaidLeaves()
        {
            int? hrId = HttpContext.Session.GetInt32("EmpId");

            var list = await _context.UnpaidLeaves
                .Include(u => u.Request)
                .Where(u => u.Request.FinalApprovalStatus == "Pending" &&
                            u.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == hrId && e.Status == "Pending"))
                .Select(u => new ConsolidatedLeaveViewModel
                {
                    RequestId = u.RequestId,
                    Type = "Unpaid Leave",
                    StartDate = u.Request.StartDate,
                    EndDate = u.Request.EndDate
                }).ToListAsync();

            return View(list);
        }

        [HttpPost]
        public async Task<IActionResult> ProcessUnpaidLeaves(int requestId)
        {
            int? hrId = HttpContext.Session.GetInt32("EmpId");
            try
            {
                // SP: HR_approval_unpaid
                string sql = "EXEC HR_approval_unpaid @request_ID={0}, @HR_ID={1}";
                await _context.Database.ExecuteSqlRawAsync(sql, requestId, hrId);
                TempData["Message"] = $"Unpaid Leave {requestId} processed.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
            }
            return RedirectToAction(nameof(ProcessUnpaidLeaves));
        }

        // =========================================================================
        // REQUIREMENT 4: Approve/Reject Compensation Leaves
        // =========================================================================
        [HttpGet]
        public async Task<IActionResult> ProcessCompensationLeaves()
        {
            int? hrId = HttpContext.Session.GetInt32("EmpId");

            var list = await _context.CompensationLeaves
                .Include(c => c.Request)
                .Where(c => c.Request.FinalApprovalStatus == "Pending" &&
                            c.Request.EmployeeApproveLeaves.Any(e => e.Emp1Id == hrId && e.Status == "Pending"))
                .Select(c => new ConsolidatedLeaveViewModel
                {
                    RequestId = c.RequestId,
                    Type = "Compensation Leave",
                    StartDate = c.Request.StartDate,
                    EndDate = c.Request.EndDate
                }).ToListAsync();

            return View(list);
        }

        [HttpPost]
        public async Task<IActionResult> ProcessCompensationLeaves(int requestId)
        {
            int? hrId = HttpContext.Session.GetInt32("EmpId");
            try
            {
                // SP: HR_approval_comp
                string sql = "EXEC HR_approval_comp @request_ID={0}, @HR_ID={1}";
                await _context.Database.ExecuteSqlRawAsync(sql, requestId, hrId);
                TempData["Message"] = $"Compensation Leave {requestId} processed.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error: " + ex.Message;
            }
            return RedirectToAction(nameof(ProcessCompensationLeaves));
        }

        // =========================================================================
        // REQUIREMENT 5, 6, 7: Deductions
        // =========================================================================

        [HttpGet]
        public IActionResult ApplyDeduction()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> ApplyDeduction(int empId, string type)
        {
            try
            {
                string sql = "";
                if (type == "MissingHours")
                    sql = "EXEC Deduction_hours @employee_ID={0}";
                else if (type == "MissingDays")
                    sql = "EXEC Deduction_days @employee_ID={0}";
                else if (type == "Unpaid")
                    sql = "EXEC Deduction_unpaid @employee_ID={0}";

                await _context.Database.ExecuteSqlRawAsync(sql, empId);
                TempData["Message"] = $"Deduction ({type}) applied successfully for Employee {empId}.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Deduction Failed: " + ex.Message;
            }
            return RedirectToAction(nameof(ApplyDeduction));
        }

        // =========================================================================
        // REQUIREMENT 8: Generate Payroll
        // =========================================================================

        [HttpGet]
        public IActionResult GeneratePayroll()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> GeneratePayroll(int empId, DateTime from, DateTime to)
        {
            try
            {
                // SP: Add_Payroll
                string sql = "EXEC Add_Payroll @employee_ID={0}, @from={1}, @to={2}";
                await _context.Database.ExecuteSqlRawAsync(sql, empId, from, to);
                TempData["Message"] = $"Payroll generated for Employee {empId}.";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Payroll generation failed: " + ex.Message;
            }
            return RedirectToAction(nameof(GeneratePayroll));
        }
    }
}