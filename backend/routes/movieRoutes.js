import express from 'express';
import { fetchAndSaveMovies, getMovies } from '../controllers/movieController.js';

const router = express.Router();

router.get('/fetch-movies', fetchAndSaveMovies);
//fetch from api to mongoDB
router.get('/phims', getMovies);
//get data from mongoDB

export default router;
