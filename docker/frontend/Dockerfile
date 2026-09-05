# ==========================================
# STAGE 1: Build the React Application
# ==========================================
FROM node:22-alpine AS builder

WORKDIR /app

ARG VITE_AUTH_SERVICE

ENV VITE_AUTH_SERVICE=${VITE_AUTH_SERVICE}

# 1. Copy package files first to take advantage of Docker caching
COPY syncseatapp/Frontend/package*.json ./

# 2. Install dependencies cleanly (using install since we verified locks might be missing)
RUN npm install

# 3. Copy the rest of the Frontend codebase into the builder
COPY syncseatapp/Frontend/ .

# 4. Compile and bundle the React code (This creates the 'dist' directory)
RUN npm run build

# ==========================================
# STAGE 2: Lightweight Production Web Server
# ==========================================
FROM nginx:stable-alpine AS runner

# Remove Nginx's default placeholder static landing page
RUN rm -rf /usr/share/nginx/html/*

# Copy the static production bundle compiled by Vite from Stage 1 into Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Add this line near the end of your Stage 2 (runner) in Dockerfile.frontend
COPY syncseatapp/Frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Expose standard HTTP web traffic port
EXPOSE 80

# Start Nginx in the foreground so the container stays alive
CMD ["nginx", "-g", "daemon off;"]
