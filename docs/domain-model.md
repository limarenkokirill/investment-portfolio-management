# Domain Model

Main business objects:

- Investor
- Portfolio
- Security
- Transaction
- Market Price

```mermaid
erDiagram
    INVESTOR ||--o{ PORTFOLIO : owns
    PORTFOLIO ||--o{ TRANSACTION : contains
    SECURITY ||--o{ MARKET_PRICE : has
    SECURITY ||--o{ TRANSACTION : referenced_by
```
