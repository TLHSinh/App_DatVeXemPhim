import express from 'express';
import { fetchAndSaveMovies, getAllMovies,addPhim,updatePhim } from '../controllers/movieController.js';

const router = express.Router();

//lấy danh sách phim lưu vào database
router.get('/fetch-movies', fetchAndSaveMovies);
//lấy all phim trong database
router.get('/movies', getAllMovies);
//Thêm phim mới thủ công
router.post('/addMovies', addPhim);
//cập nhật phim 
router.get('/updateMovies', updatePhim);



export default router;
