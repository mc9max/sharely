# Sharely Railway template.
# Two-stage build: React client (Vite) + Node/Express server.
#
# Two non-default settings, both required for Railway:
#
# 1. USER root — upstream runs as `appuser` (uid ~1000). Railway mounts the
#    /uploads volume as root-owned; non-root cannot write to a root-owned
#    path and restart-loops on EACCES. Switching to USER root matches
#    Railway's RAILWAY_RUN_UID=0 convention.
#
# 2. Source build (no prebuilt image) — the repo's published image is the
#    same source Dockerfile. Building from source pins the exact React
#    bundle to the deployed commit; layer cache is preserved across
#    redeploys.
#
# Healthcheck is delegated to Railway's platform check (railway.json
# healthcheckPath=/). The upstream docker-compose uses wget which is not
# present in node:20-alpine; doing it at the platform layer avoids a
# second in-container probe that would just race the platform one.

# ---- Stage 1: Build React client ----
FROM node:20-alpine AS builder
WORKDIR /app/client
COPY client/package*.json ./
RUN npm ci
COPY client/ ./
RUN npm run build

# ---- Stage 2: Production server ----
FROM node:20-alpine AS production
WORKDIR /app

# ffmpeg + ghostscript: required for video thumbnails and PDF previews
# (see src/utils/thumbnails.js and src/utils/document-preview.js).
RUN apk add --no-cache ffmpeg ghostscript

COPY package*.json ./
RUN npm ci --omit=dev

COPY app.js ./
COPY src/ ./src/
COPY scripts/ ./scripts/
COPY --from=builder /app/client/dist ./client/dist/

# uploads/ persists between restarts via the /uploads Railway volume.
# Railway mounts volumes as root-owned; appuser cannot write here.
RUN mkdir -p uploads

USER root
EXPOSE 3000
CMD ["node", "app.js"]
