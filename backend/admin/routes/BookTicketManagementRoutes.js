import express from 'express';
import { getListBookTickets, confirmCancelTicket, refundProcessing, requestRefund, confirmRefund } from '../controllers/BookTicketManagementController.js';

const router = express.Router();

router.get('/tickets', getListBookTickets);
router.put('/tickets/:id_don/cancel', confirmCancelTicket);
router.put('/tickets/:id_don/refund', refundProcessing);
router.put('/tickets/:id_don/request-refund', requestRefund);
router.put('/tickets/:id_don/confirm-refund', confirmRefund);

export default router;