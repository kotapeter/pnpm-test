# Base image with Node.js and core tools
FROM node:22-slim

# Enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack prepare pnpm@10.0.0 --activate
RUN corepack enable

# Install system dependencies
RUN apt-get update -y && \
    apt-get install -y python3 python3-pip procps && \
    npm install -g @nestjs/cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies - this layer will be cached unless package files change
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --shamefully-hoist

# Copy source and build - this layer only rebuilds if source files change
COPY . .
RUN pnpm run build

ENV PORT 3000
EXPOSE ${PORT}

CMD [ "pnpm", "run", "start:prod" ]
