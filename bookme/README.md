# BookMe — AI-Powered Multi-Vendor Event Service Booking Platform

[![Course](https://img.shields.io/badge/Course-CS%20543%20Web%20Services-blue.svg)]()
[![Platform](https://img.shields.io/badge/Project-BookMe%20(Team%2011)-brightgreen.svg)]()
[![Repository](https://img.shields.io/badge/GitHub-BookMe__Assignment-orange.svg)](https://github.com/Nandinikanaujiya/BookMe_Assignment)

BookMe connects customers with event service vendors (photography, catering, DJ, decoration, makeup, lighting, transport and more) for weddings, birthdays, engagements, anniversaries and corporate events.

---

### 👥 Team 11 Members & Service Ownership

| Member Name | University Roll No. | Assigned Service | Service Responsibilities & Owned Data |
| :--- | :--- | :--- | :--- |
| **Radhika Verma** | `20251651075` | **Auth Service** (`auth-service`) | Registration, JWT auth, RBAC (`users`, `user_credentials`, `user_sessions`) |
| **Nandini Kanaujiya** | `20251651061` | **Vendor Service** (`vendor-service`) | Profiles, catalogs, packages, calendar availability (`vendors`, `services`, `packages`, `availability`) |
| **Alka Jha** | `20251651013` | **Event & Booking Service** (`event-booking-service`) *(Central)* | Event containers, checklists, booking lifecycle (`events`, `bookings`, `checklist_items`) |
| **Alok Mishra** | `20251651014` | **Payment & Feedback Service** (`payment-feedback-service`) | Escrow transactions, vendor payouts, reviews, complaints (`payments`, `payouts`, `reviews`, `complaints`) |

---

## 🔗 Submission & Demonstration Links

* **GitHub Repository:** [https://github.com/Nandinikanaujiya/BookMe_Assignment](https://github.com/Nandinikanaujiya/BookMe_Assignment)
* **Working Demonstration (Google Drive):** [https://drive.google.com/drive/folders/YOUR_DEMO_FOLDER_LINK?usp=sharing](https://drive.google.com/drive/folders/YOUR_DEMO_FOLDER_LINK?usp=sharing) *(Share setting: Anyone with the link can view)*

---

## 📂 Repository Structure
```
BookMe_Assignment/
├── README.md                           # Top-level repository overview
├── ReadMe.pdf                          # Top-level submission document with demo & repo links
├── bookme/                             # Assignment 1: HTTP Diagnostics & Project Setup
│   ├── README.md                       # Assignment 1 overview (this file)
│   ├── brief.md                        # Assignment 1 brief (Nouns & Verbs)
│   ├── http-log.md                     # Raw curl -i diagnostics
│   ├── network-analysis.md             # DevTools network profiling
│   └── docs/
│       ├── assignment-1.md             # Assignment 1 status & summary
│       └── http-testing-guide.md       # Curl reproduction guide
└── Assignment-2/                       # Assignment 2: Services, Contracts & Schema
    ├── README.md                       # Assignment 2 documentation
    ├── ReadMe.pdf                      # Printable Assignment 2 Brief
    ├── design.pdf                      # Capabilities, Contracts & createBooking spec
    ├── services.drawio                 # Editable Service Design Benchmark (Draw.io)
    ├── services.png                    # Exported Service Architecture image
    ├── schema.drawio                   # Editable Database Schema ERD (Draw.io)
    ├── schema.png                      # Exported Database Schema image
    └── schema.sql                      # PostgreSQL CREATE TABLE DDL sketch
```

---

## 📦 Deliverables Summary

### 📝 Assignment 1 Deliverables (HTTP Diagnostics & Project Setup)
| Deliverable | File Location | Status |
| :--- | :--- | :--- |
| Project overview | [README.md](README.md) | ✅ Complete |
| HTTP by hand with curl | [http-log.md](http-log.md) | ✅ Complete |
| DevTools network analysis | [network-analysis.md](network-analysis.md) | ✅ Complete |
| Project architectural brief | [brief.md](brief.md) | ✅ Complete |
| Supporting assignment brief | [docs/assignment-1.md](docs/assignment-1.md) | ✅ Complete |
| HTTP Testing Guide | [docs/http-testing-guide.md](docs/http-testing-guide.md) | ✅ Complete |

---

### 🚀 Assignment 2 Deliverables (Design BookMe: Services, Contracts & Schema)
| Task | Deliverable | File Location | Status |
| :--- | :--- | :--- | :--- |
| **Task 1: Capabilities** | 7 Verbs mapped from `brief.md` to BookMe services | [../Assignment-2/design.pdf](../Assignment-2/design.pdf) (Page 1) | ✅ Complete |
| **Task 2: Service Architecture Benchmark** | Editable Draw.io Diagram + Exported PNG image with data boundaries and team members | [../Assignment-2/services.drawio](../Assignment-2/services.drawio) & [../Assignment-2/services.png](../Assignment-2/services.png) | ✅ Complete |
| **Task 3: Service API Contracts** | Formal operation contracts hiding SQL/tables for all 4 services | [../Assignment-2/design.pdf](../Assignment-2/design.pdf) (Page 2) | ✅ Complete |
| **Task 4: Central Operation Specification** | Full specification of `createBooking` (`POST /bookings`): inputs, outputs, errors, hidden details | [../Assignment-2/design.pdf](../Assignment-2/design.pdf) (Page 3) | ✅ Complete |
| **Task 5: Database Schema Benchmark** | Editable Draw.io ERD + PNG image + PostgreSQL DDL (`schema.sql`) enforcing zero shared tables | [../Assignment-2/schema.drawio](../Assignment-2/schema.drawio), [../Assignment-2/schema.png](../Assignment-2/schema.png) & [../Assignment-2/schema.sql](../Assignment-2/schema.sql) | ✅ Complete |
| **Task 6: Service Property Validation** | 5 Properties of a Service audit with trade-offs & mitigations | [../Assignment-2/design.pdf](../Assignment-2/design.pdf) (Page 4) | ✅ Complete |
| **Assignment 2 Full Walkthrough** | Comprehensive documentation and task breakdown | [../Assignment-2/README.md](../Assignment-2/README.md) | ✅ Complete |
| **Submission Brief PDF** | Submission PDF with links and complete descriptions | [../Assignment-2/ReadMe.pdf](../Assignment-2/ReadMe.pdf) / [../ReadMe.pdf](../ReadMe.pdf) | ✅ Complete |

---

## 🛠️ Verification & Usage Instructions

1. **Viewing / Editing Benchmark Diagrams:**
   - Open [draw.io (diagrams.net)](https://app.diagrams.net/).
   - Open [`../Assignment-2/services.drawio`](../Assignment-2/services.drawio) for the Service Benchmark.
   - Open [`../Assignment-2/schema.drawio`](../Assignment-2/schema.drawio) for the Database ERD Benchmark.
2. **Testing PostgreSQL DDL:**
   - Execute the boundary-enforced SQL script:
     ```bash
     psql -U postgres -d bookme -f ../Assignment-2/schema.sql
     ```
