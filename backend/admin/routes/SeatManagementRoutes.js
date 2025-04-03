import express from 'express';
import {updateSeatStatus, getAllSeats, createSeats, updateStateSeat, resetAllSeatsState } from '../controllers/SeatManagementController.js';

const router = express.Router();

router.get('/rooms/:id_phong/seats', getAllSeats);
router.post('/rooms/:id_phong/seats', createSeats);
router.put('/rooms/:id_phong/seats/:id_ghe', updateStateSeat);
router.put('/rooms/:id_phong/seats/trangthai/reset', resetAllSeatsState);
router.put('/rooms/:id_phong/seats/status/:id_ghe', updateSeatStatus);

router.get('//:/',);
router.post('//:/',);
router.put('//://:id',);

export default router;