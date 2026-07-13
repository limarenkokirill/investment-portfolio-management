# ADR-001: Use UUID as Technical Primary Key

## Status

Accepted

---

## Context

The application requires a unique identifier for all business entities such as Investors, Portfolios, Securities, and Transactions.

Several options were considered:

- Sequential Number Range
- GUID / UUID

---

## Decision

The project will use UUID (SYSUUID_X16) as the technical primary key for all persistent business objects.

Business-readable numbers may be added later if required by business users, but they will not be used as primary keys.

---

## Rationale

Using UUID provides several advantages:

- Globally unique identifiers
- No dependency on number range objects
- Better support for distributed systems
- Simplified data migration
- Better compatibility with RAP
- Alignment with SAP ABAP Cloud recommendations

Separating technical identifiers from business identifiers also provides greater flexibility for future enhancements.

---

## Consequences

### Positive

- Better scalability
- Easier integrations
- Cleaner architecture
- Cloud-ready design
- Reduced coupling

### Negative

- UUIDs are not user-friendly
- Business users may require readable document numbers

This will be addressed by introducing separate business identifiers if needed.

---

## Alternatives Considered

### Sequential Number Range

Advantages:

- Easy for users to read
- Familiar business format

Disadvantages:

- Additional infrastructure
- Harder to migrate
- More difficult in distributed environments
- Less suitable for cloud-native applications

---

## References

- SAP ABAP Cloud Development Guidelines
- SAP RAP Best Practices
- Clean Core Principles
