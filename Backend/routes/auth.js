const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');

router.post('/sync', auth, async (req, res) => {
  try {
    let user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) {
      user = new User({
        firebaseUid: req.user.uid,
        email: req.user.email,
        name: req.user.name || req.user.email.split('@')[0]
      });
      await user.save();
    }
    res.json({ user });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ user });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;