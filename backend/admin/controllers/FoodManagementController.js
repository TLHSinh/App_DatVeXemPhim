import DoAn from "../../models/DoAnSchema.js";

//Lấy danh sách đồ ăn
export const getAllFoods = async (req, res) => {
    try {
        const foods = await DoAn.find();
        res.status(200).json(foods);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi lấy danh sách đồ ăn", error });
    }
}

//Thêm món ăn mới
export const addFood = async (req, res) => {
    try {
        const { ten_do_an, mo_ta, gia, url_hinh } = req.body;
        if (!ten_do_an || !gia) {
            return res.status(400).json({ message: "Tên đồ ăn và giá là bắt buộc" });
        }
        const newFood = new DoAn({ ten_do_an, mo_ta, gia, url_hinh });
        await newFood.save();
        res.status(201).json(newFood);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi thêm món ăn", error });
    }
}

//Cập nhật món ăn
export const updateFood = async (req, res) => {
    try {
        const { id } = req.params;
        const updatedFood = await DoAn.findByIdAndUpdate(id, req.body, { new: true });
        if (!updatedFood) {
            return res.status(404).json({ message: "Không tìm thấy món ăn" });
        }
        res.status(200).json(updatedFood);
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi cập nhật món ăn", error });
    }
}

//Xóa món ăn
export const deleteFood = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedFood = await DoAn.findByIdAndDelete(id);
        if (!deletedFood) {
            return res.status(404).json({ message: "Không tìm thấy món ăn" });
        }
        res.status(200).json({ message: "Xóa món ăn thành công" });
    } catch (error) {
        res.status(500).json({ message: "Lỗi khi xóa món ăn", error });
    }
}