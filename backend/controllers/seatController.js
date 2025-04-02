import LichChieu from "../models/LichChieuSchema.js";
import Ghe from "../models/GheSchema.js";
import TrangThaiGhe from "../models/TrangThaiGheSchema.js";
import DonDatVe from "../models/DonDatVeSchema.js";
import Voucher from "../models/VoucherSchema.js";

import mongoose from "mongoose";



/**
 * Lấy danh sách ghế theo suất chiếu
 */
export const getSeatsByShowtime = async (req, res) => {
  try {
    const { idLichChieu } = req.params;

    // Tìm suất chiếu để lấy id phòng
    const lichChieu = await LichChieu.findById(idLichChieu);
    if (!lichChieu) {
      return res.status(404).json({ message: "Suất chiếu không tồn tại!" });
    }

    // Lấy danh sách ghế của phòng
    const danhSachGhe = await Ghe.find({ id_phong: lichChieu.id_phong });

    // Lấy trạng thái ghế của suất chiếu này
    const trangThaiGhe = await TrangThaiGhe.find({ id_lich_chieu: idLichChieu });

    // Kết hợp dữ liệu ghế với trạng thái ghế
    const danhSachGheCoTrangThai = danhSachGhe.map((ghe) => {
      const trangThai = trangThaiGhe.find(tg => tg.id_ghe.toString() === ghe._id.toString());
      return {
        _id_Ghe: ghe._id,
        so_ghe: ghe.so_ghe,
        trang_thai: trangThai ? trangThai.trang_thai : "có sẵn"
      };
    });

    res.status(200).json({
      phong: lichChieu.id_phong,
      danh_sach_ghe: danhSachGheCoTrangThai,
    });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};




  