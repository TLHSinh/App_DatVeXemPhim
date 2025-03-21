import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";

const ChinhSuaPhim = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const token = "your-auth-token"; // Mock token for testing

  const [movie, setMovie] = useState({
    ten_phim: "",
    ma_phim: "",
    mo_ta: "",
    thoi_luong: "",
    ngay_cong_chieu: "",
    url_poster: "",
    url_trailer: "",
    gioi_han_tuoi: "P",
    ngon_ngu: "",
    danh_gia: 0,
    phien_ban: "",
  });

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [successMessage, setSuccessMessage] = useState("");

  useEffect(() => {
    fetchMovieDetails();
  }, [id]);

  const fetchMovieDetails = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `http://localhost:5000/api/v1/movie/phims/${id}`
      );

      if (!response.ok) {
        throw new Error(`Lỗi HTTP: ${response.status}`);
      }

      const result = await response.json();

      if (result.success && result.data) {
        // Format date to YYYY-MM-DD for input[type="date"]
        const formattedMovie = {
          ...result.data,
          ngay_cong_chieu: result.data.ngay_cong_chieu
            ? new Date(result.data.ngay_cong_chieu).toISOString().split("T")[0]
            : "",
        };
        setMovie(formattedMovie);
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

  const handleChange = (e) => {
    const { name, value } = e.target;
    setMovie({ ...movie, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError(null);
    setSuccessMessage("");

    try {
      const response = await fetch(
        `http://localhost:5000/api/v1/admin/movies/${id}`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify(movie),
        }
      );

      if (!response.ok) {
        throw new Error(`Lỗi HTTP: ${response.status}`);
      }

      const result = await response.json();

      if (result.success) {
        setSuccessMessage("Cập nhật phim thành công!");
        // Reload movie data to get the updated information
        fetchMovieDetails();
      } else {
        throw new Error(result.message || "Lỗi khi cập nhật phim");
      }
    } catch (err) {
      console.error("Lỗi khi cập nhật phim:", err);
      setError(`Không thể cập nhật phim: ${err.message}`);
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    navigate(`/admin/ListMovies `);
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
    form: {
      display: "flex",
      flexDirection: "column",
      gap: "20px",
    },
    formSection: {
      display: "flex",
      flexWrap: "wrap",
      gap: "20px",
    },
    formGroup: {
      flex: "1 1 300px",
      display: "flex",
      flexDirection: "column",
      gap: "8px",
    },
    label: {
      fontWeight: "bold",
      color: "#555",
      fontSize: "0.9rem",
    },
    input: {
      padding: "10px 15px",
      borderRadius: "4px",
      border: "1px solid #ddd",
      fontSize: "0.95rem",
    },
    textarea: {
      padding: "10px 15px",
      borderRadius: "4px",
      border: "1px solid #ddd",
      fontSize: "0.95rem",
      minHeight: "120px",
      resize: "vertical",
    },
    select: {
      padding: "10px 15px",
      borderRadius: "4px",
      border: "1px solid #ddd",
      fontSize: "0.95rem",
    },
    buttonContainer: {
      display: "flex",
      gap: "15px",
      justifyContent: "flex-end",
      marginTop: "20px",
      paddingTop: "20px",
      borderTop: "1px solid #eee",
    },
    button: {
      padding: "12px 20px",
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
    errorMessage: {
      padding: "15px",
      backgroundColor: "#ffebee",
      color: "red",
      borderRadius: "4px",
      marginBottom: "20px",
    },
    successMessage: {
      padding: "15px",
      backgroundColor: "#e8f5e9",
      color: "green",
      borderRadius: "4px",
      marginBottom: "20px",
    },
    loadingContainer: {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      minHeight: "300px",
    },
    previewSection: {
      marginTop: "30px",
    },
    previewTitle: {
      fontSize: "18px",
      fontWeight: "bold",
      marginBottom: "15px",
      color: "#333",
      borderBottom: "2px solid #66B5A3",
      paddingBottom: "8px",
      display: "inline-block",
    },
    posterPreview: {
      maxWidth: "200px",
      borderRadius: "8px",
      boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
    },
    noImageContainer: {
      width: "200px",
      height: "300px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: "#f5f5f5",
      borderRadius: "8px",
      color: "#999",
    },
    ratingContainer: {
      display: "flex",
      alignItems: "center",
      gap: "8px",
    },
  };

  if (loading) {
    return (
      <div style={styles.container}>
        <div style={styles.breadcrumb}>
          <span>Trang chủ / </span>
          <span
            style={styles.breadcrumbLink}
            onClick={() => navigate("/admin/ListMovies")}
          >
            Quản lý phim
          </span>
          <span> / Chỉnh sửa phim</span>
        </div>
        <div style={styles.card}>
          <div style={styles.loadingContainer}>
            <p>Đang tải thông tin phim...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error && !movie._id) {
    return (
      <div style={styles.container}>
        <div style={styles.breadcrumb}>
          <span>Trang chủ / </span>
          <span
            style={styles.breadcrumbLink}
            onClick={() => navigate("/admin/ListMovies")}
          >
            Quản lý phim
          </span>
          <span> / Chỉnh sửa phim</span>
        </div>
        <div style={styles.card}>
          <div style={styles.errorMessage}>
            <p>{error}</p>
            <button
              style={{
                ...styles.button,
                ...styles.primaryButton,
                marginTop: "15px",
              }}
              onClick={fetchMovieDetails}
            >
              Thử lại
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
        <span
          style={styles.breadcrumbLink}
          onClick={() => navigate("/admin/ListMovies")}
        >
          Quản lý phim
        </span>
        <span> / </span>
        <span
          style={styles.breadcrumbLink}
          onClick={() => navigate(`/admin/chitietphim/${id}`)}
        >
          Chi tiết phim
        </span>
        <span> / Chỉnh sửa phim</span>
      </div>

      <div style={styles.card}>
        <div style={styles.header}>
          <h1 style={styles.title}>Chỉnh sửa phim: {movie.ten_phim}</h1>
        </div>

        {error && <div style={styles.errorMessage}>{error}</div>}
        {successMessage && (
          <div style={styles.successMessage}>{successMessage}</div>
        )}

        <form style={styles.form} onSubmit={handleSubmit}>
          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="ten_phim">
                Tên phim *
              </label>
              <input
                style={styles.input}
                type="text"
                id="ten_phim"
                name="ten_phim"
                value={movie.ten_phim}
                onChange={handleChange}
                required
              />
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="ma_phim">
                Mã phim *
              </label>
              <input
                style={styles.input}
                type="text"
                id="ma_phim"
                name="ma_phim"
                value={movie.ma_phim}
                onChange={handleChange}
                required
              />
            </div>
          </div>

          <div style={styles.formGroup}>
            <label style={styles.label} htmlFor="mo_ta">
              Mô tả
            </label>
            <textarea
              style={styles.textarea}
              id="mo_ta"
              name="mo_ta"
              value={movie.mo_ta || ""}
              onChange={handleChange}
            />
          </div>

          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="thoi_luong">
                Thời lượng (phút) *
              </label>
              <input
                style={styles.input}
                type="number"
                id="thoi_luong"
                name="thoi_luong"
                value={movie.thoi_luong}
                onChange={handleChange}
                min="0"
                required
              />
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="ngay_cong_chieu">
                Ngày công chiếu *
              </label>
              <input
                style={styles.input}
                type="date"
                id="ngay_cong_chieu"
                name="ngay_cong_chieu"
                value={movie.ngay_cong_chieu}
                onChange={handleChange}
                required
              />
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="ngon_ngu">
                Ngôn ngữ
              </label>
              <input
                style={styles.input}
                type="text"
                id="ngon_ngu"
                name="ngon_ngu"
                value={movie.ngon_ngu || ""}
                onChange={handleChange}
              />
            </div>
          </div>

          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="url_poster">
                Đường dẫn Poster
              </label>
              <input
                style={styles.input}
                type="url"
                id="url_poster"
                name="url_poster"
                value={movie.url_poster || ""}
                onChange={handleChange}
                placeholder="https://example.com/poster.jpg"
              />
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="url_trailer">
                Đường dẫn Trailer
              </label>
              <input
                style={styles.input}
                type="url"
                id="url_trailer"
                name="url_trailer"
                value={movie.url_trailer || ""}
                onChange={handleChange}
                placeholder="https://youtube.com/watch?v=..."
              />
            </div>
          </div>

          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="gioi_han_tuoi">
                Giới hạn tuổi *
              </label>
              <select
                style={styles.select}
                id="gioi_han_tuoi"
                name="gioi_han_tuoi"
                value={movie.gioi_han_tuoi}
                onChange={handleChange}
                required
              >
                <option value="P">P - Phổ thông</option>
                <option value="T13">T13 - Trên 13 tuổi</option>
                <option value="T16">T16 - Trên 16 tuổi</option>
                <option value="T18">T18 - Trên 18 tuổi</option>
              </select>
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="danh_gia">
                Đánh giá
              </label>
              <div style={styles.ratingContainer}>
                <input
                  style={{ ...styles.input, flex: 1 }}
                  type="number"
                  id="danh_gia"
                  name="danh_gia"
                  value={movie.danh_gia}
                  onChange={handleChange}
                  min="0"
                  max="5"
                  step="0.1"
                />
                <span>/5</span>
              </div>
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="phien_ban">
                Phiên bản
              </label>
              <input
                style={styles.input}
                type="text"
                id="phien_ban"
                name="phien_ban"
                value={movie.phien_ban || ""}
                onChange={handleChange}
              />
            </div>
          </div>

          {movie.url_poster && (
            <div style={styles.previewSection}>
              <h3 style={styles.previewTitle}>Xem trước poster</h3>
              <img
                src={movie.url_poster}
                alt={movie.ten_phim}
                style={styles.posterPreview}
                onError={(e) => {
                  e.target.onerror = null;
                  e.target.parentNode.innerHTML =
                    '<div style="width: 200px; height: 300px; display: flex; align-items: center; justify-content: center; background-color: #f5f5f5; border-radius: 8px; color: #999;">Poster không hợp lệ</div>';
                }}
              />
            </div>
          )}

          <div style={styles.buttonContainer}>
            <button
              type="button"
              style={{ ...styles.button, ...styles.secondaryButton }}
              onClick={handleCancel}
              disabled={saving}
            >
              Hủy
            </button>
            <button
              type="submit"
              style={{ ...styles.button, ...styles.primaryButton }}
              disabled={saving}
            >
              {saving ? "Đang lưu..." : "Lưu thay đổi"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ChinhSuaPhim;
