# ======================================================
# Stage 1: Build & Dependency Installation
# ======================================================
FROM node:22-alpine AS builder

# The directory of the microservice (passed dynamically from docker-compose)
ARG SERVICE_PATH=booking

WORKDIR /app

# 1. Copy package files matching the exact workspace directory structure
COPY syncseatapp/Backend/${SERVICE_PATH}/package*.json ./Backend/${SERVICE_PATH}/

# 2. Step into the specific microservice folder to cleanly install dependencies
WORKDIR /app/Backend/${SERVICE_PATH}
RUN npm install

# 3. Step back out to the app root to lay out the source code structure
WORKDIR /app
# Copy the shared utilities folder (satisfies '../../utils/keepAlive.js')
COPY syncseatapp/Backend/utils/ ./Backend/utils/
# Copy the specific microservice source code
COPY syncseatapp/Backend/${SERVICE_PATH}/ ./Backend/${SERVICE_PATH}/

# ======================================================
# Stage 2: Production-Hardened Runtime
# ======================================================
FROM node:22-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

# Bring the service path build argument into the runtime stage environment
ARG SERVICE_PATH=booking
ENV SERVICE_PATH_ENV=${SERVICE_PATH}

# Copy the completely structured Backend directory tree from Stage 1
COPY --from=builder /app/Backend/ ./Backend/

# Security Hardening: Drop root privileges (Alpine Node images include a 'node' user)
USER node

# Set the working execution context directly inside the target microservice folder
WORKDIR /app/Backend/${SERVICE_PATH_ENV}

# Run the entry file natively using the V8 engine
CMD ["node", "index.js"]
