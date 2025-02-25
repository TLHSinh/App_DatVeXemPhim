import express from 'express';
import { addNewMovie, updateMovie, deleteMovie, createMovieSchedule, updateMovieSchedule } from '../controllers/MovieManagementController.js'

const router = express.Router();

router.post('/movies', addNewMovie);
router.put('/movies/:id', updateMovie);
router.delete('/movies/:id', deleteMovie);
router.post('/movies/schedule', createMovieSchedule);
router.put('/movies/schedule:id', updateMovieSchedule);


export default router;