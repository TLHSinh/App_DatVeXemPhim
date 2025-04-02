import express from 'express';

import {  addEmployee,
        updateEmployee,
        deleteEmployee,
        getSingleEmployee,
        getAllEmployees,
        getEmployeeByEmailOrPhone,
        changeEmployeeStatus,
        updatePoints } from '../controllers/employeeController.js';

import{authenticate, restrict} from'../auth/veryfyToken.js'
const router = express.Router();

//lấy danh sách phim lưu vào database
router.post('/addEmployee', addEmployee);
router.put('/:id', updateEmployee);
router.delete('/:id', deleteEmployee);
router.get('/allEmployee',authenticate, restrict(["admin", "nhanvien"]), getAllEmployees);
router.get('/:id', getSingleEmployee);


export default router;