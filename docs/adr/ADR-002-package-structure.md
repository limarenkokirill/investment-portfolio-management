ADR-002

Package Structure

Decision:

ZIPM

├── ZIPM_DOMAIN
├── ZIPM_EXPOSURE
├── ZIPM_INTEGRATION
└── ZIPM_TEST
Context

The application follows layered architecture with clear separation of responsibilities.

Decision

The project is divided into four top-level packages.

ZIPM_DOMAIN contains the business model and business logic.
ZIPM_EXPOSURE contains service projections and OData exposure.
ZIPM_INTEGRATION contains communication with external systems.
ZIPM_TEST contains automated tests.

Consequences

Clear separation of concerns.
Low coupling between subsystems.
Easy navigation inside ADT.
Straightforward future extension.
Alignment with Clean Architecture and SAP Clean Core principles.
