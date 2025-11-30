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
      if (userName == "admin@guc.edu.eg" && password == "admin123")
      {
        //HttpContext.Session.SetString("Role", "Admin");
        return RedirectToAction("Index", "Admin");
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
            HttpContext.Session.SetString("Role", "Academic");
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
