import './Them.css';
import { FaChevronLeft } from "react-icons/fa6";
import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import uploadImageToCloudinary from '../../../utils/uploadCloudinary';
import { BASE_URL } from '../../../config';
import { toast } from 'react-toastify';
import HashLoader from 'react-spinners/HashLoader';
import Breadcrumb from '../../../Components/Breadcrumb';
const ThemKhachHang = () => {

  const navigate = useNavigate();
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewURL, setPreviewURL] = useState("");
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
    ten: "",             // Tên bệnh nhân
    email: "",           // Email
    matKhau: "",         // Mật khẩu
    hinhAnh: "", // Hình ảnh (URL)
    gioiTinh: "",        // Giới tính
    role: "BenhNhan",    // Vai trò: mặc định là bệnh nhân
    soDienThoai: "",
    ngaySinh: "",
    cccd: "",
    diaChi: "",
    nhomMau: ""
  });

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFileInputChange = async (event) => {
    const file = event.target.files[0];
    const data = await uploadImageToCloudinary(file);
    setPreviewURL(data.url);
    setSelectedFile(data.url);
    setFormData({ ...formData, hinhAnh: data.url });
  };


  const submitHandler = async (event) => {
    event.preventDefault();
    setLoading(true);

    try {
      const res = await fetch(`${BASE_URL}/api/v1/users/addUser`, {
        method: 'post',
        headers: {
          'Content-type': 'application/json'
        },
        body: JSON.stringify(formData)  // Gửi formData lên backend
      });

      const { message } = await res.json();

      if (!res.ok) {
        throw new Error(message);
      }

      setLoading(false);
      toast.success(message);
      navigate("/admin/danhsachkhachhang");

    } catch (err) {
      toast.error(err.message);
      setLoading(false);
    }
  };
  const handlerCancel = () => {
    navigate(`/admin/danhsachkhachhang`);
  };
  return (
    <div>
      <div className='row'>
        <div className='col-sm-12'>
          <Breadcrumb />
        </div>
      </div>
      <div className="row">
        <div className='col-sm-12'>
          <div className='card-list-ad'>
            <div className=' header-list-card' >
              <div style={{ float: "left" }}>
                <h1 className="title-ad">THÊM KHÁCH HÀNG</h1>
              </div>
            </div>

            <form className="form" onSubmit={submitHandler}>
              <div style={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
                <div className="mb-4 flex items-center gap-2">
                  {/* Hiển thị ảnh hiện tại hoặc ảnh mới được chọn */}
                  <figure className="w-[100px] h-[100px] mt-3 rounded-full border-primaryColor flex items-center justify-center overflow-hidden">
                    <img
                      src={previewURL || "/Images/add-user-icon.avif"} // Ảnh hiện có hoặc ảnh mặc định
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
              <div class="column">
                <div class="input-box">
                  <label>Họ và tên</label>
                  <input type="text" name="ten" value={formData.ten} onChange={handleInputChange} />
                </div>
                <div class="input-box">
                  <label>Ngày sinh</label>
                  <input type="date" name="ngaySinh" value={formData.ngaySinh} onChange={handleInputChange} />
                </div>
              </div>
              <div class="column">
                <div class="input-box">
                  <label>Số điện thoại</label>
                  <input type="text" name="soDienThoai" value={formData.soDienThoai} onChange={handleInputChange} />
                </div>
                <div class="input-box">
                  <label>Email</label>
                  <input type="email" name="email" value={formData.email} onChange={handleInputChange} />
                </div>
              </div>
              <div class="input-box address">
                <div class="column">
                  <div class="select-box">
                    <select
                      name="gioiTinh"  // Phải là 'gioiTinh' theo schema
                      value={formData.gioiTinh}
                      onChange={handleInputChange}
                    >
                      <option value="">Chọn</option>
                      <option value="Nam">Nam</option>
                      <option value="Nữ">Nữ</option>
                      <option value="Khác">Khác</option>
                    </select>
                  </div>
                  <input type="text" name="nhomMau" value={formData.nhomMau} onChange={handleInputChange} placeholder="Nhóm máu" />
                </div>
              </div>
              <div class="column">
                <div class="input-box">
                  <label>CCCD</label>
                  <input type="text" name="cccd" value={formData.cccd} onChange={handleInputChange} />
                </div>
                <div class="input-box">
                  <label>Mật khẩu</label>
                  <input type="password" name="matKhau" value={formData.matKhau} onChange={handleInputChange} />
                </div>
              </div>


              <div class="input-box">
                <label>Địa chỉ</label>
                <input type="text" name="diaChi" value={formData.diaChi} onChange={handleInputChange} />
              </div>


              <div className='col-12'>
                <div style={{ textAlign: "right" }}>
                  <button className='submitform-ad' type="submit" disabled={loading}>
                    {loading ? <HashLoader size={35} color="#ffffff" /> : 'Tạo'}
                  </button>
                  <button className='cancelform-ad' onClick={() => handlerCancel()} >
                    Huỷ
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

  )
}

export default ThemKhachHang