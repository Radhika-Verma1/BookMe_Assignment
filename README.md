# BookMe — Web Services Assignments Repository (CS 543)

[![Course](https://img.shields.io/badge/Course-CS%20543%20Web%20Services-blue.svg)]()
[![Platform](https://img.shields.io/badge/Project-BookMe%20(Team%2011)-brightgreen.svg)]()
[![Repository](https://img.shields.io/badge/GitHub-BookMe__Assignment-orange.svg)](https://github.com/Radhika-Verma1/BookMe_Assignment)

This repository contains the CS 543 Web Services assignments for the **BookMe** project (AI-Powered Multi-Vendor Event Service Booking Platform).

---

### 👥 Team 11 Members & Service Ownership

| Member Name | University Roll No. | Assigned Service | Service Responsibilities & Data Owned |
| :--- | :--- | :--- | :--- |
| **Radhika Verma** | `20251651075` | **Auth Service** (`auth-service`) | Registration, JWT auth, RBAC (`users`, `user_credentials`, `user_sessions`) |
| **Nandini Kanaujiya** | `20251651061` | **Vendor Service** (`vendor-service`) | Profiles, catalogs, packages, calendar availability (`vendors`, `services`, `packages`, `availability`) |
| **Alka Jha** | `20251651013` | **Event & Booking Service** (`event-booking-service`) *(Central)* | Event containers, checklists, booking lifecycle (`events`, `bookings`, `checklist_items`) |
| **Alok Mishra** | `20251651014` | **Payment & Feedback Service** (`payment-feedback-service`) | Escrow transactions, vendor payouts, reviews, complaints (`payments`, `payouts`, `reviews`, `complaints`) |

---

## 🔗 Submission Links

* **GitHub Repository:** [https://github.com/Radhika-Verma1/BookMe_Assignment](https://github.com/Radhika-Verma1/BookMe_Assignment)
* **Working Demonstration (Google Drive):** [https://drive.google.com/drive/folders/YOUR_DEMO_FOLDER_LINK?usp=sharing](https://drive.google.com/drive/folders/YOUR_DEMO_FOLDER_LINK?usp=sharing)  
  *(Share setting: Configured with "anyone with the link" permissions)*

---

## 📂 Repository Structure

```
BookMe_Assignment/
├── bookme/                             # Assignment 1: HTTP by Hand & Project Setup
│   ├── brief.md                        # Project brief (Nouns & Verbs)
│   ├── http-log.md                     # Raw curl -i diagnostics
│   ├── network-analysis.md             # DevTools network profile
│   ├── README.md                       # Assignment 1 overview
│   └── docs/
│       ├── assignment-1.md
│       └── http-testing-guide.md
│
├── Assignment-2/                       # Assignment 2: Services, Contracts & Schema
│   ├── design.pdf                      # Capabilities, Contracts, createBooking Spec & Validation Table
│   ├── services.drawio                 # Editable Draw.io Service Architecture Benchmark
│   ├── services.png                    # Exported Service Architecture image
│   ├── schema.drawio                   # Editable Draw.io Database Schema ERD
│   ├── schema.png                      # Exported Database Schema image
│   ├── schema.sql                      # PostgreSQL CREATE TABLE DDL (Zero Shared Tables)
│   ├── README.md                       # Detailed Assignment 2 Walkthrough
│   └── ReadMe.pdf                      # Printable Assignment 2 Brief
│
├── BookMe_Assignment3/                 # Assignment 3: SOAP Partner Integration
│   ├── integration.pdf                 # SOAP integration architecture and design brief
│   ├── partner.wsdl                    # Web Service Description Language (WSDL 1.1) contract
│   ├── soap-request.xml                # SOAP Request with WS-Security header
│   ├── soap-response.xml               # SOAP success Response envelope
│   └── soap-fault.xml                  # SOAP Fault envelope for failed charges
│
├── README.md                           # Repository overview (this file)
└── ReadMe.pdf                          # Submission brief with links and tasks
```

---

## 📋 Assignments Overview

### 📝 [bookme/ (Assignment 1 — HTTP Diagnostics & Project Setup)](bookme/)
* **Files:** [`bookme/brief.md`](bookme/brief.md), [`bookme/http-log.md`](bookme/http-log.md), [`bookme/network-analysis.md`](bookme/network-analysis.md), [`bookme/docs/assignment-1.md`](bookme/docs/assignment-1.md).
* **Summary:** Analysis of HTTP request/response headers, browser DevTools network waterfalls, and definition of initial BookMe system entities and operations.

### 🚀 [Assignment-2/ (Assignment 2 — Design BookMe: Services, Contracts & Schema)](Assignment-2/)
* **Files:**
  * [`design.pdf`](Assignment-2/design.pdf): 7 Capabilities (Task 1), Contracts (Task 3), `createBooking` Full Specification (Task 4), and Service Validation Table (Task 6).
  * [`services.drawio`](Assignment-2/services.drawio) / [`services.png`](Assignment-2/services.png): 4 microservices with explicit boundaries, data ownership, team members, and inter-service call operations (Task 2).
  * [`schema.drawio`](Assignment-2/schema.drawio) / [`schema.png`](Assignment-2/schema.png): Database Entity-Relationship Diagram implementing private schemas and logical UUID references (Task 5).
  * [`schema.sql`](Assignment-2/schema.sql): PostgreSQL DDL table creation queries enforcing zero shared database tables (Task 5).
  * [`ReadMe.pdf`](Assignment-2/ReadMe.pdf) / [`README.md`](Assignment-2/README.md): Submission documentation and usage instructions.

### 🔌 [BookMe_Assignment3/ (Assignment 3 — SOAP Partner Integration)](BookMe_Assignment3/)
* **Files:**
  * [`integration.pdf`](BookMe_Assignment3/integration.pdf): Architectural justification, HTTP binding, service discovery, and SOAP-to-REST fault mapping.
  * [`partner.wsdl`](BookMe_Assignment3/partner.wsdl): Formal WSDL 1.1 contract defining service endpoints and port types.
  * [`soap-request.xml`](BookMe_Assignment3/soap-request.xml): Hand-crafted XML envelope with WS-Security token.
  * [`soap-response.xml`](BookMe_Assignment3/soap-response.xml): Success SOAP response with transaction details.
  * [`soap-fault.xml`](BookMe_Assignment3/soap-fault.xml): Canonical SOAP fault envelope handling declined card scenarios.
