const express = require('express');
const mongoose = require("mongoose");
const app = express();
const port = 3000;

// 
const pillRoutes = require("./routes/pills");
const allergensRoutes = require("./routes/allergens");

// Middlewares
app.use(express.json());

// Fake auth 
app.use((req, res, next) => {
  req.userId = "test-user-id";
  next();
});

// Connect to MongoDB
mongoose
  .connect(
    "mongodb+srv://lucagavra_db_user:21012003@cluster0.p5uazu0.mongodb.net/projectk?appName=Cluster0",
  )
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error(err));


app.use('/api/pills', pillRoutes);
app.use('/api/allergens', allergensRoutes);

// Route test
app.get("/", (req, res) => {
  res.send("API is running...");
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});