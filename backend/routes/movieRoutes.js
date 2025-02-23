import express from 'express';
import { fetchAndSaveMovies, getMovies, getUpcomingMovies, getNowShowingMovies } from '../controllers/movieController.js';

const router = express.Router();

//fetch from api to mongoDB
router.get('/fetch-movies', fetchAndSaveMovies);

//get data from mongoDB
router.get('/phims', getMovies);
router.get('/phims/sapchieu', getUpcomingMovies);
router.get('/phims/dangchieu', getNowShowingMovies);

export default router;
