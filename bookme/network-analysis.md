# Network Analysis — Browser DevTools

**Course:** CS 543 Web Services — Assignment 1, Task 2
**Project:** BookMe

> **Status: TO BE COMPLETED BY THE STUDENT.** This was prepared in a cloud sandbox with no access to a real browser or DevTools, so no measurements could be taken. Nothing below is invented. Fields marked `______` must be filled in from your own browser. Do not submit the template unfilled.

## How to collect the data
1. Open Chrome or Edge and go to your chosen site (suggestion: an event-vendor discovery site such as WedMeGood, ShaadiSaga or WeddingWire; any accessible site is fine if you explain the choice).
2. Press `F12` (or `Ctrl+Shift+I`, `Cmd+Option+I` on Mac) to open DevTools and click the **Network** tab.
3. Tick **Disable cache**, keep DevTools open.
4. Reload with `Ctrl+R` (hard reload `Ctrl+Shift+R`) and wait until loading finishes.
5. Read the status bar at the bottom: *N requests*, *X MB transferred* (bytes over network, compressed) and *Y MB resources* (uncompressed size).
6. Click the **Time** column header to sort; the largest value is the slowest request. Click the **Status** header to find 3xx / 4xx rows (or type `status-code:404` in the filter box).
7. Take a screenshot of the Network tab and save it in `docs/`.

## 1. Website analyzed
- URL: `______`
- Why chosen: `______` (BookMe-like vendor discovery / booking site?)

## 2. Testing conditions
- Browser and version: `______`
- Date/time: `______`
- Disable cache: ☑ on  | Throttling: `No throttling` (or state it)
- Connection / location: `______`

## 3. Total request count
`______` requests

## 4. Total transferred data and resource size
- Transferred: `______` MB (data actually sent over the network, compressed)
- Resources: `______` MB (uncompressed size of all files)

## 5. Slowest resource
| Name | Type | Status | Duration | Observations |
|------|------|--------|----------|--------------|
| `______` | `______` | `______` | `______` ms | `______` |

## 6. Observed 3xx/4xx responses
| Resource | Status | Meaning |
|----------|--------|---------|
| `______` | `______` | `______` |

(Write "none observed" if there are none.)

## 7. Waterfall observations
Write at least three, from what you actually see in the Waterfall column, e.g.:
1. `______` (e.g. the HTML document loads first and later requests for CSS/JS wait on it)
2. `______` (e.g. a large image or script is the longest bar)
3. `______` (e.g. many requests run in parallel; some wait in "Waiting for server response" for long)

## 8. Lessons for BookMe
Suggested points to connect your findings to (keep only what your data supports):
- **Frontend:** number and size of JS/image files; lazy-load vendor portfolio images; compress and size images.
- **REST APIs:** how many `fetch/XHR` calls the page makes; BookMe's vendor list should be one paginated call, not many.
- **Authentication:** look at the `Authorization` header or cookies on API calls; BookMe will send a JWT in `Authorization: Bearer ...`.
- **Vendor search:** watch the search request fired on typing; use debouncing and server-side filtering.
- **Booking workflow:** a booking touches several services; keep sequential API calls minimal to avoid a long waterfall.
