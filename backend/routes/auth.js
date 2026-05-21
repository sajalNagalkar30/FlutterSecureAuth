import express from 'express';
import User from '../model/user.js';
import { protect } from '../middleware/auth.js';
import jwt from "jsonwebtoken";

const router = express.Router();

// ---------- helpers ----------

const generateAccessToken = (id) =>
    jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: "15m" });

const generateRefreshToken = (id) =>
    jwt.sign({ id }, process.env.JWT_REFRESH_SECRET, { expiresIn: "7d" });

// ---------- routes ----------

// POST /api/auth/register
router.post('/register', async (req, res) => {
    const { username, email, password } = req.body;
    try {
        if (!username || !email || !password)
            return res.status(400).json({ message: "Please fill all the fields" });

        if (await User.findOne({ email }))
            return res.status(400).json({ message: "User already exists" });

        const user = await User.create({ username, email, password });

        const accessToken = generateAccessToken(user._id);
        const refreshToken = generateRefreshToken(user._id);

        user.refreshToken = refreshToken;
        await user.save();

        res.status(201).json({
            id: user._id,
            username: user.username,
            email: user.email,
            accessToken,
            refreshToken,
        });
    } catch (err) {
        console.error("Register error:", err.message);
        res.status(500).json({ message: err.message });
    }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        if (!email || !password)
            return res.status(400).json({ message: "Please fill all the fields" });

        const user = await User.findOne({ email });
        if (!user || !(await user.matchPassword(password)))
            return res.status(401).json({ message: "Invalid credentials" });

        const accessToken = generateAccessToken(user._id);
        const refreshToken = generateRefreshToken(user._id);

        user.refreshToken = refreshToken;
        await user.save();

        res.status(200).json({
            id: user._id,
            username: user.username,
            email: user.email,
            accessToken,
            refreshToken,
        });
    } catch (err) {
        console.error("Login error:", err.message);
        res.status(500).json({ message: err.message });
    }
});

// POST /api/auth/refresh-token
// Flutter sends { refreshToken } in body → gets a new accessToken
router.post('/refresh-token', async (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken)
        return res.status(400).json({ message: "Refresh token required" });

    try {
        const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
        const user = await User.findById(decoded.id);

        if (!user || user.refreshToken !== refreshToken)
            return res.status(401).json({ message: "Invalid refresh token" });

        const newAccessToken = generateAccessToken(user._id);
        const newRefreshToken = generateRefreshToken(user._id); // rotate

        user.refreshToken = newRefreshToken;
        await user.save();

        res.status(200).json({
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
        });
    } catch (err) {
        return res.status(401).json({ message: "Refresh token expired or invalid" });
    }
});

// POST /api/auth/logout
router.post('/logout', protect, async (req, res) => {
    try {
        req.user.refreshToken = null;
        await req.user.save();
        res.status(200).json({ message: "Logged out successfully" });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/auth/me  (protected)
router.get("/me", protect, (req, res) => {
    res.status(200).json({
        id: req.user._id,
        username: req.user.username,
        email: req.user.email,
    });
});

export default router;
