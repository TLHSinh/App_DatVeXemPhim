import mongoose from "mongoose";

const LichSuHoanTienSchema = new mongoose.Schema({
  id_don: { type: mongoose.Types.ObjectId, ref: "DonDatVe", required: true },
  id_huy: { type: mongoose.Types.ObjectId, ref: "LichSuHuyVe", default: null },
  so_tien_hoan: { type: Number, required: true },
  trang_thai: { 
    type: String, 
    enum: ['chờ xử lý', 'đang xử lý', 'đã hoàn tiền', 'từ chối hoàn tiền'] 
  },
  phuong_thuc: { 
    type: String, 
    enum: ['chuyển khoản', 'ví điện tử', 'tiền mặt', 'hoàn vào tài khoản khách'] 
  },
  ghi_chu: { type: String },
}, { timestamps: { createdAt: "thoi_gian_hoan", updatedAt: "ngay_cap_nhat" } });

export default mongoose.model("LichSuHoanTien", LichSuHoanTienSchema);
