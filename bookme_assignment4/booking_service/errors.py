"""One error shape for the whole service (RFC 7807 style)."""
from flask import jsonify

BASE = "https://bookme.example/problems/"


class ApiError(Exception):
    def __init__(self, status, slug, title, detail):
        self.status, self.slug, self.title, self.detail = status, slug, title, detail


def problem(status, slug, title, detail):
    resp = jsonify({"type": BASE + slug, "title": title,
                    "status": status, "detail": detail})
    resp.status_code = status
    resp.headers["Content-Type"] = "application/problem+json"
    return resp


def bad_request(detail):   return ApiError(400, "malformed-body", "Malformed request body", detail)
def not_found(what, id_):  return ApiError(404, "not-found", f"{what} not found", f"No {what.lower()} with id '{id_}'.")
def conflict(detail):      return ApiError(409, "state-conflict", "State conflict", detail)
def unprocessable(detail): return ApiError(422, "domain-rule", "Request refused by domain rules", detail)
def unavailable(detail):   return ApiError(503, "dependency-unavailable", "Payment service unavailable", detail)
