import DanhGia from "../models/DanhGiaSchema.js";
import DonDatVe from "../models/DonDatVeSchema.js";
import LichChieu from "../models/LichChieuSchema.js";
import Phim from "../models/PhimSchema.js";
import mongoose from "mongoose";


//Đánh giá Phim
export const feedback = async (req, res) => {
    try {
        const { id_phim, id_nguoi_dung } = req.params; // ID phim từ request params
        const { diem, binh_luan } = req.body; // Dữ liệu đánh giá từ người dùng

        // Kiểm tra ID hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_phim)) {
            return res.status(400).json({ message: "ID phim không hợp lệ" });
        }

        if (!mongoose.Types.ObjectId.isValid(id_nguoi_dung)) {
            return res.status(400).json({ message: "ID người dùng không hợp lệ" });
        }

        // Tìm lịch chiếu dựa trên id phim
        const lichChieu = await LichChieu.findOne({ id_phim: new mongoose.Types.ObjectId(id_phim) });

        if (!lichChieu) {
            return res.status(404).json({ message: "Không tìm thấy lịch chiếu cho phim này" });
        }

        // Tìm phim để lấy thời lượng
        const phim = await Phim.findById(id_phim);
        if (!phim) {
            return res.status(404).json({ message: "Không tìm thấy phim này" });
        }

        // Kiểm tra đơn đặt vé của người dùng cho lịch chiếu này
        const donDatVe = await DonDatVe.findOne({ id_lich_chieu: lichChieu._id, id_nguoi_dung });

        if (!donDatVe) {
            return res.status(200).json({ message: "Chưa xem phim này!" });
        }

        // Kiểm tra xem người dùng đã đánh giá chưa
        const danhGiaTonTai = await DanhGia.findOne({ id_nguoi_dung, id_phim: id_phim });

        if (danhGiaTonTai) {
            return res.status(200).json({ message: "Bạn đã đánh giá phim này rồi!", danhGiaTonTai });
        }

        // Tính thời gian kết thúc phim
        const thoiGianChieu = new Date(lichChieu.thoi_gian_chieu); // Giả sử có trường 'thoi_gian_chieu'
        const thoiGianKetThuc = new Date(thoiGianChieu.getTime() + phim.thoi_luong * 60000); // Cộng thêm thời lượng phim (phút)

        // Kiểm tra thời gian hiện tại so với thời gian kết thúc phim
        const thoiGianHienTai = new Date();
        if (thoiGianHienTai < thoiGianKetThuc) {
            return res.status(400).json({ message: "Bạn chỉ có thể đánh giá sau khi phim kết thúc!" });
        }

        const trang_thai = binh_luan ? "đã bình luận" : "chưa bình luận";

        // Nếu đủ điều kiện, tạo mới đánh giá
        const danhGiaMoi = new DanhGia({
            id_nguoi_dung: id_nguoi_dung,
            id_phim: id_phim,
            diem,
            binh_luan,
            trang_thai: trang_thai
        });

        await danhGiaMoi.save();

        return res.status(201).json({ message: "Đánh giá thành công!", danhGiaMoi });

    } catch (error) {
        console.error("Lỗi khi xử lý feedback:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

//Xóa đánh giá Phim
export const deleteFeedback = async (req, res) => {
    try {
        const { id_phim, id_nguoi_dung } = req.params;

        // Kiểm tra ID hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_nguoi_dung) || !mongoose.Types.ObjectId.isValid(id_phim)) {
            return res.status(400).json({ message: "ID người dùng hoặc ID phim không hợp lệ" });
        }

        // Kiểm tra xem đánh giá có tồn tại không
        const danhGia = await DanhGia.findOne({ id_phim, id_nguoi_dung });
        if (!danhGia) {
            return res.status(404).json({ message: "Không tìm thấy đánh giá" });
        }

        // Xoá đánh giá
        await DanhGia.deleteOne({ id_phim, id_nguoi_dung });

        return res.status(200).json({ message: "Xóa đánh giá thành công" });
    } catch (error) {
        console.error("Lỗi khi xóa đánh giá:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

//Cập nhật đánh giá
export const updateFeedback = async (req, res) => {
    try {
        const { id_phim, id_nguoi_dung } = req.params;
        const { diem, binh_luan } = req.body;

        // Kiểm tra ID hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_nguoi_dung) || !mongoose.Types.ObjectId.isValid(id_phim)) {
            return res.status(400).json({ message: "ID người dùng hoặc ID phim không hợp lệ" });
        }

        // Tìm đánh giá để kiểm tra trạng thái
        const danhGia = await DanhGia.findOne({ id_phim, id_nguoi_dung });

        if (!danhGia) {
            return res.status(404).json({ message: "Không tìm thấy đánh giá để cập nhật" });
        }

        // Kiểm tra nếu trạng thái là "vi_pham" thì không cho phép cập nhật
        if (danhGia.trang_thai === "vi phạm") {
            return res.status(403).json({ message: "Không thể chỉnh sửa đánh giá do đã bị báo cáo vi phạm" });
        }

        // Cập nhật đánh giá
        danhGia.diem = diem;
        danhGia.binh_luan = binh_luan;
        danhGia.trang_thai = "đã chỉnh sửa";
        await danhGia.save();

        return res.status(200).json({ message: "Cập nhật đánh giá thành công", danhGia });

    } catch (error) {
        console.error("Lỗi khi cập nhật đánh giá:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

