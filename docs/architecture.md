# Architecture

## Overview

Investment Portfolio Management is a modern SAP ABAP Cloud application built on the SAP Business Technology Platform (SAP BTP) using the RESTful Application Programming Model (RAP).

The project follows SAP Clean Core principles and modern cloud development practices to ensure maintainability, scalability, and extensibility.

---

## Architecture Goals

The application is designed with the following goals:

- Follow SAP ABAP Cloud development guidelines
- Demonstrate RAP best practices
- Maintain a clean and modular architecture
- Separate business logic from service exposure
- Support future extensibility
- Use Git-based development workflow

---

## Package Structure

The project is organized into logical packages based on responsibilities.

### ZINVESTMENT

Root package of the application.

### ZINVESTMENT_DOMAIN

Contains the domain model.

Examples:

- Database Tables
- CDS View Entities
- Root Business Objects
- Value Helps

---

### ZINVESTMENT_APPLICATION

Contains the application logic.

Examples:

- Behavior Pools
- Determinations
- Validations
- Helper Classes
- Business Logic

---

### ZINVESTMENT_SERVICES

Contains service exposure artifacts.

Examples:

- Projection Views
- Metadata Extensions
- Service Definitions
- Service Bindings

---

### ZINVESTMENT_SHARED

Contains reusable components.

Examples:

- Constants
- Exceptions
- Utility Classes

---

### ZINVESTMENT_TEST

Contains automated tests.

Examples:

- ABAP Unit Tests
- Test Helpers

---

## Naming Conventions

The project follows a consistent naming convention.

| Artifact | Prefix | Example |
|----------|----------|---------|
| Database Table | ZTB_ | ZTB_PORTFOLIO |
| Interface View | ZI_ | ZI_Portfolio |
| Projection View | ZC_ | ZC_Portfolio |
| Behavior Pool | ZBP_ | ZBP_R_PORTFOLIO |
| Service Definition | ZUI_ | ZUI_INVESTMENT |
| Service Binding | ZUI_ | ZUI_INVESTMENT_O4 |
| Class | ZCL_ | ZCL_PORTFOLIO_CALCULATOR |
| Interface | ZIF_ | ZIF_PRICE_PROVIDER |

---

## Technical Principles

The application follows these principles:

- Cloud-ready development
- RAP Managed Business Objects
- CDS View Entities
- OData V4 Services
- Clean Core
- Object-Oriented ABAP
- Git-first development

---

## Technical Keys

All business entities use UUIDs as technical primary keys.

Business identifiers (for example, portfolio numbers) may be introduced later as separate business fields if required.

This approach improves scalability, integration capabilities, and aligns with SAP recommendations for cloud-native applications.

---

## Repository Structure

```
investment-portfolio-management/

docs/
src/
test/

README.md
LICENSE
CHANGELOG.md
```

---

## Future Improvements

Planned future enhancements include:

- Market data integration
- Currency conversion
- Portfolio analytics
- Dividend tracking
- Scheduled quote updates
- Performance dashboard
