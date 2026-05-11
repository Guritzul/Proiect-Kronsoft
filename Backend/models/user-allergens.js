const mongoose = require('mongoose');


const userSchema = new mongoose.Schema({
    userId: String,
    name: String,
    allergens: [String]
});


module.exports = mongoose.model('User', userSchema);