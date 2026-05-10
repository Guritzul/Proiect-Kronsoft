const express = require('express');
const router = express.Router();


const User = require('../models/user');
const Scanare = require('../models/scan');


router.post('/verifica', async (req, res) => {
    try {
        const test_eticheta = req.body.text.toLowerCase();


        const utilizator = await User.findOne({ nume: "Luca" });
        if (!utilizator) return res.status(404).send("User negăsit");

        let alergeniGasiti = [];
        utilizator.alergeni.forEach(alergen => {
            if (test_eticheta.includes(alergen.toLowerCase())) {
                alergeniGasiti.push(alergen);
            }
        });

        let statusFinal = alergeniGasiti.length > 0 ? "PERICOL" : "SIGUR";


        const istoricNou = new Scanare({
            text_eticheta: test_eticheta,
            alergeni_gasiti: alergeniGasiti,
            status: statusFinal
        });
        await istoricNou.save();


        if (statusFinal === "PERICOL") {
            res.json({ status: "PERICOL", mesaj: `Am gasit: ${alergeniGasiti.join(", ")}. NU MANCA!` });
        } else {
            res.json({ status: "SIGUR", mesaj: "Pare OK, poti sa mananci." });
        }

    } catch (error) {
        res.status(500).send("Eroare la scanare");
    }
});

module.exports = router;