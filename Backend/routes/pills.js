const Pill = require("../models/pill");
const router = require("express").Router();


// Controller functions
const getPills = async (req, res) => {
  try {
    const pills = await Pill.find({ userId: req.userId });
    res.status(200).json(pills);
  } catch (error) {
    console.error("❌ getPills error:", error); // ← adaugă asta
    res.status(500).json({ message: "Failed to fetch pills" });
  }
};

const getPillById = async (req, res) => {
  const { id } = req.params;
  try {
    const pill = await Pill.findOne({ _id: id, userId: req.userId });
    if (!pill) {
      return res.status(404).json({ message: "Pill not found" });
    }
    res.status(200).json(pill);
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch pill" });
  }
};

const createPill = async (req, res) => {
  const { name, schedule, frequency, doctorAdvice, dosage } = req.body;
  try {
    const newPill = new Pill({
      name,
      schedule,
      frequency,
      doctorAdvice,
      dosage,
      userId: req.userId,
    });
    await newPill.save();
    res.status(201).json(newPill);
  } catch (error) {
    res.status(500).json({ message: "Failed to create pill" });
  }
};

const updatePill = async (req, res) => {
  const { id } = req.params;
  const { name, schedule, frequency, doctorAdvice, dosage } = req.body;
  try {
    const updatedPill = await Pill.findOneAndUpdate(
      { _id: id, userId: req.userId },
      { name, schedule, frequency, doctorAdvice, dosage },
      { new: true },
    );
    if (!updatedPill) {
      return res.status(404).json({ message: "Pill not found" });
    }
    res.status(200).json(updatedPill);
  } catch (error) {
    res.status(500).json({ message: "Failed to update pill" });
  }
};

const deletePill = async (req, res) => {
  const { id } = req.params;
  try {
    const deletedPill = await Pill.findOneAndDelete({
      _id: id,
      userId: req.userId,
    });
    if (!deletedPill) {
      return res.status(404).json({ message: "Pill not found" });
    }
    res.status(200).json({ message: "Pill deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Failed to delete pill" });
  }
};

const deletePillHistory = async (req, res) => {
  try {
    await Pill.updateMany(
      { userId: req.userId },
      { $set: { takenDates: [], missedDates: [] } }
    );
    res.status(200).json({ message: "Pill history cleared successfully" });
  } catch (error) {
    res.status(500).json({ message: "Failed to clear pill history" });
  }
};

const markPillAsTaken = async (req, res) => {
  const { id } = req.params;
  try {
    const pill = await Pill.findOne({ _id: id, userId: req.userId });
    if (!pill) {
      return res.status(404).json({ message: "Pill not found" });
    }
    if (!pill.takenDates) {
      pill.takenDates = [];
    }
    pill.takenDates.push(new Date());
    await pill.save();
    res.status(200).json({ message: "Pill marked as taken" });
  } catch (error) {
    res.status(500).json({ message: "Failed to mark pill as taken" });
  }
};

const markPillAsMissed = async (req, res) => {
  const { id } = req.params;
  try {
    const pill = await Pill.findOne({ _id: id, userId: req.userId });
    if (!pill) {
      return res.status(404).json({ message: "Pill not found" });
    }
    if (!pill.missedDates) {
      pill.missedDates = [];
    }
    pill.missedDates.push(new Date());
    await pill.save();
    res.status(200).json({ message: "Pill marked as missed" });
  } catch (error) {
    res.status(500).json({ message: "Failed to mark pill as missed" });
  }
};

const getPillHistory = async (req, res) => {
  const { id } = req.params;
  try {
    const pill = await Pill.findOne({ _id: id, userId: req.userId });
    if (!pill) {
      return res.status(404).json({ message: "Pill not found" });
    }
    res.status(200).json({
      takenDates: pill.takenDates || [],
      missedDates: pill.missedDates || [],
    });
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch pill history" });
  }
};


// Routes
router.get("/", getPills);
router.post("/", createPill);
router.delete("/history", deletePillHistory);
router.get("/:id", getPillById);
router.put("/:id", updatePill);
router.delete("/:id", deletePill);
router.post("/:id/taken", markPillAsTaken);
router.post("/:id/missed", markPillAsMissed);
router.get("/:id/history", getPillHistory);

module.exports = router;