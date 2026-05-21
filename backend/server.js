import express from 'express';
import https from 'https';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import helmet from 'helmet';
import cors from 'cors';
import { connectDB } from "./config/db.js";
import authRoutes from './routes/auth.js';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PORT = process.env.PORT || 9000;
const USE_HTTPS = process.env.USE_HTTPS === 'true';

const app = express();

// Security headers
app.use(helmet());

// CORS — restrict to your Flutter app's origin in production
app.use(cors({
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));

app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);

app.get('/', (req, res) => {
    res.json({ status: 'API running' });
});

connectDB().then(() => {
    if (USE_HTTPS) {
        const certDir = path.join(__dirname, 'certs');
        const options = {
            key: fs.readFileSync(path.join(certDir, 'server.key')),
            cert: fs.readFileSync(path.join(certDir, 'server.crt')),
        };
        https.createServer(options, app).listen(PORT, () => {
            console.log(`HTTPS Server started at port: ${PORT}`);
        });
    } else {
        app.listen(PORT, () => {
            console.log(`HTTP Server started at port: ${PORT}`);
            console.log('Set USE_HTTPS=true and add certs/ to enable HTTPS for SSL pinning');
        });
    }
});
