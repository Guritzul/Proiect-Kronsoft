require("dotenv").config();
const mongoose = require("mongoose");
const Exercise = require("./models/exercise");

const exercises = [
  {
    name: "Push-ups",
    description: "A classic upper body exercise focusing on the chest, shoulders, and triceps. Great for building bodyweight strength.",
    bodyPart: "chest",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 15,
    sets: 3,
    category: "Strength",
    mediaUrl: "https://www.youtube.com/watch?v=IODxDxX7oi4",
  },
  {
    name: "Squats",
    description: "Fundamental lower body exercise. Works the thighs, glutes, and lower back.",
    bodyPart: "legs",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 20,
    sets: 3,
    category: "Strength",
    mediaUrl: "https://www.youtube.com/watch?v=U3HlEF_E9fo",
  },
  {
    name: "Plank",
    description: "Excellent isometric exercise for strengthening the core, improving stability and posture.",
    bodyPart: "core",
    difficulty: "easy",
    durationMinutes: 2,
    repetitions: 1,
    sets: 3,
    category: "Endurance",
    mediaUrl: "https://www.youtube.com/watch?v=pvIjsGMCwLY",
  },
  {
    name: "Jumping Jacks",
    description: "Classic cardio move, great for warming up the entire body and increasing heart rate.",
    bodyPart: "cardio",
    difficulty: "easy",
    durationMinutes: 5,
    repetitions: 30,
    sets: 3,
    category: "Cardio",
    mediaUrl: "https://www.youtube.com/watch?v=c4DAnQ6DtF8",
  },
  {
    name: "Pull-ups",
    description: "Advanced pulling exercise that isolates and develops the back, especially the latissimus dorsi.",
    bodyPart: "back",
    difficulty: "hard",
    durationMinutes: 5,
    repetitions: 8,
    sets: 3,
    category: "Strength",
    mediaUrl: "https://www.youtube.com/watch?v=eGo4IYlbE5g",
  },
  {
    name: "Bicep Curls",
    description: "Bicep curls that isolate the biceps, ideal for building arm muscle mass. Can be done with dumbbells or water bottles.",
    bodyPart: "biceps",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 12,
    sets: 3,
    category: "Strength",
    mediaUrl: "https://www.youtube.com/watch?v=ykJmrZ5v0Oo",
  },
  {
    name: "Tricep Dips",
    description: "Bench or chair dips. Very effective exercise for isolating the triceps.",
    bodyPart: "triceps",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 12,
    sets: 3,
    category: "Strength",
    mediaUrl: "https://www.youtube.com/watch?v=0326dy_-CzM",
  },
  {
    name: "Shoulder Press",
    description: "Overhead shoulder press. Works the deltoids and helps with shoulder stability.",
    bodyPart: "shoulders",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 10,
    sets: 3,
    category: "Strength",
    mediaUrl: "https://www.youtube.com/watch?v=B-aVuy9K2co",
  },
  {
    name: "Neck Stretch",
    description: "A slow stretch for neck tension relief. Recommended for people who spend a lot of time at a desk.",
    bodyPart: "neck",
    difficulty: "easy",
    durationMinutes: 2,
    repetitions: 1,
    sets: 1,
    category: "Flexibility",
    mediaUrl: "https://www.youtube.com/watch?v=J3-FzV6jepU",
  },
  {
    name: "Wrist Curls",
    description: "Specific forearm curls. Recommended for grip strength and wrist recovery.",
    bodyPart: "forearm",
    difficulty: "easy",
    durationMinutes: 3,
    repetitions: 15,
    sets: 3,
    category: "Strength",
    mediaUrl: "https://www.youtube.com/watch?v=33mS_bQf2K8",
  }
];

mongoose
  .connect(process.env.MONGODB_URI)
  .then(async () => {
    console.log("Connected to MongoDB Atlas");
    try {
      await Exercise.deleteMany({});
      console.log("Cleared existing exercises.");
      await Exercise.insertMany(exercises);
      console.log("Successfully seeded exercises!");
    } catch (err) {
      console.error("Error seeding exercises:", err);
    } finally {
      mongoose.disconnect();
    }
  })
  .catch((err) => console.error("MongoDB connection error:", err));
