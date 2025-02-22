const axios = require('axios');
const express = require('express');
const mongoose = require('mongoose');
const CinemaModel = require('./cinema'); // Import model
const app = express();
const port = 3002;

const uri = 'mongodb+srv://hoangdoan103:Melody1603@cluster0.3pfyf.mongodb.net/cinema';

// Kết nối MongoDB
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("Connected to MongoDB"))
    .catch(err => console.error("Error connecting to MongoDB:", err));

app.get('/fetch-cinemas', async (req, res) => {
    try {
        const response = await axios.get('https://rapchieuphim.com/api/v1/cinemas');
        let cinemas = response.data;

        const filteredCinemas = cinemas.filter(cinema =>
            cinema.name && cinema.name.toUpperCase().includes("CGV")
        );

        for (const cinema of filteredCinemas) {
            try {
                const galleryString = cinema.gallery;

                if (galleryString != null || galleryString != "") {
                    const galleryArray = JSON.parse(galleryString);

                    await CinemaModel.updateOne(
                        { id: cinema.id },
                        {
                            $set: {
                                name: cinema.name,
                                image: cinema.image,
                                gallery: galleryArray,
                                city: cinema.city,
                                address: cinema.address,
                                geo_lat: cinema.geo_lat,
                                geo_long: cinema.geo_long,
                                description: cinema.description,
                                phone: cinema.phone,
                                star_rating_value: cinema.star_rating_value,
                                star_rating_count: cinema.star_rating_count,
                                created_at: cinema.created_at,
                                updated_at: cinema.updated_at,
                            }
                        },
                        { upsert: true }
                    );
                }
            } catch {
                console.log('Galary is null.')
            }

        }

        res.json({ message: "Cinemas successfully saved to MongoDB (duplicates avoided)!" });
    } catch (error) {
        console.error('Error fetching or saving cinemas:', error);
        res.status(500).json({ message: 'Error fetching or saving cinemas' });
    }
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
