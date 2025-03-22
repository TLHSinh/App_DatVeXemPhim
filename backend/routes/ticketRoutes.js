import express from "express";
import { getListTicketByID, getTicketByID } from "../controllers/ticketsController.js";

const router = express.Router();

// API lấy danh sách vé ttheo id người dung
router.get("/listticket/:id_nguoi_dung", getListTicketByID);

// API lấy chi tiết vé theo id vé
router.get("/detailticket/:id_ve", getTicketByID);

export default router;
