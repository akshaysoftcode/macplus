# --- Baseline Dockerfile ---
# This intentionally still runs as root and uses a full (not distroless/slim
# pinned-digest) base image. Chapter 7 hardens this: non-root user, minimal
# base, multi-stage build. Keeping the "before" state here so the Trivy
# image-scan diff in Chapter 7 has something real to show.

FROM python:3.11

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
