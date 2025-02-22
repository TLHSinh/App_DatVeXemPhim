import mongoose from "mongoose";

const NhanVienSchema  = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  matKhau: { type: String, required: true },
  sodienthoai: { type: String },
  hoTen: { type: String },              // Họ và tên đầy đủ
  ngaySinh: { type: Date },              // Ngày sinh
  cccd: { type: String }, // Căn cước công dân
  gioiTinh: { 
    type: String, 
    enum: ["nam", "nu", "khac"] 
  },                                   // Giới tính
  chucVu: { type: String },
  diaChi: { type: String },             // Địa chỉ
  hinhAnh: { type: String },             // URL hình ảnh đại diện
  role: { 
    type: String, 
    enum: ["nhanvien", "admin"], 
    default: "nhanvien" 
  },          
  diemTichLuy: { type: Number, default: 0 } // Trường tích điểm                          // Vai trò của người dùng
}, { timestamps: true });

export default mongoose.model("NhanVien", NhanVienSchema);