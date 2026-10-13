ARG NODE_VERSION=24.21.0
ARG ALPINE_VERSION=3.24

################################################################
# Stage 1: Build-time - Install dependencies
################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS deps

WORKDIR /app

# package-lock.json must generate locally: npm ci installs exactly what it pins.
COPY app/package.json app/package-lock.json ./

RUN npm ci --omit=dev --ignore-scripts --no-audit --no-fund

################################################################
# Stage 2: Runtime
################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS runtime

WORKDIR /app

ARG APP_PORT=3000
ENV PORT=${APP_PORT}
ENV NODE_ENV=production

# owned by root and only readable by the app user, so a compromised process can't modify its own code
COPY --from=deps --chown=root:root /app/node_modules ./node_modules
COPY --chown=root:root app/package.json app/server.js ./

# non root user for kubernetes
USER 1000:1000
EXPOSE ${APP_PORT}
CMD ["node", "server.js"]