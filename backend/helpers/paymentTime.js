import cron from "node-cron";
import DonDatVe from "../models/DonDatVeSchema.js";
import TrangThaiGhe from "../models/TrangThaiGheSchema.js";
import mongoose from "mongoose";
import LichSuHuyVe from "../models/LichSuHuyVeSchema.js";

// Cron job chạy mỗi phút
cron.schedule("* * * * *", async () => {
  console.log("🔍 Đang kiểm tra đơn vé chưa thanh toán...");

  const timeLimit = new Date(Date.now() - 5 * 60 * 1000); // 5 phút trước

  try {
    const donHetHan = await DonDatVe.find({
      trang_thai: "đang chờ",
      createdAt: { $lt: timeLimit }, // Lọc đơn đặt vé quá 5 phút chưa thanh toán
    });

    if (donHetHan.length === 0) {
      console.log("✅ Không có đơn vé nào quá hạn.");
      return;
    }

    console.log(`⚠️ Phát hiện ${donHetHan.length} đơn đặt vé chưa thanh toán, đang xử lý hủy...`);

    const session = await mongoose.startSession();
    session.startTransaction();

    for (const don of donHetHan) {
      // Hủy đơn đặt vé
      await DonDatVe.findByIdAndUpdate(
        don._id,
        { trang_thai: "đã hủy" },
        { session }
      );

      // Lưu vào lịch sử hủy vé
      const lichSuHuy = new LichSuHuyVe({
        id_don: don._id,
        id_nguoi_dung: don.id_nguoi_dung,
        ly_do_huy: "Không thanh toán trong thời gian quy định",
        trang_thai: "đã hủy",
      });

      await lichSuHuy.save({ session });

      // Cập nhật trạng thái ghế thành "có sẵn"
      await TrangThaiGhe.updateMany(
        { id_lich_chieu: don.id_lich_chieu, id_ghe: { $in: don.danh_sach_ghe } },
        { trang_thai: "có sẵn" },
        { session }
      );
    }

    await session.commitTransaction();
    session.endSession();

    console.log(`✅ Đã hủy ${donHetHan.length} đơn đặt vé và lưu vào lịch sử hủy vé.`);

  } catch (error) {
    console.error("❌ Lỗi khi hủy đơn vé quá hạn:", error);
  }
});

