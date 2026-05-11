const express = require("express");
const mongoose = require("mongoose");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
const app = express();
const port = 3000;

// Initializeaza Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const pillRoutes = require("./routes/pills");
const notificationRoutes = require("./routes/notifications");
const allergensRoutes = require("./routes/allergens");
const exerciseRoutes = require("./routes/exercises"); //alex

// Middlewares
app.use(express.json());

// Fake auth
app.use((req, res, next) => {
  req.userId = "test-user-id";
  next();
});

// Connect to MongoDB Atlas
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log("✅ Connected to MongoDB Atlas"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

app.use("/api/pills", pillRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/allergens", allergensRoutes);
app.use("/api/exercises", exerciseRoutes); //alex

app.get("/", (req, res) => {
  res.send("API is running...");
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
