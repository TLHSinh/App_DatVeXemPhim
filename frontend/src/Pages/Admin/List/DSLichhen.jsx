import React, { useEffect, useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import './DanhSach.css';
import { TextField } from '@mui/material';
import { toast } from 'react-toastify';
import { BASE_URL } from '../../../config';
import { AuthContext } from '../../../context/AuthContext.jsx'; // Import AuthContext để lấy token
import { FcSearch } from "react-icons/fc";
import Breadcrumb from '../../../Components/Breadcrumb';
import { FaSort, FaSortUp, FaSortDown } from 'react-icons/fa';

const Appointment = () => {
  const navigate = useNavigate();
  const { token } = useContext(AuthContext)
  const [appointments, setAppointment] = useState([]);
  const [filtered, setFilteredDoctors] = useState([]);
  const [sortColumn, setSortColumn] = useState('');
  const [sortDirection, setSortDirection] = useState(''); // 'asc' | 'desc'
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const doctorsPerPage = 5;

  ;
  const fetchAppointment = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/bookings`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`, // Thêm token vào header
        },
      });

      console.log("Token:", token);
      const result = await res.json(); // Chuyển đổi JSON từ API
      console.log(result); // Kiểm tra dữ liệu trả về

      if (result.success && Array.isArray(result.data)) {
        setAppointment(result.data);
        setFilteredDoctors(result.data);
      } else {
        throw new Error(result.message || 'Lỗi lấy danh sách lịch hẹn');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  // Xử lý tìm kiếm
  const handleSearch = (e) => {
    const query = e.target.value.toLowerCase();
    setSearchQuery(query);
    const filtered = appointments.filter((appointment) =>
      appointment.bacSi.ten.toLowerCase().includes(query) ||
      appointment.benhNhan.ten.toLowerCase().includes(query)
    );

    setFilteredDoctors(filtered);
    setCurrentPage(1);
  };



  // Cập nhật trạng thái cuộc hẹn
  const handleStatusChange = async (id, newStatus) => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/bookings/booking/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ trangThai: newStatus }),
      });

      const result = await res.json();
      if (result.success) {
        toast.success('Cập nhật trạng thái thành công');
        setAppointment(appointments.map(appointment =>
          appointment._id === id ? { ...appointment, trangThai: newStatus } : appointment
        ));
      } else {
        toast.error(result.message || 'Lỗi cập nhật trạng thái');
      }
    } catch (error) {
      toast.error('Lỗi cập nhật trạng thái');
    }
  };

  useEffect(() => {
    fetchAppointment();
  }, []);


  const handleSort = (column) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortColumn(column);
      setSortDirection('asc');
    }
    setCurrentPage(1); // Reset về trang đầu khi sắp xếp
  };


  const indexOfLastDoctor = currentPage * doctorsPerPage;
  const indexOfFirstDoctor = indexOfLastDoctor - doctorsPerPage;
  const currentDoctors = filtered.slice(indexOfFirstDoctor, indexOfLastDoctor);


  const sortedDoctors = [...currentDoctors].sort((a, b) => {
    if (!sortColumn) return 0;
    const direction = sortDirection === 'asc' ? 1 : -1;
    if (a[sortColumn] < b[sortColumn]) return -1 * direction;
    if (a[sortColumn] > b[sortColumn]) return 1 * direction;
    return 0;
  });



  const getSortIcon = (column) => {
    if (sortColumn !== column) return <FaSort className="sort-icon" />;
    return sortDirection === 'asc' ? (
      <FaSortUp className="sort-icon" />
    ) : (
      <FaSortDown className="sort-icon" />
    );
  };

  // Chuyển trang
  const paginate = (pageNumber) => setCurrentPage(pageNumber);

  if (loading) return <p>Đang tải dữ liệu...</p>;
  if (error) return <p>Lỗi: {error}</p>;

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
                <h1 className="title-ad">DANH SÁCH LỊCH HẸN</h1>
              </div>
              <div className="search-bar">
                <input type="text" placeholder="Tìm kiếm..."
                  value={searchQuery}
                  onChange={handleSearch} />
                <FcSearch className='search-icon' />
              </div>
            </div>

            <table className="user-table">
              <thead>
                <tr>
                <th onClick={() => handleSort('benhNhan')}>
                    <div className='nameandsort'>
                      <span>Tên khách hàng</span>
                      <span className="sort-icon">{getSortIcon('ten')}</span>
                    </div>
                  </th>
                  <th onClick={() => handleSort('bacSi')}>
                    <div className='nameandsort'>
                      <span>Tên bác sĩ</span>
                      <span className="sort-icon">{getSortIcon('ten')}</span>
                    </div>
                  </th>
                  <th>Ngày hẹn</th>
                  <th>Thời gian bắt đầu</th>
                  <th>Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                {sortedDoctors.length > 0 ? (
                  sortedDoctors.map((appointment) => (
                    <tr key={appointment._id}>
                      <td>{appointment.benhNhan.ten}</td>
                      <td>{appointment.bacSi.ten}</td>
                      <td>{appointment.ngayHen}</td>
                      <td>{appointment.thoiGianBatDau}</td>
                      <td>
                        <select
                          value={appointment.trangThai}
                          onChange={(e) => handleStatusChange(appointment._id, e.target.value)}
                          className={
                            appointment.trangThai === 'XacNhan'
                              ? 'status-confirmed'
                              : appointment.trangThai === 'Huy'
                                ? 'status-cancelled'
                                : 'status-pending'
                          }
                        >
                          <option value="XacNhan">Xác Nhận</option>
                          <option value="ChoDuyet">Chờ Duyệt</option>
                          <option value="Huy">Hủy</option>
                        </select>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="5">Không có lịch hẹn nào</td>
                  </tr>
                )}
              </tbody>
            </table>

            {/* Pagination */}
            <div className="pagination">
              {Array.from({ length: Math.ceil(filtered.length / doctorsPerPage) }, (_, index) => (
                <button
                  key={index + 1}
                  onClick={() => paginate(index + 1)}
                  className={currentPage === index + 1 ? 'active' : ''}
                >
                  {index + 1}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Appointment;

