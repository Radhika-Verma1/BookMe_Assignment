# CS 543 Web Services — Assignment 2
## Design BookMe: Services, Contracts & Schema

[![Course](https://img.shields.io/badge/Course-CS%20543%20Web%20Services-blue.svg)]()
[![Assignment](https://img.shields.io/badge/Assignment-02%20of%2014-indigo.svg)]()
[![Platform](https://img.shields.io/badge/Platform-BookMe%20(Team%2011)-brightgreen.svg)]()

---

### 👥 Team 11 Members & Service Ownership

| Member Name | University Roll No. | Assigned Service | Owned Data (No Shared Tables) |
| :--- | :--- | :--- | :--- |
| **Radhika Verma** | `20251651075` | **Auth Service** (`auth-service`) | `users`, `user_credentials`, `user_sessions` |
| **Nandini Kanaujiya** | `20251651061` | **Vendor Service** (`vendor-service`) | `vendors`, `services`, `packages`, `availability` |
| **Alka Jha** | `20251651013` | **Event & Booking Service** (`event-booking-service`) *(Central Engine)* | `events`, `bookings`, `checklist_items` |
| **Alok Mishra** | `20251651014` | **Payment & Feedback Service** (`payment-feedback-service`) | `payments`, `payouts`, `reviews`, `complaints` |

---

## 🔗 Submission Links

* **GitHub Repository:** [https://github.com/Nandinikanaujiya/BookMe_Assignment](https://github.com/Nandinikanaujiya/BookMe_Assignment)
* **Working Demonstration (Google Drive):** [https://drive.google.com/drive/folders/YOUR_DEMO_FOLDER_LINK?usp=sharing](https://drive.google.com/drive/folders/YOUR_DEMO_FOLDER_LINK?usp=sharing)  
  *(Share setting: Anyone with the link can view)*

---

## 📦 Deliverables Summary

This directory contains the complete deliverables for **Assignment 2** as specified:

| Deliverable | File | Description |
| :--- | :--- | :--- |
| **Design Document** | [`design.pdf`](design.pdf) | Capabilities (Task 1), Contracts (Task 3), `createBooking` Full Specification (Task 4), Validation Table (Task 6). |
| **Service Architecture (Draw.io)** | [`services.drawio`](services.drawio) | Editable benchmark mapping 4 services, data ownership boundaries, and inter-service operations (Task 2). |
| **Service Architecture (Export)** | [`services.png`](services.png) | High-resolution exported image of the service architecture benchmark (Task 2). |
| **Database Schema (Draw.io)** | [`schema.drawio`](schema.drawio) | Editable Entity Relationship Diagram (ERD) defining private service schemas and decoupled logical references (Task 5). |
| **Database Schema (Export)** | [`schema.png`](schema.png) | High-resolution exported image of the database ER diagram (Task 5). |
| **Database DDL** | [`schema.sql`](schema.sql) | PostgreSQL table creation queries enforcing the strict Service Boundary Rule (Task 5). |
| **Submission Brief PDF** | [`ReadMe.pdf`](ReadMe.pdf) | Printable submission document covering all tasks, descriptions, and submission links. |

---

## 📋 Task Details & Design Benchmark

### Task 1: System Capabilities (The Verbs)
The primary functional capabilities (verbs) of the BookMe platform derived from Assignment 1's `brief.md`:
1. `registerAndAuthenticateUser`: Registers user accounts, securely hashes credentials, and issues scoped JWT tokens.
2. `manageVendorCatalog`: Onboards vendor business profiles, configures catalog services, and creates package bundles.
3. `manageCalendarAvailability`: Inspects schedules, queries open slots, and provides atomic calendar reservation guards against double-booking.
4. `planEventAndBudget`: Organizes customer event metadata, maintains task checklists, and monitors vendor costs against budget ceilings.
5. `createBooking`: Orchestrates multi-vendor booking workflows, freezes rate snapshots, and advances booking lifecycle states (`pending` ➔ `confirmed` ➔ `completed` ➔ `cancelled`).
6. `processEscrowPayment`: Charges customer payment methods, places funds into escrow, handles gateway webhooks, and executes vendor payouts.
7. `submitFeedbackAndDisputes`: Records customer ratings and reviews to calibrate vendor reputation, and arbitrates customer complaints.

---

### Task 2: Service Design Benchmark
The architecture diagram models the 4 microservices with explicit data boundaries:
* **Auth Service** owns identity & sessions (`users`, `user_credentials`, `user_sessions`).
* **Vendor Service** owns vendor profiles, services, packages, and calendar availability (`vendors`, `services`, `packages`, `availability`).
* **Event & Booking Service** owns events, checklists, and booking tickets (`events`, `bookings`, `checklist_items`).
* **Payment & Feedback Service** owns escrow payments, payouts, reviews, and disputes (`payments`, `payouts`, `reviews`, `complaints`).

**Cross-Service Call Operations:**
* `event-booking-service` ➔ `auth-service`: `verifyCustomer`
* `event-booking-service` ➔ `vendor-service`: `checkAvailability`
* `event-booking-service` ➔ `vendor-service`: `reserveSlot`
* `event-booking-service` ➔ `payment-feedback-service`: `initiatePayment`
* `payment-feedback-service` ➔ `event-booking-service`: `updateBookingStatus`
* `payment-feedback-service` ➔ `vendor-service`: `getVendorPayoutAccount`

---

### Task 3: Service API Contracts
Contracts define operation signatures, inputs, outputs, and errors while strictly concealing database schemas and internal SQL:
* **Event & Booking Service (Main):** `createBooking`, `getBookingStatus`, `cancelBooking`, `createEvent`, `updateChecklist`.
* **Vendor Service (Main):** `getVendorCatalog`, `checkAvailability`, `reserveSlot`, `createService`, `createPackage`.
* **Auth Service:** `registerUser`, `authenticateUser`, `verifyCustomer`.
* **Payment & Feedback Service:** `initiatePayment`, `processPayout`, `submitReview`, `fileComplaint`.

---

### Task 4: Detailed Specification of Central Operation (`createBooking`)
* **Endpoint:** `POST /api/v1/bookings` (in `event-booking-service`)
* **Inputs:** `eventId` (UUID), `vendorId` (String), `packageId` (String), `date` (ISO Date), `customizationNotes` (String).
* **Outputs:** `bookingId` (UUID), `eventId` (UUID), `status: 'pending'`, `vendorNameSnapshot` (String), `priceSnapshot` (Decimal), `date` (Date), `createdAt` (Timestamp).
* **Errors:** `400 Bad Request` (`INVALID_BOOKING_DATE`), `401 Unauthorized` (`UNAUTHENTICATED`), `404 Not Found` (`EVENT_NOT_FOUND`, `PACKAGE_NOT_FOUND`), `409 Conflict` (`SLOT_UNAVAILABLE`), `422 Unprocessable` (`BUDGET_EXCEEDED`), `503 Unavailable` (`VENDOR_SERVICE_TIMEOUT`).
* **Encapsulated Details Hidden from Caller:**
  - Internal database tables (`bookings` row insertion, event budget mutation, checklist milestone generation).
  - Synchronous two-phase availability verification and slot reservation with compensation rollback on payment failure.
  - Snapshotting catalog rates to protect against post-booking price revisions.
  - Asynchronous event bus publication (`order.booking_created`) to decouple background email/notification alerts.

---

### Task 5: Database Schema & Service Boundary Rules
* **Strict Boundary Rule:** No table belongs to more than one service. Under no circumstance does any service directly join or query tables owned by another service.
* **Decoupled References:** All cross-service associations (such as `bookings.vendor_id` or `payments.booking_id`) are stored as logical UUID/string attributes, avoiding cross-database foreign key constraints.
* **DDL Implementation:** [`schema.sql`](schema.sql) contains full, valid PostgreSQL DDL with primary keys, indexes, check constraints, and timestamps.

---

### Task 6: Five Properties of a Service Validation
1. **Reachable:** All 4 services expose standards-compliant REST/HTTP endpoints over defined ports and API gateway paths.
2. **Self-Contained:** Every service owns its database and business logic without cross-boundary shared state.
3. **Has a Contract:** Formal input/output payloads and RFC 7807 problem details are established in contracts.
4. **Independent:** Each service can be built, updated, tested, and horizontally scaled without disrupting others.
5. **Loosely Coupled:** Services interact via decoupled logical IDs; synchronous bottlenecks (like `checkAvailability`) are mitigated using cache-fallback and transactional outbox/saga patterns.

---

## 🛠️ Verification & Usage Instructions

1. **Viewing / Editing Diagrams:**
   - Open [draw.io (diagrams.net)](https://app.diagrams.net/).
   - Click **Open Existing Diagram** and select `services.drawio` or `schema.drawio`.
   - Both files are fully editable benchmarks.
2. **Executing Database Schema:**
   - Run in any PostgreSQL instance:
     ```bash
     psql -U postgres -d bookme -f schema.sql
     ```
