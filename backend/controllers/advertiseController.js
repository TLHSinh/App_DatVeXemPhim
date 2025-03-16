// 📌 controllers/quangCao.controller.js
import QuangCao from "../models/QuangCaoSchema.js";

// Thêm quảng cáo mới
export const themQuangCao = async (req, res) => {
  try {
    const quangCao = new QuangCao(req.body);
    await quangCao.save();
    res.status(201).json({ message: "Thêm quảng cáo thành công!", quangCao });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

// Lấy danh sách quảng cáo
export const layDanhSachQuangCao = async (req, res) => {
  try {
    const danhSachQC = await QuangCao.find();
    res.status(200).json(danhSachQC);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

// Sửa quảng cáo theo ID
export const suaQuangCao = async (req, res) => {
  try {
    const quangCao = await QuangCao.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!quangCao) {
      return res.status(404).json({ message: "Không tìm thấy quảng cáo!" });
    }
    res.status(200).json({ message: "Cập nhật quảng cáo thành công!", quangCao });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

// Xóa quảng cáo theo ID
export const xoaQuangCao = async (req, res) => {
  try {
    const quangCao = await QuangCao.findByIdAndDelete(req.params.id);
    if (!quangCao) {
      return res.status(404).json({ message: "Không tìm thấy quảng cáo!" });
    }
    res.status(200).json({ message: "Xóa quảng cáo thành công!" });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};




