const ExerciseLog = require("../models/exerciseLog");

const create = async (data) => {
  const log = new ExerciseLog(data);
  return await log.save();
};

const findLogsByUser = async (userId) => {
  return await ExerciseLog.find({ userId })
    .populate("exerciseId")
    .sort({ date: -1 });
};

const findById = async (id) => {
  return await ExerciseLog.findById(id).populate("exerciseId");
};

const deleteLog = async (id) => {
  return await ExerciseLog.findByIdAndDelete(id);
};

module.exports = {
  create,
  findLogsByUser,
  findById,
  deleteLog,
};
