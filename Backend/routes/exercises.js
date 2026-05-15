const { Router } = require("express");
const controller = require("../controllers/exerciseController");
const auth = require("../middleware/auth");

const router = Router();

router
  .route("/")
  .get(controller.getAllExercises)
  .post(controller.createExercise);

router.get("/favorites", auth, controller.getFavorites);
router.post("/:id/favorite", auth, controller.toggleFavorite);

router
  .route("/:id")
  .get(controller.getExerciseById)
  .put(controller.updateExercise)
  .delete(controller.deleteExercise);

module.exports = router;
