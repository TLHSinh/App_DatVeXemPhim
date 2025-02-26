import Ghe from "../../models/GheSchema.js";
import PhongChieu from "../../models/PhongChieuSchema.js";
import mongoose from "mongoose";


//Lấy toàn bộ ghế của phòng
export const getAllSeats = async (req, res) => {
    const { id_phong } = req.params;

    try {
        // Kiểm tra id_phong có hợp lệ không
        if (!mongoose.Types.ObjectId.isValid(id_phong)) {
            return res.status(400).json({ success: false, message: "ID phòng không hợp lệ" });
        }

        // Kiểm tra phòng chiếu có tồn tại không
        const phongChieu = await PhongChieu.findById(id_phong);
        if (!phongChieu) {
            return res.status(404).json({ success: false, message: "Phòng chiếu không tồn tại" });
        }

        // Lấy danh sách ghế của phòng chiếu
        const seats = await Ghe.find({ id_phong });

        res.status(200).json({ success: true, data: seats });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

export const createSeats = async (req, res) => {
    const { id_phong } = req.params;

    try {
        // Kiểm tra ID phòng hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_phong)) {
            return res.status(400).json({ success: false, message: "ID phòng không hợp lệ" });
        }

        // Kiểm tra phòng chiếu có tồn tại không
        const phongChieu = await PhongChieu.findById(id_phong);
        if (!phongChieu) {
            return res.status(404).json({ success: false, message: "Phòng chiếu không tồn tại" });
        }

        const tong_so_ghe = phongChieu.tong_so_ghe;
        if (!tong_so_ghe || tong_so_ghe <= 0) {
            return res.status(400).json({ success: false, message: "Phòng chiếu không có ghế hợp lệ" });
        }

        // Xóa toàn bộ ghế cũ của phòng trước khi tạo mới
        await Ghe.deleteMany({ id_phong });

        // Xác định số ghế trên mỗi hàng (mặc định 10 ghế/hàng)
        const ghe_moi_hang = 10;
        const so_hang = Math.ceil(tong_so_ghe / ghe_moi_hang); // Số hàng cần thiết
        const seats = [];
        const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; // Dùng cho hàng ghế

        let ghe_tao = 0;
        for (let i = 0; i < so_hang; i++) {
            for (let j = 1; j <= ghe_moi_hang; j++) {
                if (ghe_tao >= tong_so_ghe) break; // Dừng khi đủ số lượng ghế
                seats.push({
                    id_phong,
                    so_ghe: `${alphabet[i]}${j}`, // Ví dụ: A1, A2, B1, B2...
                    trang_thai: "có sẵn"
                });
                ghe_tao++;
            }
        }

        // Lưu danh sách ghế vào database
        await Ghe.insertMany(seats);

        res.status(201).json({ success: true, message: "Tạo ghế thành công", data: seats });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

export const updateStateSeat = async (req, res) => {
    const { id_ghe } = req.params;
    const { trang_thai } = req.body;

    try {
        // Kiểm tra ID ghế hợp lệ
        if (!mongoose.Types.ObjectId.isValid(id_ghe)) {
            return res.status(400).json({ success: false, message: "ID ghế không hợp lệ" });
        }

        // Kiểm tra trạng thái có hợp lệ không
        const validStates = ["có sẵn", "đã đặt trước"];
        if (!validStates.includes(trang_thai)) {
            return res.status(400).json({ success: false, message: "Trạng thái ghế không hợp lệ" });
        }

        // Tìm ghế và cập nhật trạng thái
        const updatedSeat = await Ghe.findByIdAndUpdate(
            id_ghe,
            { trang_thai },
            { new: true } // Trả về ghế đã cập nhật
        );

        if (!updatedSeat) {
            return res.status(404).json({ success: false, message: "Ghế không tồn tại" });
        }

        res.status(200).json({ success: true, message: "Cập nhật trạng thái ghế thành công", data: updatedSeat });
    } catch (err) {
        res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};

export const resetAllSeatsState = async (req, res) => {
    const { id_phong } = req.params;

    try {
        if (!mongoose.Types.ObjectId.isValid(id_phong)) {
            return res.status(400).json({ success: false, message: "ID phòng không hợp lệ" });
        }

        // Lấy danh sách ghế trong phòng
        const seats = await Ghe.find({ id_phong });

        if (seats.length === 0) {
            return res.status(404).json({ success: false, message: "Không có ghế nào trong phòng này" });
        }

        // Reset trạng thái ghế
        await Ghe.updateMany({ id_phong }, { $set: { trang_thai: "có sẵn" } });

        return res.status(200).json({ success: true, message: "Reset trạng thái ghế thành công" });
    } catch (err) {
        return res.status(500).json({ success: false, message: "Lỗi server", error: err.message });
    }
};



