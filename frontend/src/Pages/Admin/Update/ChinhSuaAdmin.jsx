import React, { useContext, useState, useEffect } from 'react';
import { AuthContext } from '../../../context/AuthContext';
import { BASE_URL } from '../../../config';
import uploadImageToCloudinary from '../../../utils/uploadCloudinary';
import { toast } from "react-toastify";
import HashLoader from 'react-spinners/HashLoader';
import './ChinhSua.css'
import TextField from '@mui/material/TextField';

const ChinhSuaAdmin = () => {
    const { user, token, dispatch } = useContext(AuthContext);
    const [saving, setSaving] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [previewImage, setPreviewImage] = useState(user?.hinhAnh || "https://via.placeholder.com/150");
    const [selectedFile, setSelectedFile] = useState(null);

    const getInitialFormData = () => ({
        ten: user?.ten || "",
        email: user?.email || "",
        soDienThoai: user?.soDienThoai || "",
        ngaySinh: user?.ngaySinh || "",
        diaChi: user?.diaChi || "",
        gioiTinh: user?.gioiTinh || "",
        nhomMau: user?.nhomMau || "",
        cccd: user?.cccd || "",
        hinhAnh: user?.hinhAnh || "",
    });

    const [formData, setFormData] = useState(getInitialFormData());

    const fetchUserProfile = async () => {
        try {
            const res = await fetch(`${BASE_URL}/api/v1/users/${user._id}`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });
            const result = await res.json();
            if (res.ok && result.success) {
                dispatch({ type: 'UPDATE_USER', payload: result.data });
                setFormData(result.data);
                setPreviewImage(result.data.hinhAnh || "https://via.placeholder.com/150");
            } else {
                throw new Error(result.message || "Không thể tải thông tin người dùng");
            }
        } catch (error) {
            toast.error(`Lỗi: ${error.message}`);
        }
    };

    useEffect(() => {
        if (user) {
            fetchUserProfile();
        }
    }, []);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData((prevData) => ({ ...prevData, [name]: value }));
    };

    const handleImageChange = async (e) => {
        const file = e.target.files[0];
        if (file) {
            try {
                const data = await uploadImageToCloudinary(file);
                setPreviewImage(data.url);
                setFormData((prevData) => ({ ...prevData, hinhAnh: data.url }));
            } catch (error) {
                toast.error("Lỗi khi tải ảnh lên Cloudinary");
            }
        }
    };

    const handleSave = async (e) => {
        e.preventDefault();
        setSaving(true);

        try {
            const res = await fetch(`${BASE_URL}/api/v1/users/${user._id}`, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify(formData),
            });

            const result = await res.json();
            if (res.ok && result.success) {
                toast.success("Cập nhật thành công!");
                dispatch({ type: 'UPDATE_USER', payload: result.data });
                setFormData(result.data);
                setIsEditing(false);
            } else {
                throw new Error(result.message || "Cập nhật không thành công");
            }
        } catch (error) {
            toast.error(`Lỗi: ${error.message}`);
        } finally {
            setSaving(false);
        }
    };

    // Xử lý khi chọn file ảnh
    const handleFileInputChange = async (event) => {
        const file = event.target.files[0];
        const data = await uploadImageToCloudinary(file); // Upload lên Cloudinary
        setPreviewImage(data.url);
        setSelectedFile(data.url);
        setFormData({ ...formData, hinhAnh: data.url });
    };
    return (
        <form className='form'>
            <div className='card-box-update-ad'>
                <h4 className='card-title-update-ad'>Thông tin cá nhân</h4>
                <div className='row'>
                    <div className='col-md-12'>
                        <div style={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
                            <div className="flex items-center gap-2">
                                <figure className="w-[100px] h-[100px] mt-3 rounded-full border-primaryColor flex items-center justify-center overflow-hidden">
                                    <img
                                        src={previewImage || "/Images/add-user-icon.avif"}
                                        alt="Hình ảnh người dùng"
                                        className="w-full h-full object-cover"
                                    />
                                </figure>
                                <div className="relative w-[110px] h-[40px]">
                                    <input
                                        type="file"
                                        name="hinhAnh"
                                        id="customFile"
                                        onChange={handleFileInputChange}
                                        accept=".jpg, .png"
                                        className="absolute top-0 left-0 w-full h-full opacity-0 cursor-pointer"
                                    />
                                    <label
                                        htmlFor="customFile"
                                        className="absolute top-0 left-0 w-full h-full flex items-center px-[0.75rem] py-[0.375rem] text-[13px] leading-6 overflow-hidden bg-[#0066ff46] text-headingColor font-semibold rounded-lg truncate cursor-pointer"
                                    >
                                        Hình ảnh
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div className='row'>
                            <div className='profile-update-ad'>
                                <div className='row'>
                                    <div className='col-md-6'>
                                        <div class="input-box">
                                            <label>Họ và tên</label>
                                            <input type="text" name="ten" value={formData.ten} onChange={handleInputChange} />
                                        </div>
                                        <div className="input-box">
                                            <label >Giới tính</label>
                                            <div class="select-box">
                                                <select name="gioiTinh" value={formData.gioiTinh} onChange={handleInputChange}>
                                                    <option value="">Chọn</option>
                                                    <option value="Nam">Nam</option>
                                                    <option value="Nữ">Nữ</option>
                                                    <option value="Khác">Khác</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div className="input-box">
                                            <label >Ngày sinh</label>
                                            <input type="date" name="ngaySinh" value={formData.ngaySinh} onChange={handleInputChange} />
                                        </div>
                                        <div className="input-box">
                                            <label >Căn cước công dân</label>
                                            <input type="text" name="cccd" value={formData.cccd} onChange={handleInputChange} />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>


            <div className='card-box-update-ad'>
                <h4 className='card-title-update-ad'>Thông tin liên lạc</h4>
                < div className='row'>
                    <div className='col-md-12'>
                        <div className='profile-update-ad'>
                            <div className='row'>
                                <div className='col-md-6'>
                                    <div class="column">
                                        <div class="input-box">
                                            <label>Số điện thoại</label>
                                            <input type="text" name="soDienThoai" value={formData.soDienThoai} onChange={handleInputChange} />
                                        </div>
                                        <div class="input-box">
                                            <label>Email</label>
                                            <input type="email" name="email" value={formData.email} readOnly />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div className="input-box">
                                        <label>Địa chỉ</label>
                                        <input type="text" name="diaChi" value={formData.diaChi} onChange={handleInputChange} />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div className='card-box-update-ad'>
                <h4 className='card-title-update-ad'>Thông tin bảo mật</h4>
                < div className='row'>
                    <div className='col-md-12'>
                        <div className='profile-update-ad'>
                            <div className='row'>
                                    <div className="input-box">
                                        <label>Mật khẩu</label>
                                        <input type="password"  name="matKhau" value={formData.matKhau} onChange={handleInputChange} />
                                    </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    )
}

export default ChinhSuaAdmin