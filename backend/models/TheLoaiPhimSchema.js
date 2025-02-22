import mongoose from "mongoose";

const TheLoaiPhimSchema = new mongoose.Schema({
  ten_the_loai: { type: String, required: true },
  mo_ta: { type: String },
}, { timestamps: true });

export default mongoose.model("TheLoaiPhim", TheLoaiPhimSchema);
