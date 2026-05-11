//handle request/response
const exerciseService = require("../services/exerciseService");

// ==================== GET ALL ====================
// Handlează GET /exercises
// Poate primi filtre opționale prin query params
// ex: /exercises?bodyPart=genunchi&difficulty=usor
const getAllExercises = async (req, res) => {
  try {
    // Extragem filtrele din query params dacă există
    const filters = {
      bodyPart: req.query.bodyPart,
      difficulty: req.query.difficulty,
      category: req.query.category,
    };

    const exercises = await exerciseService.getAllExercises(filters);

    // Returnăm lista cu status 200 OK
    res.status(200).json({
      success: true,
      count: exercises.length, // util pentru aplicația mobilă
      data: exercises,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ==================== GET BY ID ====================
// Handlează GET /exercises/:id
const getExerciseById = async (req, res) => {
  try {
    // ID-ul vine din URL ex: /exercises/64abc123
    const exercise = await exerciseService.getExerciseById(req.params.id);

    res.status(200).json({
      success: true,
      data: exercise,
    });
  } catch (error) {
    // Dacă service-ul aruncă eroare de "nu a fost găsit", returnăm 404
    res.status(404).json({
      success: false,
      message: error.message,
    });
  }
};

// ==================== CREATE ====================
// Handlează POST /exercises
const createExercise = async (req, res) => {
  try {
    // Datele noului exercițiu vin din body-ul request-ului
    const exercise = await exerciseService.createExercise(req.body);

    // Status 201 Created pentru resurse nou create
    res.status(201).json({
      success: true,
      data: exercise,
    });
  } catch (error) {
    // 400 Bad Request pentru date invalide
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

// ==================== UPDATE ====================
// Handlează PUT /exercises/:id
const updateExercise = async (req, res) => {
  try {
    // ID-ul din URL + datele noi din body
    const exercise = await exerciseService.updateExercise(
      req.params.id,
      req.body,
    );

    res.status(200).json({
      success: true,
      data: exercise,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

// ==================== DELETE ====================
// Handlează DELETE /exercises/:id
const deleteExercise = async (req, res) => {
  try {
    await exerciseService.deleteExercise(req.params.id);

    // 200 cu mesaj de confirmare
    res.status(200).json({
      success: true,
      message: "Exercițiul a fost dezactivat cu succes",
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

// Exportăm toate funcțiile pentru a fi folosite în routes
module.exports = {
  getAllExercises,
  getExerciseById,
  createExercise,
  updateExercise,
  deleteExercise,
};
