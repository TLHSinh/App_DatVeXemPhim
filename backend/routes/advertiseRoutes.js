// 📌 routes/quangCao.routes.js
import express from "express";
import { themQuangCao, layDanhSachQuangCao, suaQuangCao, xoaQuangCao } from "../controllers/advertiseController.js";

const router = express.Router();

router.post("/themQC", themQuangCao);
router.get("/", layDanhSachQuangCao);
router.put("/suaQC/:id", suaQuangCao);
router.delete("/xoaQC/:id", xoaQuangCao);

export default router;