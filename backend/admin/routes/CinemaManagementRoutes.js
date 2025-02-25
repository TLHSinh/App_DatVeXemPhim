import express from 'express';
import { getAllCinemas, addCinema, updateCinema, getAllRooms, addRoom, updateRoom } from '../controllers/CinemaManagementController.js';

const router = express.Router();

router.post('/theaters', addCinema);
router.get('/theaters', getAllCinemas);
router.put('/theaters/:id', updateCinema);

router.get('/theaters/:id_rap/rooms', getAllRooms);
router.post('/theaters/:id_rap/rooms', addRoom);
router.put('/theaters/:id_rap/rooms/:id', updateRoom);

export default router;