import express from 'express';
import { getAllFoods, addFood, updateFood, deleteFood } from '../controllers/FoodManagementController.js'

const router = express.Router();

router.get('/foods', getAllFoods);
router.post('/foods', addFood);
router.put('/foods/:id', updateFood);
router.delete('/foods/:id', deleteFood);

export default router;