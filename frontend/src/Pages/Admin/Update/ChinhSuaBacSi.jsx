import React, { useEffect, useState, useContext } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { toast } from "react-toastify";
import { FaChevronLeft } from "react-icons/fa6";
import HashLoader from "react-spinners/HashLoader";
import { BASE_URL } from '../../../config';
import uploadImageToCloudinary from '../../../utils/uploadCloudinary';
import { AuthContext } from '../../../context/AuthContext';
import Breadcrumb from "../../../Components/Breadcrumb";


const ChinhSuaBacSi = () => {
  const { id } = useParams(); // Lấy ID từ URL
  const { token } = useContext(AuthContext); // Token từ context
  const navigate = useNavigate(); // Điều hướng trang

  const [loading, setLoading] = useState(true); // Trạng thái tải dữ liệu
  const [saving, setSaving] = useState(false); // Trạng thái lưu dữ liệu
  const [previewURL, setPreviewURL] = useState(""); // URL ảnh xem trước
  const [selectedFile, setSelectedFile] = useState(null); // File ảnh mới


  const [formData, setFormData] = useState({
    email: "", // Email bác sĩ
    matKhau: "", // Mật khẩu
    ten: "", // Tên bác sĩ
    soDienThoai: "", // Số điện thoại
    hinhAnh: "", // Hình ảnh
    gioiTinh: "", // Giới tính
    ngaySinh: "", // Ngày sinh
    cccd: "", // Căn cước công dân
    diaChi: "", // Địa chỉ
    chuyenKhoa: "", // Chuyên khoa
    giaKham: "", // Giá khám
    // bangCap: "" , // Bằng cấp
    // kinhNghiem:"" , // Kinh nghiệm
    gioiThieuNgan: "", // Giới thiệu ngắn
    // gioiThieuChiTiet: "", // Giới thiệu chi tiết
    // lichLamViec: "" , // Lịch làm việc
    trangThai: "duocDuyet", // Trạng thái phê duyệt
    role: "BacSi"
    //lichHen: [{ type: mongoose.Types.ObjectId, ref: "LichHen" }], // Lịch hẹn
  });

  // Lấy thông tin người dùng từ API
  const fetchUser = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/doctors/${id}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      const result = await res.json();
      if (result.success) {
        // Đặt dữ liệu người dùng vào formData
        setFormData(result.data);
        setPreviewURL(result.data.hinhAnh); // Hiển thị ảnh hiện có
      } else {
        throw new Error(result.message || "Không tìm thấy người dùng");
      }
    } catch (error) {
      toast.error(`Lỗi: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUser(); // Gọi API lấy dữ liệu khi component mount
  }, [id]);

  // Xử lý khi thay đổi input
  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // Xử lý khi chọn file ảnh
  const handleFileInputChange = async (event) => {
    const file = event.target.files[0];
    const data = await uploadImageToCloudinary(file); // Upload lên Cloudinary
    setPreviewURL(data.url);
    setSelectedFile(data.url);
    setFormData({ ...formData, hinhAnh: data.url });
  };

  // Xử lý submit form cập nhật thông tin
  const handleUpdate = async (e) => {
    e.preventDefault();
    setSaving(true);

    try {
      const res = await fetch(`${BASE_URL}/api/v1/doctors/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(formData), // Gửi dữ liệu dưới dạng JSON
      });

      const result = await res.json();
      if (result.success) {
        toast.success("Cập nhật thành công!");
        navigate("/admin/danhsachbacsi");
      } else {
        throw new Error(result.message || "Cập nhật không thành công");
      }
    } catch (error) {
      toast.error(`Lỗi: ${error.message}`);
    } finally {
      setSaving(false);
    }
  };

  const handlerCancel = () => {
    navigate(`/admin/danhsachbacsi`);
  };

  if (loading) return <p>Đang tải dữ liệu...</p>;
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
                <h1 className="title-ad">CHỈNH SỬA THÔNG TIN BÁC SĨ</h1>
              </div>
            </div>

            <form action="#" class="form" onSubmit={handleUpdate}>
            <div style={{ display: "flex", justifyContent: "center",  alignItems: "center" }}>
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

              <div class="input-box">
                <label>Họ và tên</label>
                <input type="text" name="ten" value={formData.ten} onChange={handleInputChange} />
              </div>
              <div class="column">
                <div className="input-box">
                  <label>Ngày sinh</label>
                  <input type="date" name="ngaySinh" value={formData.ngaySinh} onChange={handleInputChange} />
                </div>
                <div className="input-box">
                  <label>Căn cước công dân</label>
                  <input type="text" name="cccd" value={formData.cccd} onChange={handleInputChange} />
                </div>
                <div className="input-box">
                  <label>Giới tính</label>
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
              <div class="input-box address">
                <div class="column">
                  <div class="select-box">
                    <select name="chuyenKhoa" value={formData.chuyenKhoa} onChange={handleInputChange}>
                      <option hidden>Chuyên khoa</option>
                      <option value="Tiêu hoá">Tiêu hoá</option>
                      <option value="Phẫu thuật Tạo hình - Thẩm mỹ">Phẫu thuật Tạo hình - Thẩm mỹ</option>
                      <option value="Khám sức khoẻ tổng quát dành cho doanh nhân">Khám sức khoẻ tổng quát dành cho doanh nhân</option>
                      <option value="Khám sức khoẻ Doanh nghiệp">Khám sức khoẻ Doanh nghiệp</option>
                      <option value="Hỗ trợ sinh sản">Hỗ trợ sinh sản</option>
                      <option value="Nhi khoa">Nhi khoa</option>
                      <option value="Sản phụ khoa">Sản phụ khoa</option>
                    </select>
                  </div>
                  <input type="password" placeholder="Mật khẩu"
                    name="matKhau" value={formData.matKhau} onChange={handleInputChange} />
                </div>
                <div className="input-box">
                  <label>Địa chỉ</label>
                  <input type="text" name="diaChi" value={formData.diaChi} onChange={handleInputChange} />
                </div>
                <div className="input-box">
                  <label>Giá khám</label>
                  <input type="number" name="giaKham" value={formData.giaKham} onChange={handleInputChange} />
                </div>
                <div className="input-box">
                  <label>Mô tả</label>
                  <input type="text" name="gioiThieuNgan" value={formData.gioiThieuNgan} onChange={handleInputChange} />
                </div>
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
export default ChinhSuaBacSi