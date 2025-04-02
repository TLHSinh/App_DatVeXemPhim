import React, { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import "./DanhSach.css";
import { Fab, TextField } from "@mui/material";
import { toast } from "react-toastify";
import { BASE_URL } from "../../../config";
import { AuthContext } from "../../../context/AuthContext.jsx"; // Import AuthContext để lấy token
import { FaPenToSquare, FaTrash, FaPlus, FaRegEye } from "react-icons/fa6";
import { FcSearch } from "react-icons/fc";
import Breadcrumb from "../../../Components/Breadcrumb";
import { FaSort, FaSortUp, FaSortDown } from "react-icons/fa";

const DSThuocVatTu = () => {
  const navigate = useNavigate();
  const { token } = useContext(AuthContext);
  const [inventory, setInventory] = useState([]);
  const [filtered, setFilteredInventory] = useState([]);
  const [sortColumn, setSortColumn] = useState("");
  const [sortDirection, setSortDirection] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const doctorsPerPage = 5;

  const fetchInventory = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/inventory`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      const result = await res.json(); // Chuyển đổi JSON từ API
      if (result.success && Array.isArray(result.data)) {
        setInventory(result.data); // Gán mảng vật tư vào state
        setFilteredInventory(result.data); // Gán mảng vật tư vào state lọc ban đầu
      } else {
        throw new Error(result.message || "Lỗi lấy danh sách thuốc và vật tư");
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
    const filtered = inventory.filter(
      (item) => item.tenVatTu.toLowerCase().includes(query) // Lọc theo tên vật tư
    );
    setFilteredInventory(filtered);
    setCurrentPage(1);
  };

  // Xóa vật tư với xác thực
  const deleteUser = async (id) => {
    if (!window.confirm("Bạn có chắc chắn muốn xóa thuốc hoặc vật tư này?"))
      return;

    try {
      const res = await fetch(`${BASE_URL}/api/v1/inventory/${id}`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      const result = await res.json();
      if (result.success) {
        toast.success(result.message);
        setInventory(inventory.filter((item) => item._id !== id));
        setFilteredInventory(
          setFilteredInventory.filter((item) => item._id !== id)
        ); // Cập nhật danh sách lọc
      } else {
        toast.error(result.message);
      }
    } catch (err) {
      toast.error(`Lỗi: ${err.message}`);
    }
  };

  useEffect(() => {
    fetchInventory();
  }, []);

  const handleAddUser = () => {
    navigate("/admin/themthuocvattu"); // Điều hướng đến trang thêm vật tư
  };

  const handleEditUser = (id) => {
    navigate(`/admin/chinhsuathuocvattu/${id}`); // Chuyển hướng tới trang chỉnh sửa kèm ID
  };

  const detailUser = (id) => {
    navigate(`/admin/chitietthuocvattu/${id}`);
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
                <h1 className="title-ad">DANH SÁCH THUỐC - VẬT TƯ</h1>
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

            {/* Bảng danh sách vật tư */}
            <table className="user-table">
              <thead>
                <tr>
                  <th onClick={() => handleSort("tenVatTu")}>
                    <div className="nameandsort">
                      <span>Tên vật tư</span>
                      <span className="sort-icon">{getSortIcon("ten")}</span>
                    </div>
                  </th>
                  <th onClick={() => handleSort("loaiVatTu")}>
                    <div className="nameandsort">
                      <span>Loại vật tư</span>
                      <span className="sort-icon">{getSortIcon("ten")}</span>
                    </div>
                  </th>
                  <th>Số lượng</th>
                  <th>Giá</th>
                  <th>Đơn vị</th>
                  <th>Chức năng</th>
                </tr>
              </thead>
              <tbody>
                {sortedDoctors.length > 0 ? (
                  sortedDoctors.map((item) => (
                    <tr key={item._id}>
                      <td>{item.tenVatTu}</td>
                      <td>{item.loaiVatTu}</td>
                      <td>{item.soLuong}</td>
                      <td>{item.gia}</td>
                      <td>{item.donViTinh}</td>
                      <td>
                        <button
                          className="icon-function"
                          onClick={() => handleEditUser(item._id)}
                        >
                          <FaPenToSquare color="#66B5A3" />
                        </button>
                        <button
                          className="icon-function"
                          onClick={() => deleteUser(item._id)}
                        >
                          <FaTrash color="#66B5A3" />
                        </button>
                        <button
                          className="icon-function"
                          onClick={() => detailUser(item._id)}
                        >
                          <FaRegEye color="#66B5A3" />
                        </button>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="6">Không có vật tư nào</td>
                  </tr>
                )}
              </tbody>
            </table>

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

            {/* Nút thêm vật tư */}
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
        </div>
      </div>
    </div>
  );
};

export default DSThuocVatTu;
