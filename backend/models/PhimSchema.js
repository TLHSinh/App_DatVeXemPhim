import mongoose from "mongoose";

const PhimSchema = new mongoose.Schema({
  ten_phim: { type: String, required: true },
  id_the_loai: { type: mongoose.Types.ObjectId, ref: "TheLoaiPhim" },
  mo_ta: { type: String },
  url_poster: { type: String },
  url_trailer: { type: String },
  thoi_luong: { type: Number, required: true, min: 1 },
  ngay_cong_chieu: { type: Date },
  danh_gia: { type: Number, min: 0, max: 10 },
  ngon_ngu: { type: String },
}, { timestamps: true });

export default mongoose.model("Phim", PhimSchema);
