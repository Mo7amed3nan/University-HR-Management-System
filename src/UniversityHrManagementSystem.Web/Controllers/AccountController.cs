using Microsoft.AspNetCore.Mvc;
using Uni_HR_Management_System.Models;

namespace Uni_HR_Management_System.Controllers
{
  public class AccountController : Controller
  {

    private readonly UniversityHrManagementSystemContext _context;

    public AccountController(UniversityHrManagementSystemContext context)
    {
      _context = context;
    }

    public IActionResult Login()
    {
      return View();
    }

    [HttpPost]
    public IActionResult Login(string userName, string password)
    {
      if ((userName == "admin" || userName == "admin@guc.edu.eg") && password == "admin123")
      {
        HttpContext.Session.SetString("Role", "Admin");
        return RedirectToAction("Index", "Admin");
      }

      if (userName == "hr" && password == "hr123")
      {
        var hrUser = _context.Employees.FirstOrDefault(e => e.DeptName == "HR");
        if (hrUser != null)
        {
          HttpContext.Session.SetInt32("EmpId", hrUser.EmployeeId);
          HttpContext.Session.SetString("Role", "HR");
          return RedirectToAction("Index", "HR");
        }
      }

      if (userName == "dean" && password == "dean123")
      {
        var deanUser = _context.Employees.FirstOrDefault(e => e.RoleNames.Any(r => r.RoleName == "Dean" || r.RoleName == "Vice Dean" || r.RoleName == "President" || r.RoleName == "Vice President"));
        if (deanUser != null)
        {
          HttpContext.Session.SetInt32("EmpId", deanUser.EmployeeId);
          HttpContext.Session.SetString("Role", "Academic");
          HttpContext.Session.SetString("IsDean", "True");
          return RedirectToAction("Index", "Employee");
        }
      }

      if (userName == "employee" && password == "emp123")
      {
        var empUser = _context.Employees.FirstOrDefault(e => e.DeptName != "HR" && !e.RoleNames.Any(r => r.RoleName == "Dean" || r.RoleName == "Vice Dean" || r.RoleName == "President" || r.RoleName == "Vice President"));
        if (empUser != null)
        {
          HttpContext.Session.SetInt32("EmpId", empUser.EmployeeId);
          HttpContext.Session.SetString("Role", "Academic");
          HttpContext.Session.SetString("IsDean", "False");
          return RedirectToAction("Index", "Employee");
        }
      }

      if (int.TryParse(userName, out int empId))
      {
        var user = _context.Employees.FirstOrDefault(e => e.EmployeeId == empId && e.Password == password);

        if (user != null)
        {
          HttpContext.Session.SetInt32("EmpId", user.EmployeeId);

          if (user.DeptName == "HR")
          {
            HttpContext.Session.SetString("Role", "HR");
            return RedirectToAction("Index", "HR");
          }
          else
          {
            bool isUpperBoard = false;
            var empWithRoles = _context.Employees.Where(e => e.EmployeeId == empId).SelectMany(e => e.RoleNames).ToList();
            if(empWithRoles.Any(r => r.RoleName == "Dean" || r.RoleName == "Vice Dean" || r.RoleName == "President" || r.RoleName == "Vice President")) {
                isUpperBoard = true;
            }
            HttpContext.Session.SetString("Role", "Academic");
            HttpContext.Session.SetString("IsDean", isUpperBoard ? "True" : "False");
            return RedirectToAction("Index", "Employee");
          }
        }
      }
      ViewBag.Error = "Invalid ID or Password";
      return View();
    }

    public IActionResult Logout()
    {
      HttpContext.Session.Clear();
      return RedirectToAction("Login", "Account");
    }

  }
}
