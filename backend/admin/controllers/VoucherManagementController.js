import Voucher from "../../models/VoucherSchema.js";

// Lấy danh sách voucher
export const getAllVouchers = async (req, res) => {
    try {
        const vouchers = await Voucher.find();
        res.status(200).json({ success: true, data: vouchers });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Lấy danh sách voucher [còn hạn]
export const getAllVouchersAvailabled = async (req, res) => {
    try {
        const now = new Date();
        const vouchers = await Voucher.find({ ngay_het_han: { $gte: now } });
        res.status(200).json({ success: true, data: vouchers });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Lấy danh sách voucher [hết hạn]
export const getAllVouchersExpired = async (req, res) => {
    try {
        const now = new Date();
        const vouchers = await Voucher.find({ ngay_het_han: { $lt: now } });
        res.status(200).json({ success: true, data: vouchers });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Tạo voucher
export const addVoucher = async (req, res) => {
    try {
        const { ma_voucher, loai_giam_gia, gia_tri_giam, don_hang_toi_thieu, gioi_han_su_dung, ngay_het_han } = req.body;

        // Kiểm tra thông tin bắt buộc
        if (!ma_voucher || !loai_giam_gia || !gia_tri_giam) {
            return res.status(400).json({ success: false, message: "Thiếu thông tin bắt buộc" });
        }

        // Kiểm tra xem voucher đã tồn tại chưa
        const existingVoucher = await Voucher.findOne({ ma_voucher });
        if (existingVoucher) {
            return res.status(400).json({ success: false, message: "Voucher đã tồn tại" });
        }

        // Tạo voucher mới
        const newVoucher = new Voucher({
            ma_voucher,
            loai_giam_gia,
            gia_tri_giam,
            don_hang_toi_thieu,
            gioi_han_su_dung,
            ngay_het_han
        });

        await newVoucher.save();
        res.status(201).json({ success: true, message: "Tạo voucher thành công", data: newVoucher });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Cập nhật voucher
export const updateVoucher = async (req, res) => {
    const { id } = req.params;
    const updateData = req.body;

    try {
        const voucher = await Voucher.findById(id);

        if (!voucher) {
            return res.status(404).json({ success: false, message: "Voucher không tồn tại" });
        }

        // Kiểm tra nếu voucher đã có người sử dụng (gioi_han_su_dung > 0) thì không cho phép cập nhật
        if (voucher.gioi_han_su_dung <= 0) {
            return res.status(400).json({ success: false, message: "Voucher đã được sử dụng, không thể cập nhật" });
        }

        // Cập nhật voucher
        const updatedVoucher = await Voucher.findByIdAndUpdate(id, updateData, { new: true });

        return res.status(200).json({ success: true, message: "Cập nhật voucher thành công", voucher: updatedVoucher });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: error.message });
    }
};
// Xóa voucher
export const deleteVoucher = async (req, res) => {
    const { id } = req.params;

    try {
        const voucher = await Voucher.findById(id);

        if (!voucher) {
            return res.status(404).json({ success: false, message: "Voucher không tồn tại" });
        }

        // Chỉ xóa nếu voucher chưa có ai sử dụng (gioi_han_su_dung === 0)
        if (voucher.gioi_han_su_dung > 0) {
            return res.status(400).json({ success: false, message: "Voucher đã được sử dụng, không thể xóa" });
        }

        await Voucher.findByIdAndDelete(id);

        return res.status(200).json({ success: true, message: "Xóa voucher thành công" });
    } catch (error) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: error.message });
    }
};
