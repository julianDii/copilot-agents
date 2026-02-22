# Fixture: bare except — silently swallows errors
# Expected finding: Blocker/Major — bare except discards all exceptions silently

def process_payment(order_id: int) -> bool:
    try:
        order = Order.objects.get(id=order_id)
        charge = stripe.charge(order.total)
        order.mark_paid(charge.id)
        return True
    except:
        pass  # ← bare except: swallows all exceptions including KeyboardInterrupt

