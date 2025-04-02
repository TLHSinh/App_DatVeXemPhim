import { FaChevronLeft } from "react-icons/fa6";
import './Them.css';
import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import { BASE_URL } from "../../../config";
import { toast } from 'react-toastify';
import HashLoader from 'react-spinners/HashLoader';
import Breadcrumb from "../../../Components/Breadcrumb";

const ThemThuocVatTu = () => {
  const [loading, setLoading] = useState(false);

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

  const navigate = useNavigate();

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const submitHandler = async (event) => {
    event.preventDefault();
    setLoading(true);

    try {
      const res = await fetch(`${BASE_URL}/api/v1/inventory/addInventory`, {
        method: 'post',
        headers: {
          'Content-type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      const { message } = await res.json();
      if (!res.ok) throw new Error(message);

      setLoading(false);
      toast.success(message);
      navigate("/admin/danhsachthuocvattu");
    } catch (err) {
      toast.error(err.message);
      setLoading(false);
    }
  };
  const handlerCancel = () => {
    navigate(`/admin/danhsachthuocvattu`);
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
                <h1 className="title-ad">THÊM THUỐC - VẬT TƯ</h1>
              </div>
            </div>

            <form onSubmit={submitHandler} className="form">
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
                      <option value="Thuốc">Thuốc</option>
                      <option value="Vật Tư">Vật tư</option>
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
  );
};

export default ThemThuocVatTu;
