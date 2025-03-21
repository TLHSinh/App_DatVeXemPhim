import express from 'express';
import { register,
        loginAdmin,
        loginUser, 
        logout,
        changePassword,
        getCurrentUser } from '../controllers/authController.js';

const router = express.Router();

// Đảm bảo route đăng ký sử dụng phương thức POST
router.post('/register', register);
router.post('/loginAdmin', loginAdmin);
router.post('/loginUser', loginUser);

export default router;
