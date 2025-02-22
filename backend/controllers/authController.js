import NguoiDung from '../models/NguoiDungSchema.js';
import NhanVien from '../models/NhanVienSchema.js';
import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'

const generateToken = user => {
    return jwt.sign({ id: user._id, role: user.role, email: user.email }, process.env.JWT_SECRET_KEY, {
        expiresIn: '15d',
    });
}

export const register = async (req, res) => {

    const { email, matKhau, hoTen, gioiTinh, hinhAnh, role } = req.body;

    try {
        let user = null;

        if (role === "user") {
            user = await NguoiDung.findOne({ email });
        } else if (role === "nhanvien") {
            user = await NhanVien.findOne({ email });
        }

        // Kiểm tra nếu user đã tồn tại
        if (user) {
            return res.status(400).json({ message: "Người dùng đã tồn tại" });
        }

        // Hash mật khẩu
        const salt = await bcrypt.genSalt(10);
        const hashPassword = await bcrypt.hash(matKhau, salt);

        if (role === "user") {
            user = new NguoiDung({
                hoTen,
                email,
                matKhau: hashPassword,
                hinhAnh,
                gioiTinh,
                role
            });
        }

        if (role === "nhanvien") {
            user = new NhanVien({
                hoTen,
                email,
                matKhau: hashPassword,
                hinhAnh,
                gioiTinh,
                role
            });
        }

        await user.save();
        res.status(200).json({ message: "Đăng ký người dùng thành công" });

    } catch (err) {
        res.status(500).json({ success: false, message: "Mất kết nối server" });
    }
}

export const login = async (req, res) => {
    console.log("request body:", req.body);
    const { email } = req.body;

    try {
        let user = null;
        const nguoiDung = await NguoiDung.findOne({ email });
        const nhanVien = await NhanVien.findOne({ email });

        if (nguoiDung) {
            user = nguoiDung;
        }
        if (nhanVien) {
            user = nhanVien;
        }

        // Kiểm tra nếu user không tồn tại
        if (!user) {
            return res.status(404).json({ message: "Không tìm thấy người dùng" });
        }

        // Kiểm tra mật khẩu
        const isPasswordMatch = await bcrypt.compare(
            req.body.matKhau,
            user.matKhau
        );

        if (!isPasswordMatch) {
            return res.status(404).json({ message: "Thông tin xác thực không hợp lệ" });
        }

        // Lấy token
        const token = generateToken(user);

        const { matKhau, role, lichHen, ...rest } = user._doc;

        return res
            .status(200)
            .json({ status: true, message: "Đăng nhập thành công", token, data: { ...rest }, role });

    } catch (err) {
        return res
            .status(500)
            .json({ status: false, message: "Đăng nhập không thành công" });
    }
}
