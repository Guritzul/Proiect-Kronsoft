const express = require('express');
const mongoose = require ('mongoose');
const app = express();

app.use(express.json());


app.use(express.static('public'));

const mongo_URI = 'mongodb+srv://lucagavra_db_user:21012003@cluster0.p5uazu0.mongodb.net/?appName=Cluster0';

mongoose.connect(mongo_URI)
.then(() => console.log('Connection Succeded!'))
.catch(err => console.error('Connection ERROR! Uite motivul real:', err));

const user_scheme = new mongoose.Schema({
    nume: String,
    alergeni: [String]
}
);

const User = mongoose.model('User', user_scheme);


app.get('/' , (req, res) => {
    res.send("Backend is working!");

});


app.post('/set-user', async(req, res) => {
    const new_profile = new User({
        nume: "Luca",
        alergeni: ["alune" , "lapte" , "soia"]
    });

    await new_profile.save();
    res.send("Profile saved successfuly!")
});

app.post('/scan', async(req, res) => {
    const test_eticheta = req.body.text.toLowerCase();
    const utilizator = await User.findOne({ nume: "Luca" });

    let alergeniGasiti = [];
    
    utilizator.alergeni.forEach(alergen => {
        if (test_eticheta.includes(alergen.toLowerCase())) {
            alergeniGasiti.push(alergen);
        }
    });

    if (alergeniGasiti.length > 0) {
        res.json({
            status: "PERICOL",
            mesaj: `Am gasit: ${alergeniGasiti.join(", ")}. NU MANCA!`,
            culoare: "red"
        });
    } else {
        res.json({
            status: "SIGUR",
            mesaj: "Pare OK, poti sa mananci ceva de genul.",
            culoare: "green"
        });
    }
});

const PORT = 3000;

app.listen(PORT, () =>
{
    console.log(`Server is working! Go to http://localhost:${PORT}`);
});
