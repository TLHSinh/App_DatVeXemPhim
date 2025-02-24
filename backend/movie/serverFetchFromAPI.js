const axios = require('axios');
const express = require('express');
const mongoose = require('mongoose');
const MovieModel = require('./movie'); // Import model
const app = express();
const port = 3000;

const uri = 'mongodb+srv://hoangdoan103:Melody1603@cluster0.3pfyf.mongodb.net/cinema';

// Kết nối MongoDB
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("Connected to MongoDB"))
    .catch(err => console.error("Error connecting to MongoDB:", err));

app.get('/fetch-movies', async (req, res) => {
    try {
        const response = await axios.get('https://rapchieuphim.com/api/v1/movies');
        let movies = response.data;

        // Lọc phim theo điều kiện release_vn = "CGV" và năm phát hành 2025
        const filteredMovies = movies.filter(movie => {
            const releaseYear = new Date(movie.release).getFullYear();
            return movie.release_vn === "CGV" && releaseYear === new Date().getFullYear();
        });

        // Lấy 50 phim cuối cùng
        // const last50Movies = filteredMovies.slice(-50);

        // Lưu dữ liệu vào MongoDB bằng upsert để tránh trùng lặp
        for (const movie of filteredMovies) {
            await MovieModel.updateOne(
                { id: movie.id },  // Kiểm tra nếu phim đã có trong DB
                {
                    $set: {           // Cập nhật dữ liệu mới
                        name: movie.name,
                        poster: movie.poster,
                        trailer: movie.trailer,
                        description: movie.description,
                        release: movie.release,
                        release_vn: movie.release_vn,
                        duration: movie.duration,
                        year: movie.year,
                        status: movie.status,
                        age_restricted: movie.age_restricted,
                        star_rating_value: movie.star_rating_value,
                        star_rating_count: movie.star_rating_count,
                        create_at: movie.create_at,
                        updated_at: movie.updated_at
                    }
                },
                { upsert: true }  // Nếu chưa có thì thêm mới
            );
        }

        res.json({ message: "Movies successfully saved to MongoDB (duplicates avoided)!" });
    } catch (error) {
        console.error('Error fetching or saving movies:', error);
        res.status(500).json({ message: 'Error fetching or saving movies' });
    }
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
