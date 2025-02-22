import mongoose from "mongoose";

const PhimSchema = new mongoose.Schema({
  id: { type: String },
  ten_phim: { type: String, required: true },
  id_the_loai: { type: mongoose.Types.ObjectId, ref: "TheLoaiPhim" },
  mo_ta: { type: String },
  url_poster: { type: String },
  url_trailer: { type: String },
  thoi_luong: { type: String },
  gioi_han_tuoi: { type: String },
  ngay_cong_chieu: { type: String },
  danh_gia: { type: Number, min: 0, max: 5 },
  ngon_ngu: { type: String },
}, { timestamps: true });

export default mongoose.model("Phim", PhimSchema);
