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
│   ├── .gitignore                     # Local environment exclusions
│   ├── README.md                      # Assignment 1 overview
│   ├── brief.md                       # Project brief (Nouns & Verbs)
│   ├── http-log.md                    # Raw curl -i diagnostics
│   ├── network-analysis.md            # DevTools network profile
│   └── docs/
│       ├── assignment-1.md            # Assignment 1 summary notes
│       └── http-testing-guide.md     # HTTP testing instructions
│
├── Assignment-2/                      # Assignment 2: Services, Contracts & Schema
│   ├── README.md                      # Detailed Assignment 2 walkthrough
│   ├── ReadMe.pdf                     # Printable Assignment 2 brief
│   ├── design.pdf                     # Capabilities, contracts, and booking spec
│   ├── services.drawio                # Editable service architecture benchmark
│   ├── services.png                   # Exported service architecture image
│   ├── schema.drawio                  # Editable database ER diagram
│   ├── schema.png                     # Exported database schema image
│   └── schema.sql                     # PostgreSQL DDL (zero shared tables)
│
├── bookme_assignment4/                # Assignment 4: Booking Service & Payment Flow
│   ├── booking_service/
│   │   ├── NOTES.md                   # Booking service notes
│   │   ├── app.py                     # Booking service API implementation
│   │   ├── curl_transcript.txt        # API call transcript
│   │   ├── errors.py                  # Custom error handling
│   │   ├── models.py                  # Data models
│   │   ├── openapi.yaml               # Booking service OpenAPI contract
│   │   ├── payment_client.py          # Mock payment client interface
│   │   ├── pytest_output.txt          # Test output
│   │   ├── store.py                  # In-memory data store
│   │   ├── validator_output.txt       # Validation output
│   │   └── tests/                    # Service tests
│   └── mock_payments/
│       └── payments.py               # Mock payment simulation
│
├── BookMe_Assignment3/                # Assignment 3: SOAP Partner Integration
│   ├── integration.pdf                # SOAP integration architecture brief
│   ├── partner.wsdl                  # WSDL contract for partner integration
│   ├── soap-request.xml              # SOAP request with WS-Security header
│   ├── soap-response.xml             # SOAP success response envelope
│   └── soap-fault.xml                # SOAP fault response envelope
│
├── Assignment-5/                     # Assignment 5: API Validation & Contract Notes
│   ├── NOTES.md                      # Assignment 5 narrative notes
│   ├── curl-transcript.txt           # cURL validation transcript
│   ├── generate_transcript.js        # Transcript generation script
│   └── openapi.yaml                  # OpenAPI schema for validation
│
├── Assignment-6/                     # Assignment 6: API Design & Documentation
│   ├── NOTES.md                      # Assignment 6 notes
│   ├── openapi.yaml                  # OpenAPI specification
│   └── transcript.txt                # API interaction transcript
│
├── README.md                         # Repository overview (this file)
├── ReadMe.pdf                        # Submission brief with links and tasks
└── .gitignore                        # Optional repo-level ignore rules
```

---

## 📋 Assignments Overview

### 📝 [bookme/ (Assignment 1 — HTTP Diagnostics & Project Setup)](bookme/)
* **Files:** [`bookme/brief.md`](bookme/brief.md), [`bookme/http-log.md`](bookme/http-log.md), [`bookme/network-analysis.md`](bookme/network-analysis.md), [`bookme/docs/assignment-1.md`](bookme/docs/assignment-1.md), [`bookme/docs/http-testing-guide.md`](bookme/docs/http-testing-guide.md)
* **Summary:** Analysis of HTTP request/response headers, browser DevTools network waterfalls, and definition of initial BookMe system entities and operations.

### 🚀 [Assignment-2/ (Assignment 2 — Design BookMe: Services, Contracts & Schema)](Assignment-2/)
* **Files:**
  * [`design.pdf`](Assignment-2/design.pdf): 7 Capabilities (Task 1), Contracts (Task 3), `createBooking` Full Specification (Task 4), and Service Validation Table (Task 6).
  * [`services.drawio`](Assignment-2/services.drawio) / [`services.png`](Assignment-2/services.png): 4 microservices with explicit boundaries, data ownership, team members, and inter-service call operations.
  * [`schema.drawio`](Assignment-2/schema.drawio) / [`schema.png`](Assignment-2/schema.png): Database Entity-Relationship Diagram implementing private schemas and logical UUID references (Task 5).
  * [`schema.sql`](Assignment-2/schema.sql): PostgreSQL DDL table creation queries enforcing zero shared database tables (Task 5).
  * [`ReadMe.pdf`](Assignment-2/ReadMe.pdf) / [`README.md`](Assignment-2/README.md): Submission documentation and usage instructions.

### 🔧 [bookme_assignment4/ (Assignment 4 — Booking Service & Payment Flow)](bookme_assignment4/)
* **Files:**
  * [`booking_service/app.py`](bookme_assignment4/booking_service/app.py): Booking service API and orchestration logic.
  * [`booking_service/openapi.yaml`](bookme_assignment4/booking_service/openapi.yaml): Booking service contract specification.
  * [`booking_service/payment_client.py`](bookme_assignment4/booking_service/payment_client.py): Mock payment gateway integration logic.
  * [`mock_payments/payments.py`](bookme_assignment4/mock_payments/payments.py): Payment simulation implementation.

### 🔌 [BookMe_Assignment3/ (Assignment 3 — SOAP Partner Integration)](BookMe_Assignment3/)
* **Files:**
  * [`integration.pdf`](BookMe_Assignment3/integration.pdf): Architectural justification, HTTP binding, service discovery, and SOAP-to-REST fault mapping.
  * [`partner.wsdl`](BookMe_Assignment3/partner.wsdl): Formal WSDL 1.1 contract defining service endpoints and port types.
  * [`soap-request.xml`](BookMe_Assignment3/soap-request.xml): Hand-crafted XML envelope with WS-Security token.
  * [`soap-response.xml`](BookMe_Assignment3/soap-response.xml): Success SOAP response with transaction details.
  * [`soap-fault.xml`](BookMe_Assignment3/soap-fault.xml): Canonical SOAP fault envelope handling declined card scenarios.

### ✅ [Assignment-5/ (Assignment 5 — API Validation)](Assignment-5/)
* **Files:**
  * [`openapi.yaml`](Assignment-5/openapi.yaml): API schema used for validation and testing.
  * [`curl-transcript.txt`](Assignment-5/curl-transcript.txt): Execution transcript of HTTP request validation.
  * [`NOTES.md`](Assignment-5/NOTES.md): Summary of findings and implementation notes.

### 📘 [Assignment-6/ (Assignment 6 — API Design & Documentation)](Assignment-6/)
* **Files:**
  * [`openapi.yaml`](Assignment-6/openapi.yaml): Final API design specification.
  * [`NOTES.md`](Assignment-6/NOTES.md): Design rationale and documentation notes.
  * [`transcript.txt`](Assignment-6/transcript.txt): Supporting interaction transcript.
