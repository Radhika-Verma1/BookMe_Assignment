# CS 543 – Web Services
# Assignment 6: Honest Responses — Status Codes, Errors & Validation

## Team Details

| S. No. | Team Member Name | Team ID |
|---|---|---|
| 1 | Radhika Verma | Team 11 |
| 2 | Nandini Kanaujiya | Team 11 |
| 3 | Alka Jha | Team 11 |
| 4 | Alok Mishra | Team 11 |

> **Project:** BookMe – Distributed Multi-Vendor Event Services Platform  
> **Subsystem / Service:** BookMe Orders Service (`POST /orders`, `GET /orders`, `PATCH /orders`, `DELETE /orders`)  
> **Author:** Alka Jha (`TargetUltimate-Alka`, Person C)  
> **Submission Date:** October 2026  

---

## Team Information

| Name | Roll Number | Role | Module Responsibility |
| :--- | :--- | :--- | :--- |
| **Alka Jha** | **MCA-2024-3012** | **Team Lead & Lead Developer** | **Orders Service, Event Booking & Planner Orchestration** |
| Person A | MCA-2024-3001 | Team Member | Identity, Authentication & DPDP Encryption |
| Person B | MCA-2024-3007 | Team Member | Vendor Marketplace, 60 Categories & Capacity Holds |
| Person D | MCA-2024-3019 | Team Member | Escrow Payments, Webhooks & Feedback Service |

---

## Overview

Assignment 6 establishes honest, predictable, and robust HTTP communication for the **BookMe Orders Service**. Key highlights of this implementation include:
1. **Honest Status Codes:** Eliminated all fake `200 OK` responses containing `{ "ok": false }` or error bodies. Every failure produces an authentic HTTP 4xx or 5xx status code.
2. **Canonical Location Header:** `POST /orders` returns `201 Created` with a `Location: /orders/{id}` header pointing to the canonical resource URI.
3. **RFC 7807 Problem Details:** All errors are routed through a centralized `problem()` helper producing structured error envelopes with `Content-Type: application/problem+json; charset=utf-8`.
4. **Pre-flight Field-Level Validation:** Rejects bad requests before executing database or business logic, collecting multiple invalid fields into an `errors[]` array under `422 Unprocessable Content`.
5. **Content Negotiation:** Supports both `application/json` (default) and `application/xml`, returning `406 Not Acceptable` when unsupported formats are requested.
6. **Retry Safety & Signalling:** Communicates backoff expectations using `Retry-After` headers on `429 Too Many Requests` and `503 Service Unavailable`, while respecting idempotency keys and ETags.

---

## Answers to the Seven Questions

### Question 1: Status Map
> *List every endpoint, its success status, and the status for each failure. Give a one-line reason for each.*

