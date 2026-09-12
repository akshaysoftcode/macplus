# Planted Vulnerabilities — Reference Map

This app deliberately contains the vulnerabilities below so each pipeline
gate has something real to catch. Do not "fix" these until the chapter that
targets them — each one is a scanner's demo target, not a bug to close early.

| # | Vulnerability | OWASP Top 10 | Location | Expected detector |
|---|---|---|---|---|
| 1 | Hardcoded AWS access key + secret key | A05/A07 | `app-api/app/config.py` | Gitleaks |
| 2 | Outdated dependency with known CVE (PyYAML 5.3.1, requests 2.19.1) | A06 | `app-api/requirements.txt` | Trivy fs / OWASP Dependency-Check |
| 3 | SQL injection via f-string query | A03 | `app-api/app/main.py` → `search_items()` | Semgrep / SonarCloud (static), OWASP ZAP (dynamic) |
| 4 | Broken access control — no auth dependency on admin route | A01 | `app-api/app/main.py` → `admin_list_users()` | Semgrep (missing-auth-check), ZAP authenticated scan |
| 5 | Root user + full base image in Dockerfile | A05/A08 | `app-api/Dockerfile` | Trivy image scan (hardened in Chapter 7) |
| 6 | Permissive CORS (`allow_origins=["*"]`) | A05 | `app-api/app/main.py` | Semgrep / manual review |
| 7 | Hardcoded fallback JWT secret / DB password | A05/A07 | `app-api/app/config.py` | Gitleaks (secondary pattern) / manual review |

## How to reproduce each finding manually (for your own verification before wiring CI)

- **SQLi**: `GET /items/search?name=' OR '1'='1` returns all rows regardless of name.
- **Broken access control**: `GET /admin/users` with no `Authorization` header still returns the user list.
- **Secrets**: `grep -rn "AKIA" app-api/` finds the hardcoded key in `config.py`.
- **SCA**: `pip install pip-audit && pip-audit -r app-api/requirements.txt` lists CVEs for PyYAML/requests.

## Fix timeline (do not fix early)

These stay live through Chapters 4-8 so each gate has a real finding to
show and screenshot. Fix them only once the corresponding gate is wired and
has demonstrably caught them — that "before/after" is the interview story.
