const exerciseRepository = require("../repositories/exerciseRepository");
const User = require("../models/User");

const getAllExercises = async (filters = {}) => {
  const query = { isActive: true };

  if (filters.search) {
    query.name = { $regex: filters.search, $options: "i" };
  }

  if (filters.bodyPart) {
    query.bodyPart = filters.bodyPart;
  }

  if (filters.difficulty) {
    query.difficulty = filters.difficulty;
  }

  if (filters.category) {
    query.category = filters.category;
  }

  return await exerciseRepository.findAll(query);
};

const getExerciseById = async (id) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercise not found");
  }

  if (!exercise.isActive) {
    throw new Error("Exercise is no longer available");
  }

  return exercise;
};

const createExercise = async (data) => {
  const existing = await exerciseRepository.findByName(data.name);

  if (existing) {
    throw new Error("An exercise with this name already exists");
  }

  return await exerciseRepository.create(data);
};

const updateExercise = async (id, data) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercise not found");
  }

  if (!exercise.isActive) {
    throw new Error("You cannot modify an inactive exercise");
  }

  return await exerciseRepository.update(id, data);
};

const deleteExercise = async (id) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercise not found");
  }

  if (!exercise.isActive) {
    throw new Error("Exercise is already inactive");
  }

  return await exerciseRepository.softDelete(id);
};

const toggleFavorite = async (firebaseUid, exerciseId) => {
  const user = await User.findOne({ firebaseUid });
  if (!user) throw new Error("User not found");

  const index = user.favoriteExercises.indexOf(exerciseId);
  if (index === -1) {
    user.favoriteExercises.push(exerciseId);
  } else {
    user.favoriteExercises.splice(index, 1);
  }
  await user.save();
  return user.favoriteExercises;
};

const getFavorites = async (firebaseUid) => {
  const user = await User.findOne({ firebaseUid }).populate("favoriteExercises");
  if (!user) throw new Error("User not found");
  return user.favoriteExercises;
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
