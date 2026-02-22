# Fixture: DEBUG=True in production settings
# Expected finding: Blocker — exposes stack traces, internal state, and disables security checks

# settings/production.py

DEBUG = True  # ← must be False in production

ALLOWED_HOSTS = ["*"]  # ← must be restricted to actual domain(s)

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "prod_db",
        "USER": "admin",
        "PASSWORD": "supersecret123",  # ← hardcoded secret, should use env var
        "HOST": "db.example.com",
        "PORT": "5432",
    }
}

SECRET_KEY = "django-insecure-hardcoded-key-do-not-use"  # ← hardcoded secret

