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
# However, node-pty runtime might need shared libs.
# 'hello' binary needs 'infocmp' (ncurses) to verify terminal capabilities if terminfo is missing/incomplete.
RUN apk add --no-cache python3 make g++ ncurses

WORKDIR /app

# Copy built artifacts from the builder stage
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY --from=builder /app/package.json .
COPY --from=builder /app/server.js .

# Install bash and shadow (for useradd)
RUN apk add --no-cache bash shadow

# Create a new user 'guest' with restricted shell, forcing UID 1000
RUN useradd -m -u 1000 -s /bin/rbash guest

# Create a directory for allowed commands
RUN mkdir -p /home/guest/bin

# Link restricted bash
RUN ln -s /bin/bash /bin/rbash

# Allowed commands (Whitelisting directly into user's bin folder to be effective with restricted PATH)
# We will set PATH to /home/guest/bin, so only symlinks here will be executable
RUN ln -s /bin/ls /home/guest/bin/ls && \
    ln -s /bin/pwd /home/guest/bin/pwd && \
    ln -s /usr/bin/whoami /home/guest/bin/whoami && \
    ln -s /bin/cat /home/guest/bin/cat && \
    ln -s /usr/bin/clear /home/guest/bin/clear && \
    ln -s /bin/echo /home/guest/bin/echo

# Copy terminal UI executables to guest's home
COPY --from=builder /app/static/terminal-UI/hello /home/guest/bin/
COPY --from=builder /app/static/terminal-UI/welcome /home/guest/bin/

# Make them executable and owned by guest
RUN chmod +x /home/guest/bin/hello /home/guest/bin/welcome && \
    chown -R guest:guest /home/guest

# Expose the port the app runs on
EXPOSE 3000

# Set Node environment to production
ENV NODE_ENV=production

# Start the application
CMD [ "node", "server.js" ]
