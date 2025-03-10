import mongoose from "mongoose";
import RapPhim from "../../models/RapPhimSchema.js";
import PhongChieu from "../../models/PhongChieuSchema.js";
import { v4 as uuidv4 } from 'uuid';

/* [Cinema/Theater] */
// Lấy danh sách các rạp
export const getAllCinemas = async (req, res) => {
    try {
        const cinemas = await RapPhim.find().sort({ ten_rap: 1 }); // Sắp xếp theo tên rạp
        res.status(200).json({ success: true, data: cinemas });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Thêm rạp mới
export const addCinema = async (req, res) => {
    const { ma_rap, ten_rap, dia_chi, so_dien_thoai } = req.body;

    try {
        // Kiểm tra rạp đã tồn tại chưa
        const existingCinema = await RapPhim.findOne({ ten_rap, dia_chi });
        if (existingCinema) {
            return res.status(400).json({ success: false, message: "Rạp phim này đã tồn tại" });
        }

        // Tạo mã rạp ngẫu nhiên nếu không có
        const generatedMaRap = ma_rap || uuidv4();

        // Tạo rạp mới
        const rapphim = new RapPhim({
            ma_rap: generatedMaRap,
            ten_rap,
            dia_chi,
            so_dien_thoai
        });

        await rapphim.save();
        res.status(201).json({ success: true, message: "Thêm rạp phim thành công", data: rapphim });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Cập nhật thông tin rạp
export const updateCinema = async (req, res) => {
    const { id } = req.params;
    const { ten_rap, dia_chi, so_dien_thoai } = req.body;

    try {
        // Tìm và cập nhật rạp phim
        const updatedCinema = await RapPhim.findByIdAndUpdate(
            id,
            { ten_rap, dia_chi, so_dien_thoai },
            { new: true, runValidators: true } // Trả về dữ liệu mới sau khi cập nhật
        );

        // Nếu không tìm thấy rạp
        if (!updatedCinema) {
            return res.status(404).json({ success: false, message: "Không tìm thấy rạp phim" });
        }

        res.status(200).json({ success: true, message: "Cập nhật rạp phim thành công", data: updatedCinema });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};



/* [Room] */
// Lấy danh sách phòng chiếu củ rạp [...]
export const getAllRooms = async (req, res) => {
    const { id_rap } = req.params; // Lấy id_rap từ params

    try {
        const rooms = await PhongChieu.find({ id_rap }).populate("id_rap", "ten_rap");

        res.status(200).json({ success: true, data: rooms });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Thêm phòng chiếu
export const addRoom = async (req, res) => {
    const { id_rap } = req.params; // Chỉ yêu cầu id_rap
    const { tong_so_ghe } = req.body;

    try {
        // Kiểm tra id_rap có hợp lệ không
        if (!mongoose.Types.ObjectId.isValid(id_rap)) {
            return res.status(400).json({ success: false, message: "ID rạp không hợp lệ" });
        }

        // Kiểm tra xem rạp phim có tồn tại không
        const existingCinema = await RapPhim.findById(id_rap);
        if (!existingCinema) {
            return res.status(404).json({ success: false, message: "Rạp phim không tồn tại" });
        }

        // Thêm một phòng chiếu mới (tạo tên phòng tự động)
        const roomCount = await PhongChieu.countDocuments({ id_rap });
        const phongchieu = new PhongChieu({
            id_rap: id_rap,
            ten_phong: `Phòng ${roomCount + 1}`, // Tạo tên phòng tự động
            tong_so_ghe
        });
        await phongchieu.save();

        // Lấy danh sách tất cả phòng chiếu của rạp sau khi thêm
        // const allRooms = await PhongChieu.find({ id_rap });

        res.status(201).json({
            success: true,
            message: "Thêm phòng chiếu thành công",
            data: phongchieu
        });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Cập nhật phòng chiếu
export const updateRoom = async (req, res) => {
    const { id_rap, id } = req.params;
    const { ten_phong, tong_so_ghe } = req.body;

    try {
        // Kiểm tra xem rạp phim có tồn tại không
        const existingCinema = await RapPhim.findById(id_rap);
        if (!existingCinema) {
            return res.status(404).json({ success: false, message: "Rạp phim không tồn tại" });
        }

        const updatedRoom = await PhongChieu.findByIdAndUpdate(
            id,
            { ten_phong, tong_so_ghe },
            { new: true, runValidators: true }
        );

        if (!updatedRoom) {
            return res.status(404).json({ success: false, message: "Không tìm thấy phòng chiếu" });
        }

        res.status(200).json({ success: true, message: "Cập nhật phòng chiếu thành công", data: updatedRoom });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};