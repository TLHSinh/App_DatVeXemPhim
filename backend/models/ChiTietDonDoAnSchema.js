import mongoose from "mongoose";

const ChiTietDonDoAnSchema = new mongoose.Schema({
  id_don: { type: mongoose.Types.ObjectId, ref: "DonDatVe", required: true },
  id_do_an: { type: mongoose.Types.ObjectId, ref: "DoAn", required: true },
  so_luong: { type: Number, required: true },
  gia: { type: Number, required: true },
}, { timestamps: true });

export default mongoose.model("ChiTietDonDoAn", ChiTietDonDoAnSchema);
