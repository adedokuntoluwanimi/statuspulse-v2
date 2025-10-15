# ---------- 1. Build Stage ----------
FROM node:22-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy all source code
COPY . .

# Build the Next.js app in standalone mode
RUN npm run build

# ---------- 2. Runtime Stage ----------
FROM node:22-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy only the standalone server output and public assets
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/public ./public
COPY --from=build /app/.next/static ./.next/static

# Expose port and start server
EXPOSE 3000
CMD ["node", "server.js"]
