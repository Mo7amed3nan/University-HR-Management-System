# Contributing Guidelines

## Introduction
This file documents project standards and testing guidelines for the University HR Management System SQL project. It defines coding style, testing framework and conventions contributors must follow.

## Coding Standards
- SQL keywords must be UPPERCASE.
- Indentation: 4 spaces.
- Statements should end with semicolons where appropriate.
- Object naming: PascalCase for tables and procedures. Columns and variables use snake_case or camelCase consistently as existing code.
- Use explicit column lists in INSERT statements.

## Testing Framework
- Use the tSQLt framework for unit tests (https://tsqlt.org/).
- Tests live in the repository under the `Tests` folder: `Tests/Phase1`, `Tests/Phase2`, etc.
- Each phase gets a test class (schema) named `Tests_Phase1`, `Tests_Phase2`, ... using `tSQLt.NewTestClass`.

## Test Conventions
- Test stored procedures must follow naming: `test_[ObjectUnderTest]__[Scenario]`.
- Each test must clearly separate Arrange / Act / Assert sections with comments.
- Tests must create any required rows and clean up after themselves; prefer using transactions or tSQLt's fake tables to avoid altering production data.
- Tests must be idempotent and not assume prior database state.
- Use tSQLt helpers: `FakeTable`, `SpyProcedure`, `AssertEquals`, `AssertEqualsString`, `AssertEqualsTable`.

## Running Tests
- Install tSQLt in the `University_HR_ManagementSystem_5` database.
- Run all tests: `EXEC tSQLt.RunAll;` or run per class: `EXEC tSQLt.Run 'Tests_Phase1';`.

## Test Coverage Requirements
- Unit tests must cover success and failure paths for every stored procedure and scalar function implemented in the project.
- For functions that return BIT or scalar values, include boundary tests and null/empty input tests.

## Pull Request Checklist
- Add tests for new procedures/functions.
- Ensure tests pass locally with `EXEC tSQLt.RunAll;` before opening a PR.
- Update this document if new shared test utilities are added.

## Examples
- Test name: `test_Create_Holiday__InsertsRow`.
- Test class: `Tests_Phase2`.

## Notes
- If a contributor wants to change coding standards, propose changes via a PR and include updated tests demonstrating conformance.