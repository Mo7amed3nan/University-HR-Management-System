using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using WebApplication_University_HR_System.Models;
using System.Collections.Generic;
using System;

namespace WebApplication_University_HR_System.Controllers
{
    public class AdminController : Controller
    {
        private readonly DB _db;

        public AdminController(DB db)
        {
            _db = db;
        }

        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Login(string adminID, string password)
        {
            if (adminID == "ziad" && password == "ziad")
            {
                return RedirectToAction("Index");
            }
            else
            {
                ViewBag.Message = "Invalid credentials";
                return View();
            }
        }

        public IActionResult Index()
        {
            return View();
        }

      
        public IActionResult ViewAllEmployees()
        {
            List<AllEmployeeProfile> employeeList = new List<AllEmployeeProfile>();

            using (SqlConnection conn = _db.Connect())
            {
                conn.Open();
                string query = "SELECT * FROM allEmployeeProfiles";
                SqlCommand cmd = new SqlCommand(query, conn);
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    AllEmployeeProfile e = new AllEmployeeProfile()
                    {
                        // Map SQL Column Names -> C# Generated Properties
                        EmployeeId = (int)reader["employee_ID"],
                        FirstName = reader["first_name"].ToString(),
                        LastName = reader["last_name"].ToString(),
                        Email = reader["email"].ToString(),
                        Address = reader["address"].ToString(),
                        Gender = reader["gender"].ToString(),
                        OfficialDayOff = reader["official_day_off"].ToString(),
                        TypeOfContract = reader["type_of_contract"].ToString(),
                        EmploymentStatus = reader["employment_status"].ToString(),

                        // Handle Integers that might be NULL
                        YearsOfExperience = reader["years_of_experience"] == DBNull.Value ? 0 : (int)reader["years_of_experience"],
                        AnnualBalance = reader["annual_balance"] == DBNull.Value ? 0 : (int)reader["annual_balance"],
                        AccidentalBalance = reader["accidental_balance"] == DBNull.Value ? 0 : (int)reader["accidental_balance"]
                    };
                    employeeList.Add(e);
                }
            }
            return View(employeeList);
        }


        public IActionResult ViewDepartmentStats()
        {
            List<NoEmployeeDept> statsList = new List<NoEmployeeDept>();

            using (SqlConnection conn = _db.Connect())
            {
                conn.Open();
                string query = "SELECT * FROM NoEmployeeDept";
                SqlCommand cmd = new SqlCommand(query, conn);
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    NoEmployeeDept stats = new NoEmployeeDept()
                    {
                        Department = reader["Department"].ToString(),
                        NumberOfEmployees = reader["Number of Employees"] == DBNull.Value ? 0 : (int)reader["Number of Employees"]
                    };
                    statsList.Add(stats);
                }
            }
            return View(statsList);
        }

        
        public IActionResult ViewRejectedMedicalLeaves()
        {
            List<AllRejectedMedical> leavesList = new List<AllRejectedMedical>();

            using (SqlConnection conn = _db.Connect())
            {
                conn.Open();
                string query = "SELECT * FROM allRejectedMedicals";
                SqlCommand cmd = new SqlCommand(query, conn);

                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    AllRejectedMedical leave = new AllRejectedMedical()
                    {
                        request_ID = (int)reader["request_ID"],
                        emp_ID = (int)reader["Emp_ID"], // Note: View might use 'Emp_ID' (check case)

                        // Handle Dates
                        date_of_request = Convert.ToDateTime(reader["date_of_request"]),
                        start_date = Convert.ToDateTime(reader["start_date"]),
                        end_date = Convert.ToDateTime(reader["end_date"]),

                        // Handle Integers
                        num_days = reader["num_days"] == DBNull.Value ? 0 : (int)reader["num_days"],

                        final_approval_status = reader["final_approval_status"].ToString(),

                        // Handle BIT (Boolean)
                        insurance_status = reader["insurance_status"] != DBNull.Value && (bool)reader["insurance_status"],

                        disability_details = reader["disability_details"].ToString(),
                        type = reader["type"].ToString()
                    };
                    leavesList.Add(leave);
                }
            }
            return View(leavesList);
        }

        // ==========================================
        // 5. Add Official Holiday (Requirement 7)
        // ==========================================
        public IActionResult AddHoliday()
        {
            return View();
        }

        [HttpPost]
        public IActionResult AddHoliday(string name, DateTime start_date, DateTime end_date)
        {
            using (SqlConnection conn = _db.Connect())
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("Add_Holiday", conn);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@holiday_name", name);
                cmd.Parameters.AddWithValue("@from_date", start_date);
                cmd.Parameters.AddWithValue("@to_date", end_date);

                cmd.ExecuteNonQuery();
            }
            TempData["Message"] = "Holiday added successfully!";
            return RedirectToAction("Index");
        }
    }
}