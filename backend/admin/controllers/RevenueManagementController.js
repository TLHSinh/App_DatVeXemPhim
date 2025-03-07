import DonDatVe from "../../models/DonDatVeSchema.js";

//Lấy tổng doanh thu
export const getRevenue = async (req, res) => {
    try {
        const result = await DonDatVe.aggregate([
            { $match: { trang_thai: "đã xuất vé" } }, // Chỉ lấy đơn đã xuất vé
            {
                $group: {
                    _id: null,
                    tongDoanhThu: { $sum: "$tien_thanh_toan" },
                },
            },
        ]);

        return res.status(200).json({
            tongDoanhThu: result.length > 0 ? result[0].tongDoanhThu : 0,
        });
    } catch (error) {
        return res.status(500).json({ error: "Lỗi khi lấy doanh thu", message: error.message });
    }
};

//Lấy tổng doanh thu theo [phim]
export const getRevenueByMovie = async (req, res) => {
    try {
        const result = await DonDatVe.aggregate([
            // Lọc các đơn đã xuất vé
            { $match: { trang_thai: "đã xuất vé" } },

            // Nối (lookup) với bảng LichChieu để lấy id_phim
            {
                $lookup: {
                    from: "lichchieus", // Tên collection của Lịch Chiếu
                    localField: "id_lich_chieu", // Trường trong DonDatVe
                    foreignField: "_id", // Trường trong LichChieu
                    as: "lichChieu",
                },
            },

            // Giải nén mảng lichChieu thành object
            { $unwind: "$lichChieu" },

            // Nhóm theo id_phim và tính tổng doanh thu
            {
                $group: {
                    _id: "$lichChieu.id_phim", // Nhóm theo ID phim
                    tongDoanhThu: { $sum: "$tien_thanh_toan" }, // Cộng tổng tiền thanh toán
                },
            },

            // Sắp xếp theo doanh thu giảm dần
            { $sort: { tongDoanhThu: -1 } },
        ]);

        return res.status(200).json(result);
    } catch (error) {
        return res.status(500).json({ error: "Lỗi khi lấy doanh thu theo phim", message: error.message });
    }
};

//Lấy tổng doanh thu theo [rạp]
export const getRevenueByCinema = async (req, res) => {
    try {
        const result = await DonDatVe.aggregate([
            // Lọc các đơn đã xuất vé
            { $match: { trang_thai: "đã xuất vé" } },

            // Nối với bảng LichChieu để lấy id_phong
            {
                $lookup: {
                    from: "lichchieus", // Collection Lịch Chiếu
                    localField: "id_lich_chieu",
                    foreignField: "_id",
                    as: "lichChieu",
                },
            },
            { $unwind: "$lichChieu" },

            // Nối với bảng Phong để lấy id_rap
            {
                $lookup: {
                    from: "phongchieus", // Collection Phòng
                    localField: "lichChieu.id_phong",
                    foreignField: "_id",
                    as: "phong",
                },
            },
            { $unwind: "$phong" },

            // Nối với bảng Rap để lấy thông tin rạp
            {
                $lookup: {
                    from: "rapphims", // Collection Rạp
                    localField: "phong.id_rap",
                    foreignField: "_id",
                    as: "rap",
                },
            },
            { $unwind: "$rap" },

            // Nhóm theo rạp và tính tổng doanh thu
            {
                $group: {
                    _id: "$rap._id",
                    ten_rap: { $first: "$rap.ten_rap" },
                    tongDoanhThu: { $sum: "$tien_thanh_toan" },
                },
            },

            // Sắp xếp theo doanh thu giảm dần
            { $sort: { tongDoanhThu: -1 } },
        ]);

        return res.status(200).json(result);
    } catch (error) {
        return res.status(500).json({ error: "Lỗi khi lấy doanh thu theo rạp", message: error.message });
    }
};