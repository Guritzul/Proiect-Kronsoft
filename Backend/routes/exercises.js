const { Router } = require("express");
const controller = require("../controllers/exerciseController");

const router = Router();

router
  .route("/")
  .get(controller.getAllExercises)
  .post(controller.createExercise);

router
  .route("/:id")
  .get(controller.getExerciseById)
  .put(controller.updateExercise)
  .delete(controller.deleteExercise);

module.exports = router;
