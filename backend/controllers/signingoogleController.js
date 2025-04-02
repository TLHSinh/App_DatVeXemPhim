import NguoiDung from "../models/NguoiDungSchema.js";

export const SignInWithGoogle = async (req, res) => {
    try {
        const { email, matKhau, sodienthoai, hoTen, ngaySinh, cccd, gioiTinh, diaChi, hinhAnh } = req.body;

        if (!email) {
            return res.status(400).json({ message: "Thiếu email!" });
        }

        // Kiểm tra xem email đã tồn tại chưa
        const existingUser = await NguoiDung.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "Email đã được sử dụng." });
        }

        // Tạo người dùng mới với các trường mặc định nếu không có giá trị
        const nguoiDungMoi = new NguoiDung({
            email,
            matKhau: matKhau || 'undefined',
            sodienthoai: sodienthoai || "",
            hoTen: hoTen || "Không rõ",
            ngaySinh: ngaySinh || null,
            cccd: cccd || "",
            gioiTinh: gioiTinh || "khac",
            diaChi: diaChi || "",
            hinhAnh: hinhAnh || "",
            role: "user", // Mặc định là user
            trangThai: true, // Mặc định là true
            diemTichLuy: 0  // Mặc định là 0
        });

        await nguoiDungMoi.save();
        return res.status(201).json({ message: "Tạo tài khoản thành công.", user: nguoiDungMoi });
    } catch (error) {
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

export const DeleteAccount = async (req, res) => {
    try {
        const { email } = req.body;

        const user = await NguoiDung.findOneAndDelete({ email });

        if (!user) {
            return res.status(404).json({ message: "Không tìm thấy tài khoản với email này." });
        }

        return res.status(200).json({ message: "Xóa tài khoản thành công." });
    } catch (error) {
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};
