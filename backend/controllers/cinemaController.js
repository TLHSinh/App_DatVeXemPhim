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