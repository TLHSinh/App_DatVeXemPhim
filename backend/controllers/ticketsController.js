import express from "express";
import mongoose from "mongoose";
import DonDatVe from "../models/DonDatVeSchema.js";
import ChiTietVe from "../models/ChiTietVeSchema.js";
import ChiTietDonDoAn from "../models/ChiTietDonDoAnSchema.js";



const router = express.Router();

// API lấy danh sách đơn đặt vé theo ID người dùng
export const getListTicketByID = async (req, res) => {
  try {
    const { id_nguoi_dung } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id_nguoi_dung)) {
      return res.status(400).json({ message: "ID người dùng không hợp lệ" });
    }

    // Lấy danh sách đơn đặt vé theo ID người dùng
    const donDatVeList = await DonDatVe.find({ id_nguoi_dung })
      .populate("id_lich_chieu")
      .populate("id_voucher")
      .populate("nhanVienXuatVeGiay")
      .lean();

    if (!donDatVeList.length) {
      return res.status(404).json({ message: "Không tìm thấy đơn đặt vé" });
    }

    // Lấy chi tiết ghế và đồ ăn của từng đơn đặt vé
    const results = await Promise.all(
      donDatVeList.map(async (don) => {
        const chiTietVe = await ChiTietVe.find({ id_don: don._id }).populate("id_ghe").lean();
        const chiTietDoAn = await ChiTietDonDoAn.find({ id_don: don._id }).populate("id_do_an").lean();

        return {
          ...don,
          chiTietVe,
          chiTietDoAn,
        };
      })
    );

    res.status(200).json(results);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Lỗi máy chủ" });
  }
};

export const getTicketByID = async (req, res) => {
    try {
        const { id_ve } = req.params;

        if (!mongoose.Types.ObjectId.isValid(id_ve)) {
            return res.status(400).json({ message: "ID vé không hợp lệ" });
        }

        const donDatVe = await DonDatVe.findById(id_ve)
            .populate("id_nguoi_dung", "ten email")
            .populate("id_lich_chieu")
            .populate("danh_sach_ghe")
            .populate("id_voucher", "ma_voucher gia_tri")
            .populate("nhanVienXuatVeGiay", "ten")
            .lean();

        if (!donDatVe) {
            return res.status(404).json({ message: "Không tìm thấy vé" });
        }

        res.status(200).json(donDatVe);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Lỗi máy chủ" });
    }
};
