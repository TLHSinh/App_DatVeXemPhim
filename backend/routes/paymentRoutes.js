import express from 'express';
import { createPayment, callback, transactionStatus } from '../controllers/paymentController.js';

const router = express.Router();

router.post("/payment", createPayment);
router.post("/callback", callback);
router.post("/transaction-status", transactionStatus);

export default router;