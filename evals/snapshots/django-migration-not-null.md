# Snapshot: django-migration-not-null
# Agent: django-review
# Fixture: fixtures/django/migration_not_null.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Migration adds a `NOT NULL` `DateTimeField` to an existing table with no `default`
- Will fail immediately on any table that has existing rows
- Risk: production deployment fails or locks the table, causing downtime

## Blockers

1. **`NOT NULL` column without `default` — breaks on existing rows**
   - Django will attempt to backfill existing rows with a value for `confirmed_at`
   - With no `default`, Django CLI prompts interactively — this silently fails in CI/CD pipelines
   - On PostgreSQL with a large table, `ADD COLUMN NOT NULL` acquires an `ACCESS EXCLUSIVE` lock — blocks all reads and writes for the duration
   - Fix: use a two-phase migration

## Suggested patch

**Phase 1** — add as nullable, no lock:
```python
migrations.AddField(
    model_name="order",
    name="confirmed_at",
    field=models.DateTimeField(null=True, blank=True),
)
```

**Phase 2** — backfill data, then add `NOT NULL` constraint once all rows have a value:
```python
migrations.RunPython(
    lambda apps, schema_editor: apps.get_model("orders", "Order")
        .objects.filter(confirmed_at__isnull=True)
        .update(confirmed_at=timezone.now()),
    reverse_code=migrations.RunPython.noop,
),
migrations.AlterField(
    model_name="order",
    name="confirmed_at",
    field=models.DateTimeField(),
)
```

## Tests

```python
def test_migration_is_reversible():
    # Use pytest-django or Django's MigrationExecutor to verify backwards()
    # raises no exception on the phase-1 migration
    pass

def test_runpython_handles_empty_queryset(migrator):
    # Verify the RunPython backfill handles 0 existing rows without error
    pass
```

