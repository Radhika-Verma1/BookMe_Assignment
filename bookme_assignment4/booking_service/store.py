"""In-process storage. Only app.py touches this module."""
import itertools

_bookings: dict = {}
_by_key: dict = {}
_counter = itertools.count(1)


def reset():
    global _counter
    _bookings.clear(); _by_key.clear(); _counter = itertools.count(1)


def next_id():
    return f"bk_{next(_counter):04d}"


def save(b):
    _bookings[b.id] = b
    if b.idempotency_key:
        _by_key[b.idempotency_key] = b.id
    return b


def get(id_):
    return _bookings.get(id_)


def get_by_key(key):
    id_ = _by_key.get(key)
    return _bookings.get(id_) if id_ else None


def list_all():
    return list(_bookings.values())


def vendor_date_taken(vendor_id, date):
    return any(b.vendor_id == vendor_id and b.service_date == date and b.status != "cancelled"
               for b in _bookings.values())
