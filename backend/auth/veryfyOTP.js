import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import NguoiDung from '../models/NguoiDungSchema.js';
import NhanVien from '../models/NhanVienSchema.js';
import OTPModel from '../models/OTPSchema.js';
import TempUser from '../models/TempUserSchema.js';

export const verifyOtp = async (req, res) => {
    const { email, otp } = req.body;

    try {
        // Tìm OTP trong DB
        const otpRecord = await OTPModel.findOne({ email, otp });
        if (!otpRecord) {
            return res.status(400).json({ success: false, message: "Mã OTP không hợp lệ hoặc đã hết hạn" });
        }

        // Lấy thông tin người dùng từ TempUser
        const tempUser = await TempUser.findOne({ email });
        if (!tempUser) {
            return res.status(400).json({ success: false, message: "Không tìm thấy thông tin đăng ký" });
        }

        // Tạo tài khoản chính
        const user = new NguoiDung({
            hoTen: tempUser.hoTen,
            email: tempUser.email,
            matKhau: tempUser.matKhau,
            sodienthoai: tempUser.sodienthoai,
            hinhAnh: tempUser.hinhAnh,
            ngaySinh: tempUser.ngaySinh,
            cccd: tempUser.cccd,
            gioiTinh: tempUser.gioiTinh,
            diaChi: tempUser.diaChi,
            role: tempUser.role
        });

        await user.save();

        // Xóa OTP và dữ liệu tạm thời
        await OTPModel.deleteOne({ email });
        await TempUser.deleteOne({ email });

        res.status(200).json({ success: true, message: "Xác thực OTP thành công, tài khoản đã được tạo!" });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};


export const ClearOtp = async (req, res) => {
    const { email } = req.body;

    try {
        // Xóa OTP và dữ liệu tạm thời
        await OTPModel.deleteOne({ email });
        await TempUser.deleteOne({ email });

        res.status(200).json({ success: true, message: "xoá OTP và TempUser" });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

