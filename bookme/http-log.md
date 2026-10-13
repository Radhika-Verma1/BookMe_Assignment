# HTTP Log — HTTP by Hand with curl

**Project:** BookMe — AI-Powered Multi-Vendor Event Service Booking Platform
**Course:** CS 543 Web Services — Assignment 1, Task 1
**Executed:** 2026-10-13 12:23 UTC from a Linux shell using `curl`

## API used and why

BookMe's own APIs (`/auth/login`, `/vendors`, `/bookings`, ...) are **proposed contracts and are not deployed publicly**, so they cannot be called here. I therefore used the **public, read-only npm registry JSON API** (`https://registry.npmjs.org`). It needs no authentication, is stable, and returns metadata about packages that BookMe actually plans to use (`express`, `pg`, `jsonwebtoken`, `amqplib`).

> The npm registry is used **only to demonstrate HTTP concepts** (methods, status codes, headers, JSON bodies, 404 handling). It is **not** a dependency of BookMe at run time.

A public events/venues API was tried first (e.g. a public-holiday API and JSONPlaceholder), but the sandbox's network policy blocked those hosts (HTTP 403 on the proxy tunnel), so they are not logged here.

## How to reproduce

```bash
curl -i https://registry.npmjs.org/express/latest
```
All requests are `GET` (read-only). Responses below were captured from real runs. Two edits were made for readability: (1) the value of the Cloudflare `__cf_bm` cookie in `set-cookie` is replaced by `<redacted>`; (2) long bodies are truncated and marked as such, and short JSON bodies are re-indented (content unchanged). Responses may differ slightly when you re-run them (dates, versions, cache `age`).

---

## Request 1: Look up the latest metadata of `express` (BookMe's API framework)

