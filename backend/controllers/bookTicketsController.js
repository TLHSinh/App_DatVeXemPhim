import LichChieu from "../models/LichChieuSchema.js";
import Ghe from "../models/GheSchema.js";
import TrangThaiGhe from "../models/TrangThaiGheSchema.js";
import DonDatVe from "../models/DonDatVeSchema.js";
import Voucher from "../models/VoucherSchema.js";
import RapPhim from "../models/VoucherSchema.js";
import DoAn from "../models/DoAnSchema.js";


import mongoose from "mongoose";


// Lấy danh sách tất cả lịch chiếu của một phim
export const getLichChieu = async (req, res) => {
  try {
    const { idPhim } = req.params;

    if (!mongoose.Types.ObjectId.isValid(idPhim)) {
      return res.status(400).json({ message: "ID phim không hợp lệ!" });
    }

    const lichChieuList = await LichChieu.find({ id_phim: idPhim })
      .populate("id_phim", ["ten_phim", "url_poster"])
      .populate("id_phong", "ten_phong")
      .populate("id_rap", "ten_rap")
      .sort({ thoi_gian_chieu: 1 });

    if (lichChieuList.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy lịch chiếu cho phim này!" });
    }

    res.status(200).json({ message: "Lấy danh sách lịch chiếu thành công!", lich_chieu: lichChieuList });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};


// Lấy danh sách tất cả lịch chiếu của một phim theo ngày
export const getLichChieuTheoNgay = async (req, res) => {
  try {
    const { idPhim } = req.params;
    const { ngay } = req.body;

    if (!mongoose.Types.ObjectId.isValid(idPhim)) {
      return res.status(400).json({ message: "ID phim không hợp lệ!" });
    }

    const startOfDay = new Date(ngay);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(ngay);
    endOfDay.setHours(23, 59, 59, 999);

    const lichChieuList = await LichChieu.find({
      id_phim: idPhim,
      thoi_gian_chieu: { $gte: startOfDay, $lte: endOfDay }
    })
      .populate("id_phim", ["ten_phim", "url_poster", "thoi_luong", "gioi_han_tuoi", "ngay_cong_chieu"])
      .populate("id_phong", "ten_phong")
      .sort({ thoi_gian_chieu: 1 });

    if (lichChieuList.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy lịch chiếu cho phim này vào ngày đã chọn!" });
    }

    res.status(200).json({ message: "Lấy danh sách lịch chiếu thành công!", lich_chieu: lichChieuList });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};


// Lấy danh sách tất cả lịch chiếu của một phim theo rạp
export const getLichChieuTheoRap = async (req, res) => {
  try {
    const { idPhim } = req.params;
    const { idRap } = req.body;

    if (!mongoose.Types.ObjectId.isValid(idPhim) || !mongoose.Types.ObjectId.isValid(idRap)) {
      return res.status(400).json({ message: "ID phim hoặc ID rạp không hợp lệ!" });
    }

    const lichChieuList = await LichChieu.find({
      id_phim: idPhim,
      id_rap: idRap
    })
      .populate("id_phim", ["ten_phim", "url_poster", "thoi_luong", "gioi_han_tuoi", "ngay_cong_chieu"])
      .populate("id_phong", "ten_phong")
      .populate("id_rap", "ten_rap")
      .sort({ thoi_gian_chieu: 1 });

    if (lichChieuList.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy lịch chiếu cho phim này tại rạp đã chọn!" });
    }

    res.status(200).json({ message: "Lấy danh sách lịch chiếu thành công!", lich_chieu: lichChieuList });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};

export const getAllLichChieuTheoRap = async (req, res) => {
  try {
    const { idRap } = req.params;
    //const { idRap } = req.body;

    if (!mongoose.Types.ObjectId.isValid(idRap)) {
      return res.status(400).json({ message: " D rạp không hợp lệ!" });
    }

    const lichChieuList = await LichChieu.find({
      id_rap: idRap
    })
      .populate("id_phim", ["ten_phim", "url_poster", "thoi_luong", "gioi_han_tuoi", "ngay_cong_chieu"])
      .populate("id_phong", "ten_phong")
      .populate("id_rap", "ten_rap")
      .sort({ thoi_gian_chieu: 1 });

    if (lichChieuList.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy lịch chiếu cho phim này tại rạp đã chọn!" });
    }

    res.status(200).json({ message: "Lấy danh sách lịch chiếu thành công!", lich_chieu: lichChieuList });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};


export const datGhe = async (req, res) => {
  try {
    const { idLichChieu, danhSachGhe } = req.body; // danhSachGhe là mảng chứa các id ghế

    if (!Array.isArray(danhSachGhe) || danhSachGhe.length === 0) {
      return res.status(400).json({ message: "Danh sách ghế không hợp lệ!" });
    }

    // Kiểm tra xem có ghế nào đã bị đặt trước không
    const gheDaDat = await TrangThaiGhe.find({
      id_lich_chieu: idLichChieu,
      id_ghe: { $in: danhSachGhe },
      trang_thai: "đã đặt trước",
    });

    if (gheDaDat.length > 0) {
      return res.status(400).json({
        message: "Một hoặc nhiều ghế đã bị đặt trước!",
        ghe_da_dat: gheDaDat.map(ghe => ghe.id_ghe),
      });
    }

    // Cập nhật trạng thái của tất cả các ghế được chọn
    const updates = danhSachGhe.map(idGhe => ({
      updateOne: {
        filter: { id_lich_chieu: idLichChieu, id_ghe: idGhe },
        update: { trang_thai: "đã đặt trước" },
        upsert: true, // Nếu chưa có, tạo mới
      },
    }));

    await TrangThaiGhe.bulkWrite(updates);

    res.status(200).json({ message: "Đặt ghế thành công!", danh_sach_ghe: danhSachGhe });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};


// export const xacNhanDatVe = async (req, res) => {
//   const session = await mongoose.startSession();
//   session.startTransaction();

//   try {
//     const { idNguoiDung, idLichChieu, danhSachGhe, idVoucher  } = req.body;

//     if (!Array.isArray(danhSachGhe) || danhSachGhe.length === 0) {
//       return res.status(400).json({ message: "Danh sách ghế không hợp lệ!" });
//     }

//     const lichChieu = await LichChieu.findById(idLichChieu);
//     if (!lichChieu) {
//       return res.status(404).json({ message: "Suất chiếu không tồn tại!" });
//     }

//     // Kiểm tra ghế đã bị đặt trước chưa
//     const gheDaDat = await TrangThaiGhe.find({
//       id_lich_chieu: idLichChieu,
//       id_ghe: { $in: danhSachGhe },
//       trang_thai: "đã đặt",
//     });

//     if (gheDaDat.length > 0) {
//       return res.status(400).json({
//         message: "Một hoặc nhiều ghế đã bị đặt trước!",
//         ghe_da_dat: gheDaDat.map(ghe => ghe.id_ghe),
//       });
//     }

//     // Tính tiền
//     const giaVe = lichChieu.gia_ve;
//     let tongTien = giaVe * danhSachGhe.length;
//     let tienGiam = 0;
//     let tienThanhToan = tongTien;

//     if (idVoucher) {
//       const voucher = await Voucher.findById(idVoucher);
//       if (voucher && voucher.gia_tri_giam) {
//         tienGiam = Math.min(voucher.gia_tri_giam, tongTien);
//         tienThanhToan = tongTien - tienGiam;
//       }
//     }

//     // Tạo đơn đặt vé với danh sách ghế
//     const donDatVe = new DonDatVe({
//       id_nguoi_dung: idNguoiDung,
//       id_lich_chieu: idLichChieu,
//       danh_sach_ghe: danhSachGhe, // Lưu danh sách ghế
//       id_voucher: idVoucher || null,
//       gia_tri_giam_ap_dung: idVoucher ? tienGiam : 0,
//       tong_tien: tongTien,
//       tien_giam: tienGiam,
//       tien_thanh_toan: tienThanhToan,
//       trang_thai: "đang chờ",
//     });

//     const donDatVeSaved = await donDatVe.save({ session });

//     // Cập nhật trạng thái ghế thành "đã đặt trước"
//     const updates = danhSachGhe.map(idGhe => ({
//       updateOne: {
//         filter: { id_lich_chieu: idLichChieu, id_ghe: idGhe },
//         update: { trang_thai: "đã đặt" },
//         upsert: true,
//       },
//     }));

//     await TrangThaiGhe.bulkWrite(updates, { session });

//     await session.commitTransaction();
//     session.endSession();

//     res.status(200).json({ message: "Đặt vé thành công!", donDatVe: donDatVeSaved });
//   } catch (error) {
//     await session.abortTransaction();
//     session.endSession();
//     res.status(500).json({ message: "Lỗi server!", error: error.message });
//   }
// };



export const xacNhanDatVe = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { idNguoiDung, idLichChieu, danhSachGhe, danhSachDoAn, idVoucher, idNhanVien } = req.body;

    if (!Array.isArray(danhSachGhe) || danhSachGhe.length === 0) {
      return res.status(400).json({ message: "Danh sách ghế không hợp lệ!" });
    }

    const lichChieu = await LichChieu.findById(idLichChieu);
    if (!lichChieu) {
      return res.status(404).json({ message: "Suất chiếu không tồn tại!" });
    }

    // Kiểm tra ghế đã bị đặt trước chưa
    const gheDaDat = await TrangThaiGhe.find({
      id_lich_chieu: idLichChieu,
      id_ghe: { $in: danhSachGhe },
      trang_thai: "đã đặt",
    });

    if (gheDaDat.length > 0) {
      return res.status(400).json({
        message: "Một hoặc nhiều ghế đã bị đặt trước!",
        ghe_da_dat: gheDaDat.map(ghe => ghe.id_ghe),
      });
    }

    // Tính tổng tiền
    const giaVe = lichChieu.gia_ve;
    let tongTien = giaVe * danhSachGhe.length;
    let tienGiam = 0;
    let tienThanhToan = tongTien;

    if (idVoucher) {
      const voucher = await Voucher.findById(idVoucher);
      if (voucher && voucher.gia_tri_giam) {
        tienGiam = Math.min(voucher.gia_tri_giam, tongTien);
        tienThanhToan = tongTien - tienGiam;
      }
    }

    // Nếu có danh sách đồ ăn, tính thêm tiền
    if (Array.isArray(danhSachDoAn) && danhSachDoAn.length > 0) {
      const doAnList = await DoAn.find({ _id: { $in: danhSachDoAn } });
      const tongTienDoAn = doAnList.reduce((sum, item) => sum + item.gia, 0);
      tongTien += tongTienDoAn;
      tienThanhToan += tongTienDoAn;
    }

    // Tạo đơn đặt vé
    const donDatVe = new DonDatVe({
      id_nguoi_dung: idNguoiDung,
      id_lich_chieu: idLichChieu,
      danh_sach_ghe: danhSachGhe,
      danh_sach_do_an: danhSachDoAn || [],
      id_voucher: idVoucher || null,
      gia_tri_giam_ap_dung: idVoucher ? tienGiam : 0,
      tong_tien: tongTien,
      tien_giam: tienGiam,
      tien_thanh_toan: tienThanhToan,
      trang_thai: "đang chờ",
      nhanVienXuatVeGiay: idNhanVien || null,
    });

    const donDatVeSaved = await donDatVe.save({ session });

    // Cập nhật trạng thái ghế thành "đã đặt"
    const updates = danhSachGhe.map(idGhe => ({
      updateOne: {
        filter: { id_lich_chieu: idLichChieu, id_ghe: idGhe },
        update: { trang_thai: "đã đặt" },
        upsert: true,
      },
    }));

    await TrangThaiGhe.bulkWrite(updates, { session });

    await session.commitTransaction();
    session.endSession();

    res.status(200).json({ message: "Đặt vé thành công!", idDonDatVe: donDatVeSaved._id, donDatVe: donDatVeSaved });
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};


export const thanhToan = async (req, res) => {
  try {
    const { idDonDatVe } = req.body;

    // Kiểm tra đơn đặt vé có tồn tại không
    const donDatVe = await DonDatVe.findById(idDonDatVe);
    if (!donDatVe) {
      return res.status(404).json({ message: "Đơn đặt vé không tồn tại!" });
    }

    // Kiểm tra trạng thái đơn đặt vé
    if (donDatVe.trang_thai === "đã thanh toán") {
      return res.status(400).json({ message: "Đơn này đã được thanh toán!" });
    }

    if (donDatVe.trang_thai === "đã hủy") {
      return res.status(400).json({ message: "Đơn này đã bị hủy do quá thời gian thanh toán!" });
    }

    // Cập nhật trạng thái đơn đặt vé thành "đã xác nhận"
    await DonDatVe.findByIdAndUpdate(idDonDatVe, { trang_thai: "đã thanh toán" });

    res.status(200).json({ message: "Thanh toán thành công! Vé của bạn đã được thanh toán." });

  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};



export const layDonDatVe = async (req, res) => {
  try {
    const { idDonDatVe } = req.params;

    const donDatVe = await DonDatVe.findById(idDonDatVe)
      .populate("id_nguoi_dung", "ten email")
      .populate("id_lich_chieu")
      .populate("danh_sach_ghe"); // Lấy luôn danh sách ghế

    if (!donDatVe) {
      return res.status(404).json({ message: "Đơn đặt vé không tồn tại!" });
    }

    res.status(200).json(donDatVe);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};




