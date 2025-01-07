const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const User = require('../models/User');
const Transaction = require('../models/Transaction');

const router = express.Router();

const JWT_SECRET = 'your_jwt_secret';

// Middleware to validate token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.status(401).send('Access Denied');

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).send('Invalid Token');
    req.user = user;
    next();
  });
};

// Admin middleware
const isAdmin = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    if (user.role !== 'admin') {
      return res.status(403).send('Admin access required');
    }
    next();
  } catch (err) {
    res.status(500).send('Error checking admin status');
  }
};

// Register
router.post('/register', async (req, res) => {
    try {
      const { name, username, email, password } = req.body;
      
      // Check if username already exists
      const existingUsername = await User.findOne({ username: username.toLowerCase() });
      if (existingUsername) {
        return res.status(400).send('Username already taken');
      }
  
      const hashedPassword = await bcrypt.hash(password, 10);
      const user = new User({ 
        name, 
        username: username.toLowerCase(),
        email, 
        password: hashedPassword,
        balance: 0,
        role: 'user'
      });
      await user.save();
      res.status(201).send('User registered');
    } catch (err) {
      res.status(400).send('Error registering user');
    }
  });

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).send('User not found');

    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(401).send('Invalid credentials');

    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token });
  } catch (err) {
    res.status(400).send('Error logging in');
  }
});

// Get user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (err) {
    res.status(400).send('Error fetching profile');
  }
});

// Deposit money
router.post('/deposit', authenticateToken, async (req, res) => {
  try {
    const { amount } = req.body;
    if (amount <= 0) return res.status(400).send('Invalid amount');

    const user = await User.findById(req.user.id);
    user.balance += amount;
    await user.save();

    const transaction = new Transaction({
      userId: req.user.id,
      amount,
      type: 'credit',
      description: 'Deposit'
    });
    await transaction.save();

    res.json({ 
      message: 'Deposit successful',
      newBalance: user.balance 
    });
  } catch (err) {
    res.status(400).send('Error processing deposit');
  }
});

// Process Payment
router.post('/payments', authenticateToken, async (req, res) => {
    try {
      const { amount, recipientUsername } = req.body;
      if (amount <= 0) return res.status(400).send('Invalid amount');
  
      // Find recipient by username
      const recipient = await User.findOne({ username: recipientUsername.toLowerCase() });
      if (!recipient) return res.status(404).send('Recipient not found');
  
      // Prevent sending money to yourself
      if (recipient._id.toString() === req.user.id) {
        return res.status(400).send('Cannot send money to yourself');
      }
  
      const sender = await User.findById(req.user.id);
      if (sender.balance < amount) return res.status(400).send('Insufficient balance');
  
      // Update balances
      sender.balance -= amount;
      recipient.balance += amount;
  
      // Save both users
      await sender.save();
      await recipient.save();
  
      // Create transaction records
      const senderTransaction = new Transaction({
        userId: sender._id,
        amount: -amount,
        type: 'debit',
        description: `Payment to @${recipient.username}`
      });
  
      const recipientTransaction = new Transaction({
        userId: recipient._id,
        amount,
        type: 'credit',
        description: `Payment from @${sender.username}`
      });
  
      await senderTransaction.save();
      await recipientTransaction.save();
  
      res.status(201).json({
        message: 'Payment successful',
        newBalance: sender.balance
      });
    } catch (err) {
      res.status(400).send('Error processing payment');
    }
  });

  // Find user by username (to verify before sending)
router.get('/user/:username', authenticateToken, async (req, res) => {
    try {
      const user = await User.findOne({ 
        username: req.params.username.toLowerCase() 
      }).select('username name');
      
      if (!user) {
        return res.status(404).send('User not found');
      }
  
      res.json({
        username: user.username,
        name: user.name
      });
    } catch (err) {
      res.status(400).send('Error finding user');
    }
  });

// Get Payment History (for authenticated user)
router.get('/payments', authenticateToken, async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.user.id })
      .sort({ createdAt: -1 });
    res.json(transactions);
  } catch (err) {
    res.status(400).send('Error fetching payments');
  }
});

// Get all users (admin only)
router.get('/users', authenticateToken, isAdmin, async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (err) {
    res.status(400).send('Error fetching users');
  }
});

// Get all transactions (admin only)
router.get('/transactions', authenticateToken, isAdmin, async (req, res) => {
  try {
    const transactions = await Transaction.find()
      .sort({ createdAt: -1 })
      .populate('userId', 'name email');
    res.json(transactions);
  } catch (err) {
    res.status(400).send('Error fetching transactions');
  }
});

module.exports = router;