| Endpoint | HTTP Method | Status Code | Classification | Reason / Trigger |
| :--- | :---: | :---: | :---: | :--- |
| `/orders` | `POST` | `201 Created` | **Success** | Order successfully validated and persisted; returns `Location: /orders/{id}` header. |
| `/orders` | `POST` | `422 Unprocessable Content` | Client Error | Pre-flight validation failed (e.g. empty items array, invalid quantity `<= 0`, or missing address). |
| `/orders` | `POST` | `409 Conflict` | Client Error | Requested package/item is out of stock or vendor capacity is fully booked (`item-unavailable`). |
| `/orders` | `POST` | `402 Payment Required` | Client Error | Escrow deposit payment authorization was declined by the payment gateway (`payment-declined`). |
| `/orders` | `POST` | `406 Not Acceptable` | Client Error | Client requested an unsupported representation format via the `Accept` header (`not-acceptable`). |
| `/orders` | `POST` | `429 Too Many Requests` | Client Error | Client exceeded API rate limit threshold (100 req/min); includes `Retry-After: 60` header. |
| `/orders` | `POST` | `503 Service Unavailable` | Server Error | Database or payment gateway subsystem undergoing maintenance; includes `Retry-After: 120` header. |
| `/orders` | `POST` | `500 Internal Server Error` | Server Error | Unhandled runtime exception safely caught server-side without leaking stack traces. |
| `/orders` | `GET` | `200 OK` | **Success** | Orders retrieved successfully for customer context as JSON or XML. |
| `/orders` | `GET` | `406 Not Acceptable` | Client Error | Format requested in `Accept` cannot be produced. |
| `/orders/{id}` | `GET` | `200 OK` | **Success** | Full order details returned with `ETag` and `Cache-Control: private, max-age=60`. |
| `/orders/{id}` | `GET` | `304 Not Modified` | **Success (Cached)** | Request included matching `If-None-Match` ETag; returns zero-byte body to save bandwidth. |
| `/orders/{id}` | `GET` | `404 Not Found` | Client Error | No order exists with the specified identifier (`order-not-found`). |
| `/orders/{id}` | `PATCH` | `200 OK` | **Success** | Order status or attributes successfully modified. |
| `/orders/{id}` | `PATCH` | `404 Not Found` | Client Error | Order ID does not exist on server (`order-not-found`). |
| `/orders/{id}` | `PATCH` | `409 Conflict` | Client Error | Attempted an invalid state transition (e.g., trying to cancel an already `DELIVERED` order). |
| `/orders/{id}` | `PATCH` | `412 Precondition Failed` | Client Error | `If-Match` ETag header provided by client does not match current server representation (lost update prevention). |
| `/orders/{id}` | `PATCH` | `422 Unprocessable Content` | Client Error | Payload contained invalid status value outside allowed enumeration. |
| `/orders/{id}` | `DELETE` | `204 No Content` | **Success** | Order successfully cancelled; response body is deliberately empty. |
| `/orders/{id}` | `DELETE` | `404 Not Found` | Client Error | Target order to cancel does not exist (`order-not-found`). |
| `/orders/{id}` | `DELETE` | `409 Conflict` | Client Error | Cannot cancel an order that has already completed lifecycle delivery (`illegal-transition`). |

---

### Question 2: Type Catalogue
> *List the stable string for each failure and what triggers it.*

All error types in the BookMe platform use stable, namespaced URI identifiers under `https://api.bookme.internal/errors/`:

| Error Type Slug | Full Stable Type URI | HTTP Status | What Triggers It |
| :--- | :--- | :---: | :--- |
| **`empty-cart`** | `https://api.bookme.internal/errors/empty-cart` | `422` | Client attempts to place an order where the `items` array is missing, null, or has length 0. |
| **`validation-error`** | `https://api.bookme.internal/errors/validation-error` | `422` | Request body fails field-level constraints (e.g., non-integer `qty`, `qty < 1`, missing `address`). |
| **`item-unavailable`** | `https://api.bookme.internal/errors/item-unavailable` | `409` | One or more items in the cart are out of stock, vendor is unavailable, or concurrent bookings exhausted resources. |
| **`payment-declined`** | `https://api.bookme.internal/errors/payment-declined` | `402` | Escrow deposit transaction was rejected by the payment gateway due to insufficient funds, invalid card, or authorization failure. |
| **`order-not-found`** | `https://api.bookme.internal/errors/order-not-found` | `404` | Client attempts to read, mutate, or delete an order using an unknown, expired, or mistyped ID. |
| **`illegal-transition`** | `https://api.bookme.internal/errors/illegal-transition` | `409` | Client attempts a state machine transition disallowed by business rules (e.g., `DELIVERED` → `CANCELLED`). |
| **`rate-limited`** | `https://api.bookme.internal/errors/rate-limited` | `429` | Client surpasses the 100 requests per minute velocity limit; response signals `Retry-After: 60`. |
| **`service-unavailable`** | `https://api.bookme.internal/errors/service-unavailable` | `503` | Database connection pool or upstream payment provider is temporarily unreachable; response signals `Retry-After: 120`. |
| **`not-acceptable`** | `https://api.bookme.internal/errors/not-acceptable` | `406` | Client sends an `Accept` header specifying a MIME type the server cannot generate (e.g., `text/csv`). |
| **`internal-server-error`** | `https://api.bookme.internal/errors/internal-server-error` | `500` | Uncaught runtime error; sanitized error returned while stack trace is logged privately. |

---

### Question 3: Problem Details Example
> *Paste one Problem Details response body from your service and label its fields.*

Below is an authentic RFC 7807 Problem Details response captured from `POST /orders` when an out-of-stock item was ordered:

