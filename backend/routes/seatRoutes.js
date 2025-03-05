import express from "express";
import { getSeatsByShowtime } from "../controllers/seatController.js";

const router = express.Router();

// API lấy danh sách ghế theo suất chiếu
router.get("/:idLichChieu", getSeatsByShowtime);




export default router;
