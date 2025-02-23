import express from 'express';

import { getAllMovies, addPhim, updatePhim, fetchAndSaveMovies, getUpcomingMovies, getNowShowingMovies } from '../controllers/movieController.js';

const router = express.Router();

//lấy danh sách phim lưu vào database
router.get('/phims/fetchAPI', fetchAndSaveMovies);
//lấy all phim trong database
router.get('/phims', getAllMovies);
//get phim from mongoDB
router.get('/phims/sapchieu', getUpcomingMovies);
router.get('/phims/dangchieu', getNowShowingMovies);
//Thêm phim mới thủ công
router.post('/phims/addPhims', addPhim);
//cập nhật phim 
router.get('/phims/updatePhims', updatePhim);




export default router;
