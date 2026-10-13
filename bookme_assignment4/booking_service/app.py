from datetime import date
from flask import Flask, request, jsonify
import errors, store, payment_client
from errors import ApiError, problem
from models import Booking

app = Flask(__name__)

REQUIRED = {"event_id": str, "vendor_id": str, "package_id": str,
            "service_date": str, "amount_inr": int}
STATUSES = {"pending_vendor", "confirmed", "cancelled"}


def validate(body):
    """Replaces the XML Schema: runs before any field of body is used."""
    if not isinstance(body, dict):
        raise errors.bad_request("Body must be a JSON object.")
    for k, t in REQUIRED.items():
        if k not in body:
            raise errors.bad_request(f"Missing field '{k}'.")
        if not isinstance(body[k], t) or isinstance(body[k], bool):
            raise errors.bad_request(f"Field '{k}' must be of type {t.__name__}.")
    try:
        d = date.fromisoformat(body["service_date"])
    except ValueError:
        raise errors.bad_request("service_date must be YYYY-MM-DD.")
    if body["amount_inr"] <= 0:
        raise errors.bad_request("amount_inr must be positive.")
    return d


@app.errorhandler(ApiError)
def _api_error(e):
    return problem(e.status, e.slug, e.title, e.detail)


@app.errorhandler(404)
def _nf(_):
    return problem(404, "not-found", "Not found", "No such route.")


def _load(id_):
    b = store.get(id_)
    if not b:
        raise errors.not_found("Booking", id_)
    return b


@app.post("/bookings")
def create_booking():
    key = request.headers.get("Idempotency-Key")
    if not key:
        raise errors.bad_request("Idempotency-Key header is required.")
    prior = store.get_by_key(key)
    if prior:                                   # repeat: return original, no work redone
        resp = jsonify(prior.as_json()); resp.status_code = 201
        resp.headers["Location"] = f"/bookings/{prior.id}"
        resp.headers["Idempotent-Replayed"] = "true"
        return resp
    body = request.get_json(silent=True)
    d = validate(body)
    if d < date.today():
        raise errors.unprocessable("service_date is in the past.")
    if store.vendor_date_taken(body["vendor_id"], body["service_date"]):
        raise errors.unprocessable("Vendor is not available on that date.")
    bid = store.next_id()
    try:
        pay = payment_client.create_payment(bid, body["amount_inr"] // 5, f"pay-{key}")  # 20% advance
    except payment_client.PaymentRefused as e:
        raise errors.unprocessable(f"Payment refused: {e.detail}")
    except payment_client.PaymentUnavailable as e:
        raise errors.unavailable(str(e))        # fallback = fail, no booking stored
    b = Booking(id=bid, event_id=body["event_id"], vendor_id=body["vendor_id"],
                package_id=body["package_id"], service_date=body["service_date"],
                amount_inr=body["amount_inr"], idempotency_key=key,
                payment_ref=pay.get("id", ""), platform_commission_inr=body["amount_inr"] // 10)
    store.save(b)
    resp = jsonify(b.as_json()); resp.status_code = 201
    resp.headers["Location"] = f"/bookings/{b.id}"
    return resp


@app.get("/bookings/<id_>")
def get_booking(id_):
    return jsonify(_load(id_).as_json())


@app.get("/bookings")
def list_bookings():
    status, event_id, vendor_id = (request.args.get(k) for k in ("status", "event_id", "vendor_id"))
    if status and status not in STATUSES:
        raise errors.bad_request(f"status must be one of {sorted(STATUSES)}.")
    items = [b for b in store.list_all()
             if (not status or b.status == status)
             and (not event_id or b.event_id == event_id)
             and (not vendor_id or b.vendor_id == vendor_id)]
    return jsonify({"items": [b.as_json() for b in items], "count": len(items)})


@app.post("/bookings/<id_>/confirmation")
def confirm(id_):
    b = _load(id_)
    if b.status != "pending_vendor":
        raise errors.conflict(f"Booking is '{b.status}', only pending_vendor can be confirmed.")
    b.status = "confirmed"
    return jsonify(b.as_json())


@app.post("/bookings/<id_>/cancellation")
def cancel(id_):
    b = _load(id_)
    if b.status == "cancelled":
        raise errors.conflict("Booking is already cancelled.")
    reason = (request.get_json(silent=True) or {}).get("reason", "")
    if not isinstance(reason, str):
        raise errors.bad_request("reason must be a string.")
    b.status = "cancelled"
    b.cancellation = {"reason": reason, "refund_status": "pending"}
    resp = jsonify(b.as_json()); resp.status_code = 202   # refund continues after reply
    resp.headers["Location"] = f"/bookings/{b.id}"
    return resp


if __name__ == "__main__":
    app.run(port=5001)
