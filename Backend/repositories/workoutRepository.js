const Workout = require("../models/workout");

const create = async (data) => {
  const workout = new Workout(data);
  return await workout.save();
};

const findByUser = async (userId) => {
  return await Workout.find({ userId }).populate("exercises");
};

const findById = async (id) => {
  return await Workout.findById(id).populate("exercises");
};

const update = async (id, data) => {
  return await Workout.findByIdAndUpdate(id, data, {
    new: true,
    runValidators: true,
  }).populate("exercises");
};

const deleteWorkout = async (id) => {
  return await Workout.findByIdAndDelete(id);
};

module.exports = {
  create,
  findByUser,
  findById,
  update,
  deleteWorkout,
};
