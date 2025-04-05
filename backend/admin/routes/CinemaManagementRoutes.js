import express from 'express';
import { getAllCinemas, addCinema, updateCinema, getAllRooms, addRoom, updateRoom, deleteCinema } from '../controllers/CinemaManagementController.js';

const router = express.Router();

router.get('/theaters', getAllCinemas);
router.post('/theaters', addCinema);
router.put('/theaters/:id', updateCinema);
router.delete('/theaters/:id', deleteCinema);

router.get('/theaters/:id_rap/rooms', getAllRooms);
router.post('/theaters/:id_rap/rooms', addRoom);
router.put('/theaters/:id_rap/rooms/:id', updateRoom);

export default router;