# ---- build stage ----
FROM node:22-alpine AS build
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1

# Only lockfiles first for better caching
COPY package.json package-lock.json ./
RUN npm ci

# Now app code
COPY . .

# Standalone output (includes only the code it needs)
RUN npm run build

# ---- runtime stage ----
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production \
    PORT=3000

# Copy the minimal standalone server
COPY --from=build /app/.next/standalone ./          # contains server + minimal node_modules
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

EXPOSE 3000

# Run the Next standalone server
CMD ["node", "server.js"]
