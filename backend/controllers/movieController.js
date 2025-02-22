import axios from 'axios';
import MovieModel from '../movie/movie.js';
import Phim from '../models/PhimSchema.js';

// const axios = require('axios');
// const MovieModel = require('../models/Movie');
const parseDate = (dateString) => {
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0'); // getMonth() trả về 0-11
    const year = date.getFullYear();
    return `${day}-${month}-${year}`;
};
// Hàm fetch và lưu phim vào MongoDB
export const fetchAndSaveMovies = async (req, res) => {
    try {
        const response = await axios.get(process.env.API_MOVIE);
        let phims = response.data;

        // Lọc phim theo điều kiện release_vn = "CGV" và năm hiện tại
        const filteredMovies = phims.filter(phim => {
            const releaseYear = new Date(phim.release).getFullYear();
            return phim.release_vn === "CGV" && releaseYear === new Date().getFullYear();
        });

        // Lưu vào MongoDB (upsert để tránh trùng lặp)
        for (const phim of filteredMovies) {
            await Phim.updateOne(
                { id: phim.id },
                {
                    $set: {
                        ten_phim: phim.name,
                        id_the_loai: null,
                        mo_ta: phim.description,
                        url_poster: phim.poster,
                        url_trailer: phim.trailer,
                        thoi_luong: phim.duration,
                        ngay_cong_chieu: parseDate(phim.release),
                        danh_gia: phim.star_rating_count > 0 ? phim.star_rating_value / phim.star_rating_count : 0,
                        ngon_ngu: null,
                        gioi_han_tuoi: phim.age_restricted
                    }
                },
                { upsert: true }
            );
            // await MovieModel.updateOne(
            //     { id: movie.id },
            //     { $set: movie },
            //     { upsert: true }
            // );
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
        const phims = await Phim.find();
        res.json(phims);
        // const movies = await MovieModel.find();
        // res.json(movies);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving movies' });
    }
};

//module.exports = { fetchAndSaveMovies, getMovies };
