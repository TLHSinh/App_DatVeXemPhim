import mongoose from "mongoose";

const GheSchema = new mongoose.Schema({
  id_phong: { type: mongoose.Types.ObjectId, ref: "PhongChieu", required: true },
  so_ghe: { type: String, required: true },
  trang_thai: { 
    type: String, 
    enum: ["có sẵn", "đã đặt trước", "hư hỏng", "bảo trì"], 
    default: "có sẵn" 
  },
}, { timestamps: true });

export default mongoose.model("Ghe", GheSchema);
