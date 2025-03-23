import express from "express";
import { getListTicketByID, getTicketByID ,layDonVeTheoGheVaXuatChieu} from "../controllers/ticketsController.js";

const router = express.Router();

// API lấy danh sách vé ttheo id người dung
router.get("/listticket/:id_nguoi_dung", getListTicketByID);

// API lấy chi tiết vé theo id vé
router.get("/detailticket/:id_ve", getTicketByID);

// API lấy chi tiết vé theo id ghế và xuất chiếu
router.get("/ticket/:id_ghe/:id_xuat_chieu", layDonVeTheoGheVaXuatChieu);

export default router;
