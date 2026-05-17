const { Router } = require("express");
const controller = require("../controllers/workoutController");

const router = Router();

router
  .route("/")
  .get(controller.getWorkouts)
  .post(controller.createWorkout);

router
  .route("/:id")
  .get(controller.getWorkoutById)
  .put(controller.updateWorkout)
  .delete(controller.deleteWorkout);

module.exports = router;
