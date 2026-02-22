# Fixture: unsafe migration — NOT NULL column without default
# Expected finding: Blocker — will lock the table on large datasets in production

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("orders", "0004_order_status"),
    ]

    operations = [
        migrations.AddField(
            model_name="order",
            name="confirmed_at",
            field=models.DateTimeField(),  # ← NOT NULL, no default — locks table on existing rows
        ),
    ]

