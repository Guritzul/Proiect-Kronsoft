const mongoose = require("mongoose");
const exerciseService = require("../services/exerciseService");

const getAllExercises = async (req, res) => {
  try {
    const filters = {
      bodyPart: req.query.bodyPart,
      difficulty: req.query.difficulty,
      category: req.query.category,
      search: req.query.search,
    };

    const exercises = await exerciseService.getAllExercises(filters);

    res.status(200).json({
      success: true,
      count: exercises.length,
      data: exercises,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getExerciseById = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid exercise ID" });
    }
    const exercise = await exerciseService.getExerciseById(req.params.id);

    res.status(200).json({
      success: true,
      data: exercise,
    });
  } catch (error) {
    res.status(404).json({
      success: false,
      message: error.message,
    });
  }
};

const createExercise = async (req, res) => {
  try {
    const exercise = await exerciseService.createExercise(req.body);

    res.status(201).json({
      success: true,
      data: exercise,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

const updateExercise = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid exercise ID" });
    }
    const exercise = await exerciseService.updateExercise(
      req.params.id,
      req.body,
    );

    res.status(200).json({
      success: true,
      data: exercise,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

const deleteExercise = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid exercise ID" });
    }
    await exerciseService.deleteExercise(req.params.id);

    res.status(200).json({
      success: true,
      message: "Exercise successfully deactivated",
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

const toggleFavorite = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid exercise ID" });
    }
    const favorites = await exerciseService.toggleFavorite(
      req.userId,
      req.params.id,
    );
    res.status(200).json({ success: true, data: favorites });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

const getFavorites = async (req, res) => {
  try {
    const favorites = await exerciseService.getFavorites(req.userId);
    res.status(200).json({ success: true, data: favorites });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

module.exports = {
  getAllExercises,
  getExerciseById,
  createExercise,
  updateExercise,
  deleteExercise,
  toggleFavorite,
  getFavorites,
};
