import NguoiDung from '../../models/NguoiDungSchema.js';



// Lấy danh sách tất cả người dùng
export const getListUsers = async (req, res) => {
    try {
        const users = await NguoiDung.find().select("-matKhau");
        res.status(200).json({ success: true, message: 'Lấy danh sách người dùng thành công', data: users });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi server', error: err.message });
    }
};

// Khóa/Mở khóa tài khoản người dùng
export const lockUserAccount = async (req, res) => {
    try {
        const { userId } = req.params; // Lấy userId từ URL
        const { trangThai } = req.body; // Lấy trạng thái từ request body

        // Kiểm tra người dùng có tồn tại không
        const user = await NguoiDung.findById(userId);
        if (!user) {
            return res.status(404).json({ success: false, message: "Người dùng không tồn tại" });
        }

        // Cập nhật trạng thái khóa tài khoản
        user.trangThai = trangThai;
        await user.save();

        res.status(200).json({
            success: true,
            message: !trangThai ? "Đã khóa tài khoản người dùng" : "Đã mở khóa tài khoản",
            data: user,
        });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Lấy danh sách tài khoản bị khóa
export const getBannedListUsers = async (req, res) => {
    try {
        const bannedUsers = await NguoiDung.find({ trangThai: false }).select("-matKhau");

        res.status(200).json({
            success: true,
            message: "Lấy danh sách tài khoản bị khóa thành công",
            data: bannedUsers
        });
    } catch (err) {
        res.status(500).json({
            success: false,
            message: "Lỗi server",
            error: err.message
        });
    }
};

//Xem lịch sử giao dịch người dùng
//...