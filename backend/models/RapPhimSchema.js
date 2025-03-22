import { Double } from "mongodb";
import mongoose from "mongoose";

const RapPhimSchema = new mongoose.Schema({
  ma_rap: { type: String },
  ten_rap: { type: String, required: true },
  dia_chi: { type: String, required: true },
  anh: { type: String },
  so_dien_thoai: { type: String },
  geo_lat: { type: Double },
  geo_long: { type: Double },
  location: {
    type: { type: String, enum: ["Point"], required: true, default: "Point" }, // Kiểu dữ liệu GeoJSON
    coordinates: { type: [Number], required: true } // [longitude, latitude]
  }
}, { timestamps: true });

// Tạo chỉ mục không gian `2dsphere`
RapPhimSchema.index({ location: "2dsphere" });

export default mongoose.model("RapPhim", RapPhimSchema);
