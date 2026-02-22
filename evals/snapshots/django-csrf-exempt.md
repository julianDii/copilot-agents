# Snapshot: django-csrf-exempt
# Agent: django-review
# Fixture: fixtures/django/csrf_exempt.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- `@csrf_exempt` applied to a state-changing, session-authenticated endpoint
- Removes the only CSRF protection on a fund transfer action
- Risk: CSRF attack — malicious site triggers a fund transfer on behalf of any logged-in user

## Major issues

1. **`@csrf_exempt` on a session-auth state-changing endpoint — CSRF vulnerability**
   - `@login_required` uses session authentication, which requires CSRF protection
   - `@csrf_exempt` removes it entirely — any third-party site can POST to this endpoint on behalf of an authenticated user via a hidden form
   - Concrete scenario: user visits `evil.com` while logged in → hidden form auto-submits to `/transfer/` → funds moved without user interaction
   - Fix: remove `@csrf_exempt`; ensure the client sends the CSRF token in the `X-CSRFToken` header

2. **`json.loads(request.body)` without error handling**
   - Malformed JSON body raises `json.JSONDecodeError` → unhandled 500
   - Fix: wrap in `try/except` or use `request.content_type` guard

3. **No input validation on `amount` or `to_account`**
   - `amount` could be negative, zero, or a non-numeric string
   - `to_account` is used directly without ownership or existence check
   - Fix: validate with a form or serializer before processing

## Suggested patch

```python
# Remove @csrf_exempt entirely
@login_required
def transfer_funds(request):
    if request.method != "POST":
        return JsonResponse({"error": "method not allowed"}, status=405)
    try:
        data = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid JSON"}, status=400)

    amount = data.get("amount")
    to_account = data.get("to_account")
    if not amount or not to_account:
        return JsonResponse({"error": "missing fields"}, status=400)
    # validate amount > 0, to_account exists and is accessible...
    return JsonResponse({"status": "ok"})
```

## Tests

```python
def test_csrf_required(client, user):
    client.login(username=user.username, password="x")
    # POST without CSRF token must be rejected
    res = client.post("/transfer/", data={"amount": 100, "to_account": 2},
                      content_type="application/json", enforce_csrf_checks=True)
    assert res.status_code == 403

def test_unauthenticated_cannot_transfer(client):
    res = client.post("/transfer/", data={}, content_type="application/json")
    assert res.status_code in (302, 403)  # redirect to login or forbidden

def test_malformed_json_returns_400(client, user):
    client.force_login(user)
    res = client.post("/transfer/", data="not-json", content_type="application/json")
    assert res.status_code == 400
```

