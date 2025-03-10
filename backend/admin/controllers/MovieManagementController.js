import Phim from "../../models/PhimSchema.js";
import LichChieu from "../../models/LichChieuSchema.js";
import PhongChieu from "../../models/PhongChieuSchema.js";
import RapPhim from "../../models/RapPhimSchema.js";
import { v4 as uuidv4 } from 'uuid';


import mongoose from "mongoose";

/* [Movie] */
//Thêm phim mới
export const addNewMovie = async (req, res) => {
    const { ma_phim, ten_phim, id_the_loai, mo_ta, url_poster, url_trailer, thoi_luong, ngay_cong_chieu, danh_gia, ngon_ngu } = req.body;

    try {
        // Kiểm tra phim đã tồn tại qua ma_phim (nếu có)
        if (ma_phim) {
            const existingByMaPhim = await Phim.findOne({ ma_phim });
            if (existingByMaPhim) {
                return res.status(400).json({ message: "Phim đã tồn tại với mã phim này" });
            }
        }

        // Kiểm tra phim đã tồn tại qua tổ hợp thông tin quan trọng
        const existingPhim = await Phim.findOne({
            ten_phim,
            id_the_loai,
            ngay_cong_chieu,
            thoi_luong,
            ngon_ngu
        });

        let phien_ban = 1;
        if (existingPhim) {
            // Nếu phim đã tồn tại, tăng số phiên bản lên 1
            phien_ban = existingPhim.phien_ban + 1;
        }

        // Nếu không có ma_phim, tự động tạo ID duy nhất
        const generatedMaPhim = ma_phim || uuidv4();

        const phim = new Phim({
            ma_phim: generatedMaPhim,
            ten_phim,
            id_the_loai,
            phien_ban,
            mo_ta,
            url_poster,
            url_trailer,
            thoi_luong,
            ngay_cong_chieu,
            danh_gia,
            ngon_ngu
        });

        await phim.save();
        res.status(201).json({ success: true, message: `Thêm phim thành công (Phiên bản ${phien_ban})`, data: phim });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Cập nhật phim
export const updateMovie = async (req, res) => {
    try {
        const { id } = req.params; // Lấy id phim từ URL
        const { ten_phim, id_the_loai, mo_ta, url_poster, url_trailer, thoi_luong, gioi_han_tuoi, ngay_cong_chieu, ngon_ngu } = req.body;

        // Kiểm tra phim có tồn tại không
        const phim = await Phim.findById(id);
        if (!phim) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }

        // Cập nhật thông tin phim nếu có thay đổi
        phim.ten_phim = ten_phim || phim.ten_phim;
        phim.id_the_loai = id_the_loai || phim.id_the_loai;
        phim.mo_ta = mo_ta || phim.mo_ta;
        phim.url_poster = url_poster || phim.url_poster;
        phim.url_trailer = url_trailer || phim.url_trailer;
        phim.thoi_luong = thoi_luong || phim.thoi_luong;
        phim.gioi_han_tuoi = gioi_han_tuoi || phim.gioi_han_tuoi;
        phim.ngay_cong_chieu = ngay_cong_chieu || phim.ngay_cong_chieu;
        phim.ngon_ngu = ngon_ngu || phim.ngon_ngu;

        await phim.save();

        res.status(200).json({ success: true, message: "Cập nhật phim thành công", data: phim });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Xóa Phim
export const deleteMovie = async (req, res) => {
    const { id } = req.params;
    try {
        const deletedPhim = await Phim.findByIdAndDelete(id);
        if (!deletedPhim) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }
        res.status(200).json({ success: true, message: "Xóa phim thành công" });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi xóa phim", error: err.message });
    }
};



/* [Schedule] */
// Lấy lịch chiếu của phim [group-by phòng]
export const getScheduleByRoom = async (req, res) => {
    const { id_phim } = req.params;

    try {
        // Kiểm tra id_phim có hợp lệ không
        if (!mongoose.Types.ObjectId.isValid(id_phim)) {
            return res.status(400).json({ success: false, message: "ID phim không hợp lệ" });
        }

        // Kiểm tra phim có tồn tại không
        const movie = await Phim.findById(id_phim);
        if (!movie) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }

        // Lấy lịch chiếu, nhóm theo phòng chiếu
        const schedules = await LichChieu.aggregate([
            { $match: { id_phim: new mongoose.Types.ObjectId(id_phim) } },
            {
                $lookup: {
                    from: "phongchieus",
                    localField: "id_phong",
                    foreignField: "_id",
                    as: "phong"
                }
            },
            { $unwind: "$phong" },
            {
                $group: {
                    _id: "$id_phong",
                    ten_phong: { $first: "$phong.ten_phong" },
                    lich_chieu: { $push: "$$ROOT" }
                }
            }
        ]);

        res.status(200).json({ success: true, data: schedules });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Lấy lịch chiếu của phim theo phòng riêng biệt
export const getScheduleOfRoom = async (req, res) => {
    const { id_phim, id_phong } = req.params;

    try {
        // Kiểm tra id_phim và id_phong có hợp lệ không
        if (!mongoose.Types.ObjectId.isValid(id_phim) || !mongoose.Types.ObjectId.isValid(id_phong)) {
            return res.status(400).json({ success: false, message: "ID phim hoặc ID phòng không hợp lệ" });
        }

        // Kiểm tra phim có tồn tại không
        const movie = await Phim.findById(id_phim);
        if (!movie) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }

        // Kiểm tra phòng chiếu có tồn tại không
        const room = await PhongChieu.findById(id_phong);
        if (!room) {
            return res.status(404).json({ success: false, message: "Phòng chiếu không tồn tại" });
        }

        // Lấy lịch chiếu theo phòng cụ thể
        const schedules = await LichChieu.find({ id_phim, id_phong });

        res.status(200).json({ success: true, data: schedules });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Tạo lịch chiếu
export const createMovieSchedule = async (req, res) => {
    const { id_phim } = req.params;
    const { id_phong, thoi_gian_chieu, gia_ve, id_rap } = req.body;

    try {
        // Kiểm tra phim tồn tại
        const phim = await Phim.findById(id_phim);
        if (!phim) {
            return res.status(404).json({ success: false, message: "Phim không tồn tại" });
        }

        // Kiểm tra phòng chiếu tồn tại
        const phongChieu = await PhongChieu.findById(id_phong);
        if (!phongChieu) {
            return res.status(404).json({ success: false, message: "Phòng chiếu không tồn tại" });
        }

        const rapPhim = await RapPhim.findById(id_rap);
        if (!rapPhim) {
            return res.status(404).json({ success: false, message: "Rạp phim không tồn tại" });
        }

        // Kiểm tra trùng lịch chiếu (cùng phòng, cùng thời gian)
        const existingSchedule = await LichChieu.findOne({ id_phong, thoi_gian_chieu });
        if (existingSchedule) {
            return res.status(400).json({ success: false, message: "Suất chiếu này đã tồn tại trong phòng" });
        }

        // Tạo lịch chiếu mới
        const newSchedule = new LichChieu({
            id_phim,
            id_phong,
            id_rap,
            thoi_gian_chieu,
            gia_ve
        });

        await newSchedule.save();
        res.status(201).json({ success: true, message: "Tạo lịch chiếu thành công", data: newSchedule });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};
// Cập nhật lịch chiếu
export const updateMovieSchedule = async (req, res) => {
    const { id_phim, id } = req.params; // Lấy ID của lịch chiếu từ URL
    const { id_phong, thoi_gian_chieu, gia_ve } = req.body;

    try {
        // Kiểm tra lịch chiếu có tồn tại không
        const schedule = await LichChieu.findById(id);
        if (!schedule) {
            return res.status(404).json({ success: false, message: "Lịch chiếu không tồn tại" });
        }

        // Kiểm tra phim tồn tại nếu id_phim được cập nhật
        if (id_phim) {
            const phim = await Phim.findById(id_phim);
            if (!phim) {
                return res.status(404).json({ success: false, message: "Phim không tồn tại" });
            }
        }

        // Kiểm tra phòng chiếu tồn tại nếu id_phong được cập nhật
        if (id_phong) {
            const phongChieu = await PhongChieu.findById(id_phong);
            if (!phongChieu) {
                return res.status(404).json({ success: false, message: "Phòng chiếu không tồn tại" });
            }
        }

        // Kiểm tra trùng lịch chiếu nếu thay đổi phòng hoặc thời gian chiếu
        if (id_phong || thoi_gian_chieu) {
            const existingSchedule = await LichChieu.findOne({
                id_phong: id_phong || schedule.id_phong,
                thoi_gian_chieu: thoi_gian_chieu || schedule.thoi_gian_chieu,
                _id: { $ne: id } // Loại trừ lịch chiếu hiện tại để tránh tự trùng
            });

            if (existingSchedule) {
                return res.status(400).json({ success: false, message: "Suất chiếu này đã tồn tại trong phòng" });
            }
        }

        // Cập nhật thông tin lịch chiếu
        const updatedSchedule = await LichChieu.findByIdAndUpdate(
            id,
            { id_phim, id_phong, thoi_gian_chieu, gia_ve },
            { new: true } // Trả về dữ liệu đã cập nhật
        );

        res.status(200).json({ success: true, message: "Cập nhật lịch chiếu thành công", data: updatedSchedule });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};