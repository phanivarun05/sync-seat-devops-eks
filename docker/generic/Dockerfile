# ======================================================
# Stage 1: Build & Dependency Installation
# ======================================================
FROM node:22-alpine AS builder

# The directory of the microservice (e.g., booking, api-gateway, mail)
ARG SERVICE_PATH=booking

WORKDIR /app

# 1. Copy only package files for the specific service to leverage Docker cache layers
COPY syncseatapp/Backend/${SERVICE_PATH}/package*.json ./

# 2. Install dependencies cleanly
RUN npm install 

# 3. Copy only the code for this specific service directly into /app
COPY syncseatapp/Backend/${SERVICE_PATH}/ .

# ======================================================
# Stage 2: Production Run
# ======================================================
FROM node:22-alpine AS runner

ARG SERVICE_PATH=booking

WORKDIR /app

# Copy only the node_modules from the builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy the application source files from the builder stage
COPY --from=builder /app/ ./

# Drop root privileges for security (alpine node images include a 'node' user)
USER node

# Run the entry file natively
CMD ["node", "index.js"]
