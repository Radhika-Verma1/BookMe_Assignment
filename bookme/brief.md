# BookMe — Project Brief

## What
BookMe is an AI-powered, multi-vendor event service booking platform. Planning a wedding, birthday, engagement or corporate event normally means contacting many separate vendors (photography, catering, DJ, decoration, makeup, lighting, transport) and negotiating price and availability with each one. BookMe solves this by letting a customer create an event, discover and compare vendors, check availability, book, pay and manage the whole event from one place. AI-based recommendations and natural-language search are planned for Version 2.

## Who
- **Customer** – plans events, searches and compares vendors, books and pays, tracks budget and checklist, and leaves reviews. Needs transparent prices, availability and trust.
- **Vendor** – registers a business, gets verified, manages services, packages, pricing and availability, and accepts or rejects booking requests. Needs visibility, fewer manual enquiries and reliable payouts.
- **Administrator** – verifies vendors, manages users, vendors, bookings and payments, and resolves complaints and refunds. Needs control and oversight of the platform.

## Nouns — Entities and Resources
These are business entities (resources), not HTTP methods.

| Noun | Meaning |
|------|---------|
| User | Account with a role (CUSTOMER, VENDOR, ADMIN) |
| Customer / Vendor | A user acting as buyer / service provider; a vendor has a business profile and verification status |
| Event | A customer's occasion: type, date, location, guest count, budget |
| Service | Something a vendor offers (e.g. photography) with a base price |
| Package | A priced bundle under a service |
| Availability | Per-vendor date status: AVAILABLE, BOOKED, BLOCKED |
| Booking | A request/agreement between event, vendor, service and package; status PENDING, ACCEPTED, REJECTED, CONFIRMED, COMPLETED, CANCELLED |
| Payment | Transaction (and refund) for a booking |
| Review | Rating and comment for a completed booking |
| Complaint | Issue raised about a booking, handled by admin |
| Budget | Planned vs actual amount per category for an event |
| Checklist | Event tasks with due date and completion flag |

## Verbs — Actions and Operations
Proposed REST contracts (**design only, not live endpoints**):

| Action | Proposed API |
|--------|--------------|
| Register / Log in | `POST /auth/register`, `POST /auth/login` |
| Create an event | `POST /events` |
| Search / compare vendors | `GET /vendors?category=&city=`, `GET /vendors/{id}` |
| Check availability | `GET /vendors/{id}/availability` |
| Create a booking | `POST /bookings` |
| Accept or reject a booking | `PUT /bookings/{id}/status` |
| View a booking | `GET /bookings/{id}` |
| Process a payment / request a refund | `POST /payments`, `POST /payments/{id}/refund` |
| Submit a review | `POST /reviews` |
| Verify a vendor | `PUT /vendors/{id}/verification` |
| Manage a complaint | `POST /complaints`, `PUT /complaints/{id}` |

Typical mapping: GET reads, POST creates, PUT updates, DELETE removes. Compare vendors is done on the client by fetching several vendor resources.

## Web Services Perspective
BookMe is planned as four services (Auth, Vendor, Event-Booking, Payment-Feedback) behind an API gateway. They talk over HTTP/REST with JSON request and response bodies and meaningful status codes (200, 201, 400, 401, 404, 409). Each microservice **owns its own PostgreSQL database**. Other services never read or modify that database directly; they call the owner's API (e.g. Booking asks Vendor Service whether a vendor is valid) or react to messages from RabbitMQ (e.g. `BookingCreated`, `PaymentCompleted`). This keeps services loosely coupled and independently changeable.
