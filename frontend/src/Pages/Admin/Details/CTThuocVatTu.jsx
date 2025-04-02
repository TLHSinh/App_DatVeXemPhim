import React, { useEffect, useState, useContext } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { BASE_URL } from '../../../config';
import { AuthContext } from '../../../context/AuthContext.jsx'; // Để lấy token
import './ChiTiet.css'; // Tạo file CSS riêng cho chi tiết người dùng
import { FaChevronLeft } from "react-icons/fa6";
import { Link } from "react-router-dom";

const CTThuocVatTu = () => {
  const { id } = useParams(); // Lấy ID từ URL
  const navigate = useNavigate();
  const { token } = useContext(AuthContext); // Lấy token từ context
  const [inventory, setInventory] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Hàm lấy thông tin chi tiết người dùng
  const fetchInventoryDetail = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/inventory/${id}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
      });

      const result = await res.json();
      if (result.success) {
        setInventory(result.data);
      } else {
        throw new Error(result.message || 'Không tìm thấy người dùng');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchInventoryDetail();
  }, [id]);

  if (loading) return <p>Đang tải dữ liệu...</p>;
  if (error) return <p>Lỗi: {error}</p>;

  return (
    <div className="detail-container">
      <div className='title-ad'>
        <div className='icon-back'>
          <Link to="/admin/danhsachthuocvattu">
            <FaChevronLeft color='#66B5A3' />
          </Link>
        </div>
        <h1>CHI TIẾT THUỐC- VẬT TƯ</h1>
      </div>
      {inventory && (
        <div className="user-info">
          <h3 style={{textAlign:"center"}}>{inventory.tenVatTu}</h3>
          <form action="#" class="form">
            <div class="column">
              <div class="input-box">
                <label>Loại vật tư</label>
                <div className='item-detail'>
                  {inventory.loaiVatTu}
                </div>
              </div>
              <div class="input-box">
                <label>Số lượng</label>
                <div className='item-detail'>
                  {inventory.soLuong}
                </div>
              </div>
              <div class="input-box">
                <label>Đơn vị tính</label>
                <div className='item-detail'>
                  {inventory.donViTinh}
                </div>
              </div>
              <div class="input-box">
                <label>Giá</label>
                <div className='item-detail'>
                  {inventory.gia}
                </div>
              </div>
            </div>
            <div class="column">
              <div class="input-box">
                <label>Ngày nhập</label>
                <div className='item-detail'>
                  {inventory.ngayNhap}
                </div>
              </div>
              <div class="input-box">
                <label>Ngày sản xuất</label>
                <div className='item-detail'>
                  {inventory.ngaySanXuat}
                </div>
              </div>
              <div class="input-box">
                <label>Hạn sử dụng</label>
                <div className='item-detail'>
                  {inventory.hanSuDung}
                </div>
              </div>
            </div>
            <div class="column">
              <div class="input-box">
                <label>Mô tả</label>
                <div className='item-detail'>
                  {inventory.moTa}
                </div>
              </div>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};

export default CTThuocVatTu;