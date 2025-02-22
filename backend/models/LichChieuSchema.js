import mongoose from "mongoose";

const LichChieuSchema = new mongoose.Schema({
  id_phim: { type: mongoose.Types.ObjectId, ref: "Phim", required: true },
  id_phong: { type: mongoose.Types.ObjectId, ref: "PhongChieu", required: true },
  thoi_gian_chieu: { type: Date, required: true },
  gia_ve: { type: Number, required: true, min: 0 },
}, { timestamps: true });

// Tạo index duy nhất để tránh trùng suất chiếu theo phòng và thời gian
LichChieuSchema.index({ id_phong: 1, thoi_gian_chieu: 1 }, { unique: true });

export default mongoose.model("LichChieu", LichChieuSchema);
