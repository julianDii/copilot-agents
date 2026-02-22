# Snapshot: django-n-plus-one
# Agent: django-review
# Fixture: fixtures/django/n_plus_one.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- List view iterates all orders and accesses `order.user.email` in a loop without `select_related`
- Fires one DB query per order — 1000 orders = 1001 queries
- Risk: severe performance degradation under load; will time out on large datasets

## Major issues

1. **N+1 query — `order.user.email` in loop without `select_related`**
   - `Order.objects.all()` fetches orders in one query
   - Each `order.user` access in the loop fires a separate `SELECT` on the `auth_user` table
   - Fix: `Order.objects.select_related('user').all()`

2. **No pagination — `Order.objects.all()` returns entire table**
   - On any non-trivial dataset this will OOM or time out
   - Fix: add DRF pagination or manual `LIMIT`/`OFFSET`

## Suggested patch

```python
class OrderListView(APIView):
    def get(self, request):
        orders = Order.objects.select_related('user').all()[:100]  # add proper pagination
        data = [
            {
                "id": order.id,
                "total": str(order.total),
                "user_email": order.user.email,
            }
            for order in orders
        ]
        return Response(data)
```

## Tests

```python
def test_list_view_query_count(client, django_assert_num_queries, user):
    Order.objects.bulk_create([Order(user=user, total="9.99") for _ in range(10)])
    client.force_authenticate(user)
    with django_assert_num_queries(1):  # exactly 1 query with select_related
        client.get("/orders/")
```

