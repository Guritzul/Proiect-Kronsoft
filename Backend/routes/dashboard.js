const express = require('express');
const router = express.Router();

const Pill = require('../models/pill');
const Scan = require('../models/scan');
const UserAllergen = require('../models/user-allergens');

router.get('/', async (req, res) => {
  try {
    const userId = req.userId;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const pills = await Pill.find({ userId });

    const lastScan = await Scan.findOne({ userId }).sort({ date: -1 });

    const userAllergens = await UserAllergen.findOne({ userId });

    res.status(200).json({
      pills,
      lastScan: lastScan || null,
      allergens: userAllergens?.allergens || [],
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch dashboard data' });
  }
});

module.exports = router;