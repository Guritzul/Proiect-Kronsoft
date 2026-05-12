const mongoose = require('mongoose');

const pillSchema = new mongoose.Schema({
  name: String,
  schedule: [String],
  frequency: String,
  takenDates: [Date],
  missedDates: [Date],
  doctorAdvice: String,
  dosage: String,
  userId: String,
});

module.exports = mongoose.model('Pill', pillSchema);
