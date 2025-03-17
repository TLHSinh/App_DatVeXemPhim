import express from 'express';
import cookieParser from "cookie-parser";
import cors from 'cors';
import mongoose from "mongoose";
import dotenv from 'dotenv';

// Import routes
import authRoute from "./routes/auth.js";
import movieRoutes from "./routes/movieRoutes.js";
import cinemaRoutes from "./routes/cinemaRoutes.js";
import userRoutes from './routes/userRoutes.js';
import seatRoutes from "./routes/seatRoutes.js";
import bookTicketsRoutes from "./routes/bookTicketsRoutes.js";
import advertiseRoutes from "./routes/advertiseRoutes.js";

// Admin routes
import UserManagementRoutes from './admin/routes/UserManagementRoutes.js';
import MovieManagementRoutes from './admin/routes/MovieManagementRoutes.js';
import CinemaManagementRoutes from './admin/routes/CinemaManagementRoutes.js';
import SeatManagementRoutes from './admin/routes/SeatManagementRoutes.js';
import BookTicketManagementRoutes from './admin/routes/BookTicketManagementRoutes.js';
import VoucherManagementRoutes from './admin/routes/VoucherManagementRoutes.js';
import FoodManagementRoutes from './admin/routes/FoodManagementRoutes.js';
import AdsManagementRoutes from './admin/routes/AdsManagementRoutes.js';
import RevenueManagementRoutes from './admin/routes/RevenueManagementRoutes.js';

//Kiểm tra huỷ vé nếu chưa thanh toán
//import "./controllers/paymentTime.js"; // Import cron job

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 8000;

const corsOptions = {
    origin: true
};

// Test API route
app.get('/', (req, res) => {
    res.send("API is working");
});

// Database connection
mongoose.set('strictQuery', false);
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URL, {});
        console.log('MongoDB is connected');
    } catch (err) {
        console.log('MongoDB connection failed');
    }
};

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(cors(corsOptions));

// User routes
app.use('/api/v1/auth', authRoute);
app.use('/api/v1', movieRoutes);
app.use('/api/v1', cinemaRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/seat', seatRoutes);
app.use('/api/v1/book', bookTicketsRoutes);
app.use('/api/v1/advertise', advertiseRoutes);

// Admin routes
app.use('/api/v1/admin', UserManagementRoutes);
app.use('/api/v1/admin', MovieManagementRoutes);
app.use('/api/v1/admin', CinemaManagementRoutes);
app.use('/api/v1/admin', SeatManagementRoutes);
app.use('/api/v1/admin', BookTicketManagementRoutes);
app.use('/api/v1/admin', VoucherManagementRoutes);
app.use('/api/v1', FoodManagementRoutes);
app.use('/api/v1/admin', AdsManagementRoutes);
app.use('/api/v1/admin', RevenueManagementRoutes);

// Start server
app.listen(port, () => {
    connectDB();
    console.log("Server running on port: " + port);
});
