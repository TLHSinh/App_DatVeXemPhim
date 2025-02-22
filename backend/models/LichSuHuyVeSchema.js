import mongoose from "mongoose";

const LichSuHuyVeSchema = new mongoose.Schema({
  id_don: { type: mongoose.Types.ObjectId, ref: "DonDatVe", required: true },
  id_nguoi_dung: { type: mongoose.Types.ObjectId, ref: "NguoiDung", required: true },
  ly_do_huy: { type: String },
  trang_thai: { type: String, enum: ['chờ xác nhận', 'đã hủy'] },
}, { timestamps: { createdAt: "thoi_gian_huy", updatedAt: "ngay_cap_nhat" } });

export default mongoose.model("LichSuHuyVe", LichSuHuyVeSchema);
