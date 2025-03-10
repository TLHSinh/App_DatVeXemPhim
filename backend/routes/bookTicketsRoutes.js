import express from 'express';

import {  datGhe, xacNhanDatVe, layDonDatVe , thanhToan, getLichChieu,getLichChieuTheoNgay, getLichChieuTheoRap} from "../controllers/bookTicketsController.js";

const router = express.Router();

router.post("/chonGhe", datGhe); //API chọn ghế
router.post("/xacNhanDatVe", xacNhanDatVe); // API xác nhận đặt vé
router.get("/:idDonDatVe", layDonDatVe);    //API lấy thông tin đơn vé

router.post("/thanhtoan", thanhToan);// API xử lý thanh toán đơn vé

router.get("/lich-chieu/:idPhim", getLichChieu); //API lấy lịch chiếu theo phim
router.post("/lich-chieu/ngay", getLichChieuTheoNgay);  //API lấy lịch chiếu theo ngày 
router.post("/lich-chieu/rap", getLichChieuTheoRap);    //API lấy lịch chiếu theo rạp


export default router;


//quy trình chọn phim 
//          => lấy lịch chiếu theo(ngày or rạp or phim) 
//          => lấy danh sách ghế ngồi của suất đó (trong seatRoutes) 
//          => chọn ghế 
//          => xác nhận đặt vé 
//          => thanh toán




