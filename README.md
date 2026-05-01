<div align="center">
  <img src="https://img.icons8.com/color/96/000000/university.png" alt="University HR System Logo" width="80" />
  
  # University HR Management System 🎓💼

  A full-stack, enterprise-grade Human Resources management platform built for modern universities. It streamlines employee workflows, HR operations, payroll, attendance, and administrative management through a highly secure, role-based architecture.

  [![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet)](https://dotnet.microsoft.com/)
  [![ASP.NET Core](https://img.shields.io/badge/ASP.NET_Core-MVC-512BD4?style=for-the-badge&logo=dotnet)](https://learn.microsoft.com/en-us/aspnet/core/mvc/overview?view=aspnetcore-8.0)
  [![SQL Server](https://img.shields.io/badge/SQL_Server-Database-CC2927?style=for-the-badge&logo=microsoft-sql-server)](https://www.microsoft.com/en-us/sql-server)
  [![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-7952B3?style=for-the-badge&logo=bootstrap)](https://getbootstrap.com/)
</div>

---

## ✨ Key Features

*   **🔒 Role-Based Access Control (RBAC):** Tailored dashboards and permissions for **Admins, HR Officers, Deans/HODs, and Standard Employees**.
*   **🌌 Modern & Responsive UI:** A custom, futuristic "Glassmorphism" interface with neon accents, smooth transitions, and a mobile-first responsive grid.
*   **🏖️ Comprehensive Leave Management:** Automated workflows for requesting, evaluating, and approving Annual, Medical, Accidental, Unpaid, and Compensation leaves.
*   **⏱️ Attendance Tracking:** Real-time logging and heuristic evaluation of daily employee attendance and performance.
*   **💰 Payroll & Deductions:** Automated monthly payroll generation, dynamic deduction calculation, and clear financial breakdowns for employees.
*   **📊 Department Statistics:** Granular reporting on departmental efficiency, rejected leaves, and staff performance metrics.

---

## 🛠️ Tech Stack

*   **Backend:** C#, ASP.NET Core MVC (.NET 8)
*   **Database:** Microsoft SQL Server, Entity Framework Core (ADO.NET integrations)
*   **Frontend:** HTML5, Custom Modular CSS (Variables, Layout, Components), Bootstrap 5, FontAwesome
*   **Tools:** Visual Studio 2022, SQL Server Data Tools (SSDT)

---

## 🚀 Getting Started

### Prerequisites

*   [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) or newer
*   [Visual Studio 2022](https://visualstudio.microsoft.com/) (Recommended)
*   SQL Server (LocalDB, Express, or Full)

### Installation & Setup

**1. Clone the Repository**
```bash
git clone https://github.com/your-username/University-HR-Management-System.git
cd University-HR-Management-System
```

**2. Initialize the Database**
*   **Option A (Visual Studio):** Open `database/UniversityHrManagementSystem.Database.sln` and publish the `.sqlproj` to your SQL Server instance.
*   **Option B (Manual scripts):** Execute the SQL schema and data insertion scripts located in `database/UniversityHrManagementSystem.Database/queries/` using SQL Server Management Studio (SSMS).

**3. Configure the Application**
*   Open `src/UniversityHrManagementSystem.Web/appsettings.json`.
*   Update the `"DefaultConnection"` string to point to your local SQL Server instance.

**4. Build and Run**
```bash
dotnet restore .\src\UniversityHrManagementSystem.sln
dotnet build .\src\UniversityHrManagementSystem.sln -c Debug
dotnet run --project .\src\UniversityHrManagementSystem.Web\UniversityHrManagementSystem.Web.csproj
```
The application will launch on `https://localhost:port`.

---

## 📂 Project Structure

```text
University-HR-Management-System/
├── src/
│   ├── UniversityHrManagementSystem.sln            # Main solution file
│   └── UniversityHrManagementSystem.Web/           # ASP.NET Core MVC project
│       ├── Controllers/                            # App logic & routing
│       ├── Views/                                  # Razor views (.cshtml)
│       └── wwwroot/                                # Static assets (CSS, JS)
├── database/
│   ├── UniversityHrManagementSystem.Database.sln   # SSDT project
│   └── UniversityHrManagementSystem.Database/      # Schema and seed data
└── docs/
    └── CONTRIBUTING.md                             # Contribution guidelines
```

---

## 📸 Screenshots

![alt text](docs/images/image.png)



<!-- Replace the paths below with actual image paths once you take screenshots -->
- **Login Screen:** <br> `<img src="docs/images/login.png" width="600" alt="Login Screen">`
- **Admin Dashboard:** <br> `<img src="docs/images/admin.png" width="600" alt="Admin Dashboard">`
- **Employee View:** <br> `<img src="docs/images/employee.png" width="600" alt="Employee View">`

---

## 🤝 Contributors

- **Mohamed Enan** - [LinkedIn Profile](https://www.linkedin.com/in/mohamed-enan/)
- **[Contributor Name]** - [LinkedIn Profile](https://www.linkedin.com/)
- **[Contributor Name]** - [LinkedIn Profile](https://www.linkedin.com/)
