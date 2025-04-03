import bcrypt from 'bcryptjs';
import NguoiDung from '../models/NguoiDungSchema.js';
import DonDatVe from "../models/DonDatVeSchema.js";
import mongoose from "mongoose";

// Thêm người dùng mới
export const addUser = async (req, res) => {
    const { email, matKhau, sodienthoai, hoTen, hinhAnh, ngaySinh, cccd, diaChi, gioiTinh } = req.body;

    try {
        let user = await NguoiDung.findOne({ email });

        if (user) {
            return res.status(400).json({ message: "Người dùng đã tồn tại" });
        }

        const salt = await bcrypt.genSalt(10);
        const hashPassword = await bcrypt.hash(matKhau, salt);

        user = new NguoiDung({
            email,
            matKhau: hashPassword,
            sodienthoai,
            hoTen,
            hinhAnh,
            ngaySinh,
            cccd,
            diaChi,
            gioiTinh
        });

        await user.save();
        res.status(200).json({ success: true, message: "Đăng ký người dùng thành công" });

    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

// Cập nhật thông tin người dùng
export const updateUser = async (req, res) => {
    const id = req.params.id;
    const { matKhau, ...rest } = req.body;

    try {
        if (matKhau) {
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(matKhau, salt);
            rest.matKhau = hashedPassword;
        }

        const updatedUser = await NguoiDung.findByIdAndUpdate(id, { $set: rest }, { new: true });

        res.status(200).json({ success: true, message: 'Cập nhật thành công', data: updatedUser });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Cập nhật không thành công', error: err.message });
    }
};

// Xóa người dùng
export const deleteUser = async (req, res) => {
    const id = req.params.id;

    try {
        await NguoiDung.findByIdAndDelete(id);
        res.status(200).json({ success: true, message: 'Xóa người dùng thành công' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Xóa người dùng không thành công', error: err.message });
    }
};

// Lấy thông tin một người dùng theo ID
export const getSingleUser = async (req, res) => {
    const id = req.params.id;

    try {
        const user = await NguoiDung.findById(id);

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        res.status(200).json({ success: true, message: 'Tìm người dùng thành công', data: user });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};

// Tìm kiếm người dùng theo email hoặc số điện thoại
export const getUserByEmailOrPhone = async (req, res) => {
    const { emailOrPhone } = req.body;

    if (!emailOrPhone) {
        return res.status(400).json({ success: false, message: 'Vui lòng nhập email hoặc số điện thoại' });
    }

    try {
        const user = await NguoiDung.findOne({
            $or: [{ email: emailOrPhone }, { sodienthoai: emailOrPhone }]
        }).select("-matKhau");

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        res.status(200).json({ success: true, message: 'Tìm người dùng thành công', data: user });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};


// Lấy danh sách tất cả người dùng
export const getAllUsers = async (req, res) => {
    try {
        const users = await NguoiDung.find().select("-matKhau");
        res.status(200).json({ success: true, message: 'Lấy danh sách người dùng thành công', data: users });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};

// Lấy thông tin hồ sơ người dùng
export const getUserProfile = async (req, res) => {
    const userID = req.userID;

    try {
        console.log("User ID từ middleware:", req.userId); // Debug ID lấy từ middleware
        const user = await NguoiDung.findById(userID).select("-matKhau");

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        res.status(200).json({ success: true, message: 'Lấy hồ sơ người dùng thành công', data: user });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};


// API lấy tổng chi tiêu của người dùng
export const getTotalExpenditure = async (req, res) => {
    try {
        const id = req.params.id;
   
        
        // Kiểm tra ID có hợp lệ không
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: "ID người dùng không hợp lệ" });
        }

        // Tính tổng chi tiêu của người dùng
        const result = await DonDatVe.aggregate([
            { $match: { id_nguoi_dung: new mongoose.Types.ObjectId(id) } },
            { $group: { _id: "$id_nguoi_dung", total_spent: { $sum: "$tien_thanh_toan" } } }
        ]);

        const totalSpent = result.length > 0 ? result[0].total_spent : 0;
        
        res.json({ id_nguoi_dung: id, total_spent: totalSpent });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Lỗi server" });
    }
};



// Hàm xác định rank dựa trên điểm thưởng
const getRank = (diem) => {
    if (diem < 100) return "Basic";
    if (diem < 500) return "Silver";
    if (diem < 1000) return "Gold";
    if (diem < 5000) return "Diamond";
    if (diem > 5000) return "VIP";

  };
  
  // API cập nhật điểm thưởng và rank khi thanh toán thành công
  export const updatePoint = async (req, res) => {
    try {
      const { id_nguoi_dung, id_don_dat_ve } = req.body;
  
      // Kiểm tra người dùng và đơn đặt vé có tồn tại không
      const donDatVe = await DonDatVe.findById(id_don_dat_ve);
      if (!donDatVe || donDatVe.trang_thai !== "đã thanh toán") {
        return res.status(400).json({ message: "Đơn đặt vé không hợp lệ hoặc chưa thanh toán" });
      }
  
      const nguoiDung = await NguoiDung.findById(id_nguoi_dung);
      if (!nguoiDung) {
        return res.status(404).json({ message: "Người dùng không tồn tại" });
      }
  
      // Tính điểm thưởng từ tổng tiền thanh toán
      const diemThuongMoi = Math.floor(donDatVe.tien_thanh_toan / 1000);
  
      // Cập nhật điểm tích lũy và kiểm tra rank mới
      const diemMoi = nguoiDung.diemTichLuy + diemThuongMoi;
      const rankMoi = getRank(diemMoi);
  
      // Cập nhật vào database
      nguoiDung.diemTichLuy = diemMoi;
      nguoiDung.rank = rankMoi;
      await nguoiDung.save();
  
      return res.status(200).json({
        message: "Cập nhật điểm thưởng và rank thành công",
        diemTichLuy: diemMoi,
        rank: rankMoi
      });
  
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }
  
