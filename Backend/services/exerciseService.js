const exerciseRepository = require("../repositories/exerciseRepository");
const User = require("../models/User");

const getAllExercises = async (filters = {}, userId) => {
  const query = { isActive: true };

  if (userId) {
    query.$or = [
      { createdBy: { $exists: false } },
      { createdBy: null },
      { createdBy: userId }
    ];
  } else {
    query.$or = [
      { createdBy: { $exists: false } },
      { createdBy: null }
    ];
  }

  if (filters.search) {
    query.name = { $regex: filters.search, $options: "i" };
  }

  if (filters.bodyPart && filters.bodyPart.toLowerCase() !== "all") {
    query.bodyPart = filters.bodyPart.toLowerCase();
  }

  if (filters.difficulty && filters.difficulty.toLowerCase() !== "all") {
    query.difficulty = filters.difficulty.toLowerCase();
  }

  if (filters.category && filters.category.toLowerCase() !== "all") {
    query.category = filters.category;
  }

  return await exerciseRepository.findAll(query);
};

const getExerciseById = async (id, userId) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercise not found");
  }

  if (!exercise.isActive) {
    throw new Error("Exercise is no longer available");
  }

  if (exercise.createdBy && exercise.createdBy !== userId) {
    throw new Error("You do not have permission to access this exercise");
  }

  return exercise;
};

const createExercise = async (data) => {
  const existing = await exerciseRepository.findByNameAndUser(data.name, data.createdBy);

  if (existing) {
    throw new Error("An exercise with this name already exists");
  }

  return await exerciseRepository.create(data);
};

const updateExercise = async (id, data, userId) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercise not found");
  }

  if (!exercise.isActive) {
    throw new Error("You cannot modify an inactive exercise");
  }

  if (!exercise.createdBy) {
    throw new Error("You cannot modify global exercises");
  }

  if (exercise.createdBy !== userId) {
    throw new Error("You do not have permission to modify this exercise");
  }

  return await exerciseRepository.update(id, data);
};

const deleteExercise = async (id, userId) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercise not found");
  }

  if (!exercise.isActive) {
    throw new Error("Exercise is already inactive");
  }

  if (!exercise.createdBy) {
    throw new Error("You cannot delete global exercises");
  }

  if (exercise.createdBy !== userId) {
    throw new Error("You do not have permission to delete this exercise");
  }

  return await exerciseRepository.softDelete(id);
};

const toggleFavorite = async (firebaseUid, exerciseId) => {
  const user = await User.findOne({ firebaseUid });
  if (!user) throw new Error("User not found");

  const index = user.favoriteExercises.findIndex(id => id.toString() === exerciseId.toString());
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
