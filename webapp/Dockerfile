FROM node:20-slim AS base

WORKDIR /app

# Install wget for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build-time environment variables - URLs
ARG WEBSOCKET_SERVER_URL=http://localhost:8081
ARG NEXT_PUBLIC_WEBSOCKET_SERVER_URL=http://localhost:8081

# Build-time environment variables - Twilio credentials
ARG TWILIO_ACCOUNT_SID=
ARG TWILIO_AUTH_TOKEN=
ARG TWILIO_WEBHOOK_URL=

# Build-time environment variables - Feature flags
ARG ENABLE_TWILIO=true
ARG NEXT_PUBLIC_ENABLE_TWILIO=true

# Set env vars for build time - URLs
ENV WEBSOCKET_SERVER_URL=${WEBSOCKET_SERVER_URL}
ENV NEXT_PUBLIC_WEBSOCKET_SERVER_URL=${NEXT_PUBLIC_WEBSOCKET_SERVER_URL}

# Set env vars for build time - Twilio credentials
ENV TWILIO_ACCOUNT_SID=${TWILIO_ACCOUNT_SID}
ENV TWILIO_AUTH_TOKEN=${TWILIO_AUTH_TOKEN}
ENV TWILIO_WEBHOOK_URL=${TWILIO_WEBHOOK_URL}

# Set env vars for build time - Feature flags
ENV ENABLE_TWILIO=${ENABLE_TWILIO}
ENV NEXT_PUBLIC_ENABLE_TWILIO=${NEXT_PUBLIC_ENABLE_TWILIO}

# Build with variables
RUN npm run build

FROM base AS runner
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY package.json next.config.mjs ./

EXPOSE 3000
CMD ["npm", "run", "start"]