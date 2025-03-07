import express from 'express';
import { getAllAds, addAds, updateAds, deleteAds } from '../controllers/AdsManagementController.js'

const router = express.Router();

router.get('/ads', getAllAds);
router.post('/ads', addAds);
router.put('/ads/:id', updateAds);
router.delete('/ads/:id', deleteAds);

export default router;