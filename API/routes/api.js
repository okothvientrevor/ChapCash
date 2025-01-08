const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const User = require('../models/User');
const Transaction = require('../models/Transaction');

const router = express.Router();

const JWT_SECRET = 'your_jwt_secret';

// Enhanced error messages
const ERROR_MESSAGES = {
  TOKEN_MISSING: 'Authentication token is missing. Please provide a valid token.',
  TOKEN_EXPIRED: 'Your session has expired. Please log in again.',
  TOKEN_INVALID: 'Invalid authentication token. Please log in again.',
  ADMIN_REQUIRED: 'This operation requires administrator privileges.',
  USERNAME_INVALID: 'Username can only contain letters, numbers, and underscores.',
  USERNAME_EXISTS: 'This username is already taken. Please choose another one.',
  INSUFFICIENT_BALANCE: 'Your balance is insufficient for this transaction.',
  SELF_PAYMENT: 'You cannot send money to yourself.',
  USER_NOT_FOUND: 'The specified user could not be found.',
  INVALID_AMOUNT: 'Please enter a valid positive amount.',
  INVALID_CREDENTIALS: 'Invalid email or password.',
  SERVER_ERROR: 'An unexpected error occurred. Please try again later.'
};

// Username validation middleware
const validateUsername = (username) => {
  const usernameRegex = /^[a-zA-Z0-9_]+$/;
  return usernameRegex.test(username);
};

// Token authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({
      error: ERROR_MESSAGES.TOKEN_MISSING
    });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
          error: ERROR_MESSAGES.TOKEN_EXPIRED
        });
      }
      return res.status(403).json({
        error: ERROR_MESSAGES.TOKEN_INVALID
      });
    }
    req.user = user;
    next();
  });
};

// Admin middleware
const isAdmin = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({
        error: ERROR_MESSAGES.USER_NOT_FOUND
      });
    }
    if (user.role !== 'admin') {
      return res.status(403).json({
        error: ERROR_MESSAGES.ADMIN_REQUIRED
      });
    }
    next();
  } catch (err) {
    res.status(500).json({
      error: ERROR_MESSAGES.SERVER_ERROR
    });
  }
};

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, username, email, password } = req.body;
    
    if (!validateUsername(username)) {
      return res.status(400).json({
        error: ERROR_MESSAGES.USERNAME_INVALID
      });
    }

    const existingUsername = await User.findOne({ username: username.toLowerCase() });
    if (existingUsername) {
      return res.status(400).json({
        error: ERROR_MESSAGES.USERNAME_EXISTS
      });
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
    
    res.status(201).json({
      message: 'User registered successfully'
    });
  } catch (err) {
    res.status(500).json({
      error: ERROR_MESSAGES.SERVER_ERROR,
      details: err.message
    });
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

// Enhanced payment processing
// Route to process payments between users
// Allows an authenticated user to send money to another user by username
router.post('/payments', authenticateToken, async (req, res) => {
  try {
    const { amount, recipientUsername, description } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({
        error: ERROR_MESSAGES.INVALID_AMOUNT
      });
    }

    if (!validateUsername(recipientUsername)) {
      return res.status(400).json({
        error: ERROR_MESSAGES.USERNAME_INVALID
      });
    }

    if (!description || description.trim() === '') {
      return res.status(400).json({
        error: 'Payment description is required'
      });
    }

    const recipient = await User.findOne({ username: recipientUsername.toLowerCase() });
    if (!recipient) {
      return res.status(404).json({
        error: ERROR_MESSAGES.USER_NOT_FOUND
      });
    }

    if (recipient._id.toString() === req.user.id) {
      return res.status(400).json({
        error: ERROR_MESSAGES.SELF_PAYMENT
      });
    }

    const sender = await User.findById(req.user.id);
    if (sender.balance < amount) {
      return res.status(400).json({
        error: ERROR_MESSAGES.INSUFFICIENT_BALANCE,
        currentBalance: sender.balance,
        requiredAmount: amount
      });
    }

    // Update balances
    sender.balance -= amount;
    recipient.balance += amount;

    // Save both users
    await sender.save();
    await recipient.save();

    // Create enhanced transaction records with sender and receiver details
    const senderTransaction = new Transaction({
      userId: sender._id,
      amount: -amount,
      type: 'debit',
      description: `Payment to @${recipient.username}: ${description}`,
      senderDetails: {
        name: sender.name,
        username: sender.username
      },
      recipientDetails: {
        name: recipient.name,
        username: recipient.username
      }
    });

    const recipientTransaction = new Transaction({
      userId: recipient._id,
      amount,
      type: 'credit',
      description: `Payment from @${sender.username}: ${description}`,
      senderDetails: {
        name: sender.name,
        username: sender.username
      },
      recipientDetails: {
        name: recipient.name,
        username: recipient.username
      }
    });

    await senderTransaction.save();
    await recipientTransaction.save();

    res.status(201).json({
      message: 'Payment processed successfully',
      newBalance: sender.balance,
      transaction: {
        amount,
        recipient: {
          name: recipient.name,
          username: recipient.username
        },
        description,
        timestamp: senderTransaction.createdAt
      }
    });
  } catch (err) {
    res.status(500).json({
      error: ERROR_MESSAGES.SERVER_ERROR,
      details: err.message
    });
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


// Enhanced payment history endpoint
router.get('/payments', authenticateToken, async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .select('amount type description senderDetails recipientDetails createdAt');
    
    res.json({
      transactions,
      count: transactions.length
    });
  } catch (err) {
    res.status(500).json({
      error: ERROR_MESSAGES.SERVER_ERROR,
      details: err.message
    });
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