const express = require('express');
const router = express.Router();


const User = require('../models/user-allergens');
const Scan = require('../models/scan');


router.post('/profile', async (req, res) => {


    const userId = req.userId; 
    const { name, allergens } = req.body;

    try {


        // Folosim userId pentru a gasi si updata profilul corect, nu doar numele
        const user = await User.findOneAndUpdate(
            { userId: userId }, 
            { userId: userId, name: name, allergens: allergens },
            { new: true, upsert: true }
        );
        res.status(200).json({ message: "Allergy profile saved successfully!", user });
    } catch (error) {
        res.status(500).json({ message: "Error saving profile." });
    }
});


router.post('/scan', async (req, res) => {
    try {
        const labelText = req.body.text.toLowerCase();
        


        // Folosim id-ul utilizatorului logat in loc de "Luca"
        const currentUser = await User.findOne({ userId: req.userId });
        if (!currentUser) {
            return res.status(404).json({ message: "Please set your profile and allergens first!" });
        }

        let dangerAllergens = [];
        let warningAllergens = [];


        currentUser.allergens.forEach(allergen => {
            const lowerAllergen = allergen.toLowerCase();
            

            
            const warningRegex = new RegExp(`\\b(traces of|may contain)\\s+${lowerAllergen}\\b`, 'i');
            const dangerRegex = new RegExp(`\\b${lowerAllergen}\\b`, 'i');


            if (warningRegex.test(labelText)) {
                warningAllergens.push(allergen);
            } 


            else if (dangerRegex.test(labelText)) {
                dangerAllergens.push(allergen);
            }
        });


        let result;
        if (dangerAllergens.length > 0) {
            result = {
                status: "DANGER",
                message: `Found: ${dangerAllergens.join(", ")}. DO NOT EAT! 🛑`
            };
        } else if (warningAllergens.length > 0) {
            result = {
                status: "WARNING",
                message: `Warning! May contain traces of: ${warningAllergens.join(", ")}. Eat at your own risk. ⚠️`
            };
        } else {
            result = {
                status: "SAFE",
                message: "Looks OK, you can eat it safely. ✅"
            };
        }



        const newScan = new Scan({
            userId: req.userId,
            labelText: labelText,
            allergensFound: [...dangerAllergens, ...warningAllergens],
            status: result.status
        });
        await newScan.save();

        res.status(200).json(result);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error processing the label." });
    }
});


router.get('/history', async (req, res) => {
    try {
        const history = await Scan.find({ userId: req.userId }).sort({ date: -1 });
        res.status(200).json(history);
    } catch (error) {
        res.status(500).json({ message: "Could not fetch history." });
    }
});

module.exports = router;