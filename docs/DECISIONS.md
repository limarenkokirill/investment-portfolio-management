# Engineering Decisions

This document records the most important engineering decisions made during the development of Investment Portfolio Management (IPM).

The purpose of this document is not only to explain *what* decisions were made, but also *why* they were made.

The project follows the principle that every significant architectural decision should be documented.

---

# Decision Log

| ID | Decision | Status |
|----|----------|--------|
| DEC-001 | Use UUID as technical keys | Accepted |
| DEC-002 | Portfolio is the primary Business Object | Accepted |
| DEC-003 | Positions are calculated instead of stored | Accepted |
| DEC-004 | Architecture follows Clean Core principles | Accepted |
| DEC-005 | Business logic before technical implementation | Accepted |

---

# Decision Principles

When making architectural decisions, the following priorities are used:

1. Business requirements over technical convenience.
2. Simplicity over unnecessary complexity.
3. Readability over cleverness.
4. SAP best practices over legacy techniques.
5. Cloud-native design over on-premise habits.
6. Long-term maintainability over short-term speed.

---

# Review Process

Before implementing a new feature, the following questions should be answered:

- Why does this feature exist?
- Does it solve a real business problem?
- Is there a simpler solution?
- Does it comply with SAP ABAP Cloud guidelines?
- Will another developer understand this implementation one year later?

If one of these questions cannot be answered, the design should be reconsidered.
