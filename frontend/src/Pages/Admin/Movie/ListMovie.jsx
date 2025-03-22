import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import { AuthContext } from "../../../context/AuthContext.jsx";

// Component quản lý danh sách phim
const DSPhim = () => {
  const navigate = useNavigate();
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

  const createSchedule = (id) => {
    navigate(`/admin/CreateScheduleMovie/${id}`);
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

  // Get sort icon (dùng các icon SVG đẹp hơn thay vì emoji)
  const getSortIcon = (column) => {
    if (sortColumn !== column) {
      return (
        <svg
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="m7 15 5 5 5-5"></path>
          <path d="m7 9 5-5 5 5"></path>
        </svg>
      );
    }
    return sortDirection === "asc" ? (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="m18 15-6-6-6 6"></path>
      </svg>
    ) : (
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="m6 9 6 6 6-6"></path>
      </svg>
    );
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
      color: "#666",
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
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      color: "#555",
      transition: "color 0.2s ease",
      borderRadius: "4px",
      width: "32px",
      height: "32px",
    },
    editButton: {
      color: "#4285F4",
      backgroundColor: "rgba(66, 133, 244, 0.1)",
    },
    deleteButton: {
      color: "#EA4335",
      backgroundColor: "rgba(234, 67, 53, 0.1)",
    },
    viewButton: {
      color: "#34A853",
      backgroundColor: "rgba(52, 168, 83, 0.1)",
    },
    scheduleButton: {
      color: "#FBBC05",
      backgroundColor: "rgba(251, 188, 5, 0.1)",
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
      transition: "transform 0.2s ease, background-color 0.2s ease",
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
      display: "flex",
      alignItems: "center",
      gap: "8px",
    },
    iconWrapper: {
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
    },
    ratingWrapper: {
      display: "flex",
      alignItems: "center",
      gap: "4px",
    },
  };

  return (
    <div style={styles.container}>
      <div style={{ marginBottom: "20px" }}>
        {/* Breadcrumb với icon đẹp hơn */}
        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
            <polyline points="9 22 9 12 15 12 15 22"></polyline>
          </svg>
          <span>Trang chủ</span>
          <svg
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
          <span style={{ fontWeight: "500" }}>Quản lý phim</span>
        </div>
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
            <div style={styles.searchIcon}>
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
              </svg>
            </div>
          </div>
        </div>

        {/* Loading state */}
        {loading && (
          <div style={styles.loadingContainer}>
            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                style={{ animation: "spin 2s linear infinite" }}
              >
                <line x1="12" y1="2" x2="12" y2="6"></line>
                <line x1="12" y1="18" x2="12" y2="22"></line>
                <line x1="4.93" y1="4.93" x2="7.76" y2="7.76"></line>
                <line x1="16.24" y1="16.24" x2="19.07" y2="19.07"></line>
                <line x1="2" y1="12" x2="6" y2="12"></line>
                <line x1="18" y1="12" x2="22" y2="12"></line>
                <line x1="4.93" y1="19.07" x2="7.76" y2="16.24"></line>
                <line x1="16.24" y1="7.76" x2="19.07" y2="4.93"></line>
              </svg>
              <p>Đang tải dữ liệu phim...</p>
            </div>
          </div>
        )}

        {/* Error state */}
        {error && (
          <div style={styles.errorContainer}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "10px",
                marginBottom: "10px",
              }}
            >
              <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                style={{ color: "#EA4335" }}
              >
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="8" x2="12" y2="12"></line>
                <line x1="12" y1="16" x2="12.01" y2="16"></line>
              </svg>
              <p>{error}</p>
            </div>
            <button style={styles.refreshButton} onClick={fetchFilms}>
              <svg
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M21 2v6h-6"></path>
                <path d="M3 12a9 9 0 0 1 15-6.7L21 8"></path>
                <path d="M3 22v-6h6"></path>
                <path d="M21 12a9 9 0 0 1-15 6.7L3 16"></path>
              </svg>
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
                            src={`https://rapchieuphim.com${film.url_poster}`}
                            alt={film.ten_phim}
                            style={styles.poster}
                            onError={(e) =>
                              (e.target.src = "https://via.placeholder.com/300")
                            }
                          />
                        ) : (
                          <div style={styles.noImage}>
                            <svg
                              width="20"
                              height="20"
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="2"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            >
                              <rect
                                x="3"
                                y="3"
                                width="18"
                                height="18"
                                rx="2"
                                ry="2"
                              ></rect>
                              <circle cx="8.5" cy="8.5" r="1.5"></circle>
                              <polyline points="21 15 16 10 5 21"></polyline>
                            </svg>
                          </div>
                        )}
                      </td>

                      <td style={styles.td}>
                        <div style={styles.ratingWrapper}>
                          {film.danh_gia}/5
                          <svg
                            width="16"
                            height="16"
                            viewBox="0 0 24 24"
                            fill="#FFD700"
                            stroke="#FFD700"
                            strokeWidth="1"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          >
                            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                          </svg>
                        </div>
                      </td>
                      <td style={styles.td}>
                        {renderAgeLimit(film.gioi_han_tuoi)}
                      </td>
                      <td style={styles.td}>
                        <div
                          style={{
                            display: "flex",
                            alignItems: "center",
                            gap: "5px",
                          }}
                        >
                          <svg
                            width="16"
                            height="16"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          >
                            <circle cx="12" cy="12" r="10"></circle>
                            <polyline points="12 6 12 12 16 14"></polyline>
                          </svg>
                          {film.thoi_luong} phút
                        </div>
                      </td>
                      <td style={styles.td}>
                        <div
                          style={{
                            display: "flex",
                            alignItems: "center",
                            gap: "5px",
                          }}
                        >
                          <svg
                            width="16"
                            height="16"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          >
                            <rect
                              x="3"
                              y="4"
                              width="18"
                              height="18"
                              rx="2"
                              ry="2"
                            ></rect>
                            <line x1="16" y1="2" x2="16" y2="6"></line>
                            <line x1="8" y1="2" x2="8" y2="6"></line>
                            <line x1="3" y1="10" x2="21" y2="10"></line>
                          </svg>
                          {formatDate(film.ngay_cong_chieu)}
                        </div>
                      </td>
                      <td style={styles.td}>
                        <button
                          style={{
                            ...styles.actionButton,
                            ...styles.editButton,
                          }}
                          onClick={() => handleEditFilm(film._id)}
                          title="Chỉnh sửa phim"
                        >
                          <svg
                            width="18"
                            height="18"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          >
                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                          </svg>
                        </button>
                        <button
                          style={{
                            ...styles.actionButton,
                            ...styles.deleteButton,
                          }}
                          onClick={() => deleteFilm(film._id)}
                          title="Xóa phim"
                        >
                          <svg
                            width="18"
                            height="18"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          >
                            <path d="M3 6h18"></path>
                            <path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"></path>
                            <path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"></path>
                          </svg>
                        </button>
                        <button
                          style={{
                            ...styles.actionButton,
                            ...styles.viewButton,
                          }}
                          onClick={() => detailFilm(film._id)}
                          title="Xem chi tiết"
                        >
                          <svg
                            width="18"
                            height="18"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          >
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                          </svg>
                        </button>

                        <button
                          style={{
                            ...styles.actionButton,
                            ...styles.scheduleButton,
                          }}
                          onClick={() => createSchedule(film._id)}
                          title="Thêm lịch chiếu"
                        >
                          <svg
                            width="18"
                            height="18"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeWidth="2"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          >
                            <rect
                              x="3"
                              y="4"
                              width="18"
                              height="18"
                              rx="2"
                              ry="2"
                            ></rect>
                            <line x1="16" y1="2" x2="16" y2="6"></line>
                            <line x1="8" y1="2" x2="8" y2="6"></line>
                            <line x1="3" y1="10" x2="21" y2="10"></line>
                            <line x1="10" y1="14" x2="14" y2="18"></line>
                            <line x1="14" y1="14" x2="10" y2="18"></line>
                          </svg>
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
                      <div
                        style={{
                          display: "flex",
                          justifyContent: "center",
                          alignItems: "center",
                          gap: "10px",
                        }}
                      >
                        <svg
                          width="24"
                          height="24"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2"
                          strokeLinecap="round"
                          strokeLinejoin="round"
                        >
                          <circle cx="12" cy="12" r="10"></circle>
                          <line x1="12" y1="8" x2="12" y2="12"></line>
                          <line x1="12" y1="16" x2="12.01" y2="16"></line>
                        </svg>
                        Không có phim nào phù hợp với điều kiện tìm kiếm
                      </div>
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
