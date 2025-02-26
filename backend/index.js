import express from 'express';
import cookieParser from "cookie-parser"
import cors from 'cors'
import mongoose from "mongoose"
import dotenv from 'dotenv'







//Import routes

import authRoute from "./routes/auth.js"
import movieRoutes from "./routes/movieRoutes.js"
import cinemaRoutes from "./routes/cinemaRoutes.js"
import userRoutes from './routes/userRoutes.js';
import UserManagementRoutes from './admin/routes/UserManagementRoutes.js';
import MovieManagementRoutes from './admin/routes/MovieManagementRoutes.js';
import CinemaManagementRoutes from './admin/routes/CinemaManagementRoutes.js';
import SeatManagementRoutes from './admin/routes/SeatManagementRoutes.js';


dotenv.config()

const app = express()
const port = process.env.PORT || 8000

const corsOptions = {
    origin: true
}

app.get('/', (req, res) => {
    res.send("Api is test working")
})


//database conection
mongoose.set('strictQuery', false)
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URL, {

        })

        console.log('mongoDB is conected')
    } catch (err) {
        console.log('mongoDB is conection failed true ')
    }
}
//middleware
//middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(cors(corsOptions));

app.use('/api/v1/auth', authRoute); //domain/api/v1/auth/register
app.use('/api/v1', movieRoutes);
app.use('/api/v1', cinemaRoutes);
app.use('/api/v1/user', userRoutes);
//-----------------------------------
//[ADMIN]
app.use('/api/admin', UserManagementRoutes);
app.use('/api/admin', MovieManagementRoutes);
app.use('/api/admin', CinemaManagementRoutes);
app.use('/api/admin', SeatManagementRoutes);

app.listen(port, () => {
    connectDB();

    console.log("server running on port: " + port)
})




