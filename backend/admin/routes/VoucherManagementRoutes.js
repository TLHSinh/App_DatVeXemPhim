import express from 'express';
import { getAllVouchers, getAllVouchersAvailabled, getAllVouchersExpired, addVoucher, updateVoucher, deleteVoucher } from '../controllers/VoucherManagementController.js';

const router = express.Router();

router.get('/vouchers', getAllVouchers);
router.get('/vouchers/availabled', getAllVouchersAvailabled);
router.get('/vouchers/expired', getAllVouchersExpired);
router.post('/vouchers', addVoucher);
router.put('/vouchers/:id', updateVoucher);
router.delete('/vouchers/:id', deleteVoucher);


export default router;