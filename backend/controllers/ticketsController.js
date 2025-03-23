import express from "express";
import mongoose from "mongoose";
import DonDatVe from "../models/DonDatVeSchema.js";
import ChiTietVe from "../models/ChiTietVeSchema.js";
import ChiTietDonDoAn from "../models/ChiTietDonDoAnSchema.js";
import Ghe from "../models/GheSchema.js";
import DoAn from "../models/DoAnSchema.js";


// API lấy danh sách đơn đặt vé theo ID người dùng
export const getListTicketByID = async (req, res) => {
  try {
    const { id_nguoi_dung } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id_nguoi_dung)) {
      return res.status(400).json({ message: "ID người dùng không hợp lệ" });
    }

    // Lấy danh sách đơn đặt vé theo ID người dùng và populate các trường liên quan
    const donDatVeList = await DonDatVe.find({ id_nguoi_dung })
      .populate({
        path: "id_lich_chieu",
        populate: {
          path: "id_phim",
          select: "ten_phim url_poster", // Sửa lỗi dấu phẩy sai cú pháp
        },
      })
      .populate({
        path: "id_lich_chieu",
        populate: {
          path: "id_phong",
          select: "ten_phong", // Sửa lỗi dấu phẩy sai cú pháp
        },
      })
      .populate({
        path: "id_lich_chieu",
        populate: {
          path: "id_rap",
          select: "ten_rap", // Sửa lỗi dấu phẩy sai cú pháp
        },
      })
      .populate("id_voucher")
      .populate("nhanVienXuatVeGiay")
      .populate({
        path: "danh_sach_ghe",
        select: "so_ghe",
      })
      .populate({
        path: "danh_sach_do_an",
        select: "ten_do_an",
      })
      .lean();

    if (!donDatVeList.length) {
      return res.status(404).json({ message: "Không tìm thấy đơn đặt vé" });
    }

    res.status(200).json(donDatVeList);
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
          .populate({
            path: "id_lich_chieu",
            populate: {
              path: "id_phim",
              select: "ten_phim url_poster", // Sửa lỗi dấu phẩy sai cú pháp
            },
          })
          .populate({
            path: "id_lich_chieu",
            populate: {
              path: "id_phong",
              select: "ten_phong", // Sửa lỗi dấu phẩy sai cú pháp
            },
          })
          .populate({
            path: "id_lich_chieu",
            populate: {
              path: "id_rap",
              select: "ten_rap", // Sửa lỗi dấu phẩy sai cú pháp
            },
          })
          .populate("id_voucher", "ma_voucher gia_tri")
          .populate("nhanVienXuatVeGiay", "ten")
          .populate({
              path: "danh_sach_ghe",
              select: "so_ghe",
          })
          .populate({
              path: "danh_sach_do_an",
              select: "ten_do_an",
          })
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



export const layDonVeTheoGheVaXuatChieu = async (req, res) => {
  try {
    const { id_ghe, id_xuat_chieu } = req.params;

    const donDatVe = await DonDatVe.findOne({
      id_lich_chieu: id_xuat_chieu,
      danh_sach_ghe: id_ghe,
    })
      .populate("id_nguoi_dung", "ten email")
      .populate("id_lich_chieu")
      .populate("danh_sach_ghe")
      .populate("danh_sach_do_an")
      .populate("id_voucher")
      .populate("nhanVienXuatVeGiay", "ten email");

    if (!donDatVe) {
      return res.status(404).json({ message: "Không tìm thấy đơn đặt vé!" });
    }

    res.status(200).json(donDatVe);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};