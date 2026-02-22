# Fixture: business logic in post_save signal
# Expected finding: Major — hidden side effect, hard to test, transaction-unsafe

from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Order
from .emails import send_confirmation_email
from .billing import charge_card


@receiver(post_save, sender=Order)
def on_order_saved(sender, instance, created, **kwargs):
    if created:
        # ← business logic in signal: hidden, transaction-unsafe, untestable in isolation
        charge_card(instance)
        send_confirmation_email(instance)
        instance.status = "confirmed"
        instance.save()  # ← triggers signal again → potential infinite loop

