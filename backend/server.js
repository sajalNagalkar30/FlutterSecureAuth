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

// CORS — allow Flutter web (GitHub Pages) and local dev
const allowedOrigins = (process.env.CORS_ORIGIN || '*').split(',').map(o => o.trim());
app.use(cors({
    origin: (origin, callback) => {
        // Allow requests with no origin (mobile apps, curl, Postman)
        if (!origin) return callback(null, true);
        if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
            return callback(null, true);
        }
        callback(new Error(`CORS: origin ${origin} not allowed`));
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Client'],
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
