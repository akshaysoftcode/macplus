# --- Hardened Dockerfile (Chapter 7) ---
# Build stage unchanged (still needs Node/npm to build the bundle).
# Final stage changed: a built React app is just static files - it never
# needed a full Node runtime to SERVE them, that was a bigger attack
# surface than necessary. distroless has no nginx/static-file variant,
# so the minimal equivalent here is nginx-unprivileged: runs as a
# non-root user by default (not root, unlike stock nginx), Alpine-based
# (small), and does one job.

FROM node:20-slim AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
# nginx-unprivileged listens on 8080 by default, not 80 - unprivileged
# users can't bind ports below 1024, which is the whole point of it.
EXPOSE 8080

# NOTE: runs as its built-in "nginx" non-root user by default - no
# explicit USER line needed, same reasoning as the api image.