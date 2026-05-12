const mongoose = require('mongoose');


const userAllergenSchema = new mongoose.Schema({
    userId: String,
    name: String,
    allergens: [String]
});


module.exports = mongoose.model('UserAllergen', userAllergenSchema);