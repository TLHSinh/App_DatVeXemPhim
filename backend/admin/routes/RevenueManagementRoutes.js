import express from 'express';
import { getRevenue, getRevenueByMovie, getRevenueByCinema } from '../controllers/RevenueManagementController.js'

const router = express.Router();

router.get('/reports/revenue', getRevenue);
router.get('/reports/revenue-by-movie', getRevenueByMovie);
router.get('/reports/revenue-by-cinema', getRevenueByCinema);

export default router;