```json
{
  "type": "https://api.bookme.internal/errors/item-unavailable",
  "title": "Item Unavailable",
  "status": 409,
  "detail": "Item 'Celebrity Vocalist Live Set' (item_celebrity_performer) is currently out of stock or capacity is exhausted.",
  "instance": "/orders",
  "itemId": "item_celebrity_performer",
  "itemName": "Celebrity Vocalist Live Set",
  "requestedQty": 1
}
```

#### Field Explanations & Labels:
- **`type`**: `https://api.bookme.internal/errors/item-unavailable`  
  *Label:* A dereferenceable URI reference that identifies the specific problem type.
- **`title`**: `"Item Unavailable"`  
  *Label:* A short, human-readable summary of the problem type.
- **`status`**: `409`  
  *Label:* The exact HTTP status code generated by the origin server for this occurrence of the problem.
- **`detail`**: `"Item 'Celebrity Vocalist Live Set' ... is currently out of stock or capacity is exhausted."`  
  *Label:* Human-readable explanation specific to this occurrence.
- **`instance`**: `"/orders"`  
  *Label:* URI reference identifying the endpoint/resource where the problem occurred.
- **Extension Members (`itemId`, `itemName`, `requestedQty`)**:  
  *Label:* Safe contextual metadata permitted by RFC 7807 to help clients render rich UI messaging.

---

### Question 4: Field-Level Validation
> *Show a 422 response that reports two invalid fields at once.*

When a client submits an invalid request with `qty: -3` and omits the required `address` field:

#### Request:
```http
POST /orders HTTP/1.1
Host: localhost:4006
Content-Type: application/json
Accept: application/json

{
  "items": [
    {
      "itemId": "item_dj_basic",
      "qty": -3
    }
  ]
}
```

#### Response (`HTTP/1.1 422 Unprocessable Content`):
```http
HTTP/1.1 422 Unprocessable Content
Content-Type: application/problem+json; charset=utf-8
X-Content-Type-Options: nosniff
X-Request-Id: 785ea9fc-2c40-410a-b3fa-0947ae5b4e3e

{
  "type": "https://api.bookme.internal/errors/validation-error",
  "title": "Unprocessable Content",
  "status": 422,
  "detail": "The order request failed validation with one or more invalid fields.",
  "instance": "/orders",
  "errors": [
    {
      "field": "items[0].qty",
      "message": "Quantity must be greater than or equal to 1. Received: -3"
    },
    {
      "field": "address",
      "message": "Delivery address is required."
    }
  ]
}
```

**Implementation note:** The validator executes all schema checks upfront and appends every failure into the `errors` array before returning, preventing frustrating one-field-at-a-time retries.

---

### Question 5: Retry Safety
> *Which endpoints are safe to retry, and which status codes communicate retry guidance to the client?*

#### 1. Endpoints Safe to Retry:
- **`GET /orders` & `GET /orders/{id}`**: Inherently safe and idempotent per RFC 9110.
- **`POST /orders` (when guarded by `Idempotency-Key`)**: Safe to retry after transient network errors.
- **`PATCH /orders/{id}` (when guarded by `If-Match`)**: Safe to retry as long as the resource version has not changed.
- **`DELETE /orders/{id}`**: Idempotent; retrying cancellation leaves the order in the `CANCELLED` state.

#### 2. Status Codes Communicating Retry Guidance:
- **`HTTP 429 Too Many Requests`**: `Retry-After: 60`.
- **`HTTP 503 Service Unavailable`**: `Retry-After: 120`.
- **`HTTP 504 Gateway Timeout` & `HTTP 502 Bad Gateway`**: Transient proxy failures; safe to retry for idempotent requests.

#### 3. Critical Rule on 4xx Errors:
**Never retry an unchanged 4xx request** (such as `400 Bad Request`, `404 Not Found`, `409 Conflict`, or `422 Unprocessable Content`). These indicate client-side errors that will deterministically fail until the client changes its request.

---

### Question 6: Internal Error Mapping
> *Where did you map an internal error to a clean client error, and what details did you hide from the caller?*

#### 1. Code Location:
- Centralized in `src/app.js` and the `try/catch` wrapper in the controller layer.

