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
// Tạo ghế cho phòng
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
// Cập nhật trạng thái ghê [có sẵn <-> đã đặt trước]
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
// Reset tất cả trạng thái ghê về [có sẵn] khi chiếu phim xong
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

export const updateSeatStatus = async (req, res, next) => {
    try {
      const { id_phong, id_ghe } = req.params;
      const { trang_thai } = req.body;
  
      // Kiểm tra id_phong có tồn tại không
      const room = await PhongChieu.findById(id_phong);
      if (!room) {
        return res.status(404).json({ status: "error", message: "Không tìm thấy phòng với ID này" });
      }
  
      // Kiểm tra trạng thái hợp lệ
      const validStatuses = ["có sẵn", "đã đặt trước", "hư hỏng", "bảo trì"];
      if (!validStatuses.includes(trang_thai)) {
        return res.status(400).json({ status: "error", message: "Trạng thái không hợp lệ" });
      }
  
      // Xử lý cập nhật nhiều ghế
      const seatIds = id_ghe.split(",").map((id) => id.trim());
  
      // Kiểm tra tất cả ID ghế có hợp lệ không
      for (const id of seatIds) {
        if (!mongoose.Types.ObjectId.isValid(id)) {
          return res.status(400).json({ status: "error", message: `ID ghế không hợp lệ: ${id}` });
        }
      }
  
      // Cập nhật trạng thái cho tất cả ghế có ID trong danh sách và thuộc phòng cụ thể
      const result = await Ghe.updateMany(
        {
          _id: { $in: seatIds },
          id_phong: id_phong,
        },
        {
          $set: {
            trang_thai,
            updatedAt: Date.now(),
          },
        }
      );
  
      if (result.matchedCount === 0) {
        return res.status(404).json({ status: "error", message: "Không tìm thấy ghế nào phù hợp để cập nhật" });
      }
  
      res.status(200).json({
        status: "success",
        data: {
          updatedCount: result.modifiedCount,
          message: `Đã cập nhật ${result.modifiedCount} ghế thành "${trang_thai}"`,
        },
      });
    } catch (error) {
        
      console.error("Lỗi cập nhật trạng thái ghế:", error);
      res.status(500).json({ status: "error", message: "Lỗi server, vui lòng thử lại sau." });
    }
  };
  



