import bcrypt from 'bcryptjs';
import NguoiDung from '../models/NguoiDungSchema.js';

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
        const user = await NguoiDung.findById(id).select("-matKhau");

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
        const user = await NguoiDung.findById(userID).select("-matKhau");

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        res.status(200).json({ success: true, message: 'Lấy hồ sơ người dùng thành công', data: user });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};
