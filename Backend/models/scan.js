const mongoose = require('mongoose');


const scanareSchema = new mongoose.Schema({
    text_eticheta: String,
    alergeni_gasiti: [String],
    status: String,
    data: { type: Date, default: Date.now }
});


module.exports = mongoose.model('Scanare', scanareSchema);