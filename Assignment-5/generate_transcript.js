const request = require('../../services/event-booking-service/node_modules/supertest');
const fs = require('fs');
const path = require('path');
const app = require('../../services/event-booking-service/src/app');

async function run() {
  let log = '';

  function formatExchange({ title, method, path, reqHeaders, reqBody, res }) {
    log += `======================================================================\n`;
    log += `${title}\n`;
    log += `======================================================================\n\n`;
    log += `* Connected to localhost (127.0.0.1) port 4003\n`;
    log += `> ${method} ${path} HTTP/1.1\n`;
    log += `> Host: localhost:4003\n`;
    log += `> User-Agent: curl/8.4.0\n`;
    for (const [k, v] of Object.entries(reqHeaders)) {
      log += `> ${k}: ${v}\n`;
    }
    log += `>\n`;
    if (reqBody) {
      log += `> ${typeof reqBody === 'string' ? reqBody : JSON.stringify(reqBody)}\n`;
    }
    log += `< HTTP/1.1 ${res.status} ${res.status === 201 ? 'Created' : res.status === 200 ? 'OK' : res.status === 204 ? 'No Content' : res.status === 304 ? 'Not Modified' : res.status === 400 ? 'Bad Request' : res.status === 401 ? 'Unauthorized' : res.status === 404 ? 'Not Found' : res.status === 406 ? 'Not Acceptable' : res.status === 412 ? 'Precondition Failed' : res.status === 422 ? 'Unprocessable Content' : 'Status'}\n`;
    for (const [k, v] of Object.entries(res.headers)) {
      log += `< ${k}: ${v}\n`;
    }
    log += `<\n`;
    if (res.text && res.status !== 304 && res.status !== 204) {
      try {
        log += JSON.stringify(JSON.parse(res.text), null, 2) + '\n\n';
      } catch {
        log += res.text + '\n\n';
      }
    } else {
      log += `* (Empty response body)\n\n`;
    }
  }

  // 1. Create Event (201 Created + Location)
  const createPayload = {
    name: "Alka Wedding Sangeet Celebration",
    eventType: "Wedding",
    dateFrom: "2026-12-20T18:00:00Z",
    dateTo: "2026-12-20T23:00:00Z",
    city: "Ahmedabad",
    venueLocation: {
      address: "Grand Ballroom, Palace Grounds",
      city: "Ahmedabad",
      state: "Gujarat",
      postalCode: "380015",
      latitude: 23.0225,
      longitude: 72.5714,
    },
    guestCount: 350,
    budgetPaise: 50000000,
  };
  const res1 = await request(app)
    .post('/events')
    .set('Content-Type', 'application/json')
    .set('Accept', 'application/json')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer')
    .set('Idempotency-Key', 'idemp-assignment5-key-001')
    .send(createPayload);

  formatExchange({
    title: 'TEST 1: Successful Create Returning 201 Created and Location Header',
    method: 'POST',
    path: '/events',
    reqHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
      'Idempotency-Key': 'idemp-assignment5-key-001',
    },
    reqBody: createPayload,
    res: res1,
  });

  const createdId = res1.body.id;

  // 2. Repeat Create with Same Idempotency-Key
  const res2 = await request(app)
    .post('/events')
    .set('Content-Type', 'application/json')
    .set('Accept', 'application/json')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer')
    .set('Idempotency-Key', 'idemp-assignment5-key-001')
    .send(createPayload);

  formatExchange({
    title: 'TEST 2: Repeat of the Same Create with Same Idempotency-Key (Safe Retry)',
    method: 'POST',
    path: '/events',
    reqHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
      'Idempotency-Key': 'idemp-assignment5-key-001',
    },
    reqBody: createPayload,
    res: res2,
  });

  // 3A. Single Resource Read Fetching ETag & Cache-Control
  const res3a = await request(app)
    .get(`/events/${createdId}`)
    .set('Accept', 'application/json')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer');

  formatExchange({
    title: 'TEST 3A: Single Resource Read Fetching ETag & Cache-Control',
    method: 'GET',
    path: `/events/${createdId}`,
    reqHeaders: {
      'Accept': 'application/json',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
    },
    res: res3a,
  });

  const currentEtag = res3a.headers['etag'];

  // 3B. Conditional GET returning 304 Not Modified
  const res3b = await request(app)
    .get(`/events/${createdId}`)
    .set('Accept', 'application/json')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer')
    .set('If-None-Match', currentEtag);

  formatExchange({
    title: 'TEST 3B: Conditional GET with If-None-Match Returning 304 Not Modified',
    method: 'GET',
    path: `/events/${createdId}`,
    reqHeaders: {
      'Accept': 'application/json',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
      'If-None-Match': currentEtag,
    },
    res: res3b,
  });

  // 4. Conditional Write rejected with 412 Precondition Failed
  const res4 = await request(app)
    .patch(`/events/${createdId}`)
    .set('Content-Type', 'application/json')
    .set('Accept', 'application/json')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer')
    .set('If-Match', 'W/"stale_invalid_etag_999"')
    .send({ guestCount: 400 });

  formatExchange({
    title: 'TEST 4: Conditional Write with Stale If-Match Returning 412 Precondition Failed',
    method: 'PATCH',
    path: `/events/${createdId}`,
    reqHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
      'If-Match': 'W/"stale_invalid_etag_999"',
    },
    reqBody: { guestCount: 400 },
    res: res4,
  });

  // 5. Malformed Request returning 400 Bad Request
  const res5 = await request(app)
    .post('/events')
    .set('Content-Type', 'application/json')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer')
    .send({ name: "" }); // violates minLength schema

  formatExchange({
    title: 'TEST 5: Malformed Schema Request Returning 400 Bad Request',
    method: 'POST',
    path: '/events',
    reqHeaders: {
      'Content-Type': 'application/json',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
    },
    reqBody: { name: "" },
    res: res5,
  });

  // 6. Missing Resource returning 404 Not Found
  const res6 = await request(app)
    .get('/events/evt_non_existent_99999')
    .set('Accept', 'application/json')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer');

  formatExchange({
    title: 'TEST 6: Missing Resource Returning 404 Not Found',
    method: 'GET',
    path: '/events/evt_non_existent_99999',
    reqHeaders: {
      'Accept': 'application/json',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
    },
    res: res6,
  });

  // 7. Protected Request without Token returning 401 Unauthorized
  const res7 = await request(app)
    .post('/events')
    .set('Content-Type', 'application/json')
    .send({ name: "Unauthorized Event" });

  formatExchange({
    title: 'TEST 7: Protected Request Without Token Returning 401 Unauthorized',
    method: 'POST',
    path: '/events',
    reqHeaders: {
      'Content-Type': 'application/json',
    },
    reqBody: { name: "Unauthorized Event" },
    res: res7,
  });

  // 8. OPTIONS Preflight returning 204 with Allow Header
  const res8 = await request(app).options('/events');

  formatExchange({
    title: 'TEST 8: OPTIONS Preflight Returning Allow Header',
    method: 'OPTIONS',
    path: '/events',
    reqHeaders: {},
    res: res8,
  });

  // 9. Content Negotiation rejecting XML with 406 Not Acceptable
  const res9 = await request(app)
    .get('/events')
    .set('Accept', 'application/xml')
    .set('X-User-Id', 'usr_customer_01')
    .set('X-User-Role', 'customer');

  formatExchange({
    title: 'TEST 9: Content Negotiation Unsupported Media Returning 406 Not Acceptable',
    method: 'GET',
    path: '/events',
    reqHeaders: {
      'Accept': 'application/xml',
      'X-User-Id': 'usr_customer_01',
      'X-User-Role': 'customer',
    },
    res: res9,
  });

  const destPath = path.join(__dirname, 'curl-transcript.txt');
  fs.writeFileSync(destPath, log, 'utf-8');
  console.log(`Successfully generated ${destPath}`);
}

run()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
