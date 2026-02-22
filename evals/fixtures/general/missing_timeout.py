# Fixture: missing timeout — HTTP request hangs forever
# Expected finding: Major — requests.get with no timeout will hang indefinitely

import requests


def fetch_exchange_rate(currency: str) -> float:
    response = requests.get(  # ← no timeout — will hang if server is slow/unresponsive
        f"https://api.exchangerate.example.com/latest/{currency}"
    )
    response.raise_for_status()
    return response.json()["rate"]

