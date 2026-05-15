const exerciseRepository = require("../repositories/exerciseRepository");

const getAllExercises = async (filters = {}) => {
  const query = { isActive: true }; // afișăm doar exercițiile active

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
    throw new Error("Exercițiul nu a fost găsit");
  }

  if (!exercise.isActive) {
    throw new Error("Exercițiul nu mai este disponibil");
  }

  return exercise;
};

const createExercise = async (data) => {
  const existing = await exerciseRepository.findByName(data.name);

  if (existing) {
    throw new Error("Un exercițiu cu acest nume există deja");
  }

  return await exerciseRepository.create(data);
};

const updateExercise = async (id, data) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercițiul nu a fost găsit");
  }

  if (!exercise.isActive) {
    throw new Error("Nu poți modifica un exercițiu inactiv");
  }

  return await exerciseRepository.update(id, data);
};

const deleteExercise = async (id) => {
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercițiul nu a fost găsit");
  }

  if (!exercise.isActive) {
    throw new Error("Exercițiul este deja inactiv");
  }

  return await exerciseRepository.softDelete(id);
};

module.exports = {
  getAllExercises,
  getExerciseById,
  createExercise,
  updateExercise,
  deleteExercise,
};
