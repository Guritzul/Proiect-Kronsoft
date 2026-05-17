const mongoose = require("mongoose");

const exerciseSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Exercise name is required"],
      trim: true,
    },

    description: {
      type: String,
      required: [true, "Exercise description is required"],
      trim: true,
    },

    bodyPart: {
      type: String,
      required: [true, "Body part is required"],
      trim: true,
      enum: {
        values: [
          "forearm",
          "biceps",
          "triceps",
          "back",
          "legs",
          "shoulders",
          "chest",
          "core",
          "neck",
          "cardio",
        ],
        message: "Invalid body part",
      },
    },

    difficulty: {
      type: String,
      enum: {
        values: ["easy", "medium", "hard"],
        message: "Difficulty must be: easy, medium or hard",
      },
      required: [true, "Difficulty is required"],
    },

    durationMinutes: {
      type: Number,
      min: [1, "Minimum duration is 1 minute"],
    },

    repetitions: {
      type: Number,
      min: [1, "Minimum number of repetitions is 1"],
    },

    sets: {
      type: Number,
      min: [1, "Minimum number of sets is 1"],
    },

    mediaUrl: {
      type: String,
      trim: true,
    },

    category: {
      type: String,
      trim: true,
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    createdBy: {
      type: String,
      default: null,
    },
  },
  {
    timestamps: true,
  },
);

const Exercise = mongoose.model("Exercise", exerciseSchema);
module.exports = Exercise;
