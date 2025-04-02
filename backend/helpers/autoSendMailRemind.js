import mongoose from "mongoose";
import DonDatVe from "../models/DonDatVeSchema.js";
import { sendMail } from "./sendMail.js";
import cron from "node-cron";

// Hàm định dạng ngày tháng
const formatDate = (date, includeDayOfWeek = false) => {
  if (!date) return "Chưa xác định";
  
  const options = { 
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric'
  };
  
  if (includeDayOfWeek) {
    options.weekday = 'long';
  }
  
  return new Intl.DateTimeFormat('vi-VN', options).format(new Date(date));
};

// Hàm định dạng giờ
const formatTime = (date) => {
  if (!date) return "Chưa xác định";
  return new Intl.DateTimeFormat('vi-VN', { 
    hour: '2-digit', 
    minute: '2-digit'
  }).format(new Date(date));
};

// Hàm định dạng tiền tệ
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('vi-VN', { 
    style: 'currency', 
    currency: 'VND' 
  }).format(amount || 0);
};

// Hàm kiểm tra và gửi email nhắc nhở
const sendReminders = async () => {
  try {
    const now = new Date();
    const next24h = new Date(now.getTime() + 24 * 60 * 60 * 1000); // Thời gian 24 giờ sau

    // Lọc vé cần nhắc nhở
    const veCanNhacNho = await DonDatVe.find({
      trang_thai: "đã thanh toán",
      nhac_nho: true,
      da_gui_nhac_nho: false, // Chỉ lấy vé chưa gửi nhắc nhở
    })
      .populate("id_nguoi_dung", "hoTen email")
      .populate({
        path: "id_lich_chieu",
        match: { thoi_gian_chieu: { $gte: now, $lte: next24h } },
        populate: [
          { path: "id_phim", select: "ten_phim thoi_luong url_poster" },
          { path: "id_phong", select: "ten_phong" },
          { path: "id_rap", select: "ten_rap" },
        ],
      })
      .populate({
        path: "danh_sach_ghe",
        select: "so_ghe",
      })
      .populate({
        path: "danh_sach_do_an",
        select: "ten_do_an so_luong",
      })
      .lean();

    // Gửi email cho từng người dùng có vé hợp lệ
    for (const ve of veCanNhacNho) {
      if (!ve.id_lich_chieu) continue; // Bỏ qua nếu không có lịch chiếu hợp lệ

      const id_don_dat_ve = ve._id; // ID đơn đặt vé

      console.log("không lấy đc id",id_don_dat_ve)
      const { hoTen: tenNguoiDung, email } = ve.id_nguoi_dung;
      const { ten_phim, thoi_luong, url_poster } = ve.id_lich_chieu.id_phim;
      const { ten_rap } = ve.id_lich_chieu.id_rap;
      const { ten_phong } = ve.id_lich_chieu.id_phong;
      const thoiGianChieu = new Date(ve.id_lich_chieu.thoi_gian_chieu);
      const danhSachGhe = ve.danh_sach_ghe.map((ghe) => ghe.so_ghe).join(", ");
      
      // Tính giờ kết thúc
      const gioChieu = thoiGianChieu.getHours();
      const phutChieu = thoiGianChieu.getMinutes();
      const tongPhut = gioChieu * 60 + phutChieu + (thoi_luong || 120);
      const gioKetThuc = Math.floor(tongPhut / 60) % 24;
      const phutKetThuc = tongPhut % 60;
      const gioChieuFormatted = `${String(gioChieu).padStart(2, '0')}:${String(phutChieu).padStart(2, '0')}`;
      const gioKetThucFormatted = `${String(gioKetThuc).padStart(2, '0')}:${String(phutKetThuc).padStart(2, '0')}`;
      
      // Xử lý đồ ăn
      const danhSachDoAn = ve.danh_sach_do_an.length > 0
        ? ve.danh_sach_do_an.map(item => `${item.ten_do_an} (x${item.so_luong})`).join(", ")
        : "Không có đồ ăn";

      // Xử lý URL poster
      const posterUrl = url_poster 
        ? `https://rapchieuphim.com${url_poster}` 
        : "https://rapchieuphim.com/images/default-poster.jpg";

      const subject = `🎬 Nhắc nhở xem phim: ${ten_phim} - ${formatDate(thoiGianChieu)}`;
      
      // Văn bản thông thường
      const text = `
        Chào ${tenNguoiDung},
        
        Nhắc nhở: Bạn có vé xem phim vào ngày mai!
        
        THÔNG TIN VÉ:
        - Phim: ${ten_phim}
        - Rạp: ${ten_rap} - ${ten_phong}
        - Ngày chiếu: ${formatDate(thoiGianChieu)}
        - Giờ chiếu: ${gioChieuFormatted} - ${gioKetThucFormatted}
        - Ghế: ${danhSachGhe}
        - Đồ ăn: ${danhSachDoAn}
        
        Vui lòng đến trước giờ chiếu 15-20 phút để không bỏ lỡ phim.
        Xuất trình mã QR khi vào rạp chiếu phim.
        Vé đã mua không được đổi hoặc trả lại.
        
        Hẹn gặp bạn tại rạp!
        Rapchieuphim.com
      `;
      
      // HTML nâng cao dựa trên thiết kế của DetailsTicketScreen
      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Nhắc nhở xem phim: ${ten_phim}</title>
          <style>
            body {
              font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
              line-height: 1.6;
              color: #1F2937;
              background-color: #F9FAFB;
              margin: 0;
              padding: 0;
            }
            .container {
              max-width: 600px;
              margin: 0 auto;
              background-color: #FFFFFF;
              border-radius: 16px;
              overflow: hidden;
              box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            }
            .header {
              background-color: #EE0033;
              color: white;
              padding: 20px;
              text-align: center;
            }
            .content {
              padding: 20px;
              color:rgb(0, 0, 0);
              font-weight: bold;
            }
            .movie-banner {
              background-color: white;
              border-radius: 12px;
              padding: 24px;
              text-align: center;
              margin-bottom: 20px;
              box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            }
            .movie-poster {
              width: 160px;
              height: 220px;
              object-fit: cover;
              border-radius: 12px;
              box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
            }
            .movie-title {
              font-size: 22px;
              font-weight: bold;
              margin: 16px 0 8px;
              color: #111827;
            }
            .movieid-title {
              font-size: 15px;
              font-weight: bold;
              margin: 16px 0 8px;
              color: #111827;
            }
            .status-badge {
              display: inline-block;
              background-color: #DCFCE7;
              color: #047857;
              padding: 6px 12px;
              border-radius: 20px;
              font-weight: bold;
              font-size: 13px;
              margin-top: 12px;
            }
            .info-section {
              background-color: white;
              border-radius: 12px;
              padding: 20px;
              margin-bottom: 16px;
              box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            }
            .section-title {
              display: flex;
              align-items: center;
              margin-bottom: 12px;
              color: #1F2937;
              font-size: 18px;
              font-weight: bold;
            }
            .section-title img {
              width: 20px;
              height: 20px;
              margin-right: 8px;
            }
            .info-row {
              display: flex;
              margin-bottom: 12px;
            }
            .info-icon {
              width: 32px;
              height: 32px;
              border-radius: 8px;
              display: flex;
              align-items: center;
              justify-content: center;
              margin-right: 12px;
              flex-shrink: 0;
            }
            .info-content {
              flex-grow: 1;
            }
            .info-label {
              color: #6B7280;
              font-size: 14px;
              margin-bottom: 4px;
            }
            .info-value {
              color: #1F2937;
              font-size: 15px;
              font-weight: 600;
            }
            .notes {
              background-color: #FEF3C7;
              border: 1px solid #FCD34D;
              border-radius: 12px;
              padding: 16px;
              margin-bottom: 20px;
            }
            .notes-title {
              display: flex;
              align-items: center;
              font-weight: bold;
              color: #92400E;
              margin-bottom: 12px;
            }
            .note-item {
              display: flex;
              margin-bottom: 8px;
            }
            .note-dot {
              color: #D97706;
              margin-right: 8px;
            }
            .footer {
              text-align: center;
              padding: 16px;
              background-color: #F3F4F6;
              font-size: 13px;
              color: #6B7280;
            }
            .qr-note {
              text-align: center;
              font-size: 14px;
              color: #6B7280;
              margin: 12px 0;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1 style="margin: 0;">Nhắc Nhở Xem Phim</h1>
            </div>
            
            <div class="content">
              <p>Chào <strong>${tenNguoiDung}</strong>,</p>
              <p>Bạn có một suất chiếu phim sắp tới vào ${formatDate(thoiGianChieu, true)}. Dưới đây là thông tin vé của bạn:</p>
              
              <!-- Thông tin phim -->
              <div class="movie-banner">
                <img src="${posterUrl}" alt="${ten_phim}" class="movie-poster">
                <h2 class="movie-title">${ten_phim.toUpperCase()}</h2>
                <h6 class="movieid-title">${id_don_dat_ve.toString()}</h6>


                <div class="status-badge">Đã thanh toán</div>
              </div>
              
              <!-- Chi tiết vé -->
              <div class="info-section">
                <div class="section-title">
                  <span style="font-size: 22px; margin-right: 8px;">🎟️</span> Chi tiết vé
                </div>
                <hr style="border: 0; border-top: 1px solid #E5E7EB; margin: 12px 0;">
                
                <!-- Rạp và phòng -->
                <div class="info-row">
                  <div class="info-icon">
                    <span style="font-size: 18px;">🍿</span>
                  </div>
                  <div class="info-content">
                    <div class="info-label">Tại:</div>
                    <div class="info-value">${ten_rap} - ${ten_phong}</div>
                  </div>
                </div>
                
                <!-- Ngày chiếu -->
                <div class="info-row">
                  <div class="info-icon">
                    <span style="font-size: 18px;">📅</span>
                  </div>
                  <div class="info-content">
                    <div class="info-label">Ngày chiếu:</div>
                    <div class="info-value">${formatDate(thoiGianChieu, true)}</div>
                  </div>
                </div>
                
                <!-- Giờ chiếu -->
                <div class="info-row">
                  <div class="info-icon">
                    <span style="font-size: 18px;">⏰</span>
                  </div>
                  <div class="info-content">
                    <div class="info-label">Suất chiếu:</div>
                    <div class="info-value">${gioChieuFormatted} - ${gioKetThucFormatted}</div>
                  </div>
                </div>
                
                <!-- Ghế -->
                <div class="info-row">
                  <div class="info-icon">
                    <span style="font-size: 18px;">💺</span>
                  </div>
                  <div class="info-content">
                    <div class="info-label">Ghế:</div>
                    <div class="info-value">${danhSachGhe}</div>
                  </div>
                </div>
                
                ${ve.danh_sach_do_an.length > 0 ? `
                <!-- Đồ ăn -->
                <div class="info-row">
                  <div class="info-icon">
                    <span style="font-size: 18px;">🍕</span>
                  </div>
                  <div class="info-content">
                    <div class="info-label">Combo:</div>
                    <div class="info-value">${danhSachDoAn}</div>
                  </div>
                </div>
                ` : ''}
              </div>
              
              <div class="qr-note">
                <strong>🎟️ Vui lòng xuất trình mã QR hoặc ID vé khi đến rạp</strong>
              </div>
              
              <!-- Lưu ý -->
              <div class="notes">
                <div class="notes-title">
                  <span style="margin-right: 8px;">ℹ️</span> Lưu ý quan trọng:
                </div>
                
                <div class="note-item">
                  <div class="note-dot">▶</div>
                  <div>Vui lòng đến trước giờ chiếu 15-20 phút để không bỏ lỡ phim</div>
                </div>
                
                <div class="note-item">
                  <div class="note-dot">▶</div>
                  <div>Vé đã mua không được đổi hoặc trả lại</div>
                </div>
                
                <div class="note-item">
                  <div class="note-dot">▶</div>
                  <div>Xuất trình mã QR khi vào rạp chiếu phim</div>
                </div>
              </div>
            </div>
            
            <div class="footer">
              <p>© ${new Date().getFullYear()} Rapchieuphim.com - Hệ thống đặt vé xem phim trực tuyến</p>
              <p>Email này được gửi tự động, vui lòng không trả lời.</p>
            </div>
          </div>
        </body>
        </html>
      `;

      await sendMail(email, subject, text, html);
      console.log(`✅ Đã gửi email nhắc nhở cho ${email} - ${ten_phim}`);
      
      // Cập nhật trạng thái đã gửi nhắc nhở
      await DonDatVe.findByIdAndUpdate(ve._id, { da_gui_nhac_nho: true });
    }
    
    console.log(`✅ Đã xử lý ${veCanNhacNho.length} email nhắc nhở`);
  } catch (error) {
    console.error("❌ Lỗi khi gửi email nhắc nhở:", error);
  }
};

// Thiết lập cron job chạy mỗi giờ
cron.schedule("* * * * *", () => {
  console.log("🔄 Đang kiểm tra vé để gửi nhắc nhở...", new Date());
  sendReminders();
});

export default sendReminders;