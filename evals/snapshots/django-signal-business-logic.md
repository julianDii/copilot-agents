# Snapshot: django-signal-business-logic
# Agent: django-review
# Fixture: fixtures/django/signal_business_logic.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Signal handler doing three things it shouldn't: charging a card, sending email, and mutating state
- The `on_commit` omission is the most dangerous — charges can fire on rolled-back transactions
- Risk: data loss, double-charges, and an infinite loop in production

## Blockers

1. `charge_card()` called inside `post_save` without `on_commit` — fires within the transaction; if anything rolls back, money is taken but no order is recorded
2. `instance.save()` inside `post_save` triggers the signal again — potential infinite loop of charges and emails if the `created` guard is ever bypassed

## Major issues

3. Business logic in a signal — untestable in isolation, hidden side effects, hard to reason about transaction boundaries
4. `send_confirmation_email()` inside the transaction — user gets confirmation email for an order that may not exist if the transaction rolls back

## Suggested patch

```python
@receiver(post_save, sender=Order)
def on_order_saved(sender, instance, created, **kwargs):
    if not created:
        return

    def _process():
        charge_card(instance.pk)
        send_confirmation_email(instance.pk)
        Order.objects.filter(pk=instance.pk).update(status="confirmed")

    transaction.on_commit(_process)
```

## Tests

```python
def test_charge_not_called_on_rollback(self, mock_email, mock_charge):
    try:
        with transaction.atomic():
            order = Order.objects.create(total="99.99")
            raise Exception("forced rollback")
    except Exception:
        pass
    mock_charge.assert_not_called()

def test_charge_called_once_on_create(self, mock_email, mock_charge):
    Order.objects.create(total="49.99")
    mock_charge.assert_called_once()

def test_no_charge_on_update(self, mock_charge):
    order = Order.objects.create(total="49.99")
    mock_charge.reset_mock()
    order.total = "59.99"
    order.save()
    mock_charge.assert_not_called()
```

