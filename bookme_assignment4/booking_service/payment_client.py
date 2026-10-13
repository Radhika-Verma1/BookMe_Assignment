"""Outbound call to Payment service: env-configured, timeout, retry+backoff+jitter."""
import os, random, time
import requests

TIMEOUT_S = 2.0
MAX_ATTEMPTS = 3
BASE_DELAY_S = 0.2
SLEEP = time.sleep   # patched in tests


class PaymentUnavailable(Exception):
    pass


class PaymentRefused(Exception):
    """4xx from Payments: never retried."""
    def __init__(self, status, detail):
        super().__init__(detail); self.status, self.detail = status, detail


def _base_url():
    url = os.environ.get("PAYMENT_SERVICE_URL")
    if not url:
        raise PaymentUnavailable("PAYMENT_SERVICE_URL is not configured")
    return url.rstrip("/")


def create_payment(booking_id, amount_inr, idempotency_key):
    """Create a payment. Idempotency-Key makes retries safe."""
    url = _base_url() + "/payments"
    last = None
    for attempt in range(1, MAX_ATTEMPTS + 1):
        try:
            r = requests.post(url, json={"booking_id": booking_id, "amount_inr": amount_inr},
                              headers={"Idempotency-Key": idempotency_key}, timeout=TIMEOUT_S)
            if r.status_code < 300:
                return r.json()
            if 400 <= r.status_code < 500:                 # client error: do NOT retry
                raise PaymentRefused(r.status_code, r.text)
            last = f"Payments returned {r.status_code}"    # 5xx: retry
        except (requests.Timeout, requests.ConnectionError) as e:
            last = type(e).__name__
        if attempt < MAX_ATTEMPTS:
            SLEEP(random.uniform(0, BASE_DELAY_S * 2 ** (attempt - 1)))  # full jitter
    raise PaymentUnavailable(f"Payment service failed after {MAX_ATTEMPTS} attempts ({last})")
