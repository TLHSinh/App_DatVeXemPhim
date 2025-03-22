import DanhGia from "../../models/DanhGiaSchema.js";
import DonDatVe from "../../models/DonDatVeSchema.js";
import LichChieu from "../../models/LichChieuSchema.js";
import Phim from "../../models/PhimSchema.js";
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
//
export const updateFeedback = async (req, res) => {
    try {
        const { id_phim, id_nguoi_dung } = req.params;
        const { diem, binh_luan } = req.body;

        // Kiểm tra ID hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_nguoi_dung) || !mongoose.Types.ObjectId.isValid(id_phim)) {
            return res.status(400).json({ message: "ID người dùng hoặc ID phim không hợp lệ" });
        }

        // Tìm và cập nhật đánh giá dựa trên id_nguoi_dung và id_phim
        const danhGia = await DanhGia.findOneAndUpdate(
            { id_phim, id_nguoi_dung }, // Điều kiện tìm đánh giá
            {
                diem,
                binh_luan,
                trang_thai: "đã chỉnh sửa"
            }, // Cập nhật điểm & bình luận
            { new: true, runValidators: true } // Trả về dữ liệu mới sau cập nhật
        );

        if (!danhGia) {
            return res.status(404).json({ message: "Không tìm thấy đánh giá để cập nhật" });
        }

        return res.status(200).json({ message: "Cập nhật đánh giá thành công", danhGia });

    } catch (error) {
        console.error("Lỗi khi cập nhật đánh giá:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};


//Lấy danh sách tất cả đánh giá (bao gồm vi phạm)
export const getAllFeedbacks = async (req, res) => {
    try {
        const danhGias = await DanhGia.find().populate("id_nguoi_dung id_phim");
        return res.status(200).json(danhGias);
    } catch (error) {
        console.error("Lỗi khi lấy danh sách đánh giá:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};
//Lấy danh sách tất cả đánh giá theo Phim (không vi phạm)
export const getFeedbacksByMovieId = async (req, res) => {
    try {
        const { id_phim } = req.params;

        // Kiểm tra id phim hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_phim)) {
            return res.status(400).json({ message: "ID phim không hợp lệ" });
        }

        // Lấy danh sách đánh giá theo id_phim, bỏ qua trạng thái "vi_pham"
        const danhGias = await DanhGia.find({ id_phim: id_phim, trang_thai: { $ne: "vi_pham" } })
            .populate("id_nguoi_dung");

        if (danhGias.length === 0) {
            return res.status(404).json({ message: "Không có đánh giá hợp lệ nào cho phim này" });
        }

        return res.status(200).json(danhGias);
    } catch (error) {
        console.error("Lỗi khi lấy đánh giá theo ID phim:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};
//Láy danh sách tất cả đánh giá theo Người dùng (không vi phạm)
export const getFeedbacksByUserId = async (req, res) => {
    try {
        const { id_nguoi_dung } = req.params;

        // Kiểm tra ID hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_nguoi_dung)) {
            return res.status(400).json({ message: "ID người dùng không hợp lệ" });
        }

        // Tìm tất cả đánh giá của người dùng, bỏ qua trạng thái "vi_pham"
        const danhGias = await DanhGia.find({ id_nguoi_dung, trang_thai: { $ne: "vi_pham" } });

        if (!danhGias || danhGias.length === 0) {
            return res.status(404).json({ message: "Người dùng chưa có đánh giá hợp lệ nào" });
        }

        return res.status(200).json({ message: "Lấy đánh giá thành công", danhGias });

    } catch (error) {
        console.error("Lỗi khi lấy đánh giá:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};


//Lấy danh sách đánh giá bị vi phạm (báo cáo)
export const getReportFeedbacks = async (req, res) => {
    try {
        const { id_phim } = req.params;

        // Kiểm tra ID hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_phim)) {
            return res.status(400).json({ message: "ID phim không hợp lệ" });
        }

        // Tìm tất cả đánh giá có trạng thái 'vi_pham' theo id_phim
        const danhGiaList = await DanhGia.find({
            id_phim,
            trang_thai: "vi phạm"
        });

        if (danhGiaList.length === 0) {
            return res.status(404).json({ message: "Không có đánh giá vi phạm nào" });
        }

        return res.status(200).json({ message: "Lấy danh sách đánh giá vi phạm thành công", danhGiaList });

    } catch (error) {
        console.error("Lỗi khi lấy danh sách đánh giá vi phạm:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};
//Cập nhật đánh giá đó bị vi phạm
export const reportFeedbackViolation = async (req, res) => {
    try {
        const { id_phim, id_nguoi_dung } = req.params;

        // Kiểm tra ID hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_phim) || !mongoose.Types.ObjectId.isValid(id_nguoi_dung)) {
            return res.status(400).json({ message: "ID phim hoặc ID người dùng không hợp lệ" });
        }

        // Tìm đánh giá cần báo cáo
        const danhGia = await DanhGia.findOne({ id_phim, id_nguoi_dung });

        if (!danhGia) {
            return res.status(404).json({ message: "Không tìm thấy đánh giá" });
        }

        // Cập nhật trạng thái thành "vi_pham"
        danhGia.trang_thai = "vi phạm";
        await danhGia.save();

        return res.status(200).json({ message: "Bình luận đã được báo cáo vi phạm", danhGia });

    } catch (error) {
        console.error("Lỗi khi báo cáo bình luận vi phạm:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};