### 1. Objective
Look up the latest metadata of `express` (BookMe's API framework).

### 2. Exact curl command
```bash
curl -i https://registry.npmjs.org/express/latest
```

### 3. Actual HTTP request (from `curl -v`)
```http
GET /express/latest HTTP/2
Host: registry.npmjs.org
User-Agent: curl/8.5.0
Accept: */*

```

### 4. Actual response status and headers
```http
HTTP/2 200 
date: Tue, 13 Oct 2026 12:22:51 GMT
content-type: application/json
content-length: 3837
cf-ray: a49e4fea39e2fa11-ORD
cf-cache-status: HIT
accept-ranges: bytes
access-control-allow-origin: *
age: 213
cache-control: public, max-age=300
last-modified: Tue, 13 Oct 2026 12:19:17 GMT
server: cloudflare
vary: accept-encoding, accept
set-cookie: __cf_bm=<redacted>; HttpOnly; SameSite=None; Secure; Path=/; Domain=npmjs.org; Expires=Tue, 13 Oct 2026 12:52:51 GMT
```

### 5. Actual response body
```json
{"bugs":{"url":"https://github.com/expressjs/express/issues"},"dist":{"shasum":"ab72dace89c50c8417bd3f865dad0b4fd1ca1c73","tarball":"https://registry.npmjs.org/express/-/express-5.3.0.tgz","fileCount":10,"integrity":"sha512-qCqy1xSoaugxOD4IVHb1ZWdkvCF2W3aE2okKouWj8VwJ+ztskSiXoBnCSJqfKT+cVPJhuJqe9YLbY425+Zh00g==","signatures":[{"sig":"MEQCICHxm5Q3ouMkRSvPzBL4cd1e1inNV4jvmEskclN0pLl5AiAA2D5Tc8x4V1F3mmyvA+cVgJs6yQiGwONT44JG+yX29A==","keyid":"SHA256:DhQ8wR5APBvFHLF/+Tc+AYvPOdTpcIDqOhxsBHRwC7U"}],"attestations":{"url":"https://registry.npmjs.org/-/npm/v1/attestations/express@5.3.0","provenance":{"predicateType":"https://slsa.dev/provenance/v1"}},"unpackedSize":76638},"name":"express","author":{"name":"TJ Holowaychuk","email":"tj@vision-media.ca"},"engines":{"node":">= 18"},"funding":{"url":"https://opencollective.com/express","type":"opencollective"},"gitHead":"cf6722bf89a86905281d9160b6482e08166b5ef0","license":"MIT","scripts":{"lint":"eslint .","test":"mocha --require test/support/env --reporter spec --check-leaks test/ test/acceptance/","test-ci":"nyc --exclude examples --exclude test --exclude benchmarks --reporter=lcovonly --reporter=text npm test","lint:fix":"eslint . --fix","test-cov":"nyc --exclude examples --exclude test --exclude benchmarks --reporter=html --reporter=text npm test","test-tap":"mocha --require test/support/env --reporter tap --check-leaks test/ test/acceptance/"},"_npmUser":{"name":"GitHub Actions","email":"npm-oidc-no-reply@github.com","approver":{"name"
```

_(Body truncated to the first 1500 of 3837 characters for readability; the full body was received.)_

### 6. Status code and Content-Type
**HTTP/2 200** — 200 OK = resource found and returned. application/json = body is JSON, so a client must parse it with `JSON.parse` / `res.json()`.

### 7. Relevance to BookMe
Used by every BookMe microservice (auth, vendor, event-booking, payment-feedback). A GET on a resource that exists is the same shape as `GET /vendors/{id}`.

---

## Request 2: List the dist-tags of `pg` (PostgreSQL driver)

### 1. Objective
List the dist-tags of `pg` (PostgreSQL driver).

### 2. Exact curl command
```bash
curl -i https://registry.npmjs.org/-/package/pg/dist-tags
```

### 3. Actual HTTP request (from `curl -v`)
```http
GET /-/package/pg/dist-tags HTTP/2
Host: registry.npmjs.org
User-Agent: curl/8.5.0
Accept: */*

```

### 4. Actual response status and headers
```http
HTTP/2 200 
date: Tue, 13 Oct 2026 12:23:13 GMT
content-type: application/json
content-length: 43
cf-ray: a49e5077baed1cde-ORD
cf-cache-status: DYNAMIC
server: cloudflare
set-cookie: __cf_bm=<redacted>; HttpOnly; SameSite=None; Secure; Path=/; Domain=npmjs.org; Expires=Tue, 13 Oct 2026 12:53:13 GMT
```

### 5. Actual response body
```json
{
  "beta": "8.14.2-alpha.1",
  "latest": "8.23.1"
}
```

### 6. Status code and Content-Type
**HTTP/2 200** — 200 OK = success. application/json = JSON object body.

### 7. Relevance to BookMe
BookMe uses one PostgreSQL database per service. This small JSON object shows a typical 'collection/summary' read, like `GET /vendors/{id}/services`.

---

## Request 3: Look up the latest metadata of `jsonwebtoken` (JWT library)

### 1. Objective
Look up the latest metadata of `jsonwebtoken` (JWT library).

### 2. Exact curl command
```bash
curl -i https://registry.npmjs.org/jsonwebtoken/latest
```

### 3. Actual HTTP request (from `curl -v`)
```http
GET /jsonwebtoken/latest HTTP/2
Host: registry.npmjs.org
User-Agent: curl/8.5.0
Accept: */*

```

### 4. Actual response status and headers
```http
HTTP/2 200 
date: Tue, 13 Oct 2026 12:23:14 GMT
content-type: application/json
content-length: 2217
cf-ray: a49e5078cf25706b-ORD
cf-cache-status: HIT
accept-ranges: bytes
access-control-allow-origin: *
age: 99
cache-control: public, max-age=300
last-modified: Tue, 13 Oct 2026 12:21:34 GMT
server: cloudflare
vary: accept-encoding, accept
set-cookie: __cf_bm=<redacted>; HttpOnly; SameSite=None; Secure; Path=/; Domain=npmjs.org; Expires=Tue, 13 Oct 2026 12:53:14 GMT
```

### 5. Actual response body
```json
{"nyc":{"lines":95,"exclude":["./test/**"],"branches":95,"reporter":["json","lcov","text-summary"],"functions":100,"statements":95,"check-coverage":true},"bugs":{"url":"https://github.com/auth0/node-jsonwebtoken/issues"},"dist":{"shasum":"6cd57ab01e9b0ac07cb847d53d3c9b6ee31f7ae2","tarball":"https://registry.npmjs.org/jsonwebtoken/-/jsonwebtoken-9.0.3.tgz","fileCount":15,"integrity":"sha512-MT/xP0CrubFRNLNKvxJ2BYfy53Zkm++5bX9dtuPbqAeQpTVe0MQTFhao8+Cp//EmJp244xt6Drw/GVEGCUj40g==","signatures":[{"sig":"MEUCICE5k0CMsR6OIdP9Zpm5B9xBhoJ3h7RV5M/5AfUtNmRBAiEAospGuIHliRFQBbiwRUDXJE03hN4ZXkjSQbLmEZSLGO8=","keyid":"SHA256:DhQ8wR5APBvFHLF/+Tc+AYvPOdTpcIDqOhxsBHRwC7U"}],"unpackedSize":43403},"main":"index.js","name":"jsonwebtoken","author":{"name":"auth0"},"engines":{"npm":">=6","node":">=12"},"gitHead":"ed59e76ea37a80f54b833668c02a5271984dcba3","license":"MIT","scripts":{"lint":"eslint .","test":"mocha","coverage":"nyc mocha --use_strict"},"_npmUser":{"name":"julien.wollscheid","email":"julien.wollscheid@auth0.com"},"homepage":"https://github.com/auth0/node-jsonwebtoken#readme","keywords":["jwt"],"repository":{"url":"git+https://github.com/auth0/node-jsonwebtoken.git","type":"git"},"_npmVersion":"11.6.0","description":"JSON Web Token implementation (symmetric and asymmetric)","directories":{},"maintainers":[{"name":"charlesrea","email":"charles.rea@auth0.com"},{"name":"david.renaud.okta","email":"david.renaud@okta.com"},{"name":"julien.wollscheid","email":"julien.wollscheid@auth0.com"},{
```

_(Body truncated to the first 1500 of 2217 characters for readability; the full body was received.)_

### 6. Status code and Content-Type
**HTTP/2 200** — 200 OK = success. application/json = JSON body.

### 7. Relevance to BookMe
JWT is BookMe's authentication mechanism (`POST /auth/login` returns a token). This request shows a read-only GET with response headers like `cache-control` that BookMe's vendor search could also use.

---

## Request 4: Look up the latest metadata of `amqplib` (RabbitMQ client)

### 1. Objective
Look up the latest metadata of `amqplib` (RabbitMQ client).

### 2. Exact curl command
```bash
curl -i https://registry.npmjs.org/amqplib/latest
```

### 3. Actual HTTP request (from `curl -v`)
```http
GET /amqplib/latest HTTP/2
Host: registry.npmjs.org
User-Agent: curl/8.5.0
Accept: */*

```

### 4. Actual response status and headers
```http
HTTP/2 200 
date: Tue, 13 Oct 2026 12:23:14 GMT
content-type: application/json
content-length: 2504
cf-ray: a49e5079786af603-ORD
cf-cache-status: DYNAMIC
access-control-allow-origin: *
cache-control: max-age=300
server: cloudflare
vary: accept-encoding, accept
set-cookie: __cf_bm=<redacted>; HttpOnly; SameSite=None; Secure; Path=/; Domain=npmjs.org; Expires=Tue, 13 Oct 2026 12:53:14 GMT
```

### 5. Actual response body
```json
{"bugs":{"url":"https://github.com/amqp-node/amqplib/issues"},"dist":{"shasum":"9d70d20d4d04306abb22cadf2431259b3b5e68a9","tarball":"https://registry.npmjs.org/amqplib/-/amqplib-2.2.0.tgz","fileCount":89,"integrity":"sha512-VifzN9aHs/Q3zTruVHXh2yCisQyXexBN91CQ2E5iSyUKyNjH6ilYhJGte5AXZH/Bj1PaH7SwPhyuSf6Msd2udw==","signatures":[{"sig":"MEUCIQCF62tdPgvwhyY4rEJl5ibO/N4cQYtNelTWUMThy3l6sAIgFjRgq4pLIUv5SLfWrr7uG4YOCuh09rRLGtIZQSyzeWg=","keyid":"SHA256:DhQ8wR5APBvFHLF/+Tc+AYvPOdTpcIDqOhxsBHRwC7U"}],"attestations":{"url":"https://registry.npmjs.org/-/npm/v1/attestations/amqplib@2.2.0","provenance":{"predicateType":"https://slsa.dev/provenance/v1"}},"unpackedSize":576753},"main":"./channel_api.js","name":"amqplib","types":"./index.d.ts","author":{"name":"Michael Bridgen","email":"mikeb@squaremobius.net"},"engines":{"node":">=18"},"exports":{".":{"types":"./index.d.ts","default":"./channel_api.js"},"./callback_api":{"types":"./callback_api.d.ts","default":"./callback_api.js"}},"gitHead":"bcd72ddeed61f5fd336b492621584ebb45154621","license":"MIT","scripts":{"lint":"biome lint --max-diagnostics=1000 .","test":"node --test --test-timeout=1000","format":"biome format . --write","test:only":"node --test --test-only --test-timeout=1000","typecheck":"tsc --noEmit -p tsconfig.types.json","rabbitmq-3":"docker run -d --rm --name rabbitmq -p 5672:5672 rabbitmq:3.12-alpine","rabbitmq-4":"docker run -d --rm --name rabbitmq -p 5672:5672 rabbitmq:4.2-alpine"},"_npmUser":{"name":"GitHub Actions","email
```

_(Body truncated to the first 1500 of 2504 characters for readability; the full body was received.)_

### 6. Status code and Content-Type
**HTTP/2 200** — 200 OK = success. application/json = JSON body.

### 7. Relevance to BookMe
RabbitMQ carries events such as BookingCreated / PaymentCompleted. Again a plain GET of a single resource.

---

## Request 5: Request a package that does not exist (intentional 404)

### 1. Objective
Request a package that does not exist (intentional 404).

### 2. Exact curl command
```bash
curl -i https://registry.npmjs.org/bookme-this-package-does-not-exist-404
```

### 3. Actual HTTP request (from `curl -v`)
```http
GET /bookme-this-package-does-not-exist-404 HTTP/2
Host: registry.npmjs.org
User-Agent: curl/8.5.0
Accept: */*

```

### 4. Actual response status and headers
```http
HTTP/2 404 
date: Tue, 13 Oct 2026 12:23:14 GMT
content-type: application/json
content-length: 21
cf-ray: a49e507a9805ca43-ORD
access-control-allow-origin: *
cache-control: public, max-age=300
server: cloudflare
set-cookie: __cf_bm=<redacted>; HttpOnly; SameSite=None; Secure; Path=/; Domain=npmjs.org; Expires=Tue, 13 Oct 2026 12:53:14 GMT
```

### 5. Actual response body
```json
{
  "error": "Not found"
}
```

### 6. Status code and Content-Type
**HTTP/2 404** — 404 Not Found = the server understood the request but the resource does not exist. application/json = even errors come as JSON (`{"error":...}`), the style BookMe's APIs should follow.

### 7. Relevance to BookMe
BookMe must return 404 for e.g. `GET /vendors/99999` or `GET /bookings/{unknownId}`; the client must handle it (show 'Vendor not found').

---

## Request 6: Request a non-existent version of a real package (second 404)

### 1. Objective
Request a non-existent version of a real package (second 404).

### 2. Exact curl command
```bash
curl -i https://registry.npmjs.org/express/0.0.0-bookme-nope
```

### 3. Actual HTTP request (from `curl -v`)
```http
GET /express/0.0.0-bookme-nope HTTP/2
Host: registry.npmjs.org
User-Agent: curl/8.5.0
Accept: */*

```

### 4. Actual response status and headers
```http
HTTP/2 404 
date: Tue, 13 Oct 2026 12:23:14 GMT
content-type: application/json
content-length: 38
cf-ray: a49e507b9e80ab71-ORD
access-control-allow-origin: *
server: cloudflare
set-cookie: __cf_bm=<redacted>; HttpOnly; SameSite=None; Secure; Path=/; Domain=npmjs.org; Expires=Tue, 13 Oct 2026 12:53:14 GMT
```

### 5. Actual response body
```json
"version not found: 0.0.0-bookme-nope"
```

### 6. Status code and Content-Type
**HTTP/2 404** — 404 Not Found = the package exists but that version does not. application/json = JSON error body again.

### 7. Relevance to BookMe
Like asking for an event/booking id that exists in no database: the collection exists, the item does not.

---

## Summary

| # | Request | Status | Content-Type |
|---|---------|--------|--------------|
| 1 | `GET /express/latest` | 200 | application/json |
| 2 | `GET /-/package/pg/dist-tags` | 200 | application/json |
| 3 | `GET /jsonwebtoken/latest` | 200 | application/json |
| 4 | `GET /amqplib/latest` | 200 | application/json |
| 5 | `GET /bookme-this-package-does-not-exist-404` | 404 | application/json |
| 6 | `GET /express/0.0.0-bookme-nope` | 404 | application/json |

Task 1 check: 6 requests (>= 5) with `curl -i`, 2 genuine HTTP 404 responses, all GET, all real output.
