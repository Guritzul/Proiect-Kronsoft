const mongoose = require('mongoose');


const userSchema = new mongoose.Schema({
    nume: String,
    alergeni: [String]
});


module.exports = mongoose.model('User', userSchema);