import mongoose from "mongoose";

const QuangCaoSchema = new mongoose.Schema({
  tieu_de: { type: String, required: true },
  mo_ta: { type: String },
  loai_qc: { type: String, required: true },
  url_hinh: { type: String, required: true },
  url_dich: { type: String },
  ngay_bat_dau: { type: Date, required: true },
  ngay_ket_thuc: { type: Date, required: true },
  trang_thai: { type: Boolean, default: true },
}, { timestamps: true });

export default mongoose.model("QuangCao", QuangCaoSchema);
