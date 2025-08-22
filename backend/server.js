// backend/server.js

const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();

// -------- App config --------
const PORT = process.env.PORT || 5000;
const MONGODB_URI =
  process.env.MONGODB_URI || 'mongodb://localhost:27017/mern_auth_db';
const JWT_SECRET =
  process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';
const CORS_ORIGIN = process.env.CORS_ORIGIN || 'http://localhost:3000';

// -------- Middleware --------
app.use(
  cors({
    origin: CORS_ORIGIN,
    credentials: true,
  })
);
app.use(express.json({ limit: '1mb' }));

// Minimal security headers (adjust as needed)
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});

// -------- MongoDB connection --------
mongoose.set('strictQuery', true);

const connectDB = async () => {
  try {
    await mongoose.connect(MONGODB_URI, {
      autoIndex: true,
    });
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

// -------- Schemas & Models --------
const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    password: { type: String, required: true, minlength: 6 },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
  },
  { timestamps: true }
);

const dataItemSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    description: { type: String, required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

const User = mongoose.model('User', userSchema);
const DataItem = mongoose.model('DataItem', dataItemSchema);

// -------- Helpers --------
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

// Auth middleware
const authenticateToken = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers['authorization'] || '';
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.slice(7)
    : null;

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password');
    if (!user) {
      return res.status(401).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
});

// -------- Routes: Auth --------
app.post(
  '/api/auth/register',
  asyncHandler(async (req, res) => {
    const { name, email, password } = req.body || {};

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }
    if (password.length < 6) {
      return res
        .status(400)
        .json({ error: 'Password must be at least 6 characters' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const user = new User({ name, email, password: hashedPassword });
    await user.save();

    const token = jwt.sign({ userId: user._id }, JWT_SECRET, {
      expiresIn: '24h',
    });

    return res.status(201).json({
      message: 'User created successfully',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  })
);

app.post(
  '/api/auth/login',
  asyncHandler(async (req, res) => {
    const { email, password } = req.body || {};
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ error: 'Invalid credentials' });

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid)
      return res.status(400).json({ error: 'Invalid credentials' });

    const token = jwt.sign({ userId: user._id }, JWT_SECRET, {
      expiresIn: '24h',
    });

    return res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  })
);

app.get(
  '/api/auth/me',
  authenticateToken,
  asyncHandler(async (req, res) => {
    return res.json({
      user: {
        id: req.user._id,
        name: req.user.name,
        email: req.user.email,
        role: req.user.role,
      },
    });
  })
);

// -------- Routes: Data (CRUD) --------
app.get(
  '/api/data',
  authenticateToken,
  asyncHandler(async (req, res) => {
    const items = await DataItem.find({ userId: req.user._id }).sort({
      createdAt: -1,
    });
    return res.json(items);
  })
);

app.post(
  '/api/data',
  authenticateToken,
  asyncHandler(async (req, res) => {
    const { title, description } = req.body || {};
    if (!title || !description) {
      return res
        .status(400)
        .json({ error: 'Title and description are required' });
    }

    const item = new DataItem({
      title,
      description,
      userId: req.user._id,
    });
    await item.save();
    return res.status(201).json(item);
  })
);

app.put(
  '/api/data/:id',
  authenticateToken,
  asyncHandler(async (req, res) => {
    const { title, description } = req.body || {};
    const { id } = req.params;

    if (!title || !description) {
      return res
        .status(400)
        .json({ error: 'Title and description are required' });
    }

    const item = await DataItem.findOneAndUpdate(
      { _id: id, userId: req.user._id },
      { title, description },
      { new: true }
    );

    if (!item) {
      return res.status(404).json({ error: 'Data item not found' });
    }
    return res.json(item);
  })
);

app.delete(
  '/api/data/:id',
  authenticateToken,
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const item = await DataItem.findOneAndDelete({
      _id: id,
      userId: req.user._id,
    });
    if (!item) {
      return res.status(404).json({ error: 'Data item not found' });
    }
    return res.json({ message: 'Data item deleted successfully' });
  })
);

// -------- Health check --------
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// -------- Global error handler --------
app.use((err, req, res, next) => {
  console.error(err);
  if (res.headersSent) return next(err);
  const status = err.status || 500;
  res.status(status).json({ error: err.message || 'Server error' });
});

// -------- Start server --------
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
});
