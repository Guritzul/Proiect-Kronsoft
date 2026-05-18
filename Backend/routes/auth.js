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
        name: req.user.name || req.user.email.split('@')[0],
        photoUrl: req.user.picture
      });
      await user.save();
    } else {
      let updated = false;
      if (req.user.picture && user.photoUrl !== req.user.picture) {
        user.photoUrl = req.user.picture;
        updated = true;
      }
      if (req.user.name && user.name !== req.user.name && user.name === user.email.split('@')[0]) {
        user.name = req.user.name;
        updated = true;
      }
      if (updated) {
        await user.save();
      }
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

router.delete('/delete-account', auth, async (req, res) => {
  try {
    const userId = req.user.uid;

    // Delete all linked user data across all schemas
    await Promise.all([
      User.findOneAndDelete({ firebaseUid: userId }),
      require('../models/exerciseLog').deleteMany({ userId }),
      require('../models/pill').deleteMany({ userId }),
      require('../models/scan').deleteMany({ userId }),
      require('../models/user-allergens').deleteMany({ userId }),
      require('../models/workout').deleteMany({ userId }),
      require('../models/exercise').deleteMany({ createdBy: userId })
    ]);

    res.json({ success: true, message: 'Account and all linked data deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

const multer = require('multer');
const path = require('path');
const fs = require('fs');
const admin = require('firebase-admin');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = path.join(__dirname, '../uploads/avatars');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `${req.user.uid}_${Date.now()}${ext}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|webp/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Only images are allowed (jpg, jpeg, png, webp)'));
  }
});

router.post('/upload-avatar', auth, upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Nicio imagine incarcata' });
    }

    const protocol = req.headers['x-forwarded-proto'] || req.protocol;
    const host = req.get('host');
    const photoUrl = `${protocol}://${host}/uploads/avatars/${req.file.filename}`;

    // 1. Update Firebase Auth user profile
    await admin.auth().updateUser(req.user.uid, {
      photoURL: photoUrl
    });

    // 2. Update MongoDB User profile
    const user = await User.findOneAndUpdate(
      { firebaseUid: req.user.uid },
      { photoUrl: photoUrl },
      { new: true }
    );

    res.json({
      message: 'Imaginea de profil a fost incarcata cu succes',
      photoUrl,
      user
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;