import mongoose from "mongoose";

const TrangThaiGheSchema = new mongoose.Schema({
  id_lich_chieu: { type: mongoose.Types.ObjectId, ref: "LichChieu", required: true },
  id_ghe: { type: mongoose.Types.ObjectId, ref: "Ghe", required: true },
  trang_thai: { 
    type: String, 
    enum: ["có sẵn", ,"đã đặt", "đã đặt trước"], 
    default: "có sẵn" 
  },
  id_user: { type: mongoose.Types.ObjectId, ref: "NguoiDung", required: true },
}, { timestamps: true });

// Đảm bảo mỗi suất chiếu có trạng thái riêng cho từng ghế
TrangThaiGheSchema.index({ id_lich_chieu: 1, id_ghe: 1 }, { unique: true });

export default mongoose.model("TrangThaiGhe", TrangThaiGheSchema);
