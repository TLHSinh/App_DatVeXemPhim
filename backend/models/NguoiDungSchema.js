import mongoose from "mongoose";

const NguoiDungSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  matKhau: { type: String },
  sodienthoai: { type: String },
  hoTen: { type: String },              // Họ và tên đầy đủ
  ngaySinh: { type: Date },              // Ngày sinh
  cccd: { type: String }, // Căn cước công dân
  gioiTinh: {
    type: String,
    enum: ["nam", "nu", "khac"]
  },                                   // Giới tính
  diaChi: { type: String },             // Địa chỉ
  hinhAnh: { type: String },             // URL hình ảnh đại diện
  role: {
    type: String,
    enum: ["user"],
    default: "user"
  },
  trangThai: { type: Boolean, default: true },
  diemTichLuy: { type: Number, default: 0 } // Trường tích điểm                          // Vai trò của người dùng
}, { timestamps: true });

export default mongoose.model("NguoiDung", NguoiDungSchema);
