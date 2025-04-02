import express from 'express';
import cookieParser from "cookie-parser";
import cors from 'cors';
import mongoose from "mongoose";
import dotenv from 'dotenv';
import path from "path";
import { fileURLToPath } from "url";
import { default as axios } from "axios";
import crypto from "crypto";

// Import routes
import authRoute from "./routes/auth.js";
import movieRoutes from "./routes/movieRoutes.js";
import cinemaRoutes from "./routes/cinemaRoutes.js";
import userRoutes from './routes/userRoutes.js';
import seatRoutes from "./routes/seatRoutes.js";
import bookTicketsRoutes from "./routes/bookTicketsRoutes.js";
import advertiseRoutes from "./routes/advertiseRoutes.js";
import feedbackRoutes from "./routes/feedbackRoutes.js";
import ticketRoutes from "./routes/ticketRoutes.js";
import paymentRoutes from "./routes/paymentRoutes.js";


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
import FeedbackManagementRoutes from './admin/routes/FeedbackManagementRoutes.js';

// Sign in Google
import signingoogleRoute from './routes/signingoogleRoute.js';

//EmloyeeRoutes
import emloyeeRoutes from "./routes/employeeRoutes.js";;


//Kiểm tra huỷ vé nếu chưa thanh toán
//import "./helpers/paymentTime.js"; // Import cron job

//auto gửi mail nhắc nhở
//import "./helpers/autoSendMailRemind.js"; // Import cron job


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

// Xác định __dirname trong ES Module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use("/.well-known", express.static(path.join(__dirname, ".well-known")));

// User routes
app.use('/api/v1/auth', authRoute);
app.use('/api/v1/movie', movieRoutes);
app.use('/api/v1', cinemaRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/seat', seatRoutes);
app.use('/api/v1/book', bookTicketsRoutes);
app.use('/api/v1/advertise', advertiseRoutes);
app.use('/api/v1/reviews', feedbackRoutes);
app.use('/api/v1/ticket', ticketRoutes);
app.use('/api/v1', paymentRoutes);

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
app.use('/api/v1', FeedbackManagementRoutes);

// Sign in Google
app.use('/api/v1/google', signingoogleRoute);

//EmloyeeRoutes
app.use('/api/v1/employee', emloyeeRoutes);


// Start server
app.listen(port, () => {
    connectDB();
    console.log("Server running on port: " + port);
});
