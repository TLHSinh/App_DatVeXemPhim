import axios from 'axios';
import MovieModel from '../movie/movie.js';

// const axios = require('axios');
// const MovieModel = require('../models/Movie');

// Hàm fetch và lưu phim vào MongoDB
export const fetchAndSaveMovies = async (req, res) => {
    try {
        const response = await axios.get(process.env.API_MOVIE);
        let movies = response.data;

        // Lọc phim theo điều kiện release_vn = "CGV" và năm hiện tại
        const filteredMovies = movies.filter(movie => {
            const releaseYear = new Date(movie.release).getFullYear();
            return movie.release_vn === "CGV" && releaseYear === new Date().getFullYear();
        });

        // Lưu vào MongoDB (upsert để tránh trùng lặp)
        for (const movie of filteredMovies) {
            await MovieModel.updateOne(
                { id: movie.id },
                { $set: movie },
                { upsert: true }
            );
        }

        res.json({ message: "Movies successfully saved to MongoDB!" });
    } catch (error) {
        console.error('Error fetching or saving movies:', error);
        res.status(500).json({ message: 'Error fetching or saving movies' });
    }
};

// Hàm lấy danh sách phim từ MongoDB
export const getMovies = async (req, res) => {
    try {
        const movies = await MovieModel.find();
        res.json(movies);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving movies' });
    }
};

//module.exports = { fetchAndSaveMovies, getMovies };
