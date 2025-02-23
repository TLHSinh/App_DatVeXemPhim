import express from 'express';

import { fetchAndSaveMovies, getAllMovies,addPhim,updatePhim, fetchAndSaveMovies, getMovies, getUpcomingMovies, getNowShowingMovies } from '../controllers/movieController.js';

const router = express.Router();

//lấy danh sách phim lưu vào database
router.get('/fetch-movies', fetchAndSaveMovies);
//lấy all phim trong database
router.get('/movies', getAllMovies);
//Thêm phim mới thủ công
router.post('/addMovies', addPhim);
//cập nhật phim 
router.get('/updateMovies', updatePhim);




//fetch from api to mongoDB
router.get('/fetch-movies', fetchAndSaveMovies);

//get data from mongoDB
router.get('/phims', getMovies);
router.get('/phims/sapchieu', getUpcomingMovies);
router.get('/phims/dangchieu', getNowShowingMovies);


export default router;
