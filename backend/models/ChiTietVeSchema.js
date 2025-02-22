import mongoose from "mongoose";

const ChiTietVeSchema = new mongoose.Schema({
  id_don: { type: mongoose.Types.ObjectId, ref: "DonDatVe", required: true },
  id_ghe: { type: mongoose.Types.ObjectId, ref: "Ghe", required: true },
  gia_ve: { type: Number },
}, { timestamps: true });

export default mongoose.model("ChiTietVe", ChiTietVeSchema);
