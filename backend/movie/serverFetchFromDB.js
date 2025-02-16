const express = require('express');
const mongoose = require('mongoose');
const MovieModel = require('./movie');
const cors = require('cors');

const app = express();
const port = 3001;

const uri = 'mongodb+srv://hoangdoan103:Melody1603@cluster0.3pfyf.mongodb.net/cinema';

//Dùng cors tránh lỗi khi chạy bằng web
app.use(cors());
app.use(express.json());

// Kết nối MongoDB khi khởi động server
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("Connected to MongoDB"))
    .catch(err => console.error("Error connecting to MongoDB:", err));

app.get('/', async (req, res) => {
    try {
        let movies = await MovieModel.find();
        console.log({ movies });
        res.json({ movies }); // Gửi cả hai danh sách trong một object
    } catch (error) {
        console.error(error);
        res.status(500).send("Error retrieving data");
    }
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
