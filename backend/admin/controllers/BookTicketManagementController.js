import DonDatVe from "../../models/DonDatVeSchema.js";


// Xem danh sách đặt vé
export const getListBookTickets = async (req, res) => {
    try {
        const danhSachDonDatVe = await DonDatVe.find()
            .populate("id_nguoi_dung", "hoTen email")  // Populate thông tin người dùng
            .populate("id_lich_chieu")  // Populate lịch chiếu
            .populate("id_voucher", "ma_giam_gia gia_tri") // Populate voucher (nếu có)
            .populate("nhanVienXuatVeGiay", "ten email"); // Populate nhân viên xuất vé (nếu có)

        return res.status(200).json({ success: true, data: danhSachDonDatVe });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: error.message });
    }
};
// Duyệt yêu cầu hủy vé
export const confirmCancelTicket = async (req, res) => {
    const { id_don } = req.params;

    try {
        // Kiểm tra đơn đặt vé có tồn tại không
        const donDatVe = await DonDatVe.findById(id_don);
        if (!donDatVe) {
            return res.status(404).json({ success: false, message: "Không tìm thấy đơn đặt vé" });
        }

        // Kiểm tra nếu đơn đã hủy hoặc đã xuất vé thì không thể hủy nữa
        if (donDatVe.trang_thai === "đã hủy") {
            return res.status(400).json({ success: false, message: "Đơn đặt vé đã bị hủy trước đó" });
        }
        if (donDatVe.trang_thai === "đã xuất vé") {
            return res.status(400).json({ success: false, message: "Không thể hủy vì vé đã được xuất" });
        }

        // Cập nhật trạng thái đơn đặt vé thành 'đã hủy'
        donDatVe.trang_thai = "đã hủy";
        await donDatVe.save();

        return res.status(200).json({ success: true, message: "Yêu cầu hủy vé đã được xác nhận" });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: error.message });
    }
};

/* ================================================== */

// Xử lý hoàn tiền [auto]
export const refundProcessing = async (req, res) => {
    const { id_don } = req.params;

    try {
        // Kiểm tra đơn đặt vé có tồn tại không
        const donDatVe = await DonDatVe.findById(id_don);
        if (!donDatVe) {
            return res.status(404).json({ success: false, message: "Không tìm thấy đơn đặt vé" });
        }

        // Kiểm tra trạng thái đơn đặt vé
        if (donDatVe.trang_thai !== "đã hủy") {
            return res.status(400).json({ success: false, message: "Chỉ có thể hoàn tiền cho đơn đã hủy" });
        }

        // Xử lý hoàn tiền (tuỳ vào phương thức thanh toán, có thể gọi API bên thứ 3)
        const soTienHoan = donDatVe.tien_thanh_toan; // Giả sử hoàn lại toàn bộ tiền

        // Cập nhật trạng thái hoàn tiền (thêm field refundStatus nếu cần)
        donDatVe.trang_thai = "đã hoàn tiền";
        await donDatVe.save();

        return res.status(200).json({
            success: true,
            message: `Hoàn tiền thành công số tiền ${soTienHoan} VND`,
            refundAmount: soTienHoan
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: error.message });
    }
};
// Xử lý hoàn tiền [manual]
/*  --> Người dùng gửi yêu cầu  */
export const requestRefund = async (req, res) => {
    const { id_don } = req.params;

    try {
        // Kiểm tra đơn đặt vé
        const donDatVe = await DonDatVe.findById(id_don);
        if (!donDatVe) {
            return res.status(404).json({ success: false, message: "Không tìm thấy đơn đặt vé" });
        }

        // Chỉ cho phép yêu cầu hoàn tiền nếu đơn đã bị hủy
        if (donDatVe.trang_thai !== "đã hủy") {
            return res.status(400).json({ success: false, message: "Chỉ có thể yêu cầu hoàn tiền cho đơn đã hủy" });
        }

        // Cập nhật trạng thái thành "chờ hoàn tiền"
        donDatVe.trang_thai = "chờ hoàn tiền";
        await donDatVe.save();

        return res.status(200).json({ success: true, message: "Yêu cầu hoàn tiền đã được gửi, chờ nhân viên duyệt" });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: error.message });
    }
};
/*  --> Nhân viên xác nhận yêu cầu  */
export const confirmRefund = async (req, res) => {
    const { id_don } = req.params;

    try {
        // Kiểm tra đơn đặt vé
        const donDatVe = await DonDatVe.findById(id_don);
        if (!donDatVe) {
            return res.status(404).json({ success: false, message: "Không tìm thấy đơn đặt vé" });
        }

        // Kiểm tra trạng thái có phải "chờ hoàn tiền" không
        if (donDatVe.trang_thai !== "chờ hoàn tiền") {
            return res.status(400).json({ success: false, message: "Đơn đặt vé không ở trạng thái chờ hoàn tiền" });
        }

        // Thực hiện hoàn tiền
        const soTienHoan = donDatVe.tien_thanh_toan; // Giả sử hoàn toàn bộ

        // Cập nhật trạng thái đơn hàng
        donDatVe.trang_thai = "đã hoàn tiền";
        await donDatVe.save();

        return res.status(200).json({
            success: true,
            message: `Hoàn tiền thành công số tiền ${soTienHoan} VND`,
            refundAmount: soTienHoan
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: error.message });
    }
};
