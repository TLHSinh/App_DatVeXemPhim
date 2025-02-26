import mongoose from "mongoose";

const DonDatVeSchema = new mongoose.Schema({
  id_nguoi_dung: { type: mongoose.Types.ObjectId, ref: "NguoiDung", required: true },
  id_lich_chieu: { type: mongoose.Types.ObjectId, ref: "LichChieu", required: true },
  id_voucher: { type: mongoose.Types.ObjectId, ref: "Voucher" },
  gia_tri_giam_ap_dung: { type: Number },
  tong_tien: { type: Number, required: true, min: 0 },
  tien_giam: { type: Number, default: 0 },
  tien_thanh_toan: { type: Number, required: true, min: 0 },
  trang_thai: { type: String, enum: ['đang chờ', 'đã xác nhận', 'đã hủy', 'đã xuất vé', 'đã hoàn tiền', 'chờ hoàn tiền'] },
  nhanVienXuatVeGiay: { type: mongoose.Types.ObjectId, ref: "NhanVien" }
}, { timestamps: true });

export default mongoose.model("DonDatVe", DonDatVeSchema);
