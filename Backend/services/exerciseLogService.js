const exerciseLogRepository = require("../repositories/exerciseLogRepository");
const exerciseRepository = require("../repositories/exerciseRepository");

const logExercise = async (userId, data) => {
  if (!data.exerciseId) {
    throw new Error("Exercise ID is required to log an exercise");
  }

  const exercise = await exerciseRepository.findById(data.exerciseId);
  if (!exercise) {
    throw new Error("Exercise not found");
  }

  if (!exercise.isActive) {
    throw new Error("Cannot log an inactive exercise");
  }

  // Populate default sets/repetitions/duration from the exercise if not provided
  const logData = {
    userId,
    exerciseId: data.exerciseId,
    date: data.date || new Date(),
    sets: data.sets !== undefined ? data.sets : exercise.sets,
    repetitions: data.repetitions !== undefined ? data.repetitions : exercise.repetitions,
    durationMinutes: data.durationMinutes !== undefined ? data.durationMinutes : exercise.durationMinutes,
    weight: data.weight,
    notes: data.notes,
    workoutName: data.workoutName,
  };

  const createdLog = await exerciseLogRepository.create(logData);
  return await exerciseLogRepository.findById(createdLog._id);
};

const getLogs = async (userId) => {
  return await exerciseLogRepository.findLogsByUser(userId);
};

const getHistory = async (userId) => {
  const logs = await exerciseLogRepository.findLogsByUser(userId);
  
  // Group logs by date (YYYY-MM-DD format based on the exercise log date)
  const grouped = {};
  
  logs.forEach((log) => {
    const logDate = log.date || log.createdAt;
    const dateString = new Date(logDate).toISOString().split("T")[0];
    
    if (!grouped[dateString]) {
      grouped[dateString] = [];
    }
    grouped[dateString].push(log);
  });

  // Return a sorted array of objects grouped by date (newest first)
  return Object.keys(grouped)
    .sort((a, b) => b.localeCompare(a))
    .map((date) => ({
      date,
      logs: grouped[date],
    }));
};

const deleteLog = async (id, userId) => {
  const log = await exerciseLogRepository.findById(id);
  if (!log) {
    throw new Error("Exercise log not found");
  }

  if (log.userId !== userId) {
    throw new Error("You do not have permission to delete this log");
  }

  return await exerciseLogRepository.deleteLog(id);
};

module.exports = {
  logExercise,
  getLogs,
  getHistory,
  deleteLog,
};
