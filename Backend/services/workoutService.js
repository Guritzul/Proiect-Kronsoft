const workoutRepository = require("../repositories/workoutRepository");
const exerciseRepository = require("../repositories/exerciseRepository");

const createWorkout = async (userId, data) => {
  if (!data.name) {
    throw new Error("Workout name is required");
  }

  // Validate exercises if provided
  if (data.exercises && Array.isArray(data.exercises)) {
    for (const exerciseId of data.exercises) {
      const exercise = await exerciseRepository.findById(exerciseId);
      if (!exercise) {
        throw new Error(`Exercise not found: ${exerciseId}`);
      }
      if (!exercise.isActive) {
        throw new Error(`Exercise is not active: ${exercise.name || exerciseId}`);
      }
      // Check if it's a private custom exercise and belongs to another user
      if (exercise.createdBy && exercise.createdBy !== userId) {
        throw new Error(`You do not have permission to use exercise: ${exercise.name}`);
      }
    }
  }

  const workoutData = {
    name: data.name,
    description: data.description,
    userId,
    exercises: data.exercises || [],
  };

  return await workoutRepository.create(workoutData);
};

const getWorkouts = async (userId) => {
  return await workoutRepository.findByUser(userId);
};

const getWorkoutById = async (id, userId) => {
  const workout = await workoutRepository.findById(id);
  if (!workout) {
    throw new Error("Workout not found");
  }

  if (workout.userId !== userId) {
    throw new Error("You do not have permission to access this workout");
  }

  return workout;
};

const updateWorkout = async (id, data, userId) => {
  const workout = await workoutRepository.findById(id);
  if (!workout) {
    throw new Error("Workout not found");
  }

  if (workout.userId !== userId) {
    throw new Error("You do not have permission to update this workout");
  }

  // Validate new exercises if provided
  if (data.exercises && Array.isArray(data.exercises)) {
    for (const exerciseId of data.exercises) {
      const exercise = await exerciseRepository.findById(exerciseId);
      if (!exercise) {
        throw new Error(`Exercise not found: ${exerciseId}`);
      }
      if (!exercise.isActive) {
        throw new Error(`Exercise is not active: ${exercise.name || exerciseId}`);
      }
      if (exercise.createdBy && exercise.createdBy !== userId) {
        throw new Error(`You do not have permission to use exercise: ${exercise.name}`);
      }
    }
  }

  const updateData = {};
  if (data.name !== undefined) updateData.name = data.name;
  if (data.description !== undefined) updateData.description = data.description;
  if (data.exercises !== undefined) updateData.exercises = data.exercises;

  return await workoutRepository.update(id, updateData);
};

const deleteWorkout = async (id, userId) => {
  const workout = await workoutRepository.findById(id);
  if (!workout) {
    throw new Error("Workout not found");
  }

  if (workout.userId !== userId) {
    throw new Error("You do not have permission to delete this workout");
  }

  return await workoutRepository.deleteWorkout(id);
};

module.exports = {
  createWorkout,
  getWorkouts,
  getWorkoutById,
  updateWorkout,
  deleteWorkout,
};
