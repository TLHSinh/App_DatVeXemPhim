import React, { useEffect, useState } from "react";
// Chỉ import những thư viện cần thiết và sẵn có trong dự án của bạn
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import { AuthContext } from "../../../context/AuthContext.jsx";

// Component quản lý danh sách phim
const DSPhim = () => {
  // Thay thế bằng tham chiếu thực tế hoặc mock function cho testing
  const navigate = useNavigate(); // Gọi hook đúng cách
  const token = "your-auth-token"; // Mock token for testing

  const [films, setFilms] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [sortColumn, setSortColumn] = useState("");
  const [sortDirection, setSortDirection] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const filmsPerPage = 5;

  // Fetch data from API
  const fetchFilms = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        "http://localhost:5000/api/v1/movie/Allphims"
      );

      if (!response.ok) {
        throw new Error(`Lỗi HTTP: ${response.status}`);
      }

      const data = await response.json();
      console.log("Data received:", data); // For debugging
      setFilms(data);
      setFiltered(data);
      setLoading(false);
    } catch (err) {
      console.error("Lỗi khi tải dữ liệu:", err);
      setError(`Lỗi khi tải dữ liệu: ${err.message}`);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFilms();
  }, []);

  // Xử lý tìm kiếm
  const handleSearch = (e) => {
    const query = e.target.value.toLowerCase();
    setSearchQuery(query);
    const filtered = films.filter(
      (item) =>
        item.ten_phim.toLowerCase().includes(query) ||
        item.ma_phim.toLowerCase().includes(query)
    );
    setFiltered(filtered);
    setCurrentPage(1);
  };

  // Xử lý xóa film
  const deleteFilm = async (id) => {
    if (!window.confirm("Bạn có chắc chắn muốn xóa phim này?")) return;

    try {
      //Thay thế bằng API call thực tế
      const response = await fetch(
        `http://localhost:5000/api/v1/admin/movies/${id}`,
        {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!response.ok) {
        throw new Error(`Lỗi HTTP: ${response.status}`);
      }

      // Cập nhật UI sau khi xóa
      const updatedFilms = films.filter((film) => film._id !== id);
      setFilms(updatedFilms);
      setFiltered(
        updatedFilms.filter(
          (film) =>
            film.ten_phim.toLowerCase().includes(searchQuery.toLowerCase()) ||
            film.ma_phim.toLowerCase().includes(searchQuery.toLowerCase())
        )
      );

      alert("Xóa phim thành công!");
    } catch (err) {
      console.error("Lỗi khi xóa phim:", err);
      alert(`Lỗi khi xóa phim: ${err.message}`);
    }
  };

  // Định dạng ngày tháng
  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    const date = new Date(dateString);
    return date.toLocaleDateString("vi-VN");
  };

  // Navigation handlers
  const handleAddFilm = () => {
    navigate("/admin/CreateMovie");
  };

  const handleEditFilm = (id) => {
    navigate(`/admin/UpdateMovie/${id}`);
  };

  const detailFilm = (id) => {
    navigate(`/admin/DetailMovie/${id}`);
  };

  // Sorting handler
  const handleSort = (column) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(column);
      setSortDirection("asc");
    }
    setCurrentPage(1);
  };

  // Pagination calculations
  const indexOfLastFilm = currentPage * filmsPerPage;
  const indexOfFirstFilm = indexOfLastFilm - filmsPerPage;
  const currentFilms = filtered.slice(indexOfFirstFilm, indexOfLastFilm);

  // Sort films
  const sortedFilms = [...currentFilms].sort((a, b) => {
    if (!sortColumn) return 0;
    const direction = sortDirection === "asc" ? 1 : -1;

    // Special handling for date fields
    if (sortColumn === "ngay_cong_chieu") {
      return direction * (new Date(a[sortColumn]) - new Date(b[sortColumn]));
    }

    if (a[sortColumn] < b[sortColumn]) return -1 * direction;
    if (a[sortColumn] > b[sortColumn]) return 1 * direction;
    return 0;
  });

  // Get sort icon (simple text instead of icon component)
  const getSortIcon = (column) => {
    if (sortColumn !== column) return "↕️";
    return sortDirection === "asc" ? "↑" : "↓";
  };

  // Pagination handler
  const paginate = (pageNumber) => setCurrentPage(pageNumber);

  // Render age limit
  const renderAgeLimit = (limit) => {
    let color = "";

    if (limit === "P") {
      color = "green";
    } else if (limit === "T13") {
      color = "yellow";
    } else if (limit === "T16") {
      color = "orange";
    } else if (limit === "T18") {
      color = "red";
    }

    return (
      <span
        style={{
          backgroundColor: color,
          padding: "3px 6px",
          borderRadius: "4px",
          color: "white",
          fontWeight: "bold",
          fontSize: "0.8rem",
        }}
      >
        {limit}
      </span>
    );
  };

  // CSS inline styles
  const styles = {
    container: {
      padding: "20px",
      fontFamily: "Arial, sans-serif",
    },
    cardList: {
      backgroundColor: "white",
      borderRadius: "8px",
      boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
      padding: "20px",
      marginBottom: "20px",
    },
    header: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      marginBottom: "20px",
    },
    title: {
      fontSize: "24px",
      fontWeight: "bold",
      color: "#333",
    },
    searchBar: {
      position: "relative",
      width: "300px",
    },
    searchInput: {
      width: "100%",
      padding: "8px 12px 8px 36px",
      borderRadius: "4px",
      border: "1px solid #ddd",
    },
    searchIcon: {
      position: "absolute",
      left: "10px",
      top: "50%",
      transform: "translateY(-50%)",
    },
    table: {
      width: "100%",
      borderCollapse: "collapse",
      marginBottom: "20px",
    },
    th: {
      padding: "12px 8px",
      backgroundColor: "#f5f5f5",
      textAlign: "left",
      borderBottom: "2px solid #ddd",
      cursor: "pointer",
    },
    td: {
      padding: "12px 8px",
      borderBottom: "1px solid #ddd",
    },
    columnHeader: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
    },
    poster: {
      width: "50px",
      height: "70px",
      objectFit: "cover",
      borderRadius: "4px",
    },
    noImage: {
      width: "50px",
      height: "70px",
      backgroundColor: "#eee",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: "4px",
      fontSize: "10px",
      color: "#999",
    },
    actionButton: {
      background: "none",
      border: "none",
      cursor: "pointer",
      marginRight: "10px",
      padding: "5px",
    },
    pagination: {
      display: "flex",
      justifyContent: "center",
      marginTop: "20px",
    },
    pageButton: {
      margin: "0 5px",
      padding: "8px 12px",
      borderRadius: "4px",
      border: "1px solid #ddd",
      background: "white",
      cursor: "pointer",
    },
    activePageButton: {
      backgroundColor: "#66B5A3",
      color: "white",
      border: "1px solid #66B5A3",
    },
    addButton: {
      position: "fixed",
      bottom: "50px",
      right: "50px",
      width: "56px",
      height: "56px",
      borderRadius: "50%",
      backgroundColor: "#66B5A3",
      color: "white",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      border: "none",
      boxShadow: "0 4px 8px rgba(0,0,0,0.2)",
      cursor: "pointer",
      fontSize: "24px",
    },
    loadingContainer: {
      display: "flex",
      justifyContent: "center",
      padding: "50px 0",
    },
    errorContainer: {
      padding: "20px",
      color: "red",
      backgroundColor: "#ffebee",
      borderRadius: "4px",
      marginBottom: "20px",
    },
    refreshButton: {
      padding: "8px 16px",
      backgroundColor: "#66B5A3",
      color: "white",
      border: "none",
      borderRadius: "4px",
      cursor: "pointer",
      marginTop: "10px",
    },
  };

  return (
    <div style={styles.container}>
      <div style={{ marginBottom: "20px" }}>
        {/* Breadcrumb placeholder */}
        <div>Trang chủ / Quản lý phim</div>
      </div>

      <div style={styles.cardList}>
        <div style={styles.header}>
          <h1 style={styles.title}>DANH SÁCH PHIM</h1>
          <div style={styles.searchBar}>
            <input
              style={styles.searchInput}
              type="text"
              placeholder="Tìm kiếm theo tên hoặc mã phim..."
              value={searchQuery}
              onChange={handleSearch}
            />
            <span style={styles.searchIcon}>🔍</span>
          </div>
        </div>

        {/* Loading state */}
        {loading && (
          <div style={styles.loadingContainer}>
            <p>Đang tải dữ liệu phim...</p>
          </div>
        )}

        {/* Error state */}
        {error && (
          <div style={styles.errorContainer}>
            <p>{error}</p>
            <button style={styles.refreshButton} onClick={fetchFilms}>
              Thử lại
            </button>
          </div>
        )}

        {/* Bảng danh sách phim */}
        {!loading && !error && (
          <>
            <table style={styles.table}>
              <thead>
                <tr>
                  <th style={styles.th} onClick={() => handleSort("ma_phim")}>
                    <div style={styles.columnHeader}>
                      <span>Mã phim</span>
                      <span>{getSortIcon("ma_phim")}</span>
                    </div>
                  </th>
                  <th style={styles.th} onClick={() => handleSort("ten_phim")}>
                    <div style={styles.columnHeader}>
                      <span>Tên phim</span>
                      <span>{getSortIcon("ten_phim")}</span>
                    </div>
                  </th>
                  <th style={styles.th}>Poster</th>
                  <th style={styles.th} onClick={() => handleSort("danh_gia")}>
                    <div style={styles.columnHeader}>
                      <span>Đánh giá</span>
                      <span>{getSortIcon("danh_gia")}</span>
                    </div>
                  </th>
                  <th style={styles.th}>Giới hạn tuổi</th>
                  <th
                    style={styles.th}
                    onClick={() => handleSort("thoi_luong")}
                  >
                    <div style={styles.columnHeader}>
                      <span>Thời lượng</span>
                      <span>{getSortIcon("thoi_luong")}</span>
                    </div>
                  </th>
                  <th
                    style={styles.th}
                    onClick={() => handleSort("ngay_cong_chieu")}
                  >
                    <div style={styles.columnHeader}>
                      <span>Ngày công chiếu</span>
                      <span>{getSortIcon("ngay_cong_chieu")}</span>
                    </div>
                  </th>
                  <th style={styles.th}>Chức năng</th>
                </tr>
              </thead>
              <tbody>
                {sortedFilms.length > 0 ? (
                  sortedFilms.map((film) => (
                    <tr key={film._id}>
                      <td style={styles.td}>{film.ma_phim}</td>
                      <td style={styles.td}>{film.ten_phim}</td>
                      <td style={styles.td}>
                        {film.url_poster ? (
                          <img
                            src={film.url_poster}
                            alt={film.ten_phim}
                            style={styles.poster}
                          />
                        ) : (
                          <div style={styles.noImage}>No image</div>
                        )}
                      </td>
                      <td style={styles.td}>
                        <div>{film.danh_gia}/5 ⭐</div>
                      </td>
                      <td style={styles.td}>
                        {renderAgeLimit(film.gioi_han_tuoi)}
                      </td>
                      <td style={styles.td}>{film.thoi_luong} phút</td>
                      <td style={styles.td}>
                        {formatDate(film.ngay_cong_chieu)}
                      </td>
                      <td style={styles.td}>
                        <button
                          style={styles.actionButton}
                          onClick={() => handleEditFilm(film._id)}
                          title="Chỉnh sửa phim"
                        >
                          ✏️
                        </button>
                        <button
                          style={styles.actionButton}
                          onClick={() => deleteFilm(film._id)}
                          title="Xóa phim"
                        >
                          🗑️
                        </button>
                        <button
                          style={styles.actionButton}
                          onClick={() => detailFilm(film._id)}
                          title="Xem chi tiết"
                        >
                          👁️
                        </button>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td
                      colSpan="8"
                      style={{
                        ...styles.td,
                        textAlign: "center",
                        padding: "20px",
                      }}
                    >
                      Không có phim nào
                    </td>
                  </tr>
                )}
              </tbody>
            </table>

            {/* Pagination */}
            {filtered.length > 0 && (
              <div style={styles.pagination}>
                {Array.from(
                  { length: Math.ceil(filtered.length / filmsPerPage) },
                  (_, index) => (
                    <button
                      key={index + 1}
                      onClick={() => paginate(index + 1)}
                      style={{
                        ...styles.pageButton,
                        ...(currentPage === index + 1
                          ? styles.activePageButton
                          : {}),
                      }}
                    >
                      {index + 1}
                    </button>
                  )
                )}
              </div>
            )}
          </>
        )}

        {/* Nút thêm phim */}
        <button
          style={styles.addButton}
          onClick={handleAddFilm}
          title="Thêm phim mới"
        >
          +
        </button>
      </div>
    </div>
  );
};

export default DSPhim;
