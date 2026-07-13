# Functional Specification

## Project Overview

Investment Portfolio Management (IPM) is a cloud-native SAP ABAP application designed to help investors manage investment portfolios, record financial transactions, and monitor portfolio performance.

The application is built using SAP ABAP Cloud, the RESTful Application Programming Model (RAP), and SAP BTP, following Clean Core principles and modern SAP development practices.

---

# Business Objectives

The application aims to:

- Manage investment portfolios
- Track investment transactions
- Maintain financial instruments
- Monitor market prices
- Calculate portfolio value
- Calculate investment performance
- Demonstrate enterprise-grade SAP ABAP Cloud development

---

# Target Users

The primary users of the application are:

- Private investors
- Financial advisors
- Portfolio managers

---

# Functional Scope

## Investor Management

The system shall allow users to:

- Create investors
- Update investor information
- View investor details
- Assign portfolios to investors

---

## Portfolio Management

The system shall allow users to:

- Create investment portfolios
- Update portfolio information
- Close portfolios
- View portfolio summaries

Each portfolio shall contain:

- Portfolio Name
- Base Currency
- Status
- Creation Date

---

## Security Management

The system shall maintain financial instruments.

Supported security types:

- Stock
- ETF
- Bond

Each security shall include:

- ISIN
- Ticker
- Name
- Exchange
- Currency
- Security Type

---

## Transaction Management

Users shall be able to record:

- Buy transactions
- Sell transactions

Each transaction shall include:

- Portfolio
- Security
- Quantity
- Price
- Currency
- Trade Date

---

## Market Price Management

The system shall maintain market prices.

Each price record shall contain:

- Security
- Price
- Currency
- Timestamp

Initially, market prices will be entered manually.

Automatic price import will be implemented in a future release.

---

## Portfolio Valuation

The system shall calculate:

- Current portfolio value
- Position value
- Total invested amount
- Unrealized profit/loss

---

# Business Rules

## BR-001

A Portfolio belongs to exactly one Investor.

---

## BR-002

An Investor may own multiple Portfolios.

---

## BR-003

A Portfolio may contain multiple Transactions.

---

## BR-004

A Transaction references exactly one Security.

---

## BR-005

Portfolio positions are calculated from Transactions.

Positions are not stored as persistent database records.

---

## BR-006

Market Prices are maintained independently from Transactions.

---

## BR-007

Technical identifiers use UUID.

Business-readable numbers may be introduced later.

---

## BR-008

Deleting a Portfolio also deletes all associated Transactions.

---

# Non-Functional Requirements

The application shall:

- Follow SAP Clean Core principles
- Use RAP Managed Business Objects
- Use CDS View Entities
- Expose OData V4 services
- Follow Object-Oriented ABAP
- Be Git version controlled
- Be cloud-ready

---

# Out of Scope

The first version will not include:

- User authentication
- Authorization management
- Real-time stock exchange integration
- Dividend processing
- Tax calculation
- Cryptocurrency
- Mutual funds
- Options trading
- Multi-currency valuation
- Risk analysis

---

# Future Enhancements

Planned future features include:

- Automatic market data import
- Currency conversion
- Dividend management
- Portfolio analytics
- Investment dashboard
- Watchlists
- Scheduled background jobs
- REST API integration
- Unit testing coverage
- CI/CD pipeline

---

# Technology Stack

- SAP ABAP Cloud
- SAP BTP ABAP Environment
- RAP
- CDS View Entities
- OData V4
- ABAP Development Tools (ADT)
- Git
- GitHub

---

# Success Criteria

The project is considered successful if it:

- Demonstrates modern SAP development practices
- Covers the core topics of the SAP Backend Developer - ABAP Cloud certification
- Serves as a professional GitHub portfolio project
- Is deployable and maintainable
- Can be extended with additional business features
