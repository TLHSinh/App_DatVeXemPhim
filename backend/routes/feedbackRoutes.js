import express from 'express';
import { feedback, deleteFeedback, updateFeedback } from '../controllers/feedbackController.js';

const router = express.Router();

// router.get('/movie', getAllFeedbacks);
// router.get('/movie/:id_phim', getFeedbacksByMovieId);
router.post('/movie/:id_phim/user/:id_nguoi_dung', feedback);
router.put('/movie/:id_phim/user/:id_nguoi_dung', updateFeedback);
router.delete('/movie/:id_phim/user/:id_nguoi_dung', deleteFeedback);

export default router;