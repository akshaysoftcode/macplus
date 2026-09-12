"""
Application configuration.

NOTE FOR REVIEWERS: The AWS credentials below are AWS's own published
documentation placeholder values (used throughout AWS's official docs and
test suites) — they are not live credentials. They are left hardcoded here
ON PURPOSE as the Gitleaks demo target for this pipeline. In Chapter 9 these
get replaced with AWS Secrets Manager / Vault-issued dynamic credentials.
"""

import os

# --- INTENTIONAL SECRET (Gitleaks demo target) ---
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
AWS_REGION = "ap-south-1"

# DB config — fine to come from env, but note the default is also a
# hardcoded fallback (a second, softer secrets-hygiene issue to flag)
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://appuser:changeme123@db:5432/appdb",
)

JWT_SECRET = os.getenv("JWT_SECRET", "super-secret-key-change-me")
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_MINUTES = 60
