import mongoose from "mongoose";

const DoAnSchema = new mongoose.Schema({
  ten_do_an: { type: String, required: true },
  mo_ta: { type: String },
  gia: { type: Number, required: true },
  url_hinh: { type: String },
}, { timestamps: true });

export default mongoose.model("DoAn", DoAnSchema);
