import mongoose from "mongoose";

const PhongChieuSchema = new mongoose.Schema({
  id_rap: { type: mongoose.Types.ObjectId, ref: "RapPhim", required: true },
  ten_phong: { type: String, required: true },
  tong_so_ghe: { type: Number },
}, { timestamps: true });

export default mongoose.model("PhongChieu", PhongChieuSchema);
