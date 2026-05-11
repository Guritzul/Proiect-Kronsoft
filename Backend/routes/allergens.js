require('dotenv').config();
const express = require('express');
const router = express.Router();
const { GoogleGenerativeAI } = require('@google/generative-ai');

const User = require('../models/user-allergens');
const Scan = require('../models/scan');

//Initialized Gemini API client
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

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

//Prompt for AI
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


        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
        const result = await model.generateContent(prompt);
        let responseText = result.response.text();
        

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

router.get('/history', async (req, res) => {
    try {
        const history = await Scan.find({ userId: req.userId }).sort({ date: -1 });
        res.status(200).json(history);
    } catch (error) {
        res.status(500).json({ message: "Could not fetch history." });
    }
});

module.exports = router;