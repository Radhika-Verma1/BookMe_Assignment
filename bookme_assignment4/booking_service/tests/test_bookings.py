import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
import pytest, store, payment_client
from app import app

GOOD = {"event_id": "ev_1", "vendor_id": "v_9", "package_id": "pk_2",
        "service_date": "2030-12-01", "amount_inr": 50000}


@pytest.fixture(autouse=True)
def client(monkeypatch):
    store.reset()
    calls = []
    def fake_pay(bid, amt, key):
        calls.append(key); return {"id": "pay_1"}
    monkeypatch.setattr(payment_client, "create_payment", fake_pay)
    c = app.test_client(); c.calls = calls
    return c


def test_create_returns_201_and_location(client):
    r = client.post("/bookings", json=GOOD, headers={"Idempotency-Key": "k1"})
    assert r.status_code == 201
    assert r.headers["Location"] == "/bookings/" + r.get_json()["id"]
    assert "idempotency_key" not in r.get_json() and "payment_ref" not in r.get_json()


def test_idempotent_repeat_returns_original(client):
    a = client.post("/bookings", json=GOOD, headers={"Idempotency-Key": "k1"})
    b = client.post("/bookings", json=GOOD, headers={"Idempotency-Key": "k1"})
    assert b.get_json()["id"] == a.get_json()["id"]
    assert len(client.calls) == 1            # payment not charged twice
    assert len(client.get("/bookings").get_json()["items"]) == 1


def test_malformed_body_returns_400_problem(client):
    r = client.post("/bookings", json={"vendor_id": "v_9"}, headers={"Idempotency-Key": "k2"})
    assert r.status_code == 400
    assert set(r.get_json()) == {"type", "title", "status", "detail"}


def test_unknown_id_returns_404(client):
    r = client.get("/bookings/bk_9999")
    assert r.status_code == 404 and r.get_json()["status"] == 404
