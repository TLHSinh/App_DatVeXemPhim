import express from 'express';
import cookieParser from "cookie-parser"
import cors from 'cors'
import mongoose from "mongoose"
import dotenv from 'dotenv'






//Import routes

import authRoute from "./routes/auth.js"
import movieRoutes from "./routes/movieRoutes.js"


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


app.listen(port, () => {
    connectDB();
    console.log("server running on port: " + port)
})




