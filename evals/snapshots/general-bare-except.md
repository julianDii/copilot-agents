# Snapshot: general-bare-except
# Agent: code-review
# Fixture: fixtures/general/bare_except.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Payment function silently swallows all exceptions with a bare `except: pass`
- Failed charges, DB errors, and `KeyboardInterrupt` all disappear without a trace
- Risk: payments fail silently — orders marked neither paid nor failed, no alerting possible

## Blockers

1. **Bare `except: pass` swallows all exceptions**
   - `stripe.charge()` failure → returns `False`? No — returns nothing, `pass` falls through to implicit `return None`
   - `Order.objects.get()` raises `DoesNotExist` → silently ignored, function returns `None`
   - Also catches `KeyboardInterrupt`, `SystemExit`, `MemoryError` — prevents clean shutdown
   - Fix: catch the specific exceptions you expect, re-raise or log everything else

## Suggested patch

```python
import logging
logger = logging.getLogger(__name__)

def process_payment(order_id: int) -> bool:
    try:
        order = Order.objects.get(id=order_id)
    except Order.DoesNotExist:
        logger.error("process_payment: order %s not found", order_id)
        return False

    try:
        charge = stripe.charge(order.total)
        order.mark_paid(charge.id)
        return True
    except stripe.StripeError as exc:
        logger.error("process_payment: stripe error for order %s: %s", order_id, exc)
        return False
    # Let all other exceptions propagate — they are unexpected
```

## Tests

```python
def test_returns_false_when_order_not_found():
    result = process_payment(order_id=99999)
    assert result is False

def test_returns_false_on_stripe_error(order):
    with patch("stripe.charge", side_effect=stripe.StripeError("card declined")):
        assert process_payment(order.id) is False

def test_returns_true_on_success(order):
    with patch("stripe.charge", return_value=Mock(id="ch_123")):
        assert process_payment(order.id) is True

def test_unexpected_exception_propagates(order):
    with patch("stripe.charge", side_effect=RuntimeError("unexpected")):
        with pytest.raises(RuntimeError):
            process_payment(order.id)
```

