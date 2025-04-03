import express from 'express';

import { addUser,updateUser,deleteUser, getSingleUser, getUserByEmailOrPhone,getAllUsers, getUserProfile } from '../controllers/UserController.js';
import{authenticate, restrict} from'../auth/veryfyToken.js'
const router = express.Router();

//lấy danh sách phim lưu vào database
router.post('/addUser', addUser);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);
router.get('/allUser',authenticate, restrict(["admin", "nhanvien"]), getAllUsers);
router.get('/:id', getSingleUser);

//router.get('/profile/me', getUserProfile);

router.post('/search', getUserByEmailOrPhone);


export default router;