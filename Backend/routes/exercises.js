//validate input
const { Router } = require("express");
const controller = require("../controllers/exerciseController");

const router = Router();

// GET /exercises        → lista tuturor exercițiilor (cu filtre opționale)
// POST /exercises       → creare exercițiu nou
router
  .route("/")
  .get(controller.getAllExercises)
  .post(controller.createExercise);

// GET /exercises/:id    → un exercițiu după ID
// PUT /exercises/:id    → modificare exercițiu
// DELETE /exercises/:id → dezactivare exercițiu
router
  .route("/:id")
  .get(controller.getExerciseById)
  .put(controller.updateExercise)
  .delete(controller.deleteExercise);

module.exports = router;
