using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Uni_HR_Management_System.Filters
{
  public class AcademicAuthAttribute : ActionFilterAttribute
  {
    public override void OnActionExecuting(ActionExecutingContext context)
    {
      string role = context.HttpContext.Session.GetString("Role");

      // Check if Role is Academic
      if (string.IsNullOrEmpty(role) || role != "Academic")
      {
        context.Result = new RedirectToActionResult("Login", "Account", null);
      }
      base.OnActionExecuting(context);
    }
  }
}