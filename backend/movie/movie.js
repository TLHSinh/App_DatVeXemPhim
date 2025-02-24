import mongoose from "mongoose";

const MovieSchema = new mongoose.Schema({
    id: { type: Number, },
    name: { type: String, },
    poster: { type: String, },
    trailer: { type: String, },
    description: { type: String, },
    release: { type: String, },
    release_vn: { type: String, },
    duration: { type: String, },
    year: { type: String, },
    status: { type: String, },
    age_restricted: { type: String, },
    star_rating_value: { type: Number, },
    star_rating_count: { type: Number, },
    create_at: { type: String, },
    updated_at: { type: String, },
});

const MovieModel = mongoose.model('movie', MovieSchema);

module.exports = MovieModel;