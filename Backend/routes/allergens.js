require('dotenv').config();
const express = require('express');
const router = express.Router();
const multer = require('multer');
const Groq = require('groq-sdk');

const UserAllergen = require('../models/user-allergens');
const Scan = require('../models/scan');

const upload = multer({ storage: multer.memoryStorage() });

let _groq = null;
function getGroq() {
    if (!_groq) {
        if (!process.env.GROQ_API_KEY) {
            throw new Error('GROQ_API_KEY is not set in .env');
        }
        _groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
    }
    return _groq;
}

router.get('/profile', async (req, res) => {
    try {
        const user = await UserAllergen.findOne({ userId: req.userId });
        if (!user) {
            return res.status(200).json({ userId: req.userId, name: '', allergens: [] });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: "Error fetching allergen profile." });
    }
});

router.post('/profile', async (req, res) => {
    const userId = req.userId;
    const { name, allergens } = req.body;

    try {
        const user = await UserAllergen.findOneAndUpdate(
            { userId: userId },
            { userId: userId, name: name, allergens: allergens },
            { new: true, upsert: true }
        );
        res.status(200).json({ message: "Allergy profile saved successfully!", user });
    } catch (error) {
        res.status(500).json({ message: "Error saving profile." });
    }
});

router.delete('/profile', async (req, res) => {
    try {
        await UserAllergen.findOneAndUpdate(
            { userId: req.userId },
            { allergens: [] },
            { new: true }
        );
        res.status(200).json({ message: "Allergen profile cleared." });
    } catch (error) {
        res.status(500).json({ message: "Error clearing allergen profile." });
    }
});


router.post('/scan', async (req, res) => {
    try {
        const labelText = req.body.text;

        const currentUser = await UserAllergen.findOne({ userId: req.userId });
        if (!currentUser) {
            return res.status(404).json({ message: "Please set your profile and allergens first!" });
        }

        const prompt = `
            You are an expert nutritionist and allergist. 
            The user is highly allergic to the following ingredients: ${currentUser.allergens.join(", ")}.
            
            Analyze the following text extracted from a food label via OCR (it might contain typos):
            "${labelText}"
            
            Check if the label contains any of the user's allergens, including synonyms, derivatives (example: casein for milk, whey, etc.), or variations in different languages (mainly Romanian / English).
            
            You must reply ONLY with a valid JSON object, absolutely no markdown formatting, no code blocks, and no extra text. Use this exact structure:
            {
                "status": "DANGER" (if the allergen or a derivative is clearly in the ingredients), "WARNING" (if it says "may contain" or "traces of"), or "SAFE" (if no risk is found),
                "allergensFound": ["array", "of", "found", "allergens"],
                "message": "A short, user-friendly message explaining the verdict."
            }
        `;

        const result = await getGroq().chat.completions.create({
            model: "llama-3.3-70b-versatile",
            messages: [{ role: "user", content: prompt }],
        });

        let responseText = result.choices[0].message.content;
        responseText = responseText.replace(/```json/gi, '').replace(/```/gi, '').trim();

        const aiDecision = JSON.parse(responseText);

        const newScan = new Scan({
            userId: req.userId,
            labelText: labelText,
            allergensFound: aiDecision.allergensFound,
            status: aiDecision.status,
            message: aiDecision.message
        });
        await newScan.save();

        res.status(200).json(aiDecision);

    } catch (error) {
        console.error("AI Scan Error:", error);
        res.status(500).json({ message: "Error processing the label with AI." });
    }
});


router.post('/scan-image', upload.single('image'), async (req, res) => {
    try {
        const currentUser = await UserAllergen.findOne({ userId: req.userId });
        if (!currentUser) {
            return res.status(404).json({ message: "Please set your profile and allergens first!" });
        }

        if (!req.file) {
            return res.status(400).json({ message: "No image provided. Please upload an image with key 'image'." });
        }

        const Tesseract = require('tesseract.js');
        let extractedText = "";
        try {
            const ocrResult = await Tesseract.recognize(req.file.buffer, 'eng+ron');
            extractedText = ocrResult.data.text.trim();
        } catch (ocrError) {
            console.error("OCR Error:", ocrError);
            return res.status(500).json({ message: "Could not read text from the image." });
        }

        if (!extractedText || extractedText.length < 5) {
            return res.status(400).json({ message: "Nu am putut gasi suficient text vizibil in imagine. Incearca o poza mai clara." });
        }

        const prompt = `
            You are an expert nutritionist and allergist. 
            The user is highly allergic to the following ingredients: ${currentUser.allergens.join(", ")}.
            
            Analyze the following text extracted from a food label via OCR (it might contain typos):
            "${extractedText}"
            
            Check if the label contains any of the user's allergens, including synonyms, derivatives (example: casein for milk, whey, etc.), or variations in different languages (mainly Romanian / English).
            
            You must reply ONLY with a valid JSON object, absolutely no markdown formatting, no code blocks, and no extra text. Use this exact structure:
            {
                "status": "DANGER" (if the allergen or a derivative is clearly in the ingredients), "WARNING" (if it says "may contain" or "traces of"), or "SAFE" (if no risk is found),
                "allergensFound": ["array", "of", "found", "allergens"],
                "extractedText": "The text you read from the image",
                "message": "A short, user-friendly message explaining the verdict."
            }
        `;

        const result = await getGroq().chat.completions.create({
            model: "llama-3.3-70b-versatile",
            messages: [{ role: "user", content: prompt }],
        });

        let responseText = result.choices[0].message.content;
        responseText = responseText.replace(/```json/gi, '').replace(/```/gi, '').trim();
        const aiDecision = JSON.parse(responseText);
        
        aiDecision.extractedText = extractedText;

        const newScan = new Scan({
            userId: req.userId,
            labelText: aiDecision.extractedText || "Image Scan",
            allergensFound: aiDecision.allergensFound,
            status: aiDecision.status,
            message: aiDecision.message
        });
        await newScan.save();

        res.status(200).json(aiDecision);

    } catch (error) {
        console.error("AI Image Scan Error:", error);
        res.status(500).json({ message: "Error processing the image with AI." });
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

router.delete('/history', async (req, res) => {
    try {
        const result = await Scan.deleteMany({ userId: req.userId });
        res.status(200).json({ message: "Scan history cleared.", deletedCount: result.deletedCount });
    } catch (error) {
        res.status(500).json({ message: "Error clearing scan history." });
    }
});

module.exports = router;