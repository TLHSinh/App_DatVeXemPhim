import React, { useEffect, useState, useContext } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { BASE_URL } from '../../../config';
import { AuthContext } from '../../../context/AuthContext.jsx'; // Để lấy token
import './ChiTiet.css'; // Tạo file CSS riêng cho chi tiết người dùng
import { FaChevronLeft } from "react-icons/fa6";
import { Link } from "react-router-dom";

const CTKhachHang = () => {
  const { id } = useParams(); // Lấy ID từ URL
  // const navigate = useNavigate();
  const { token, role } = useContext(AuthContext); // Lấy token từ context
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Hàm lấy thông tin chi tiết người dùng
  const fetchUserDetail = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/users/${id}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
      });
      console.log("Token:", token);
      console.log("Role:", role);
      const result = await res.json();
      if (result.success) {
        setUser(result.data);
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
    fetchUserDetail();
  }, [id]);

  if (loading) return <p>Đang tải dữ liệu...</p>;
  if (error) return <p>Lỗi: {error}</p>;

  return (
    <div className="detail-container">
      <div className='title-ad'>
        <div className='icon-back'>
          <Link to="/admin/danhsachkhachhang">
            <FaChevronLeft color='#66B5A3' />
          </Link>
        </div>
        <h1>CHI TIẾT KHÁCH HÀNG</h1>
      </div>
      {user && (
        <div className="user-info">
          <div className='avt-name-detail'>
            <img
              src={user.hinhAnh}
              alt={`Hình của ${user.ten}`}
              style={{ width: '150px', height: '150px', borderRadius: '50%' }}
            />

          </div>
          <h2 style={{textAlign:"center", color:"#66B5A3"}}>{user.ten}</h2>
          <form action="#" class="form">
            <div class="column">
              <div class="input-box">
                <label>CCCD</label>
                <div className='item-detail'>
                  {user.cccd}
                </div>
              </div>
              <div class="input-box">
                <label>Ngày sinh</label>
                <div className='item-detail'>
                  {user.ngaySinh}
                </div>
              </div>
              <div class="input-box">
                <label>Giới tính</label>
                <div className='item-detail'>
                  {user.gioiTinh}
                </div>
              </div>
            </div>
            <div class="column">
              <div class="input-box">
                <label>Email</label>
                <div className='item-detail'>
                  {user.email}
                </div>
              </div>
              <div class="input-box">
                <label>Số điện thoại</label>
                <div className='item-detail'>
                  {user.soDienThoai}
                </div>
              </div>
              <div class="input-box">
                <label>Nhóm máu</label>
                <div className='item-detail'>
                  {user.nhomMau}
                </div>
              </div>
            </div>
            <div class="column">
              <div class="input-box">
                <label>Địa chỉ</label>
                <div className='item-detail'>
                  {user.diaChi}
                </div>
              </div>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};

export default CTKhachHang;
