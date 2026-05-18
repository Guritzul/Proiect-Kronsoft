const mongoose = require("mongoose");

const workoutSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Workout name is required"],
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    userId: {
      type: String,
      required: true,
    },
    exercises: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Exercise",
      },
    ],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Workout", workoutSchema);
