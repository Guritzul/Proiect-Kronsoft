require("dotenv").config();
const mongoose = require("mongoose");
const Exercise = require("./models/exercise");

const exercises = [
  {
    name: "Push-ups",
    description: "Un exercițiu clasic pentru partea superioară a corpului, axat pe piept, umeri și tricepși. Excelent pentru construirea forței cu greutatea corpului.",
    bodyPart: "chest",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 15,
    sets: 3,
    category: "Strength",
  },
  {
    name: "Squats",
    description: "Exercițiu fundamental pentru trenul inferior. Lucrează mușchii coapselor, fesierii și partea inferioară a spatelui.",
    bodyPart: "legs",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 20,
    sets: 3,
    category: "Strength",
  },
  {
    name: "Plank",
    description: "Exercițiu izometric excelent pentru întărirea zonei core, îmbunătățind stabilitatea și postura.",
    bodyPart: "core",
    difficulty: "easy",
    durationMinutes: 2,
    repetitions: 1,
    sets: 3,
    category: "Endurance",
  },
  {
    name: "Jumping Jacks",
    description: "Mișcare cardio clasică, excelentă pentru încălzirea întregului corp și creșterea ritmului cardiac.",
    bodyPart: "cardio",
    difficulty: "easy",
    durationMinutes: 5,
    repetitions: 30,
    sets: 3,
    category: "Cardio",
  },
  {
    name: "Pull-ups",
    description: "Exercițiu avansat de tracțiune care izolează și dezvoltă spatele, în special mușchiul marele dorsal.",
    bodyPart: "back",
    difficulty: "hard",
    durationMinutes: 5,
    repetitions: 8,
    sets: 3,
    category: "Strength",
  },
  {
    name: "Bicep Curls",
    description: "Flexii care izolează bicepsul, ideal pentru creșterea masei musculare la nivelul brațelor. Poate fi făcut cu gantere sau sticle cu apă.",
    bodyPart: "biceps",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 12,
    sets: 3,
    category: "Strength",
  },
  {
    name: "Tricep Dips",
    description: "Flotări la bancă sau scaun. Exercițiu foarte eficient pentru izolarea tricepșilor.",
    bodyPart: "triceps",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 12,
    sets: 3,
    category: "Strength",
  },
  {
    name: "Shoulder Press",
    description: "Presă deasupra capului pentru umeri. Lucrează deltoizii și ajută la stabilitatea umerilor.",
    bodyPart: "shoulders",
    difficulty: "medium",
    durationMinutes: 5,
    repetitions: 10,
    sets: 3,
    category: "Strength",
  },
  {
    name: "Neck Stretch",
    description: "O întindere lentă pentru detensionarea gâtului. Recomandat persoanelor care stau mult la birou.",
    bodyPart: "neck",
    difficulty: "easy",
    durationMinutes: 2,
    repetitions: 1,
    sets: 1,
    category: "Flexibility",
  },
  {
    name: "Wrist Curls",
    description: "Flexii specifice pentru antebrațe. Recomandate pentru forța prizei și a recuperării la încheieturi.",
    bodyPart: "forearm",
    difficulty: "easy",
    durationMinutes: 3,
    repetitions: 15,
    sets: 3,
    category: "Strength",
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
