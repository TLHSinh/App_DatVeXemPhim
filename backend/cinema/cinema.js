const mongoose = require('mongoose');

const CinemaSchema = new mongoose.Schema({
    id: { type: Number, },
    name: { type: String, },
    image: { type: String, },
    gallery: { type: [String], },
    city: { type: String, },
    address: { type: String, },
    geo_lat: { type: String, },
    geo_long: { type: String, },
    description: { type: String, },
    phone: { type: String, },
    star_rating_value: { type: Number, },
    star_rating_count: { type: Number, },
    created_at: { type: String, },
    updated_at: { type: String, },
});

const CinemaModel = mongoose.model('cinema', CinemaSchema);

module.exports = CinemaModel;