"""Record (what we store) vs representation (what we publish)."""
from dataclasses import dataclass, field
from datetime import datetime, timezone


@dataclass
class Booking:
    id: str
    event_id: str
    vendor_id: str
    package_id: str
    service_date: str            # YYYY-MM-DD
    amount_inr: int
    status: str = "pending_vendor"   # pending_vendor | confirmed | cancelled
    created_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    # ---- internal-only fields: never published ----
    idempotency_key: str = ""
    payment_ref: str = ""            # reference at Payment service
    platform_commission_inr: int = 0
    cancellation: dict | None = None

    def as_json(self):
        body = {
            "id": self.id,
            "event_id": self.event_id,
            "vendor_id": self.vendor_id,
            "package_id": self.package_id,
            "service_date": self.service_date,
            "amount_inr": self.amount_inr,
            "status": self.status,
            "created_at": self.created_at,
            "links": {"self": f"/bookings/{self.id}",
                      "cancellation": f"/bookings/{self.id}/cancellation"},
        }
        if self.cancellation:
            body["cancellation"] = self.cancellation
        return body
