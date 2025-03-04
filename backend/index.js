import express from 'express';
import cookieParser from "cookie-parser"
import cors from 'cors'
import mongoose from "mongoose"
import dotenv from 'dotenv'








//Import routes

import authRoute from "./routes/auth.js"
import movieRoutes from "./routes/movieRoutes.js"
import cinemaRoutes from "./routes/cinemaRoutes.js"
import userRoutes  from './routes/userRoutes.js';
import seatRoutes from "./routes/seatRoutes.js"
import bookTicketsRoutes from "./routes/bookTicketsRoutes.js"
import advertiseRoutes from "./routes/advertiseRoutes.js"


//import "./controllers/paymentTime.js"; // Import cron job

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
app.use(cookieParser());
app.use(cors(corsOptions));

app.use('/api/v1/auth', authRoute); //domain/api/v1/auth/register
app.use('/api/v1', movieRoutes);
app.use('/api/v1', cinemaRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/seat', seatRoutes);
app.use('/api/v1/book', bookTicketsRoutes);
app.use('/api/v1/advertise', advertiseRoutes);




app.listen(port, () => {
    connectDB();


    console.log("server running on port: " + port)
})




