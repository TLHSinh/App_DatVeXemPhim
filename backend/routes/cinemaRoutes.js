import express from 'express';
import { fetchAndSaveCinemas, getAllCinemas } from '../controllers/cinemaController.js';

const router = express.Router();

router.get('/rapphims/fetchAPI', fetchAndSaveCinemas);
router.get('/rapphims', getAllCinemas);

export default router;