import mongoose from "mongoose";

const VoucherSchema = new mongoose.Schema({
  ma_voucher: { type: String, required: true, unique: true },
  loai_giam_gia: { type: String, enum: ['phan_tram', 'tien_mat'] },
  gia_tri_giam: { type: Number, required: true, min: 0 },
  don_hang_toi_thieu: { type: Number, default: 0 },
  gioi_han_su_dung: { type: Number, default: 0 },
  ngay_het_han: { type: Date },
  url_hinh: { type: String },
}, { timestamps: true });

export default mongoose.model("Voucher", VoucherSchema);
