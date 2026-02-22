# Snapshot: django-debug-settings
# Agent: django-review
# Fixture: fixtures/django/debug_settings.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Production settings file with four hardcoded secrets and two insecure configuration values
- No good findings — every issue here is a Blocker
- Risk: deploying this file exposes the entire application and database

## Blockers

1. `DEBUG = True` — exposes full stack traces, local variables, and settings values to unauthenticated users; disables security checks
2. `ALLOWED_HOSTS = ["*"]` — allows HTTP Host header injection; must be restricted to actual domain(s)
3. `SECRET_KEY = "django-insecure-..."` — hardcoded in version control; anyone with repo access can forge sessions, CSRF tokens, and password reset links
4. `PASSWORD = "supersecret123"` in `DATABASES` — hardcoded DB password in source; full database access for anyone with repo access

## Suggested patch

```python
import os

DEBUG = os.environ.get("DEBUG", "False") == "True"
ALLOWED_HOSTS = os.environ["ALLOWED_HOSTS"].split(",")
SECRET_KEY = os.environ["SECRET_KEY"]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ["DB_NAME"],
        "USER": os.environ["DB_USER"],
        "PASSWORD": os.environ["DB_PASSWORD"],
        "HOST": os.environ["DB_HOST"],
        "PORT": os.environ.get("DB_PORT", "5432"),
    }
}

SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

## Tests

```python
def test_debug_is_false_in_production(settings):
    assert settings.DEBUG is False

def test_secret_key_not_hardcoded(settings):
    assert "insecure" not in settings.SECRET_KEY
    assert len(settings.SECRET_KEY) >= 50

def test_allowed_hosts_not_wildcard(settings):
    assert "*" not in settings.ALLOWED_HOSTS

def test_db_password_from_env():
    assert "supersecret" not in os.environ.get("DB_PASSWORD", "")
```

