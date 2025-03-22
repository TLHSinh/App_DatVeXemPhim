import express from 'express';
import { addNewMovie, updateMovie, deleteMovie, getScheduleByRoom, getScheduleOfRoom, createMovieSchedule, updateMovieSchedule } from '../controllers/MovieManagementController.js'

const router = express.Router();

router.post('/addmovies', addNewMovie);
router.put('/movies/:id', updateMovie);
router.delete('/movies/:id', deleteMovie);
router.get('/movies/:id_phim/schedule', getScheduleByRoom);
router.get('/movies/:id_phim/rooms/:id_phong/schedule', getScheduleOfRoom);
router.post('/movies/:id_phim/schedule', createMovieSchedule);
router.put('/movies/:id_phim/schedule/:id', updateMovieSchedule);


export default router;