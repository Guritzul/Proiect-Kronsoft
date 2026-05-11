const mongoose = require("mongoose");

// Definim schema exercițiului - structura unui document din colecția MongoDB
// Schema validează datele înainte să fie salvate în baza de date
const exerciseSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Numele exercițiului este obligatoriu"],
      trim: true,
    },

    description: {
      type: String,
      required: [true, "Descrierea exercițiului este obligatorie"],
      trim: true,
    },

    bodyPart: {
      type: String,
      required: [true, "Partea corpului este obligatorie"],
      trim: true,
    },

    difficulty: {
      type: String,
      enum: {
        values: ["usor", "mediu", "avansat"],
        message: "Dificultatea trebuie să fie: usor, mediu sau avansat",
      },
      required: [true, "Dificultatea este obligatorie"],
    },

    durationMinutes: {
      type: Number,
      min: [1, "Durata minimă este de 1 minut"],
    },

    repetitions: {
      type: Number,
      min: [1, "Numărul minim de repetări este 1"],
    },

    sets: {
      type: Number,
      min: [1, "Numărul minim de seturi este 1"],
    },

    mediaUrl: {
      type: String,
      trim: true,
    },

    category: {
      type: String,
      trim: true,
    },

    // Flag pentru soft delete
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  },
);

const Exercise = mongoose.model("Exercise", exerciseSchema);
module.exports = Exercise;
