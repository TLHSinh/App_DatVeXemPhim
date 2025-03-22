import express from 'express';
import { feedback, deleteFeedback, getAllFeedbacks, getFeedbacksByMovieId, getFeedbacksByUserId, updateFeedback, getReportFeedbacks, reportFeedbackViolation } from '../controllers/FeedbackManagementController.js';

const router = express.Router();

router.get('/reviews/movie', getAllFeedbacks);
router.get('/reviews/movie/:id_phim', getFeedbacksByMovieId);
router.get('/reviews/movie/:id_nguoi_dung', getFeedbacksByUserId);

router.get('/reviews/report/movie/:id_phim', getReportFeedbacks);
router.put('/reviews/report/movie/:id_phim/user/:id_nguoi_dung', reportFeedbackViolation);

router.post('/reviews/movie/:id_phim/user/:id_nguoi_dung', feedback);
router.put('/reviews/movie/:id_phim/user/:id_nguoi_dung', updateFeedback);
router.delete('/reviews/movie/:id_phim/user/:id_nguoi_dung', deleteFeedback);

export default router;