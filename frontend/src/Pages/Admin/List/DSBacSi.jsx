import React, { useEffect, useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import './DanhSach.css';
import { FaSort, FaSortUp, FaSortDown } from 'react-icons/fa';
import { BASE_URL } from '../../../config';
import { AuthContext } from '../../../context/AuthContext';
import { RiCalendarScheduleLine } from "react-icons/ri";
import { FaPenToSquare, FaTrash, FaRegEye, FaPlus } from "react-icons/fa6";
import { toast } from 'react-toastify';
import { FcSearch } from "react-icons/fc";
import Breadcrumb from '../../../Components/Breadcrumb';
import { Fab, Modal, Box, TextField, Button } from '@mui/material';




const DSBacSi = () => {
  const navigate = useNavigate();
  const { token } = useContext(AuthContext);
  const [selectedDoctorId, setSelectedDoctorId] = useState(null);
  const [doctors, setDoctors] = useState([]);
  const [filteredDoctors, setFilteredDoctors] = useState([]);
  const [sortColumn, setSortColumn] = useState('');
  const [sortDirection, setSortDirection] = useState(''); // 'asc' | 'desc'
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [open, setOpen] = useState(false); // Control popup
  const [schedule, setSchedule] = useState({ ngay: '', batDau: '', ketThuc: '' });
  const [currentPage, setCurrentPage] = useState(1);
  const doctorsPerPage = 5;

  const fetchDoctors = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/doctors`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
      });

      const result = await res.json();
      if (result.success) {
        setDoctors(result.data);
        setFilteredDoctors(result.data);
      } else {
        throw new Error(result.message || 'Lỗi lấy danh sách bác sĩ');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDoctors();
  }, []);


  //tạo lịch làm việc
  const saveSchedule = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/doctors/addWorkingSchedule/${selectedDoctorId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(schedule),
      });
      const result = await res.json();
      if (result.success) {
        toast.success('Lịch làm việc đã được thêm');
        closePopup();
        fetchDoctors();
      } else {
        throw new Error(result.message);
      }
    } catch (err) {
      toast.error(`Lỗi: ${err.message}`);
    }
  };

  const openPopup = (id) => {
    setSelectedDoctorId(id);
    setOpen(true);
  };

  const closePopup = () => {
    setOpen(false);
    setSchedule({ ngay: '', batDau: '', ketThuc: '' });
  };

  // Điều hướng đến trang thêm người dùng
  const handleAddUser = () => {
    navigate('/admin/thembacsi');
  };


  // Chuyển hướng tới trang chỉnh sửa kèm ID
  const handleEditUser = (id) => {
    navigate(`/admin/chinhsuabacsi/${id}`);
  };

  // Chuyển hướng tới trang chi tiết người dùng với ID
  const detailUser = (id) => {
    navigate(`/admin/chitietbacsi/${id}`);
  };

  // Xóa bác sĩ với xác thực và kiểm tra quyền
  const deleteUser = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa bác sĩ này?')) return;

    try {
      const res = await fetch(`${BASE_URL}/api/v1/doctors/${id}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
      });

      const result = await res.json();
      if (result.success) {
        toast.success(result.message);
        setDoctors(doctors.filter((doctors) => doctors._id !== id));
      } else {
        toast.error(result.message);
      }
    } catch (err) {
      toast.error(`Lỗi: ${err.message}`);
    }
  };


  const handleSearch = (e) => {
    const query = e.target.value.toLowerCase();
    setSearchQuery(query);
    const filtered = doctors.filter((doctor) =>
      doctor.ten.toLowerCase().includes(query)
    );
    setFilteredDoctors(filtered);
    setCurrentPage(1);
  };

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
  const currentDoctors = filteredDoctors.slice(indexOfFirstDoctor, indexOfLastDoctor);


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
                <h1 className="title-ad">DANH SÁCH BÁC SĨ</h1>
              </div>
              <div className="search-bar">
                <input type="text" placeholder="Tìm kiếm..."
                  value={searchQuery}
                  onChange={handleSearch} />
                <FcSearch className='search-icon' />
              </div>
            </div>
            <table className="user-table ">
              <thead>
                <tr>
                  <th>Hình ảnh</th>
                  <th onClick={() => handleSort('ten')}>
                    <div className='nameandsort'>
                      <span>Tên</span>
                      <span className="sort-icon">{getSortIcon('ten')}</span>
                    </div>
                  </th>
                  <th onClick={() => handleSort('gioiTinh')}>
                    <div className='nameandsort'>
                      <span>Giới Tính</span>
                      <span className="sort-icon">{getSortIcon('gioiTinh')}</span>
                    </div>
                  </th>
                  <th>Email</th>
                  <th>Số Điện Thoại</th>
                  <th>Chức Năng</th>
                </tr>
              </thead>
              <tbody>
                {sortedDoctors.length > 0 ? (
                  sortedDoctors.map((doctor) => (
                    <tr key={doctor._id}>
                      <td>
                        <img
                          src={doctor.hinhAnh}
                          alt={`Hình của ${doctor.ten}`}
                          style={{ width: '3rem', height: '3rem', borderRadius: '50%', objectFit: 'cover' }}
                        />
                      </td>
                      <td>{doctor.ten}</td>
                      <td>{doctor.gioiTinh}</td>
                      <td>{doctor.email}</td>
                      <td>{doctor.soDienThoai}</td>
                      <td >
                        <button className="icon-function" onClick={() => handleEditUser(doctor._id)}>
                          <FaPenToSquare color="#66B5A3" />
                        </button>
                        <button className="icon-function" onClick={() => deleteUser(doctor._id)}>
                          <FaTrash color="#66B5A3" />
                        </button>
                        <button className="icon-function" onClick={() => detailUser(doctor._id)}>
                          <FaRegEye color="#66B5A3" />
                        </button>
                        <button className="icon-function" onClick={() => openPopup(doctor._id)}>
                          <RiCalendarScheduleLine color="#66B5A3" />
                        </button>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="5">Không tìm thấy bác sĩ nào</td>
                  </tr>
                )}
              </tbody>
            </table>

            {/* Pagination */}
            <div className="pagination">
              {Array.from({ length: Math.ceil(filteredDoctors.length / doctorsPerPage) }, (_, index) => (
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



      <Modal open={open} onClose={closePopup}>
        <Box className="pop-up-addworking">
          <h2 style={{ color: '#66B5A3' }}>THÊM LỊCH LÀM</h2>

          <TextField
            label="Ngày"
            type="date"
            value={schedule.ngay}
            onChange={(e) => setSchedule({ ...schedule, ngay: e.target.value })}
            InputLabelProps={{ shrink: true }}
            fullWidth
            margin="normal"
          />
          <TextField
            label="Giờ Bắt Đầu"
            type="time"
            value={schedule.batDau}
            onChange={(e) => setSchedule({ ...schedule, batDau: e.target.value })}
            InputLabelProps={{ shrink: true }}
            fullWidth
            margin="normal"
          />
          <TextField
            label="Giờ Kết Thúc"
            type="time"
            value={schedule.ketThuc}
            onChange={(e) => setSchedule({ ...schedule, ketThuc: e.target.value })}
            InputLabelProps={{ shrink: true }}
            fullWidth
            margin="normal"
          />
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '16px' }}>
            <Button
              variant="contained"
              onClick={saveSchedule}
              sx={{ backgroundColor: '#66B5A3', '&:hover': { backgroundColor: '#55A392' } }}
            >
              Lưu
            </Button>
          </div>


        </Box>
      </Modal>



      {/* Nút thêm người dùng */}
      <Fab
        onClick={handleAddUser}
        sx={{
          backgroundColor: '#66B5A3',
          '&:hover': { backgroundColor: '#97c9bc' },
          position: 'fixed',
          bottom: 50,
          right: 50,
          animation: 'animate 2s linear infinite',
        }}
        aria-label="add"
      >
        <FaPlus color='white' size={18} />
      </Fab>
    </div>
  );
};

export default DSBacSi;

