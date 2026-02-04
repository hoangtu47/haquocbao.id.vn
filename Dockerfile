# Stage 1: Build the application
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Remove development dependencies
RUN npm prune --production

# Stage 2: Create the production image
FROM node:22-alpine

WORKDIR /app

# Copy built artifacts from the builder stage
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY --from=builder /app/package.json .

# Expose the port the app runs on
EXPOSE 3000

# Set Node environment to production
ENV NODE_ENV=production

# Start the application
CMD [ "node", "build" ]
