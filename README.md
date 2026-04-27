# University HR Management System

A full-stack university Human Resources management platform that supports employee workflows, HR operations, and administrative management.

This repository has been reorganized into a professional, component-based structure with clear separation between application code, database assets, and documentation.

## Tech Stack

- C#
- ASP.NET Core MVC (.NET 8)
- SQL Server (SSDT SQL Project + SQL scripts)
- Entity Framework Core
- HTML, CSS, Bootstrap

## Prerequisites

- .NET SDK 8.0+
- Visual Studio 2022 (recommended) or VS Code with C# tooling
- SQL Server (LocalDB / SQL Server Express / full SQL Server)
- SQL Server Data Tools (SSDT) for building `.sqlproj` projects (if building DB project from IDE)

## Getting Started

### 1) Clone and Restore

```powershell
git clone <your-repository-url>
cd University-HR-Management-System
dotnet restore .\src\UniversityHrManagementSystem.sln
```

### 2) Build the ASP.NET Core Solution

```powershell
dotnet build .\src\UniversityHrManagementSystem.sln -c Debug
```

### 3) Configure the Web Application

- Update connection strings in `src/UniversityHrManagementSystem.Web/appsettings.json`.
- Optionally set environment-specific values in `src/UniversityHrManagementSystem.Web/appsettings.Development.json`.

### 4) Run the Web Application

```powershell
dotnet run --project .\src\UniversityHrManagementSystem.Web\UniversityHrManagementSystem.Web.csproj
```

The app will start using the launch profile and URLs configured in `src/UniversityHrManagementSystem.Web/Properties/launchSettings.json`.

### 5) Initialize Database

You can use either option:

- Option A: Use the SQL project in Visual Studio:
  - Open `database/UniversityHrManagementSystem.Database.sln`
  - Build and publish `UniversityHrManagementSystem.Database.sqlproj` to your SQL Server instance

- Option B: Execute SQL scripts manually in SQL Server Management Studio:
  - `database/UniversityHrManagementSystem.Database/queries/final_implementation.sql`
  - `database/UniversityHrManagementSystem.Database/AI Generated insertions.sql`
  - `database/UniversityHrManagementSystem.Database/insertions updated.sql`

Run schema scripts first, then data insertion scripts.

## Project Structure

```text
.
├── src/
│   ├── UniversityHrManagementSystem.sln
│   └── UniversityHrManagementSystem.Web/
├── database/
│   ├── UniversityHrManagementSystem.Database.sln
│   └── UniversityHrManagementSystem.Database/
│       ├── UniversityHrManagementSystem.Database.sqlproj
│       ├── queries/
│       └── insertion scripts
├── docs/
│   └── CONTRIBUTING.md
├── .gitignore
└── README.md
```

## Notes

- Generated build artifacts (`bin/`, `obj/`, `*.dll`, `*.pdb`, `*.dacpac`, `*.cache`) are intentionally ignored.
- Milestone-based folder naming has been removed in favor of `src/`, `database/`, and `docs/`.
