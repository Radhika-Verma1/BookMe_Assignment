# CS 543 – Web Services
# Assignment 5: HTTP Methods & Headers

## Team Details

| S. No. | Team Member Name | Team ID |
|---|---|---|
| 1 | Radhika Verma | Team 11 |
| 2 | Nandini Kanaujiya | Team 11 |
| 3 | Alka Jha | Team 11 |
| 4 | Alok Mishra | Team 11 |

> **Project context:** BookMe – Distributed Multi-Vendor Event Services Platform  
> **Service:** Event-Booking Service (`services/event-booking-service`, Port 4003)  
> **Author:** Alka Jha (`TargetUltimate-Alka`, Person C)  

---

## Project Information

- **Team ID:** Team BookMe (Group 3)
- **Team Members:**
  - **Person C (Lead Author):** Alka Jha – Event Booking Service & Planner Orchestration
  - **Person A:** Radhika Verma – Authentication & Identity Service
  - **Person B:** Nandini Kannaujiya– Vendor & Catalog Service
  - **Person D:** Alok Mishra – Payment & Feedback Service
- **GitHub Repository:** [https://github.com/TargetUltimate-Alka/BookMe](https://github.com/TargetUltimate-Alka/BookMe)
- **Submission Date:** 2026-10-13

---

## 1. Objective

The objective of this assignment is to audit the service endpoints from Assignment 4 and verify correct HTTP methods, safety and idempotency, query parameters, response status codes, request and response headers, and protocol behavior of the BookMe Event-Booking Service.

The implementation deliverables are:
- Updated service source files (`src/app.js`, `eventController.js`, `routes.js`)
- Updated `openapi.yaml` in this folder
- `curl-transcript.txt`, captured with verbose HTTP request/response headers
- This comprehensive `CS543_Assignment_5_HTTP_Methods_and_Headers_NOTES.md` document

---

## 2. Part A — HTTP Methods and the Message

### A1. Endpoint Method Map

| Action | HTTP Method | URL / Endpoint | Success Status | Safe? | Idempotent? |
| |---|---|---|---|---|
| Create an event resource | `POST` | `/events` | `201 Created` | No | No (without key); Yes (with `Idempotency-Key`) |
| Read one event resource | `GET` | `/events/{id}` | `200 OK` | Yes | Yes |
| List customer's events | `GET` | `/events` | `200 OK` | Yes | Yes |
| Replace an event resource | `PUT` | `/events/{id}` | `200 OK` | No | Yes (complete replacement) |
| Partially update an event | `PATCH` | `/events/{id}` | `200 OK` | No | Yes (when guarded by `If-Match`) |
| Delete/Cancel an event | `DELETE` | `/events/{id}` | `200 OK` | No | Yes (repeated cancellations yield cancelled state) |
| Add checklist item | `POST` | `/events/{id}/items` | `201 Created` | No | No (inherently appends) |
| List checklist items | `GET` | `/events/{id}/items` | `200 OK` | Yes | Yes |
| Update checklist item | `PATCH` | `/events/{id}/items/{itemId}` | `200 OK` | No | Yes |
| Delete checklist item | `DELETE` | `/events/{id}/items/{itemId}` | `204 No Content` | No | Yes |
| Create booking contract | `POST` | `/bookings` | `201 Created` | No | Yes (enforces mandatory `Idempotency-Key`) |
| Read one booking contract | `GET` | `/bookings/{id}` | `200 OK` | Yes | Yes |
| List bookings | `GET` | `/bookings` | `200 OK` | Yes | Yes |

### A2. Non-CRUD Actions

In accordance with RESTful API best practices and OpenAPI 3.1 guidelines, state-machine mutations and operational lifecycle transitions are modelled as **POST requests to sub-resources** rather than hidden RPC verbs.

1. **Booking Cancellation (`POST /bookings/{id}/cancel`):**
   - *Description:* Initiates cancellation per SRS §2.4 fee schedule.
   - *Implementation:* `src/modules/booking/routes.js:127-140`.
   - *Verification:* Transitions status to `CANCELLED_BY_CUSTOMER` or `CANCELLED_BY_VENDOR`, computes cancellation quote, and releases vendor capacity.
2. **Vendor GPS Check-In (`POST /bookings/{id}/check-in`):**
   - *Description:* Validates vendor latitude/longitude against event venue geofence.
   - *Implementation:* `src/modules/booking/routes.js:105-111`.
   - *Verification:* Transitions status from `CONFIRMED` → `IN_PROGRESS` and logs `check_in_at` timestamp.
3. **Booking Completion (`POST /bookings/{id}/complete`):**
   - *Description:* Customer or vendor marks service as delivered.
   - *Implementation:* `src/modules/booking/routes.js:113-125`.
   - *Verification:* Transitions status from `IN_PROGRESS` → `COMPLETED` and schedules 24-hour escrow payout.
4. **Dispute Filing (`POST /bookings/{id}/dispute`):**
   - *Description:* Customer raises damage claim or non-performance dispute.
   - *Implementation:* `src/modules/booking/routes.js:142-148`.
   - *Verification:* Transitions status to `DISPUTED`, halting automated payout.

### A3. Safety and Idempotency

- **Safe Operations:**
  - `GET /events`, `GET /events/{id}`, `GET /events/{id}/items`, `GET /bookings`, `GET /bookings/{id}`, `OPTIONS /events`.
  - *Proof:* These endpoints execute strictly read-only queries against `events`, `event_checklist`, and `bookings` tables without modifying database records or producing side effects.
- **Idempotent Operations:**
  - `PUT /events/{id}`: Replacing event attributes yields identical state regardless of repetition.
  - `DELETE /events/{id}`: Soft-cancelling an already-cancelled event yields the same final state.
  - `PATCH /events/{id}`: Enforces `If-Match` conditional ETag check.
- **Inherently Non-Idempotent Operations Protected by Mechanism:**
  - `POST /events`: Protected by `Idempotency-Key` header. If repeated, the cached 201 response is returned with no duplicate event created.
  - `POST /bookings`: Enforces mandatory `Idempotency-Key` header per ADR-005. Replays return the initial reservation snapshot and avoid double-booking capacity.

### A4. Query Parameters for List Operations

The list endpoint `GET /events` supports filtering, sorting, and cursor/page pagination while maintaining pure read-only safety:
- **Filtering Parameters:** `status` (`PLANNING`, `CONFIRMED`, `COMPLETED`, `CANCELLED`).
- **Sorting Parameters:** `sortBy` (`createdAt`, `dateFrom`, `budgetPaise`), `order` (`asc`, `desc`).
- **Pagination Parameters:** `page` (1-indexed integer), `limit` (max 50, default 10).
- **Verification Example:**
  ```http
  GET /events?status=PLANNING&sortBy=createdAt&order=desc&page=1&limit=10 HTTP/1.1
  Host: localhost:4003
  Accept: application/json
  X-User-Id: usr_customer_01
  X-User-Role: customer
  ```
  Returns `{ items: [...], meta: { page: 1, limit: 10, total: 1 } }`.

### A5. OPTIONS, Allow, and Method Override

- **Resource:** `OPTIONS /events` and `OPTIONS /events/{id}`
- **Supported Methods in `Allow` Header:**
  - On collection (`/events`): `Allow: GET, POST, OPTIONS`
  - On single resource (`/events/{id}`): `Allow: GET, PATCH, PUT, DELETE, OPTIONS`
- **`X-HTTP-Method-Override` Behavior:**
  Implemented in `src/app.js:16-19`. When a client behind a restrictive proxy or legacy firewall sends `POST /events/{id}` with header `X-HTTP-Method-Override: PATCH`, Express rewrites `req.method` to `PATCH`.
- **Verification Result:**
  Verified via Test 8 in `curl-transcript.txt`: `OPTIONS /events` returns `204 No Content` with `Allow: GET, POST, OPTIONS` and `Access-Control-Allow-Origin: *`.

### A6. Complete HTTP Exchange (Captured from Running Service)

#### Request
```http
POST /events HTTP/1.1
Host: localhost:4003
User-Agent: curl/8.4.0
Content-Type: application/json
Accept: application/json
X-User-Id: usr_customer_01
X-User-Role: customer
Idempotency-Key: idemp-assignment5-key-001

{
  "name": "Alka Wedding Sangeet Celebration",
  "eventType": "Wedding",
  "dateFrom": "2026-12-20T18:00:00Z",
  "dateTo": "2026-12-20T23:00:00Z",
  "city": "Ahmedabad",
  "venueLocation": {
    "address": "Grand Ballroom, Palace Grounds",
    "city": "Ahmedabad",
    "state": "Gujarat",
    "postalCode": "380015",
    "latitude": 23.0225,
    "longitude": 72.5714
  },
  "guestCount": 350,
  "budgetPaise": 50000000
}
```

#### Response
```http
HTTP/1.1 201 Created
x-powered-by: Express
access-control-allow-origin: *
x-request-id: 18b748a0-9ef0-471d-be8c-c235150c12c4
x-content-type-options: nosniff
x-ratelimit-limit: 100
x-ratelimit-remaining: 99
location: /events/d79a69d3-6aea-4039-b449-a7d9d04cb4fa
content-type: application/json; charset=utf-8
content-length: 1017
etag: W/"3f9-pBluPWpIzaPY2MUfUJglWcv9Qoc"
date: Tue, 13 Oct 2026 15:12:08 GMT
connection: close

{
  "id": "d79a69d3-6aea-4039-b449-a7d9d04cb4fa",
  "customerId": "usr_customer_01",
  "name": "Alka Wedding Sangeet Celebration",
  "dateFrom": "2026-12-20",
  "dateTo": "2026-12-20",
  "venueLocation": {
    "address": "Grand Ballroom, Palace Grounds",
    "city": "Ahmedabad",
    "state": "Gujarat",
    "postalCode": "380015",
    "latitude": 23.0225,
    "longitude": 72.5714
  },
  "guestCount": 350,
  "status": "PLANNING",
  "createdAt": "2026-10-13T15:12:08.182Z",
  "budget": 500000,
  "budget_items": [
    { "category": "Venue & Catering", "planned_amount": 250000, "actual_amount": 0 },
    { "category": "Photography & Video", "planned_amount": 100000, "actual_amount": 0 }
  ]
}
```

---

## 3. Part B — Headers on Every Message

### B1. Content-Type and Negotiation
- **JSON Default:** All response payloads specify `Content-Type: application/json; charset=utf-8`.
- **Content Negotiation:** The service inspects incoming `Accept` headers. If a client requests an unsupported media representation such as `Accept: application/xml`, the middleware immediately rejects it with a structured `406 Not Acceptable` error.

### B2. Status Codes and Location

| Scenario | Required Status / Behavior | Endpoint Verified |
|---|---|---|
| Successful resource creation | `201 Created` with `Location: /events/{id}` | `POST /events` |
| Successful read | `200 OK` | `GET /events/{id}` |
| Successful deletion | `204 No Content` | `DELETE /checklist/{id}` |
| Malformed request | `400 Bad Request` | `POST /events` with empty string name |
| Missing resource | `404 Not Found` | `GET /events/evt_non_existent_99999` |
| Conflict / State conflict | `409 Conflict` | `POST /bookings/{id}/counter` exceeding 3 rounds |
| Syntactically valid request refused by domain validation | `422 Unprocessable Content` | `POST /bookings/{id}/check-in` beyond geofence radius |
| Precondition Failed | `412 Precondition Failed` | `PATCH /events/{id}` with stale `If-Match` |
| Not Modified | `304 Not Modified` | `GET /events/{id}` with matching `If-None-Match` |

### B3. Authorization
- **Format:** `Authorization: Bearer <JWT_TOKEN>` (or gateway forwarded `X-User-Id` / `X-User-Role`).
- **Missing Token Behavior:** Returning `401 Unauthorized`.

### B4. Cache-Control and ETag
- **Endpoint:** `GET /events/{id}`
- **Cache-Control Policy:** `Cache-Control: private, max-age=60`
- **Example ETag:** `W/"3f9-pBluPWpIzaPY2MUfUJglWcv9Qoc"`

### B5. Rate-Limit Signalling
- **Response Headers:**
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 99`
- **Excess Traffic:** Returns `429 Too Many Requests` with `Retry-After: 900` when quota is exhausted.

### B6. CORS
- **Permitted Origin:** Configured via `cors()` middleware with `Access-Control-Allow-Origin: *`.
- **Allowed Methods & Headers:** `GET, POST, PUT, PATCH, DELETE, OPTIONS`, `Content-Type, Authorization, Idempotency-Key, If-Match, If-None-Match`.

### B7. Security and General Headers
- **`X-Content-Type-Options: nosniff`**
- **`X-Request-Id`**
- **`Date`**
- **`Connection: close`**

---

## 4. Part C — Caching and Safe Retries

### C1. Conditional GET — 304 Not Modified
When a client caches an event representation and issues a conditional GET with `If-None-Match`:
- **Request:** `GET /events/{id}` with `If-None-Match` matching the current ETag.
- **Response:** `304 Not Modified` with empty body.

### C2. Conditional Write — 412 Precondition Failed
When a client sends a stale `If-Match` value, the write is rejected with `412 Precondition Failed`.

### C3. Idempotency-Key
- **Mechanism:** Idempotency middleware stores the request path, status code, and response body indexed by key.
- **Repeated Request:** Returns the cached original response and avoids duplicates.

### C4. Safe-Retry Plan

| Risky Operation | Method | Safety / Idempotency Classification | Risk on Retry | Safe Mechanism | Expected Behavior |
|---|---|---|---|---|---|
| Event Creation | `POST /events` | Not safe; not inherently idempotent | Duplicate events | `Idempotency-Key` | Cached original 201 response |
| Booking Creation | `POST /bookings` | Not safe; not inherently idempotent | Double-booking | `Idempotency-Key` | Cached original reservation snapshot |
| Event Retrieval | `GET /events/{id}` | Safe & Idempotent | Redundant payload transfer | `If-None-Match` | `304 Not Modified` |
| Event Mutation | `PATCH /events/{id}` | Not safe; idempotent conditionally | Overwriting concurrent edits | `If-Match` | `412 Precondition Failed` |
| Booking Cancellation | `POST /bookings/{id}/cancel` | Not safe; idempotent by state machine | Re-charging cancellation penalties | Status guard | Existing state is returned |

---

## 5. Part D — Verification and Documentation

### D1. `curl -v` Verification Matrix

| # | Test Scenario | Expected Outcome | Actual Outcome | Status |
|---|---|---|---|:---:|
| **1** | Create Resource | `201 Created` + `Location: /events/{id}` | `201 Created` + `location: /events/...` | **PASS** |
| **2** | Idempotent Repeat | Original 201 result; zero duplicate work | `201 Created` from idempotent cache | **PASS** |
| **3** | Conditional GET | `304 Not Modified`, empty body | `304 Not Modified`, 0-byte body | **PASS** |
| **4** | Conditional Write | `412 Precondition Failed` | `412 Precondition Failed` | **PASS** |
| **5** | Malformed Request | `400 Bad Request` + validation details | `400 Bad Request` + schema issue details | **PASS** |
| **6** | Missing Resource | `404 Not Found` | `404 Not Found` | **PASS** |
| **7** | Missing Token / Identity | `401 Unauthorized` | `401 Unauthorized` | **PASS** |
| **8** | OPTIONS Preflight | `204 No Content` + `Allow` header | `204 No Content` + `Allow: GET, POST, OPTIONS` | **PASS** |
| **9** | Content Negotiation | `406 Not Acceptable` on XML | `406 Not Acceptable` | **PASS** |

### D2. Endpoint × Header Table

| Endpoint | Supported / Required Request Headers | Response Headers Set |
|---|---|---|
| `POST /events` | `Content-Type: application/json`, `Accept: application/json`, `Idempotency-Key`, `X-User-Id` | `Content-Type`, `Location`, `ETag`, `X-RateLimit-*` |
| `GET /events/{id}` | `Accept: application/json`, `If-None-Match`, `X-User-Id` | `Content-Type`, `ETag`, `Cache-Control`, `X-RateLimit-*` |
| `PATCH /events/{id}` | `Content-Type: application/json`, `Accept: application/json`, `If-Match`, `X-User-Id` | `Content-Type`, `ETag`, `X-RateLimit-*`, `X-Content-Type-Options` |
| `GET /events` | `Accept: application/json`, `X-User-Id` | `Content-Type`, `X-RateLimit-*`, `X-Content-Type-Options` |
| `OPTIONS /events` | None | `Allow`, `Access-Control-Allow-Origin` |
| `DELETE /events/{id}` | `X-User-Id`, `X-User-Role` | `Content-Type`, `X-RateLimit-*` |

### D3. OpenAPI and Automated Tests
- **OpenAPI 3.1 Spec Updated:** Yes.
- **Automated Tests Executed:** `npm test` inside `services/event-booking-service`.
- **Test Result:** 7 test suites passed, 88 tests passed (100% pass rate).
- **Remaining Issues:** None.

---

## 6. Answers to the Eight Questions

### Q1. For three endpoints, give the method, success status, and the single response header that matters most — and why.
1. **`POST /events`:** Method `POST`, Status `201 Created`.  
   *Key Header:* `Location: /events/{id}`.  
   *Why:* It gives the canonical URI of the newly created resource.
2. **`GET /events/{id}`:** Method `GET`, Status `200 OK`.  
   *Key Header:* `ETag: W/"..."`.  
   *Why:* Enables conditional requests and caching validation.
3. **`OPTIONS /events`:** Method `OPTIONS`, Status `204 No Content`.  
   *Key Header:* `Allow: GET, POST, OPTIONS`.  
   *Why:* Informs clients which methods are legal for that resource.

### Q2. Which endpoints are safe, and which are idempotent? Which one is neither, and how did you make it retry-safe?
- **Safe Endpoints:** `GET /events`, `GET /events/{id}`, `GET /events/{id}/items`, `GET /bookings`, `OPTIONS /events`.
- **Idempotent Endpoints:** `PUT /events/{id}`, `DELETE /events/{id}`, and `POST /bookings/{id}/cancel`.
- **Neither Safe Nor Inherently Idempotent:** `POST /events` and `POST /bookings`.
- **How Made Retry-Safe:** Implemented the `Idempotency-Key` header mechanism.

### Q3. Show one ETag, the request that returns 304, and the write that returns 412. What does each save or prevent?
- **Observed ETag:** `W/"3f9-pBluPWpIzaPY2MUfUJglWcv9Qoc"`
- **Conditional GET (304):** `GET /events/{id}` with `If-None-Match` returns `304 Not Modified`.
- **Conditional Write (412):** `PATCH /events/{id}` with stale `If-Match` returns `412 Precondition Failed`.

### Q4. You return 422 for one case and 400 for another. Give the exact request that triggers each, and explain the difference.
- **400 Bad Request:** `POST /events` with body `{ "name": "" }`.
- **422 Unprocessable Content:** `POST /bookings/{id}/check-in` outside the geofence.

### Q5. A browser page on another origin calls your API and is blocked, yet the server logs show 200. Who blocked it, and which response header fixes it?
- **Who Blocked It:** The client browser's Same-Origin Policy (SOP) engine.
- **Header that Fixes It:** `Access-Control-Allow-Origin: http://localhost:5173` (or `*`).

### Q6. Name one response where Cache-Control allows caching and one where you must use no-store. Why?
1. **Allows Caching:** `GET /events/{id}` → `Cache-Control: private, max-age=60`.
2. **Must Use `no-store`:** `POST /api/auth/login` or `POST /api/payments`.

### Q7. Your search endpoint is GET. When would POST be the right choice instead, and what do you give up by switching?
- **When POST is Right:** For large nested search payloads or non-idempotent operational commands.
- **What You Give Up:** Safe semantics, URL bookmarkability, and HTTP caching behavior.

### Q8. Location appears on a 201 and on a 3xx. What does it point to in each case?
- **On a `201 Created`:** It points to the newly created resource URI.
- **On a `3xx Redirect`:** It points to the target redirect URI.

---

## 7. Conclusion

The BookMe Event-Booking Service has been comprehensively verified against all requirements of Assignment 5.

---

## 8. Final Submission Checklist

- [x] Updated service source files (`src/app.js`, `eventController.js`, `routes.js`)
- [x] Updated tests and verified results (88/88 passed)
- [x] Updated `openapi.yaml`
- [x] Completed method map (A1)
- [x] Documented non-CRUD actions (A2)
- [x] Classified safety and idempotency (A3)
- [x] Implemented list filtering, sorting, and pagination (A4)
- [x] Implemented OPTIONS, Allow, and documented override fallback (A5)
- [x] Added a complete real HTTP exchange (A6)
- [x] Implemented and verified Part B headers
- [x] Verified conditional GET, conditional write, and idempotency (Part C)
- [x] Saved real `curl -v` evidence in `curl-transcript.txt` (D1)
- [x] Completed the endpoint-header table (D2)
- [x] Answered all eight questions (Q1..Q8)
- [x] Added Team ID, roll numbers, and names

