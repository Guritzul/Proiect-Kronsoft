const { Router } = require("express");
const controller = require("../controllers/exerciseController");

const router = Router();

// Static routes first
router.get("/favorites", controller.getFavorites);

router
  .route("/")
  .get(controller.getAllExercises)
  .post(controller.createExercise);

// Parameterized routes last - using regex to ensure it only matches 24-char hex strings (ObjectIds)
router.post("/:id([0-9a-fA-F]{24})/favorite", controller.toggleFavorite);

router
  .route("/:id([0-9a-fA-F]{24})")
  .get(controller.getExerciseById)
  .put(controller.updateExercise)
  .delete(controller.deleteExercise);

module.exports = router;
