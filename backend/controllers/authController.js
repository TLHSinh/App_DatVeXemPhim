import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import NguoiDung from '../models/NguoiDungSchema.js';
import NhanVien from '../models/NhanVienSchema.js';

// Tạo token JWT
const generateToken = user => {
    return jwt.sign(
        { id: user._id, role: user.role, email: user.email }, 
        process.env.JWT_SECRET_KEY, 
        { expiresIn: '15d' }
    );
};

// Đăng ký tài khoản 
export const register = async (req, res) => {
    const { email, matKhau, hoTen, gioiTinh, hinhAnh, role, sodienthoai, ngaySinh, cccd, diaChi, chucVu } = req.body;

    try {
        let user = null;

        // Kiểm tra user đã tồn tại
        if (role === "user") {
            user = await NguoiDung.findOne({ email });
        } else if (role === "nhanvien" || role === "admin") {
            user = await NhanVien.findOne({ email });
        } else {
            return res.status(400).json({ 
                success: false, 
                message: "Vai trò không hợp lệ. Vui lòng chọn 'user', 'nhanvien' hoặc 'admin'" 
            });
        }

        if (user) {
            return res.status(400).json({ success: false, message: "Email đã được sử dụng" });
        }

        // Hash mật khẩu
        const salt = await bcrypt.genSalt(10);
        const hashPassword = await bcrypt.hash(matKhau, salt);

        // Tạo đối tượng mới dựa vào role
        if (role === "user") {
            user = new NguoiDung({
                hoTen,
                email,
                matKhau: hashPassword,
                sodienthoai,
                hinhAnh,
                ngaySinh,
                cccd,
                gioiTinh,
                diaChi,
                role
            });
        } else if (role === "nhanvien" || role === "admin") {
            user = new NhanVien({
                hoTen,
                email,
                matKhau: hashPassword,
                sodienthoai,
                hinhAnh,
                ngaySinh,
                cccd,
                gioiTinh,
                diaChi,
                chucVu,
                role,
                trangThai: true
            });
        }

        await user.save();
        res.status(201).json({ success: true, message: "Đăng ký thành công" });

    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

// Đăng nhập
export const loginAdmin = async (req, res) => {
    const { email, matKhau } = req.body;

    try {
        // Kiểm tra email tồn tại
        const employee = await NhanVien.findOne({ email });
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Email không tồn tại' });
        }

        // Kiểm tra trạng thái tài khoản
        if (employee.trangThai === false) {
            return res.status(403).json({ success: false, message: 'Tài khoản đã bị vô hiệu hóa' });
        }

        // Kiểm tra mật khẩu
        const isPasswordCorrect = await bcrypt.compare(matKhau, employee.matKhau);
        if (!isPasswordCorrect) {
            return res.status(400).json({ success: false, message: 'Mật khẩu không đúng' });
        }

        // Tạo JWT token
        const token = jwt.sign(
            { id: employee._id, role: employee.role },
            process.env.JWT_SECRET_KEY,
            { expiresIn: '15d' }
        );

        // Lưu token vào cookie
        res.cookie('accessToken', token, {
            httpOnly: true,
            expires: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000) // 15 ngày
        });

        const { matKhau: _, ...employeeDetails } = employee._doc;

        res.status(200).json({
            success: true,
            message: 'Đăng nhập thành công',
            token,
            data: employeeDetails
        });

    } catch (err) {
        res.status(500).json({ success: false, message: 'Đăng nhập thất bại', error: err.message });
    }
};


// Đăng nhập
export const loginUser = async (req, res) => {
    const { email, matKhau } = req.body;

    try {
        // Kiểm tra email tồn tại
        const user = await NguoiDung.findOne({ email });
        if (!user) {
            return res.status(404).json({ success: false, message: 'Email không tồn tại' });
        }

        // Kiểm tra trạng thái tài khoản
        if (user.trangThai === false) {
            return res.status(403).json({ success: false, message: 'Tài khoản đã bị vô hiệu hóa' });
        }

        // Kiểm tra mật khẩu
        const isPasswordCorrect = await bcrypt.compare(matKhau, user.matKhau);
        if (!isPasswordCorrect) {
            return res.status(400).json({ success: false, message: 'Mật khẩu không đúng' });
        }

        // Tạo JWT token
        const token = jwt.sign(
            { id: user._id, role: user.role },
            process.env.JWT_SECRET_KEY,
            { expiresIn: '15d' }
        );

        // Lưu token vào cookie
        res.cookie('accessToken', token, {
            httpOnly: true,
            expires: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000) // 15 ngày
        });

        const { matKhau: _, ...userDetails } = user._doc;

        res.status(200).json({
            success: true,
            message: 'Đăng nhập thành công',
            token,
            data: userDetails
        });

    } catch (err) {
        res.status(500).json({ success: false, message: 'Đăng nhập thất bại', error: err.message });
    }
};


// Đăng xuất
export const logout = async (req, res) => {
    res.cookie('accessToken', '', {
        httpOnly: true,
        expires: new Date(0)
    });

    res.status(200).json({ success: true, message: 'Đăng xuất thành công' });
};

// Đổi mật khẩu
export const changePassword = async (req, res) => {
    const { matKhauCu, matKhauMoi } = req.body;
    const userID = req.userID;
    const userRole = req.role;

    if (!matKhauCu || !matKhauMoi) {
        return res.status(400).json({ 
            success: false, 
            message: 'Vui lòng cung cấp mật khẩu cũ và mật khẩu mới' 
        });
    }

    try {
        let user = null;
        
        // Tìm user dựa vào role
        if (userRole === 'user') {
            user = await NguoiDung.findById(userID);
        } else if (userRole === 'nhanvien' || userRole === 'admin') {
            user = await NhanVien.findById(userID);
        }

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        // Kiểm tra mật khẩu cũ
        const isPasswordCorrect = await bcrypt.compare(matKhauCu, user.matKhau);
        if (!isPasswordCorrect) {
            return res.status(400).json({ success: false, message: 'Mật khẩu cũ không đúng' });
        }

        // Hash mật khẩu mới
        const salt = await bcrypt.genSalt(10);
        const hashPassword = await bcrypt.hash(matKhauMoi, salt);

        // Cập nhật mật khẩu
        user.matKhau = hashPassword;
        await user.save();

        res.status(200).json({ success: true, message: 'Đổi mật khẩu thành công' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};

// Lấy thông tin người dùng hiện tại
export const getCurrentUser = async (req, res) => {
    const userID = req.userID;
    const userRole = req.role;

    try {
        let user = null;
        
        if (userRole === 'user') {
            user = await NguoiDung.findById(userID).select("-matKhau");
        } else if (userRole === 'nhanvien' || userRole === 'admin') {
            user = await NhanVien.findById(userID).select("-matKhau");
        }

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy thông tin người dùng' });
        }

        res.status(200).json({ 
            success: true, 
            message: 'Lấy thông tin người dùng thành công', 
            data: user 
        });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};