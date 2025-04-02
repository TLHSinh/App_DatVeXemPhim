import express from 'express';

import { SignInWithGoogle, DeleteAccount } from '../controllers/signingoogleController.js';
const router = express.Router();

router.post('/signin', SignInWithGoogle);
router.delete('/delete', DeleteAccount);

export default router;