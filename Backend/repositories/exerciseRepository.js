
const Exercise = require("../models/exercise");

const findAll = async (query) => {
  return await Exercise.find(query);
};

const findById = async (id) => {
  return await Exercise.findById(id);
};

const findByName = async (name) => {
  return await Exercise.findOne({ name });
};

const findByNameAndUser = async (name, userId) => {
  return await Exercise.findOne({
    name: { $regex: new RegExp(`^${name}$`, 'i') },
    isActive: true,
    $or: [
      { createdBy: { $exists: false } },
      { createdBy: null },
      ...(userId ? [{ createdBy: userId }] : [])
    ]
  });
};

const create = async (data) => {
  const exercise = new Exercise(data);
  return await exercise.save();
};

const update = async (id, data) => {
  return await Exercise.findByIdAndUpdate(id, data, {
    new: true,
    runValidators: true,
  });
};

const softDelete = async (id) => {
  return await Exercise.findByIdAndUpdate(
    id,
    { isActive: false },
    { new: true },
  );
};

module.exports = {
  findAll,
  findById,
  findByName,
  findByNameAndUser,
  create,
  update,
  softDelete,
};
