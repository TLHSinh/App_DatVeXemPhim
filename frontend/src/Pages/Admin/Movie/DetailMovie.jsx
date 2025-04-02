import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
// Nếu bạn sử dụng thư viện phân tích HTML, hãy import nó ở đây
//simport parse from "html-react-parser";

const ChiTietPhim = () => {
  // Giả lập useParams và useNavigate nếu không sử dụng React Router
  const params = { id: window.location.pathname.split("/").pop() };
  // Thay thế bằng tham chiếu thực tế hoặc mock function cho testing
  const navigate = useNavigate(); // Gọi hook đúng cách
  const token = "your-auth-token"; // Mock token for testing

  const [movie, setMovie] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchMovieDetails();
  }, [params.id]);

  const fetchMovieDetails = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `http://localhost:5000/api/v1/movie/phims/${params.id}`
      );

      if (!response.ok) {
        throw new Error(`Lỗi HTTP: ${response.status}`);
      }

      const result = await response.json();

      if (result.success && result.data) {
        setMovie(result.data);
      } else {
        throw new Error("Không tìm thấy thông tin phim");
      }
    } catch (err) {
      console.error("Lỗi khi tải thông tin phim:", err);
      setError(`Không thể tải thông tin phim: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  // Định dạng ngày tháng
  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    const date = new Date(dateString);
    return date.toLocaleDateString("vi-VN");
  };

  // Xử lý nhúng video YouTube
  const getYoutubeEmbedUrl = (url) => {
    if (!url) return null;
    const regExp =
      /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);
    return match && match[2].length === 11
      ? `https://www.youtube.com/embed/${match[2]}`
      : null;
  };

  // Render giới hạn tuổi
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
          padding: "5px 10px",
          borderRadius: "4px",
          color: "white",
          fontWeight: "bold",
          fontSize: "0.9rem",
          display: "inline-block",
          marginRight: "10px",
        }}
      >
        {limit}
      </span>
    );
  };

  // Render đánh giá sao
  const renderStarRating = (rating) => {
    const stars = [];
    const maxStars = 5;

    for (let i = 1; i <= maxStars; i++) {
      stars.push(
        <span
          key={i}
          style={{
            color: i <= rating ? "#FFD700" : "#D3D3D3",
            fontSize: "1.5rem",
            marginRight: "5px",
          }}
        >
          ★
        </span>
      );
    }

    return (
      <div style={{ display: "flex", alignItems: "center" }}>
        {stars}
        <span style={{ marginLeft: "10px", fontSize: "1.1rem" }}>
          ({rating}/5)
        </span>
      </div>
    );
  };

  // Handle edit button click
  const handleEdit = () => {
    if (movie && movie._id) {
      navigate(`/admin/chinhsuaphim/${movie._id}`);
    }
  };

  // Handle back button click
  const handleBack = () => {
    navigate("/admin/ListMovies");
  };

  // CSS Styles
  const styles = {
    container: {
      padding: "20px",
      fontFamily: "Arial, sans-serif",
      maxWidth: "1200px",
      margin: "0 auto",
    },
    breadcrumb: {
      marginBottom: "20px",
      fontSize: "0.9rem",
    },
    breadcrumbLink: {
      color: "#66B5A3",
      textDecoration: "none",
      cursor: "pointer",
    },
    card: {
      backgroundColor: "white",
      borderRadius: "8px",
      boxShadow: "0 2px 8px rgba(0,0,0,0.1)",
      padding: "30px",
      marginBottom: "20px",
    },
    header: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      marginBottom: "30px",
      borderBottom: "1px solid #eee",
      paddingBottom: "15px",
    },
    title: {
      fontSize: "26px",
      fontWeight: "bold",
      color: "#333",
      margin: 0,
    },
    buttonContainer: {
      display: "flex",
      gap: "15px",
    },
    button: {
      padding: "10px 20px",
      borderRadius: "4px",
      cursor: "pointer",
      fontWeight: "bold",
      border: "none",
      display: "flex",
      alignItems: "center",
      gap: "8px",
    },
    primaryButton: {
      backgroundColor: "#66B5A3",
      color: "white",
    },
    secondaryButton: {
      backgroundColor: "#f5f5f5",
      color: "#333",
      border: "1px solid #ddd",
    },
    content: {
      display: "flex",
      gap: "30px",
      flexWrap: "wrap",
    },
    posterContainer: {
      flex: "0 0 300px",
    },
    poster: {
      width: "100%",
      borderRadius: "8px",
      boxShadow: "0 4px 8px rgba(0,0,0,0.2)",
    },
    infoContainer: {
      flex: "1 1 600px",
    },
    infoGroup: {
      marginBottom: "25px",
    },
    infoLabel: {
      fontWeight: "bold",
      color: "#555",
      marginBottom: "8px",
      fontSize: "0.9rem",
    },
    infoValue: {
      fontSize: "1rem",
      color: "#333",
    },
    trailerSection: {
      marginTop: "40px",
    },
    trailerContainer: {
      position: "relative",
      paddingBottom: "56.25%", // 16:9 aspect ratio
      height: 0,
      overflow: "hidden",
      borderRadius: "8px",
    },
    iframe: {
      position: "absolute",
      top: 0,
      left: 0,
      width: "100%",
      height: "100%",
      border: "none",
    },
    sectionTitle: {
      fontSize: "20px",
      fontWeight: "bold",
      marginBottom: "15px",
      color: "#333",
      borderBottom: "2px solid #66B5A3",
      paddingBottom: "8px",
      display: "inline-block",
    },
    metadata: {
      display: "flex",
      flexWrap: "wrap",
      gap: "20px",
      marginBottom: "20px",
    },
    metadataItem: {
      display: "flex",
      alignItems: "center",
      gap: "8px",
    },
    icon: {
      fontSize: "1.2rem",
      color: "#66B5A3",
    },
    description: {
      lineHeight: "1.6",
      fontSize: "1rem",
      color: "#333",
    },
    loadingContainer: {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      minHeight: "300px",
    },
    errorContainer: {
      padding: "20px",
      backgroundColor: "#ffebee",
      color: "red",
      borderRadius: "4px",
      marginBottom: "20px",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: "15px",
    },
    retryButton: {
      padding: "10px 20px",
      backgroundColor: "#66B5A3",
      color: "white",
      border: "none",
      borderRadius: "4px",
      cursor: "pointer",
      fontWeight: "bold",
    },
  };

  if (loading) {
    return (
      <div style={styles.container}>
        <div style={styles.breadcrumb}>
          <span>Trang chủ / </span>
          <span style={styles.breadcrumbLink} onClick={handleBack}>
            Quản lý phim
          </span>
          <span> / Chi tiết phim</span>
        </div>
        <div style={styles.card}>
          <div style={styles.loadingContainer}>
            <p>Đang tải thông tin phim...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div style={styles.container}>
        <div style={styles.breadcrumb}>
          <span>Trang chủ / </span>
          <span style={styles.breadcrumbLink} onClick={handleBack}>
            Quản lý phim
          </span>
          <span> / Chi tiết phim</span>
        </div>
        <div style={styles.card}>
          <div style={styles.errorContainer}>
            <p>{error}</p>
            <button style={styles.retryButton} onClick={fetchMovieDetails}>
              Thử lại
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (!movie) {
    return (
      <div style={styles.container}>
        <div style={styles.breadcrumb}>
          <span>Trang chủ / </span>
          <span style={styles.breadcrumbLink} onClick={handleBack}>
            Quản lý phim
          </span>
          <span> / Chi tiết phim</span>
        </div>
        <div style={styles.card}>
          <div style={styles.errorContainer}>
            <p>Không tìm thấy thông tin phim</p>
            <button
              style={{ ...styles.button, ...styles.primaryButton }}
              onClick={handleBack}
            >
              Quay lại danh sách phim
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      <div style={styles.breadcrumb}>
        <span>Trang chủ / </span>
        <span style={styles.breadcrumbLink} onClick={handleBack}>
          Quản lý phim
        </span>
        <span> / Chi tiết phim</span>
      </div>

      <div style={styles.card}>
        <div style={styles.header}>
          <h1 style={styles.title}>{movie.ten_phim}</h1>
          <div style={styles.buttonContainer}>
            <button
              style={{ ...styles.button, ...styles.secondaryButton }}
              onClick={handleBack}
            >
              ← Quay lại
            </button>
            <button
              style={{ ...styles.button, ...styles.primaryButton }}
              onClick={handleEdit}
            >
              ✏️ Chỉnh sửa
            </button>
          </div>
        </div>

        <div style={styles.content}>
          <div style={styles.posterContainer}>
            {movie.url_poster ? (
              <img
                src={movie.url_poster}
                alt={movie.ten_phim}
                style={styles.poster}
              />
            ) : (
              <div
                style={{
                  width: "100%",
                  height: "450px",
                  backgroundColor: "#eee",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  borderRadius: "8px",
                  color: "#999",
                }}
              >
                Không có poster
              </div>
            )}
          </div>

          <div style={styles.infoContainer}>
            <div style={styles.metadata}>
              <div style={styles.metadataItem}>
                <span style={styles.icon}>🎬</span>
                <span style={styles.infoValue}>Mã phim: {movie.ma_phim}</span>
              </div>
              <div style={styles.metadataItem}>
                <span style={styles.icon}>⏱️</span>
                <span style={styles.infoValue}>{movie.thoi_luong} phút</span>
              </div>
              <div style={styles.metadataItem}>
                <span style={styles.icon}>📅</span>
                <span style={styles.infoValue}>
                  Công chiếu: {formatDate(movie.ngay_cong_chieu)}
                </span>
              </div>
              {movie.ngon_ngu && (
                <div style={styles.metadataItem}>
                  <span style={styles.icon}>🌐</span>
                  <span style={styles.infoValue}>{movie.ngon_ngu}</span>
                </div>
              )}
            </div>

            <div style={styles.infoGroup}>
              {renderAgeLimit(movie.gioi_han_tuoi)}
              {renderStarRating(movie.danh_gia)}
            </div>

            <div style={styles.infoGroup}>
              <h3 style={styles.sectionTitle}>Mô tả</h3>
              <div
                style={styles.description}
                // Sử dụng dangerouslySetInnerHTML khi không có thư viện parse HTML
                dangerouslySetInnerHTML={{
                  __html: movie.mo_ta || "Chưa có mô tả",
                }}
                // Hoặc sử dụng parse nếu bạn có thư viện html-react-parser
                // {parse(movie.mo_ta || "Chưa có mô tả")}
              />
            </div>

            <div style={styles.infoGroup}>
              <h3 style={styles.sectionTitle}>Thông tin thêm</h3>
              <div style={{ ...styles.metadata, marginTop: "15px" }}>
                <div style={styles.metadataItem}>
                  <span style={styles.infoLabel}>Ngày tạo:</span>
                  <span style={styles.infoValue}>
                    {formatDate(movie.createdAt)}
                  </span>
                </div>
                <div style={styles.metadataItem}>
                  <span style={styles.infoLabel}>Cập nhật:</span>
                  <span style={styles.infoValue}>
                    {formatDate(movie.updatedAt)}
                  </span>
                </div>
                <div style={styles.metadataItem}>
                  <span style={styles.infoLabel}>Phiên bản:</span>
                  <span style={styles.infoValue}>{movie.phien_ban}</span>
                </div>
                <div style={styles.metadataItem}>
                  <span style={styles.infoLabel}>ID:</span>
                  <span style={styles.infoValue}>{movie._id}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {movie.url_trailer && (
          <div style={styles.trailerSection}>
            <h3 style={styles.sectionTitle}>Trailer</h3>
            <div style={styles.trailerContainer}>
              <iframe
                style={styles.iframe}
                src={getYoutubeEmbedUrl(movie.url_trailer)}
                title={`${movie.ten_phim} trailer`}
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              />
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ChiTietPhim;
