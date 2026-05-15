const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

router.post('/send', async (req, res) => {
  try {
    const { token, title, body } = req.body;

    const message = {
  notification: {
    title: title,
    body: body,
  },
  android: {
    notification: {
      icon: 'ic_notification',
    },
  },
  token: token,
};

    await admin.messaging().send(message);
    res.json({ message: 'Notification successfully sent!' });
  } catch (err) {
    res.status(500).json({ message: 'Error', error: err.message });
  }
});

module.exports = router;