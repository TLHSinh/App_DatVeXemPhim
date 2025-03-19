import mongoose from "mongoose";

const DanhGiaSchema = new mongoose.Schema({
  id_nguoi_dung: { type: mongoose.Types.ObjectId, ref: "NguoiDung", required: true },
  id_phim: { type: mongoose.Types.ObjectId, ref: "Phim", required: true },
  diem: { type: Number, required: true, min: 1, max: 5 },
  binh_luan: { type: String },
  trang_thai: {
    type: String,
    enum: ["chưa bình luận", "đã bình luận", "đã chỉnh sửa", "vi phạm"],
    default: "chưa bình luận"
  }
}, { timestamps: true });

export default mongoose.model("DanhGia", DanhGiaSchema);
