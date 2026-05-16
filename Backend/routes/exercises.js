const { Router } = require("express");
const controller = require("../controllers/exerciseController");

const router = Router();

// Static routes first
router.get("/favorites", controller.getFavorites);

router
  .route("/")
  .get(controller.getAllExercises)
  .post(controller.createExercise);

// Parameterized routes last
router.post("/:id/favorite", controller.toggleFavorite);

router
  .route("/:id")
  .get(controller.getExerciseById)
  .put(controller.updateExercise)
  .delete(controller.deleteExercise);

module.exports = router;
