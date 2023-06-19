# syntax=docker/dockerfile:1.5

ARG NODE_VERSION=18

FROM node:${NODE_VERSION}-alpine as base
ARG PNPM_VERSION=8.6.2
ARG PNPM_STORE=/root/.local/share/pnpm/store
ARG WORKDIR=/home/node/app
WORKDIR ${WORKDIR}

RUN corepack enable
RUN corepack prepare pnpm@${PNPM_VERSION} --activate


FROM base as builder

## Cache npm packages unless dependencies changed
COPY --link pnpm-lock.yaml .npmrc ./
RUN --mount=type=cache,target=${PNPM_STORE} \
  pnpm fetch

## Cache pnpm install unless package.json(s) changed
COPY --link package.json ./
# Offline used together with fetch above
RUN pnpm install --offline --frozen-lockfile

## Only rebuild on any source code changes
# .dockerignore just whitelist source code files
COPY  --link . .
RUN pnpm run build


FROM base as runtime
ENV NODE_ENV=production
# LABEL org.opencontainers.image.source https://github.com/callmelann/test-docker-cache-in-action

# Copy files required for pnpm install and node runtime
COPY --link pnpm-lock.yaml .npmrc ./
COPY --link package.json ./

# Copy source code outputs
COPY  --link --from=builder ${WORKDIR}/dist ./dist/
COPY  --link --from=builder ${WORKDIR}/node_modules ./node_modules/

# EXPOSE 8080
CMD ["/bin/ash", "-c", "pnpm start"]