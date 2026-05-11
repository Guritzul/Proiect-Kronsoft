//quesries catre DB
// src/exercises/exercise.repository.js

// Importăm modelul Exercise pentru a putea face operații pe colecția din MongoDB
const Exercise = require("../models/exercise");

// ==================== FIND ALL ====================
// Aduce toate exercițiile care corespund query-ului primit din service
// query este un obiect de filtrare ex: { isActive: true, bodyPart: "genunchi" }
const findAll = async (query) => {
  return await Exercise.find(query);
};

// ==================== FIND BY ID ====================
// Aduce un singur exercițiu după ID-ul unic generat de MongoDB
const findById = async (id) => {
  return await Exercise.findById(id);
};

// ==================== FIND BY NAME ====================
// Folosit în service pentru a verifica dacă există deja
// un exercițiu cu același nume înainte de a crea unul nou
const findByName = async (name) => {
  return await Exercise.findOne({ name });
};

// ==================== CREATE ====================
// Creează un document nou în colecția exercises
// data conține câmpurile trimise din service
const create = async (data) => {
  const exercise = new Exercise(data);
  return await exercise.save();
};

// ==================== UPDATE ====================
// Găsește exercițiul după ID și îl actualizează cu datele noi
// new: true returnează documentul actualizat, nu pe cel vechi
// runValidators: true asigură că schema Mongoose validează și la update
const update = async (id, data) => {
  return await Exercise.findByIdAndUpdate(id, data, {
    new: true,
    runValidators: true,
  });
};

// ==================== SOFT DELETE ====================
// Nu șterge documentul din DB, doar setează isActive: false
// Astfel păstrăm istoricul exercițiilor
const softDelete = async (id) => {
  return await Exercise.findByIdAndUpdate(
    id,
    { isActive: false },
    { new: true },
  );
};

// Exportăm toate funcțiile pentru a fi folosite în service
module.exports = {
  findAll,
  findById,
  findByName,
  create,
  update,
  softDelete,
};
