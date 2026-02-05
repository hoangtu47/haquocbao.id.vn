import { handler } from './build/handler.js';
import express from 'express';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import * as pty from 'node-pty';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const app = express();
const server = createServer(app);

// SvelteKit handler
app.use(handler);

const wss = new WebSocketServer({ server });

console.log("Socket is up and running...");

wss.on('connection', ws => {
    console.log("new session");

    // invoke a shell once a new session is created
    // Default to /bin/rbash to enforce restricted mode
    const shell = pty.spawn('/bin/rbash', [], {
        name: 'xterm-color',
        cwd: '/home/guest',
        env: {
            PATH: '/home/guest/bin',
            TERM: 'xterm-color',
            HOME: '/home/guest'
        },
        cols: 100,
        rows: 100,
        uid: 1001, // guest user new UID
        // Ideally we should look this up or use the name, but node-pty often takes uid/gid.
        // However, node-pty might run as the user running the process. 
        // Since the container runs as root (default), we need to downgrade permissions here if node-pty supports it, OR run the whole process as guest?
        // Wait, node-pty `spawn` allows `uid` and `gid`. 
        // But `useradd` in alpine might give a different UID. 
        // Let's check shadow in Dockerfile or force UID.
        // Actually, if we run the server as root, we can spawn as specific user.
    });

    // Catch incoming command typed
    ws.on('message', (event) => {
        try {
            const data = JSON.parse(event);

            if (typeof data === 'object' && data !== null) {
                if (data.cols && data.rows) {
                    shell.resize(data.cols, data.rows);
                }
            } else {
                shell.write(event);
            }
        } catch (error) {
            // If it's not JSON, treat it as raw input
            shell.write(event);
        }

    });

    // handle WebSocket close event
    ws.on('close', () => {
        console.log("Killed the process!");
        shell.kill();
    });

    // Output: Sent to the frontend every change
    shell.on('data', (data) => {
        ws.send(data);
    });

    // handle the exit event
    shell.on('exit', (code) => {
        // ws.close(1000, `Process exited with code ${code}`); // Optional: close socket on shell exit
        console.log(`Process exited with code ${code}`);
    });

});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
});
