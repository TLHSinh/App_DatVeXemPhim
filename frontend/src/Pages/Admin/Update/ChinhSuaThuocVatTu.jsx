import React, { useEffect, useState, useContext } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { toast } from "react-toastify";
import { FaChevronLeft } from "react-icons/fa6";
import { BASE_URL } from "../../../config.js";
import { AuthContext } from "../../../context/AuthContext.jsx";
import HashLoader from "react-spinners/HashLoader";
import Breadcrumb from "../../../Components/Breadcrumb.jsx";

const ChinhSuaThuocVatTu = () => {
  const { id } = useParams(); // Lấy ID từ URL
  const { token } = useContext(AuthContext); // Token từ context
  const navigate = useNavigate(); // Điều hướng trang
  const [loading, setLoading] = useState(true); // Trạng thái tải dữ liệu
  const [saving, setSaving] = useState(false); // Trạng thái lưu dữ liệu

  const [formData, setFormData] = useState({
    tenVatTu: "",
    loaiVatTu: "",
    soLuong: "",
    gia: "",
    donViTinh: "",
    ngayNhap: "",
    ngaySanXuat: "",
    hanSuDung: "",
    moTa: "",
  });


  const fetchUser = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/inventory/${id}`, {
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
      } else {
        throw new Error(result.message || "Không tìm thấy thuốc - vật tư");
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


  // Xử lý submit form cập nhật thông tin
  const handleUpdate = async (e) => {
    e.preventDefault();
    setSaving(true);

    try {
      const res = await fetch(`${BASE_URL}/api/v1/inventory/${id}`, {
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
        navigate("/admin/danhsachthuocvattu");
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
    navigate(`/admin/danhsachthuocvattu`);
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
                <h1 className="title-ad">CHỈNH SỬA THÔNG TIN THUỐC - VẬT TƯ</h1>
              </div>
            </div>
            <form className="form" onSubmit={handleUpdate}>
              <div className="column">
                <div className="input-box">
                  <label>Tên vật tư</label>
                  <input type="text" name="tenVatTu" value={formData.tenVatTu}
                    onChange={handleInputChange} required />
                </div>
                <div className="input-box">
                  <label>Loại thuốc</label>
                  <div className="select-box">
                    <select name="loaiVatTu" value={formData.loaiVatTu}
                      onChange={handleInputChange} required>
                      <option value="">Chọn</option>
                      <option value="Thuoc">Thuốc</option>
                      <option value="VatTu">Vật tư</option>
                    </select>
                  </div>
                </div>
              </div>

              <div className="column">
                <div className="input-box">
                  <label>Số lượng</label>
                  <input type="number" name="soLuong" value={formData.soLuong}
                    onChange={handleInputChange} required />
                </div>
                <div className="input-box">
                  <label>Đơn vị tính</label>
                  <input type="text" name="donViTinh" value={formData.donViTinh}
                    onChange={handleInputChange} required />
                </div>
              </div>
              <div className="column">
                <div className="input-box">
                  <label>Ngày nhập</label>
                  <input type="date" name="ngayNhap" value={formData.ngayNhap}
                    onChange={handleInputChange} required />
                </div>
                <div className="input-box">
                  <label>Ngày sản xuất</label>
                  <input type="date" name="ngaySanXuat" value={formData.ngaySanXuat}
                    onChange={handleInputChange} required />
                </div>
                <div className="input-box">
                  <label>Hạn sử dụng</label>
                  <input type="date" name="hanSuDung" value={formData.hanSuDung}
                    onChange={handleInputChange} required />
                </div>
              </div>
              <div className="input-box">
                <label>Giá</label>
                <input type="number" name="gia" value={formData.gia}
                  onChange={handleInputChange} required />
              </div>
              <div className="input-box">
                <label>Mô tả</label>
                <input type="text" name="moTa" value={formData.moTa}
                  onChange={handleInputChange} required />
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

export default ChinhSuaThuocVatTu