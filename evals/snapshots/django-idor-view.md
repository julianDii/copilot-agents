# Snapshot: django-idor-view
# Agent: django-review
# Fixture: fixtures/django/idor_view.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- `OrderDetailView` correctly requires authentication but performs zero ownership checks
- Both `GET` and `DELETE` are vulnerable — identical pattern, identical fix needed
- Risk: any authenticated user can read or delete any order in the system by ID enumeration

## Blockers

1. IDOR on `GET` — `get_object_or_404(Order, pk=pk)` fetches any order regardless of ownership
2. IDOR on `DELETE` — any authenticated user can permanently delete any order by PK

## Major issues

3. No `has_object_permission` — ownership logic not centralised; any future handler added to this view silently misses the check
4. `OrderSerializer` fields not verified — without seeing the serializer it may expose sensitive fields; confirm `Meta.fields` is an explicit allowlist not `'__all__'`

## Suggested patch

```python
# permissions.py
class IsOwner(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user

# view
permission_classes = [IsAuthenticated, IsOwner]

def get(self, request, pk):
    order = get_object_or_404(Order, pk=pk)
    self.check_object_permissions(request, order)
    return Response(OrderSerializer(order).data)
```

## Tests

```python
def test_owner_can_get(client, owner, order): ...
def test_other_user_cannot_get(client, other, order): ...   # must be 403 or 404, not 200
def test_other_user_cannot_delete(client, other, order): ... # order must still exist
def test_unauthenticated_cannot_get(client, order): ...      # 401
def test_unauthenticated_cannot_delete(client, order): ...   # 401
```

## Questions

1. Is `Order` multi-tenant? Scope should be `tenant=request.user.tenant` if so.
2. What does `OrderSerializer.Meta.fields` expose? Flag if `'__all__'`.

