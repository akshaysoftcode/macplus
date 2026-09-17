# --- Hardened Dockerfile (Chapter 7) ---
# Multi-stage: build stage has pip/compilers, final stage has neither -
# strips all build tooling out of what actually ships.
# Distroless final image: no shell, no package manager, no pip, nothing
# an attacker could use to pivot even with a code-execution foothold.
# Runs as the image's built-in non-root "nonroot" user, not root.

FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
# --target installs packages into a plain directory rather than the
# venv/site-packages of THIS image, so the final stage can copy just
# that directory without dragging along pip, setuptools, or this
# stage's own OS packages.
RUN pip install --no-cache-dir --target=/install -r requirements.txt

FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app
COPY --from=builder /install /usr/lib/python3.11/site-packages
COPY app ./app
ENV PYTHONPATH=/usr/lib/python3.11/site-packages

EXPOSE 8000

# Distroless has no shell, so exec-form JSON array is mandatory (shell
# form silently fails - there's no /bin/sh to interpret it). Invoking
# via `python3 -m uvicorn` (module form) rather than a bare `uvicorn`
# command, since --target installs don't create the console_scripts
# wrapper binary uvicorn's own pip install normally would.
ENTRYPOINT ["python3", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# NOTE: no HEALTHCHECK here - distroless has no shell to run one in.
# Liveness/readiness is handled by Kubernetes' own httpGet probe instead
# (kubelet does the check from outside the container, no shell needed
# inside it) - see the Deployment manifest, Chapter 10.
#
# NOTE: the image already runs as its built-in "nonroot" user by default
# (that's what the :nonroot tag means) - no explicit USER line needed.