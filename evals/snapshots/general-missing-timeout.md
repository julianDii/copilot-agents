# Snapshot: general-missing-timeout
# Agent: code-review
# Fixture: fixtures/general/missing_timeout.py
# Date: 2026-02-22
# Rubric score: 7/8 ✅

## Summary
- Single function making an external HTTP request with no timeout
- Small surface area but a genuine reliability risk in production
- Risk: one slow or unresponsive exchange rate API hangs the calling thread indefinitely

## Major issues

1. No timeout on `requests.get` — blocks forever if server is slow or drops the connection silently; in Django/gunicorn exhausts workers under load

## Minor issues

2. `response.json()["rate"]` unvalidated — if API returns an error payload, `KeyError` with no useful context
3. No retry / error handling on transient failures

## Suggested patch

```python
TIMEOUT = (3.05, 10)

def fetch_exchange_rate(currency: str) -> float:
    try:
        response = requests.get(
            f"https://api.exchangerate.example.com/latest/{currency}",
            timeout=TIMEOUT,
        )
        response.raise_for_status()
    except RequestException as exc:
        raise RuntimeError(f"Failed to fetch exchange rate for {currency!r}") from exc

    data = response.json()
    if "rate" not in data:
        raise ValueError(f"Unexpected response shape: {list(data.keys())}")
    return float(data["rate"])
```

## Tests

```python
def test_returns_rate_on_success(): ...
def test_raises_on_timeout(): ...
def test_raises_on_missing_rate_key(): ...
```

