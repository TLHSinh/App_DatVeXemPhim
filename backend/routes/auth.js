import express from 'express';
import { login, register } from '../controllers/authController.js';

const router = express.Router();

// Đảm bảo route đăng ký sử dụng phương thức POST
router.post('/register', register);
router.post('/login', login);
export default router;
