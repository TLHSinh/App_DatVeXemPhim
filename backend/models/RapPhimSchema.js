import mongoose from "mongoose";

const RapPhimSchema = new mongoose.Schema({
  ten_rap: { type: String, required: true },
  dia_chi: { type: String, required: true },
  so_dien_thoai: { type: String },
}, { timestamps: true });

export default mongoose.model("RapPhim", RapPhimSchema);
