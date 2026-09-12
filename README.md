# DevSecOps Demo Monorepo

Production-grade DevSecOps pipeline build — see `DevSecOps_Pipeline_Action_Plan.pdf`
for the full 14-chapter plan. This repo covers Chapter 1 (app foundation).

## Structure

```
app-api/          FastAPI backend (Python) — intentionally vulnerable, see VULNERABILITIES.md
app-frontend/     React frontend (Vite)
db/               Postgres schema + seed data
infra/            Terraform (added in Chapter 3)
manifests/        Helm/K8s manifests (added in Chapter 7/10)
.github/workflows/  CI pipelines (added starting Chapter 3/4)
VULNERABILITIES.md  Map of planted vulns to expected scanner/gate
```

## Run locally

```bash
docker compose up --build
```

- Frontend: http://localhost:5173
- API: http://localhost:8000 (docs at /docs)
- Postgres: localhost:5432 (appuser / changeme123 — local dev only)

Before first run, generate real bcrypt hashes for the seed users and replace
the placeholders in `db/init.sql`:

```bash
python3 -c "from passlib.hash import bcrypt; print(bcrypt.hash('Password123!'))"
```

## Infra (Chapters 2 &amp; 3 — done)

See `infra/README.md` for the actual run order, backend setup, and — importantly —
**cost control / teardown steps**. This creates real billable AWS resources
(EKS, NAT gateway) the moment you `apply`.

## Next chapters

4. Gitleaks pre-commit + CI job
5. SCA — Trivy fs + Dependency-Check
6. SAST — Semgrep + SonarCloud
7. Container hardening + Kyverno
8. DAST — OWASP ZAP
9. Vault + Secrets Manager
10. Build & CD — GitHub Actions → ECR → Argo CD/Helm
