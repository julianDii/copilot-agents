# Fixture: no issues — clean code
# Expected finding: no blockers or majors; agent must NOT fabricate issues

from decimal import Decimal
from typing import Optional


def calculate_discount(price: Decimal, percent: Optional[Decimal] = None) -> Decimal:
    """Return discounted price. percent must be between 0 and 100."""
    if percent is None:
        return price
    if not (Decimal("0") <= percent <= Decimal("100")):
        raise ValueError(f"percent must be 0–100, got {percent}")
    return price * (1 - percent / Decimal("100"))

