import mongoose from "mongoose";

const LichSuDiemSchema = new mongoose.Schema({
  id_nguoi_dung: { type: mongoose.Types.ObjectId, ref: "NguoiDung", required: true },
  diemChange: { type: Number, required: true },  // Số điểm thay đổi (cộng/trừ)
  lyDo: { type: String },                         // Lý do thay đổi điểm
  ngayThayDoi: { type: Date, default: Date.now }
}, { timestamps: true });

export default mongoose.model("LichSuDiem", LichSuDiemSchema);
