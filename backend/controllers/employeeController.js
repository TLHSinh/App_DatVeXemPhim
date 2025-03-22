import bcrypt from 'bcryptjs';
import NhanVien from '../models/NhanVienSchema.js';

// Thêm nhân viên mới
export const addEmployee = async (req, res) => {
    const { 
        email, 
        matKhau, 
        sodienthoai, 
        hoTen, 
        ngaySinh, 
        cccd, 
        gioiTinh, 
        chucVu, 
        diaChi, 
        hinhAnh, 
        role, 
        trangThai, 
        diemTichLuy 
    } = req.body;

    try {
        let employee = await NhanVien.findOne({ email });

        if (employee) {
            return res.status(400).json({ message: "Nhân viên đã tồn tại" });
        }

        const salt = await bcrypt.genSalt(10);
        const hashPassword = await bcrypt.hash(matKhau, salt);

        employee = new NhanVien({
            email,
            matKhau: hashPassword,
            sodienthoai,
            hoTen,
            ngaySinh,
            cccd,
            gioiTinh,
            chucVu,
            diaChi,
            hinhAnh,
            role: role || "nhanvien",
            trangThai: trangThai || true,
            diemTichLuy: diemTichLuy || 0
        });

        await employee.save();
        res.status(201).json({ success: true, message: "Thêm nhân viên thành công" });

    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

// Cập nhật thông tin nhân viên
export const updateEmployee = async (req, res) => {
    const id = req.params.id;
    const { matKhau, ...rest } = req.body;

    try {
        // Kiểm tra xem nhân viên có tồn tại không
        const existingEmployee = await NhanVien.findById(id);
        if (!existingEmployee) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy nhân viên' });
        }

        // Nếu có cập nhật mật khẩu
        if (matKhau) {
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(matKhau, salt);
            rest.matKhau = hashedPassword;
        }

        const updatedEmployee = await NhanVien.findByIdAndUpdate(
            id, 
            { $set: rest }, 
            { new: true }
        ).select("-matKhau");

        res.status(200).json({ 
            success: true, 
            message: 'Cập nhật thành công', 
            data: updatedEmployee 
        });
    } catch (err) {
        res.status(500).json({ 
            success: false, 
            message: 'Cập nhật không thành công', 
            error: err.message 
        });
    }
};

// Xóa nhân viên
export const deleteEmployee = async (req, res) => {
    const id = req.params.id;

    try {
        const employee = await NhanVien.findById(id);
        if (!employee) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy nhân viên' });
        }

        await NhanVien.findByIdAndDelete(id);
        res.status(200).json({ success: true, message: 'Xóa nhân viên thành công' });
    } catch (err) {
        res.status(500).json({ 
            success: false, 
            message: 'Xóa nhân viên không thành công', 
            error: err.message 
        });
    }
};

// Lấy thông tin một nhân viên theo ID
export const getSingleEmployee = async (req, res) => {
    const id = req.params.id;

    try {
        const employee = await NhanVien.findById(id).select("-matKhau");

        if (!employee) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy nhân viên' });
        }

        res.status(200).json({ 
            success: true, 
            message: 'Tìm nhân viên thành công', 
            data: employee 
        });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};

// Tìm kiếm nhân viên theo email hoặc số điện thoại
export const getEmployeeByEmailOrPhone = async (req, res) => {
    const { emailOrPhone } = req.body;

    if (!emailOrPhone) {
        return res.status(400).json({ 
            success: false, 
            message: 'Vui lòng nhập email hoặc số điện thoại' 
        });
    }

    try {
        const employee = await NhanVien.findOne({
            $or: [{ email: emailOrPhone }, { sodienthoai: emailOrPhone }]
        }).select("-matKhau");

        if (!employee) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy nhân viên' });
        }

        res.status(200).json({ 
            success: true, 
            message: 'Tìm nhân viên thành công', 
            data: employee 
        });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};

// Lấy danh sách tất cả nhân viên
export const getAllEmployees = async (req, res) => {
    try {
        const users = await NhanVien.find().select("-matKhau");
        res.status(200).json({ success: true, message: 'Lấy danh sách nhân viên thành công', data: users });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};

// Thay đổi trạng thái nhân viên (active/inactive)
export const changeEmployeeStatus = async (req, res) => {
    const { id } = req.params;
    const { trangThai } = req.body;
    
    if (!trangThai) {
        return res.status(400).json({ 
            success: false, 
            message: 'Vui lòng cung cấp trạng thái' 
        });
    }

    try {
        const employee = await NhanVien.findById(id);
        
        if (!employee) {
            return res.status(404).json({ 
                success: false, 
                message: 'Không tìm thấy nhân viên' 
            });
        }

        const updatedEmployee = await NhanVien.findByIdAndUpdate(
            id,
            { trangThai },
            { new: true }
        ).select("-matKhau");

        res.status(200).json({
            success: true,
            message: 'Cập nhật trạng thái thành công',
            data: updatedEmployee
        });
    } catch (err) {
        res.status(500).json({ 
            success: false, 
            message: 'Lỗi server', 
            error: err.message 
        });
    }
};

// Cập nhật điểm tích lũy
export const updatePoints = async (req, res) => {
    const { id } = req.params;
    const { diemTichLuy } = req.body;

    if (diemTichLuy === undefined) {
        return res.status(400).json({ 
            success: false, 
            message: 'Vui lòng cung cấp điểm tích lũy' 
        });
    }

    try {
        const employee = await NhanVien.findById(id);
        
        if (!employee) {
            return res.status(404).json({ 
                success: false, 
                message: 'Không tìm thấy nhân viên' 
            });
        }

        const updatedEmployee = await NhanVien.findByIdAndUpdate(
            id,
            { diemTichLuy },
            { new: true }
        ).select("-matKhau");

        res.status(200).json({
            success: true,
            message: 'Cập nhật điểm tích lũy thành công',
            data: updatedEmployee
        });
    } catch (err) {
        res.status(500).json({ 
            success: false, 
            message: 'Lỗi server', 
            error: err.message 
        });
    }
};
