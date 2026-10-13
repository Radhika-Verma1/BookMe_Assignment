# HTTP Testing Guide

## curl basics
| Option | Meaning |
|--------|---------|
| `curl -i URL` | Show response headers and body |
| `curl -v URL` | Also show the request sent |
| `curl -X POST -H "Content-Type: application/json" -d '{"email":"a@b.com"}' URL` | JSON POST |
| `curl -H "Authorization: Bearer <token>" URL` | Authenticated call |

## Status codes used in BookMe
| Code | Use |
|------|-----|
| 200 OK | Successful read/update |
| 201 Created | Event/booking/payment created |
| 400 Bad Request | Invalid input |
| 401 Unauthorized | Missing/invalid JWT |
| 403 Forbidden | Role not allowed (e.g. customer on admin route) |
| 404 Not Found | Unknown vendor/booking id |
| 409 Conflict | Vendor date already booked |

## Future BookMe examples (proposed, services not running yet)
```bash
curl -i -X POST http://localhost:3001/auth/login -H "Content-Type: application/json" -d '{"email":"user@example.com","password":"<password>"}'
curl -i http://localhost:3002/vendors/101
```
Never commit real passwords or tokens.
