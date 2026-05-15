const exerciseService = require("../services/exerciseService");

const getAllExercises = async (req, res) => {
  try {
    const filters = {
      bodyPart: req.query.bodyPart,
      difficulty: req.query.difficulty,
      category: req.query.category,
    };

    const exercises = await exerciseService.getAllExercises(filters);

    res.status(200).json({
      success: true,
      count: exercises.length, // util pentru aplicația mobilă
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
    await exerciseService.deleteExercise(req.params.id);

    res.status(200).json({
      success: true,
      message: "Exercițiul a fost dezactivat cu succes",
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getAllExercises,
  getExerciseById,
  createExercise,
  updateExercise,
  deleteExercise,
};
