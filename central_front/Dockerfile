# ==========================================
# Stage 1: Base & Dependencies
# ==========================================
# ⚡ Cambiar node:20-alpine por node:22-alpine
FROM node:22-alpine AS base

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN pnpm install --frozen-lockfile

# ==========================================
# Stage 2: Build
# ==========================================
FROM base AS builder

WORKDIR /app

COPY . .

RUN pnpm build

# ==========================================
# Stage 3: Production Server (Nginx)
# ==========================================
FROM nginx:alpine-slim AS runner

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
