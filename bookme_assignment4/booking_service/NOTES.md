# CS543 Assignment 4 — BookMe Booking Service (REST)
**Team:** <Name, Roll No> · <Name, Roll No>   *(first page: fill in all members)*

Service chosen: **Booking Service** (owns bookings; own DB; calls Payment service). Boundary from Assignment 2 unchanged.

## A2 · SOAP-style operations (starting point)
`createBooking(eventId, vendorId, packageId, date, amount)`, `getBooking(id)`, `searchBookings(eventId, status)`, `confirmBooking(id)`, `cancelBooking(id, reason)`

## A4 · Resource table
| Method | URL | What it does | Success | Failures |
|---|---|---|---|---|
| POST | /bookings | Create booking (needs `Idempotency-Key`) | 201 + Location | 400, 422, 503 |
| GET | /bookings/{id} | Read one booking | 200 | 404 |
| GET | /bookings?status=&event_id=&vendor_id= | Filtered list | 200 | 400 |
| POST | /bookings/{id}/confirmation | Vendor accepts | 200 | 404, 409 |
| POST | /bookings/{id}/cancellation | Cancel; refund continues later | 202 | 400, 404, 409 |

## A5 · Hardest choice: `cancelBooking`
Cancel maps naturally to `DELETE /bookings/{id}`, but a cancelled booking must survive: the refund, commission reversal and any customer complaint all need the record. I rejected DELETE and `PATCH {status: cancelled}` (which lets clients write any status). I modelled the cancellation as a noun, a sub-resource `/bookings/{id}/cancellation`, which is created once, returns 202 because the refund finishes after the reply, and returns 409 if repeated.

## D3 · Fallback: fail, do not degrade
If Payments is unreachable after 3 attempts, `POST /bookings` returns **503** and stores nothing. Degrading (saving the booking as "payment pending") would have been wrong: it would block the vendor's date for a customer who has not committed any money, so the vendor may turn away paying customers, and BookMe would later have to chase and cancel unpaid bookings. The client can safely retry with the same `Idempotency-Key`.

## Answers
1. **Line counts:** `openapi.yaml` = 184 lines; WSDL = **<run `wc -l a3.wsdl` and fill in>**. The WSDL difference is mostly ceremony: `types`, one `message` per request/response, `portType`, `binding`, `service`. OpenAPI does not need to declare (a) the SOAP binding/transport (`soap:binding`, `soapAction`) because HTTP method + URL already say it, and (b) separate input/output `message` elements, since each operation lists its request body and responses directly.
2. **Fault → status:** *(replace with your own A3 fault.)* Example form: `soap:Fault faultcode=Client faultstring="Vendor not available on date"` became `422` with `{"type":".../domain-rule","title":"Request refused by domain rules","status":422,"detail":"Vendor is not available on that date."}`. A fault returned inside 200 OK is a problem because proxies, caches, load balancers, retry logic and monitoring only read the status line: they would count the failure as success, may cache it, and will never alert or retry correctly.
3. **UDDI:** *publish* survives as `openapi.yaml` (published in the repo/docs); *find* is replaced by humans/tools reading docs, or an API gateway route table; *bind* disappeared as a runtime step: the URL is known in advance and injected via `PAYMENT_SERVICE_URL`, so the call is just an HTTP request. The gateway plus env config took over the job of the registry.
4. **Validation:** `validate()` in `app.py` now does what the XML Schema did. Without it, a body like `{"amount_inr": "abc"}` or a missing `service_date` would reach the code and crash with a 500 (or worse, a negative amount would be sent to Payments).
5. **Where I'd still choose SOAP:** the payout/settlement flow between BookMe and vendors' banks, if a partner bank required WS-Security plus WS-ReliableMessaging. I would be buying a standardised message-level guarantee: signed/encrypted messages that stay protected across intermediaries (not just TLS hop-by-hop) and exactly-once, in-order delivery handled by the protocol instead of my own idempotency keys.
