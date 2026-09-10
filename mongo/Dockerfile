# MongoDB companion service for Sharely Railway template.
# Pulls the official MongoDB 7 image and seeds the application user via
# the upstream-provided scripts/mongo-init.js.
#
# The mongo-init.js script runs once on first container start (via the
# /docker-entrypoint-initdb.d hook) and creates a least-privilege user
# scoped to the sharely database. It reads MONGO_APP_USER,
# MONGO_APP_PASSWORD, and MONGO_DB_NAME from the environment — all
# injected via mongo/template-vars.json.

FROM mongo:7

COPY scripts/mongo-init.js /docker-entrypoint-initdb.d/mongo-init.js:ro

# No USER directive — official mongo image already runs as the
# mongodb user and writes /data/db as that user. The Railway volume
# at /data/db must be root-owned on the host; mongo's entrypoint
# handles permissions internally.
