import express from 'express';

import { addUser,updateUser,deleteUser, getSingleUser, getUserByEmailOrPhone,getAllUsers, getUserProfile } from '../controllers/UserController.js';

const router = express.Router();

//lấy danh sách phim lưu vào database
router.post('/addUser', addUser);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);
router.get('/all', getAllUsers);
router.get('/:id', getSingleUser);

router.get('/profile/me', getUserProfile);

router.post('/search', getUserByEmailOrPhone);


export default router;