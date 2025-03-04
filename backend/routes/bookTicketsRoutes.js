import express from 'express';

import {  datGhe, xacNhanDatVe, layDonDatVe , thanhToan} from "../controllers/bookTicketsController.js";

const router = express.Router();

router.post("/chonGhe", datGhe);
router.post("/xacNhanDatVe", xacNhanDatVe);
router.get("/:idDonDatVe", layDonDatVe);
// API xử lý thanh toán đơn vé
router.post("/thanhtoan", thanhToan);


export default router;
