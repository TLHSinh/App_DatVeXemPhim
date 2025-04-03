import React, { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import "./DanhSach.css";
import { Fab, TextField } from "@mui/material";
import { toast } from "react-toastify";
import { BASE_URL } from "../../../config";
import { AuthContext } from "../../../context/AuthContext.jsx"; // Import AuthContext để lấy token
import { FaPenToSquare, FaTrash, FaPlus, FaRegEye } from "react-icons/fa6";
import { FaSort, FaSortUp, FaSortDown } from "react-icons/fa";
import Breadcrumb from "../../../Components/Breadcrumb";
import { FcSearch } from "react-icons/fc";

const DSKhachHang = () => {
  const navigate = useNavigate();
  const { token } = useContext(AuthContext);
  const [users, setUsers] = useState([]);
  const [filtered, setFilteredDoctors] = useState([]);
  const [sortColumn, setSortColumn] = useState("");
  const [sortDirection, setSortDirection] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const doctorsPerPage = 5;

  const fetchUsers = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/user/allUser`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      console.log("token", token);

      const result = await res.json(); // Chuyển đổi JSON từ API
      if (result.success && Array.isArray(result.data)) {
        setUsers(result.data); // Gán mảng người dùng vào state
        setFilteredDoctors(result.data);
      } else {
        throw new Error(result.message || "Lỗi lấy danh sách người dùng");
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
    const filtered = users.filter(
      (user) => user.hoTen.toLowerCase().includes(query) // Lọc theo tên người dùng
    );
    setFilteredDoctors(filtered);
    setCurrentPage(1);
  };

  // Xóa khách hàng với xác thực
  const deleteUser = async (id) => {
    if (!window.confirm("Bạn có chắc chắn muốn xóa người dùng này?")) return;

    try {
      const res = await fetch(`${BASE_URL}/api/v1/user/${id}`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      const result = await res.json();
      if (result.success) {
        toast.success(result.message);
        setUsers(users.filter((user) => user._id !== id));
      } else {
        toast.error(result.message);
      }
    } catch (err) {
      toast.error(`Lỗi: ${err.message}`);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  // Điều hướng đến trang thêm người dùng
  const handleAddUser = () => {
    navigate("/admin/themkhachhang");
  };

  // Chuyển hướng tới trang chỉnh sửa kèm ID
  const handleEditUser = (id) => {
    navigate(`/admin/chinhsuakhachhang/${id}`);
  };

  // Chuyển hướng tới trang chi tiết người dùng với ID
  const detailUser = (id) => {
    navigate(`/admin/chitietkhachhang/${id}`);
  };

  const handleSort = (column) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(column);
      setSortDirection("asc");
    }
    setCurrentPage(1); // Reset về trang đầu khi sắp xếp
  };

  const indexOfLastDoctor = currentPage * doctorsPerPage;
  const indexOfFirstDoctor = indexOfLastDoctor - doctorsPerPage;
  const currentDoctors = filtered.slice(indexOfFirstDoctor, indexOfLastDoctor);

  const sortedDoctors = [...currentDoctors].sort((a, b) => {
    if (!sortColumn) return 0;
    const direction = sortDirection === "asc" ? 1 : -1;
    if (a[sortColumn] < b[sortColumn]) return -1 * direction;
    if (a[sortColumn] > b[sortColumn]) return 1 * direction;
    return 0;
  });

  const getSortIcon = (column) => {
    if (sortColumn !== column) return <FaSort className="sort-icon" />;
    return sortDirection === "asc" ? (
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
      <div className="row">
        <div className="col-sm-12">
          <Breadcrumb />
        </div>
      </div>
      <div className="row">
        <div className="col-sm-12">
          <div className="card-list-ad">
            <div className=" header-list-card">
              <div style={{ float: "left" }}>
                <h1 className="title-ad">DANH SÁCH KHÁCH HÀNG</h1>
              </div>
              <div className="search-bar">
                <input
                  type="text"
                  placeholder="Tìm kiếm..."
                  value={searchQuery}
                  onChange={handleSearch}
                />
                <FcSearch className="search-icon" />
              </div>
            </div>

            {/* Bảng danh sách người dùng */}
            <table className="user-table">
              <thead>
                <tr>
                  <th>Hình ảnh</th>
                  <th onClick={() => handleSort("hoTen")}>
                    <div className="nameandsort">
                      <span>Tên khách</span>
                      <span className="sort-icon">{getSortIcon("hoTen")}</span>
                    </div>
                  </th>
                  <th onClick={() => handleSort("gioiTinh")}>
                    <div className="nameandsort">
                      <span>Giới Tính</span>
                      <span className="sort-icon">
                        {getSortIcon("gioiTinh")}
                      </span>
                    </div>
                  </th>
                  <th>Email</th>
                  <th>Số điện thoại</th>
                  <th>Chức năng</th>
                </tr>
              </thead>
              <tbody>
                {sortedDoctors.length > 0 ? (
                  sortedDoctors.map((user) => (
                    <tr key={user._id}>
                      <td>
                        <img
                          src={user.hinhAnh}
                          alt={`Hình của ${user.hoTen}`}
                          style={{
                            width: "6rem",
                            height: "6rem",
                            borderRadius: "50%",
                            objectFit: "cover",
                          }}
                        />
                      </td>
                      <td>{user.hoTen}</td>
                      <td>{user.gioiTinh}</td>
                      <td>{user.email}</td>
                      <td>{user.soDienThoai}</td>
                      <td>
                        <button
                          className="icon-function"
                          onClick={() => handleEditUser(user._id)}
                        >
                          <FaPenToSquare color="#66B5A3" />
                        </button>
                        <button
                          className="icon-function"
                          onClick={() => deleteUser(user._id)}
                        >
                          <FaTrash color="#66B5A3" />
                        </button>
                        <button
                          className="icon-function"
                          onClick={() => detailUser(user._id)}
                        >
                          <FaRegEye color="#66B5A3" />
                        </button>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="5">Không có người dùng nào</td>
                  </tr>
                )}
              </tbody>
            </table>

            {/* Pagination */}
            <div className="pagination">
              {Array.from(
                { length: Math.ceil(filtered.length / doctorsPerPage) },
                (_, index) => (
                  <button
                    key={index + 1}
                    onClick={() => paginate(index + 1)}
                    className={currentPage === index + 1 ? "active" : ""}
                  >
                    {index + 1}
                  </button>
                )
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Nút thêm người dùng */}
      <Fab
        onClick={handleAddUser}
        sx={{
          backgroundColor: "#66B5A3",
          "&:hover": { backgroundColor: "#97c9bc" },
          position: "fixed",
          bottom: 50,
          right: 50,
          animation: "animate 2s linear infinite",
        }}
        aria-label="add"
      >
        <FaPlus color="white" size={18} />
      </Fab>
    </div>
  );
};

export default DSKhachHang;