#### 2. Implementation:
```javascript
app.use((err, req, res, next) => {
  console.error('[OrdersService Uncaught Error]', {
    requestId: req.id,
    url: req.originalUrl,
    error: err.message,
    stack: err.stack,
  });

  if (!res.headersSent) {
    return problem(res, {
      type: 'internal-server-error',
      status: 500,
      title: 'Internal Server Error',
      detail: 'A critical unexpected error occurred. No system internals are exposed.',
    });
  }
});
```

#### 3. Details Hidden from the Caller:
1. **Stack Traces:** File paths, line numbers, and internal module names are never leaked.
2. **Database Queries & Engine Messages:** SQL, connection strings, and constraint details are suppressed.
3. **Environment & Secrets:** Credentials, tokens, or internal IPs are not revealed.
4. **Correlation Tracing:** The client receives only a clean `X-Request-Id` header.

---

### Question 7: JSON and XML Representations
> *Show the same order in JSON and XML, and include the `Accept` header that selected each representation.*

#### Representation 1: JSON
- **Request Header:** `Accept: application/json`
- **Response Content-Type:** `application/json; charset=utf-8`

```json
{
  "id": "ord_479b8ee6493a",
  "customerId": "usr_customer_01",
  "status": "CREATED",
  "items": [
    {
      "itemId": "item_dj_basic",
      "name": "Standard DJ Sound System & Console",
      "qty": 1,
      "pricePaise": 1000000,
      "lineTotalPaise": 1000000
    },
    {
      "itemId": "item_photo_gold",
      "name": "Gold Wedding Photography & Drone",
      "qty": 1,
      "pricePaise": 2500000,
      "lineTotalPaise": 2500000
    }
  ],
  "address": {
    "line1": "Grand Ballroom, Palace Grounds",
    "city": "Ahmedabad",
    "state": "Gujarat",
    "pincode": "380015"
  },
  "notes": "",
  "paymentMethod": "ESCROW_NETBANKING",
  "totalPaise": 3500000,
  "depositPaise": 1400000,
  "createdAt": "2026-10-13T16:26:55.087Z",
  "updatedAt": "2026-10-13T16:26:55.087Z",
  "etag": "W/\"ec010c6c51116efd\""
}
```

---

#### Representation 2: XML
- **Request Header:** `Accept: application/xml`
- **Response Content-Type:** `application/xml; charset=utf-8`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<order id="ord_479b8ee6493a">
  <status>CREATED</status>
  <customerId>usr_customer_01</customerId>
  <totalPaise>3500000</totalPaise>
  <depositPaise>1400000</depositPaise>
  <currency>INR</currency>
  <createdAt>2026-10-13T16:26:55.087Z</createdAt>
  <updatedAt>2026-10-13T16:26:55.087Z</updatedAt>
  <items>
    <item>
      <itemId>item_dj_basic</itemId>
      <name>Standard DJ Sound System &amp; Console</name>
      <qty>1</qty>
      <pricePaise>1000000</pricePaise>
    </item>
    <item>
      <itemId>item_photo_gold</itemId>
      <name>Gold Wedding Photography &amp; Drone</name>
      <qty>1</qty>
      <pricePaise>2500000</pricePaise>
    </item>
  </items>
  <address>
    <line1>Grand Ballroom, Palace Grounds</line1>
    <city>Ahmedabad</city>
    <state>Gujarat</state>
    <pincode>380015</pincode>
  </address>
</order>
```

#### Unsupported Representation Check (406 Not Acceptable):
- When a client sends `Accept: text/csv`, the service inspects the header and responds with `406 Not Acceptable`:

```json
{
  "type": "https://api.bookme.internal/errors/not-acceptable",
  "title": "Not Acceptable",
  "status": 406,
  "detail": "The requested Accept format 'text/csv' cannot be produced. Supported representations are 'application/json' and 'application/xml'.",
  "instance": "/orders/ord_479b8ee6493a"
}
```

---

## Deliverables Summary

All deliverables for CS543 Assignment 6 are contained in this directory:
1. `src/` — Complete Orders service source code.
2. `tests/order.test.js` — Automated test suite verifying all scenarios.
3. `openapi.yaml` — OpenAPI 3.1 specification documenting endpoints, headers, and Problem Details schemas.
4. `transcript.txt` — Full wire-level HTTP transcripts capturing all success, failure, and content negotiation exchanges.
5. `NOTES.md` — Complete reference document answering Questions 1 through 7.

