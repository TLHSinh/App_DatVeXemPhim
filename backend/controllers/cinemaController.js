import axios from "axios";
// import CinemaModel from "../cinema/cinema.js";
import RapPhim from "../models/RapPhimSchema.js";

//Hàm fetch và lưu rạp phim vào MongoDB
export const fetchAndSaveCinemas = async (req, res) => {
    try {
        const response = await axios.get(process.env.API_CINEMA);
        let rapchieuphims = response.data;

        const filteredCinemas = rapchieuphims.filter(cinema =>
            cinema.name && cinema.name.toUpperCase().includes("CGV")
        );

        for (const rapchieuphim of filteredCinemas) {
            await RapPhim.updateOne(
                { ma_rap: rapchieuphim.id },
                {
                    $set: {
                        ten_rap: rapchieuphim.name,
                        dia_chi: rapchieuphim.address,
                        so_dien_thoai: rapchieuphim.phone,
                        anh: rapchieuphim.image
                    }
                },
                { upsert: true }
            );
        }

        res.json({ message: "Cinemas successfully saved to MongoDB!" });
    } catch (error) {
        console.error('Error fetching or saving cinemas:', error);
        res.status(500).json({ message: 'Error fetching or saving cinemas' });
    }
}

//Hàm lấy danh sách rạp phim từ MongoDB
export const getAllCinemas = async (req, res) => {
    try {
        const rapphims = await RapPhim.find();
        res.json(rapphims);
        // const movies = await MovieModel.find();
        // res.json(movies);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving movies' });
    }
};

export const getAllSeatCinemas = async (req, res) => {
    try {
        const { id_rap } = req.params;
        
        // Kiểm tra xem id_rap có hợp lệ không
        if (!mongoose.Types.ObjectId.isValid(id_rap)) {
          return res.status(400).json({ message: "ID rạp không hợp lệ" });
        }
    
        // Lấy danh sách phòng chiếu của rạp
        const phongChieus = await PhongChieu.find({ id_rap });
        if (!phongChieus.length) {
          return res.status(404).json({ message: "Không tìm thấy phòng chiếu trong rạp này" });
        }
    
        // Lấy danh sách ghế từ các phòng chiếu
        const danhSachGhe = await Ghe.find({ 
          id_phong: { $in: phongChieus.map(pc => pc._id) }
        });
    
        res.status(200).json({ danhSachGhe });
      } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Lỗi server" });
      }
    }





/**
 * API lấy danh sách rạp phim gần nhất theo tọa độ GPS
 */
export const timRapPhimGan = async (req, res) => {
  try {
    const { latitude, longitude, radius = 5000 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ message: "Vui lòng cung cấp tọa độ GPS hợp lệ!" });
    }

    const rapPhimGan = await RapPhim.aggregate([
      {
        $geoNear: {
          near: {
            type: "Point",
            coordinates: [parseFloat(longitude), parseFloat(latitude)]
          },
          distanceField: "khoang_cach",
          maxDistance: parseInt(radius), // Giới hạn trong bán kính (mét)
          spherical: true
        }
      }
    ]);

    if (rapPhimGan.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy rạp phim nào gần bạn!" });
    }

    res.status(200).json(rapPhimGan);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server!", error: error.message });
  }
};




