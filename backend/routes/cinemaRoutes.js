import express from 'express';
import { fetchAndSaveCinemas, getCinemas } from '../controllers/cinemaController.js';

const router = express.Router();

router.get('/fetch-cinemas', fetchAndSaveCinemas);
router.get('/rapphims', getCinemas);

export default router;