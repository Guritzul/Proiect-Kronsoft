// Importăm repository-ul - service-ul nu vorbește direct cu DB,
// ci prin repository
const exerciseRepository = require("../repositories/exerciseRepository");

// ==================== GET ALL ====================
// Aduce toate exercițiile active, cu filtre opționale
// filters poate conține: { bodyPart, difficulty, category }
const getAllExercises = async (filters = {}) => {
  // Construim obiectul de filtrare
  // Adăugăm doar filtrele care au fost trimise, nu pe toate
  const query = { isActive: true }; // afișăm doar exercițiile active

  // Dacă s-a trimis filtru pentru partea corpului, îl adăugăm la query
  if (filters.bodyPart) {
    query.bodyPart = filters.bodyPart;
  }

  // Dacă s-a trimis filtru pentru dificultate, îl adăugăm la query
  if (filters.difficulty) {
    query.difficulty = filters.difficulty;
  }

  // Dacă s-a trimis filtru pentru categorie, îl adăugăm la query
  if (filters.category) {
    query.category = filters.category;
  }

  // Trimitem query-ul construit către repository
  return await exerciseRepository.findAll(query);
};

// ==================== GET BY ID ====================
// Aduce un exercițiu după ID
// Aruncă eroare dacă exercițiul nu există sau e inactiv
const getExerciseById = async (id) => {
  const exercise = await exerciseRepository.findById(id);

  // Dacă exercițiul nu există în DB, aruncăm o eroare cu mesaj clar
  if (!exercise) {
    throw new Error("Exercițiul nu a fost găsit");
  }

  // Dacă exercițiul există dar e marcat ca inactiv (șters soft),
  // nu îl returnăm
  if (!exercise.isActive) {
    throw new Error("Exercițiul nu mai este disponibil");
  }

  return exercise;
};

// ==================== CREATE ====================
// Creează un exercițiu nou după validarea datelor
const createExercise = async (data) => {
  // Validare de business - verificăm că numele nu e deja folosit
  // Această logică aparține service-ului, nu repository-ului
  const existing = await exerciseRepository.findByName(data.name);

  if (existing) {
    throw new Error("Un exercițiu cu acest nume există deja");
  }

  // Dacă totul e ok, trimitem datele la repository pentru salvare
  return await exerciseRepository.create(data);
};

// ==================== UPDATE ====================
// Modifică un exercițiu existent
const updateExercise = async (id, data) => {
  // Verificăm mai întâi că exercițiul există
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercițiul nu a fost găsit");
  }

  if (!exercise.isActive) {
    throw new Error("Nu poți modifica un exercițiu inactiv");
  }

  // Trimitem datele noi la repository pentru update
  return await exerciseRepository.update(id, data);
};

// ==================== SOFT DELETE ====================
// Marchează exercițiul ca inactiv în loc să îl șteargă din DB
// Astfel păstrăm istoricul - exercițiul există în DB dar nu mai e vizibil
const deleteExercise = async (id) => {
  // Verificăm că exercițiul există înainte să îl ștergem
  const exercise = await exerciseRepository.findById(id);

  if (!exercise) {
    throw new Error("Exercițiul nu a fost găsit");
  }

  // Dacă e deja inactiv, nu are sens să îl ștergem din nou
  if (!exercise.isActive) {
    throw new Error("Exercițiul este deja inactiv");
  }

  // Apelăm soft delete în repository
  return await exerciseRepository.softDelete(id);
};

// Exportăm toate funcțiile pentru a fi folosite în controller
module.exports = {
  getAllExercises,
  getExerciseById,
  createExercise,
  updateExercise,
  deleteExercise,
};
