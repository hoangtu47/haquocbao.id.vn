# Stage 1: Build the application
FROM node:22-alpine AS builder

# Install build dependencies for node-pty
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Create the production image
FROM node:22-alpine

# Install build dependencies for node-pty in production (needed for rebuild if binary not portable)
# Alternatively, copy from builder if compatible, but node-pty is native.
# Safest is to have runtime deps or ensure binary is correct.
# node-pty needs python/make/g++ to rebuild if npm install runs again, 
# but here we copy node_modules. 
# However, node-pty runtime might need shared libs.
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy built artifacts from the builder stage
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY --from=builder /app/package.json .
COPY --from=builder /app/server.js .

# Copy terminal UI executables to user's home (default root in alpine) 
# The source is in static/terminal-UI inside the builder context (files are in src/app/static/terminal-UI)
# But wait, 'static' is usually in the root. 
# Let's verify source path in builder: /app/static/terminal-UI
COPY --from=builder /app/static/terminal-UI/hello /root/
COPY --from=builder /app/static/terminal-UI/welcome /root/

# Make them executable
RUN chmod +x /root/hello /root/welcome

# Expose the port the app runs on
EXPOSE 3000

# Set Node environment to production
ENV NODE_ENV=production

# Start the application
CMD [ "node", "server.js" ]
