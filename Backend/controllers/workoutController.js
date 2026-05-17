const mongoose = require("mongoose");
const workoutService = require("../services/workoutService");

const createWorkout = async (req, res) => {
  try {
    const workout = await workoutService.createWorkout(req.userId, req.body);
    res.status(201).json({
      success: true,
      data: workout,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

const getWorkouts = async (req, res) => {
  try {
    const workouts = await workoutService.getWorkouts(req.userId);
    res.status(200).json({
      success: true,
      count: workouts.length,
      data: workouts,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getWorkoutById = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid workout ID" });
    }
    const workout = await workoutService.getWorkoutById(req.params.id, req.userId);
    res.status(200).json({
      success: true,
      data: workout,
    });
  } catch (error) {
    res.status(404).json({
      success: false,
      message: error.message,
    });
  }
};

const updateWorkout = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid workout ID" });
    }
    const workout = await workoutService.updateWorkout(req.params.id, req.body, req.userId);
    res.status(200).json({
      success: true,
      data: workout,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

const deleteWorkout = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ success: false, message: "Invalid workout ID" });
    }
    await workoutService.deleteWorkout(req.params.id, req.userId);
    res.status(200).json({
      success: true,
      message: "Workout successfully deleted",
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  createWorkout,
  getWorkouts,
  getWorkoutById,
  updateWorkout,
  deleteWorkout,
};
