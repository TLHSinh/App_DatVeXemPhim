import mongoose from "mongoose";

const TonKhoDoAnSchema = new mongoose.Schema({
  id_do_an: { type: mongoose.Types.ObjectId, ref: "DoAn", required: true },
  so_luong_ton: { type: Number, required: true },
}, { timestamps: true });

export default mongoose.model("TonKhoDoAn", TonKhoDoAnSchema);
