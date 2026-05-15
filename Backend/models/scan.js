const mongoose = require('mongoose');


const scanSchema = new mongoose.Schema({
    userId: String,
    labelText: String,
    allergensFound: [String],
    status: String,
    message: String,
    date: { type: Date, default: Date.now }
});


module.exports = mongoose.model('Scan', scanSchema);