import express from 'express';
import { addNewMovie, updateMovie, deleteMovie,createSchedule,deleteSchedule,getAllSchedule,getScheduleById ,getScheduleByRoom, getScheduleOfRoom, createMovieSchedule, updateMovieSchedule } from '../controllers/MovieManagementController.js'

const router = express.Router();

router.post('/movies/addmovies', addNewMovie);
router.put('/movies/:id', updateMovie);
router.delete('/movies/:id', deleteMovie);

router.get('/movies/allschedule', getAllSchedule);
router.get('/movies/schedule/:id', getScheduleById);
router.delete('/movies/deleteSchedule/:id', deleteSchedule);
router.post('/movies/addschedules', createSchedule);
router.get('/movies/:id_phim/schedule', getScheduleByRoom);
router.get('/movies/:id_phim/rooms/:id_phong/schedule', getScheduleOfRoom);
router.post('/movies/:id_phim/schedule', createMovieSchedule);
router.put('/movies/:id_phim/schedule/:id', updateMovieSchedule);



export default router;