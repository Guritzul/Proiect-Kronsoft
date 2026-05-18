const mongoose = require("mongoose");

const exerciseLogSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },
    exerciseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Exercise",
      required: true,
    },
    date: {
      type: Date,
      default: Date.now,
    },
    sets: {
      type: Number,
      min: [1, "Sets must be at least 1"],
    },
    repetitions: {
      type: Number,
      min: [1, "Repetitions must be at least 1"],
    },
    durationMinutes: {
      type: Number,
      min: [1, "Duration must be at least 1 minute"],
    },
    weight: {
      type: Number,
      min: [0, "Weight cannot be negative"],
    },
    notes: {
      type: String,
      trim: true,
    },
    workoutName: {
      type: String,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("ExerciseLog", exerciseLogSchema);
