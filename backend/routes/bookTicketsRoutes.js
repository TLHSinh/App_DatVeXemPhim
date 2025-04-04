import express from 'express';

import { CanceldatGhe,datGhe, xacNhanDatVe, layDonDatVe, thanhToan, getLichChieu, getLichChieuTheoNgay, getLichChieuTheoRap, getAllLichChieuTheoRap } from "../controllers/bookTicketsController.js";

const router = express.Router();

router.post("/chonGhe", datGhe); //API chọn ghế
router.delete("/cancelGhe/:idUser", CanceldatGhe); //API chọn ghế


router.post("/xacNhanDatVe", xacNhanDatVe); // API xác nhận đặt vé
router.get("/:idDonDatVe", layDonDatVe);    //API lấy thông tin đơn vé

router.put("/thanhtoan", thanhToan);// API xử lý thanh toán đơn vé

router.get("/lich-chieu/:idPhim", getLichChieu); //API lấy lịch chiếu theo phim
router.get("/lich-chieu/:idPhim/ngay", getLichChieuTheoNgay);  //API lấy lịch chiếu theo ngày 
router.get("/lich-chieu/:idPhim/rap", getLichChieuTheoRap);    //API lấy lịch chiếu theo rạp

router.get("/all-lich-chieu/:idRap", getAllLichChieuTheoRap);    //API lấy all lịch chiếu theo rạp


export default router;


//quy trình chọn phim
//          => lấy lịch chiếu theo(ngày or rạp or phim)
//          => lấy danh sách ghế ngồi của suất đó (trong seatRoutes)
//          => chọn ghế
//          => xác nhận đặt vé
//          => thanh toán




