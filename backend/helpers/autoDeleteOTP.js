import OTPModel from '../models/OTPSchema.js';
import TempUser from '../models/TempUserSchema.js';

// Hàm kiểm tra và xoá OTP hết hạn cùng với user trong bảng TempUser
const clearExpiredOtps = async () => {
  try {
    const now = new Date();

    // Tìm các OTP đã hết hạn
    const expiredOtps = await OTPModel.find({ expiresAt: { $lt: now } });

    if (expiredOtps.length === 0) {
      console.log("✅ Không có OTP nào hết hạn.");
      return;
    }

    // Lấy danh sách email từ các OTP hết hạn
    const expiredEmails = expiredOtps.map((otp) => otp.email);

    // Xóa OTP trong bảng OTPModel
    await OTPModel.deleteMany({ email: { $in: expiredEmails } });

    // Xóa user trong bảng TempUser
    const deletedUsers = await TempUser.deleteMany({ email: { $in: expiredEmails } });

    console.log(`🗑 Đã xoá ${expiredOtps.length} OTP và ${deletedUsers.deletedCount} user tạm.`);
  } catch (error) {
    console.error("❌ Lỗi khi xoá OTP và user hết hạn:", error);
  }
};

// Thiết lập khoảng thời gian kiểm tra mỗi 5 phút
setInterval(clearExpiredOtps, 0.5 * 60 * 1000);

console.log("🚀 Hệ thống tự động xoá OTP và user tạm đang chạy...");
