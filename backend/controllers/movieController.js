import axios from 'axios';
import Phim from '../models/PhimSchema.js';

import { v4 as uuidv4 } from 'uuid'; 




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
// export const getMovies = async (req, res) => {
//     try {
//         const movies = await MovieModel.find();
//         res.json(movies);
//     } catch (error) {
//         res.status(500).json({ message: 'Error retrieving movies' });
//     }
// };

//module.exports = { fetchAndSaveMovies, getMovies };


// Hàm lấy danh sách phim từ MongoDB



export const getAllMovies = async (req, res) => {
    try {

        const movies = await Phim.find();
        res.json(movies);

    } catch (error) {
        res.status(500).json({ message: 'Error retrieving movies' });
    }
};





// Thêm phim mới
export const addPhim = async (req, res) => {
    const { ma_phim, ten_phim, id_the_loai, mo_ta, url_poster, url_trailer, thoi_luong, ngay_cong_chieu, danh_gia, ngon_ngu } = req.body;

    try {
        // Kiểm tra phim đã tồn tại qua ma_phim (nếu có)
        if (ma_phim) {
            const existingByMaPhim = await Phim.findOne({ ma_phim });
            if (existingByMaPhim) {
                return res.status(400).json({ message: "Phim đã tồn tại với mã phim này" });
            }
        }

        // Kiểm tra phim đã tồn tại qua tổ hợp thông tin quan trọng
        const existingPhim = await Phim.findOne({
            ten_phim,
            id_the_loai,
            ngay_cong_chieu,
            thoi_luong,
            ngon_ngu
        });

        let phien_ban = 1;
        if (existingPhim) {
            // Nếu phim đã tồn tại, tăng số phiên bản lên 1
            phien_ban = existingPhim.phien_ban + 1;
        }

        // Nếu không có ma_phim, tự động tạo ID duy nhất
        const generatedMaPhim = ma_phim || uuidv4();

        const phim = new Phim({
            ma_phim: generatedMaPhim,
            ten_phim,
            id_the_loai,
            phien_ban, 
            mo_ta,
            url_poster,
            url_trailer,
            thoi_luong,
            ngay_cong_chieu,
            danh_gia,
            ngon_ngu
        });

        await phim.save();
        res.status(201).json({ success: true, message: `Thêm phim thành công (Phiên bản ${phien_ban})`, data: phim });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

// Cập nhật phim
export const updatePhim = async (req, res) => {
    const { id } = req.params;
    try {
        const updatedPhim = await Phim.findByIdAndUpdate(id, { $set: req.body }, { new: true });
        if (!updatedPhim) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }
        res.status(200).json({ success: true, message: "Cập nhật phim thành công", data: updatedPhim });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi cập nhật phim", error: err.message });
    }
};

// Xóa phim
export const deletePhim = async (req, res) => {
    const { id } = req.params;
    try {
        const deletedPhim = await Phim.findByIdAndDelete(id);
        if (!deletedPhim) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }
        res.status(200).json({ success: true, message: "Xóa phim thành công" });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi xóa phim", error: err.message });
    }
};

// Lấy thông tin phim theo ID
export const getSinglePhim = async (req, res) => {
    const { id } = req.params;
    try {
        const phim = await Phim.findById(id).populate("id_the_loai");
        if (!phim) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }
        res.status(200).json({ success: true, data: phim });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi tìm phim", error: err.message });
    }
};

// Lấy danh sách tất cả phim
export const getAllPhim = async (req, res) => {
    try {
        const danhSachPhim = await Phim.find().populate("id_the_loai");
        res.status(200).json({ success: true, data: danhSachPhim });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi lấy danh sách phim", error: err.message });
    }
};

//Hàm lấy danh sách phim [sắp chiếu] - 14 ngày
export const getUpcomingMovies = async (req, res) => {
    try {
        const today = new Date();
        const tenDaysLater = new Date();
        tenDaysLater.setDate(today.getDate() + 14);

        // Hàm chuyển đổi từ "dd-MM-yyyy" sang Date
        const convertToDate = (dateStr) => {
            const [day, month, year] = dateStr.split('-');
            return new Date(`${year}-${month}-${day}`);
        };

        // Lấy tất cả phim từ MongoDB (vì không thể lọc trực tiếp bằng `$gte` và `$lte` với String)
        const allMovies = await Phim.find();

        // Lọc phim có ngày công chiếu trong khoảng từ hôm nay đến 14 ngày sau
        const upcomingMovies = allMovies.filter(movie => {
            const movieDate = convertToDate(movie.ngay_cong_chieu);
            return movieDate >= today && movieDate <= tenDaysLater;
        });

        res.json(upcomingMovies);
    } catch (error) {
        console.error("Error retrieving upcoming movies:", error);
        res.status(500).json({ message: "Error retrieving upcoming movies" });
    }
};

export const getNowShowingMovies = async (req, res) => {
    try {
        const today = new Date();
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(today.getDate() - 7);

        // Hàm chuyển đổi từ "dd-MM-yyyy" sang Date
        const convertToDate = (dateStr) => {
            const [day, month, year] = dateStr.split('-');
            return new Date(`${year}-${month}-${day}`);
        };

        // Lấy tất cả phim từ MongoDB
        const allMovies = await Phim.find();

        // Lọc phim có ngày công chiếu trong khoảng từ 7 ngày trước đến hôm nay
        const nowShowingMovies = allMovies.filter(movie => {
            const movieDate = convertToDate(movie.ngay_cong_chieu);
            return movieDate >= sevenDaysAgo && movieDate <= today;
        });

        res.json(nowShowingMovies);
    } catch (error) {
        console.error("Error retrieving now showing movies:", error);
        res.status(500).json({ message: "Error retrieving now showing movies" });

    }
};



