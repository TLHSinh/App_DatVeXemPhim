import QuangCao from "../../models/QuangCaoSchema.js";

//Lấy danh sách quảng cáo
export const getAllAds = async (req, res) => {
    try {
        const ads = await QuangCao.find();
        res.status(200).json(ads);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi lấy danh sách quảng cáo", error });
    }
}

//Thêm quảng cáo mới
export const addAds = async (req, res) => {
    try {
        const { tieu_de, mo_ta, loai_qc, url_hinh, url_dich, ngay_bat_dau, ngay_ket_thuc, trang_thai } = req.body;

        // Kiểm tra dữ liệu bắt buộc
        if (!tieu_de || !loai_qc || !url_hinh || !ngay_bat_dau || !ngay_ket_thuc) {
            return res.status(400).json({ message: "Tiêu đề, loại quảng cáo, hình ảnh, ngày bắt đầu, ngày kết thúc là bắt buộc" });
        }

        const newAd = new QuangCao({
            tieu_de,
            mo_ta,
            loai_qc,
            url_hinh,
            url_dich,
            ngay_bat_dau,
            ngay_ket_thuc,
            trang_thai: trang_thai !== undefined ? trang_thai : true
        });

        await newAd.save();
        res.status(201).json(newAd);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi thêm quảng cáo", error });
    }
}

//Cập nhật quảng cáo
export const updateAds = async (req, res) => {
    try {
        const { id } = req.params;
        const updatedAd = await QuangCao.findByIdAndUpdate(id, req.body, { new: true });

        if (!updatedAd) {
            return res.status(404).json({ message: "Không tìm thấy quảng cáo" });
        }

        res.status(200).json(updatedAd);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi cập nhật quảng cáo", error });
    }
}

//Xóa quảng cáo
export const deleteAds = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedAd = await QuangCao.findByIdAndDelete(id);

        if (!deletedAd) {
            return res.status(404).json({ message: "Không tìm thấy quảng cáo" });
        }

        res.status(200).json({ message: "Xóa quảng cáo thành công" });
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi xóa quảng cáo", error });
    }
}