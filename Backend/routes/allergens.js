require('dotenv').config();
const express = require('express');
const router = express.Router();
const multer = require('multer');
const Groq = require('groq-sdk');

const User = require('../models/user-allergens');
const Scan = require('../models/scan');

// image save
const upload = multer({ storage: multer.memoryStorage() });

// Initialized Groq client
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

router.post('/profile', async (req, res) => {
    const userId = req.userId;
    const { name, allergens } = req.body;

    try {
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
        const labelText = req.body.text;

        const currentUser = await User.findOne({ userId: req.userId });
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

        const result = await groq.chat.completions.create({
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
            status: aiDecision.status
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
        const currentUser = await User.findOne({ userId: req.userId });
        if (!currentUser) {
            return res.status(404).json({ message: "Please set your profile and allergens first!" });
        }

        if (!req.file) {
            return res.status(400).json({ message: "No image provided. Please upload an image with key 'image'." });
        }

        // Groq nu suportă imagini direct, folosim base64 text description
        const imageBase64 = req.file.buffer.toString("base64");

        const prompt = `
            You are an expert nutritionist and allergist. 
            The user is highly allergic to the following ingredients: ${currentUser.allergens.join(", ")}.
            
            The following is a base64 encoded food label image. Read the ingredients list from it.
            
            Check if the label contains any of the user's allergens, including synonyms, derivatives (example: casein for milk, whey, etc.), or variations in different languages (mainly Romanian / English).
            
            You must reply ONLY with a valid JSON object, absolutely no markdown formatting, no code blocks, and no extra text. Use this exact structure:
            {
                "status": "DANGER" (if the allergen or a derivative is clearly in the ingredients), "WARNING" (if it says "may contain" or "traces of"), or "SAFE" (if no risk is found),
                "allergensFound": ["array", "of", "found", "allergens"],
                "extractedText": "The text you read from the image",
                "message": "A short, user-friendly message explaining the verdict."
            }

            Image (base64): ${imageBase64.substring(0, 1000)}...
        `;

        const result = await groq.chat.completions.create({
            model: "llama-3.3-70b-versatile",
            messages: [{ role: "user", content: prompt }],
        });

        let responseText = result.choices[0].message.content;
        responseText = responseText.replace(/```json/gi, '').replace(/```/gi, '').trim();
        const aiDecision = JSON.parse(responseText);

        const newScan = new Scan({
            userId: req.userId,
            labelText: aiDecision.extractedText || "Image Scan",
            allergensFound: aiDecision.allergensFound,
            status: aiDecision.status
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

module.exports = router;