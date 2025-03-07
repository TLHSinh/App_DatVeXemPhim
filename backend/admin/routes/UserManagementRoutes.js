import express from 'express';
import { getListUsers, lockUserAccount, getBannedListUsers } from '../controllers/UserManagementController.js'

const router = express.Router();

router.get('/users', getListUsers);
router.put('/users/ban/:userId', lockUserAccount);
router.get('/users/ban', getBannedListUsers);

export default router;