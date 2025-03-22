import React, { useState } from "react";
import { useNavigate } from "react-router-dom";

const ThemPhimMoi = () => {
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
    ngon_ngu: "Tiếng Việt",
    danh_gia: 0,
    phien_ban: "1.0"
  });

  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [successMessage, setSuccessMessage] = useState("");

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
        "http://localhost:5000/api/v1/admin/addmovies",
        {
          method: "POST",
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
        setSuccessMessage("Thêm phim mới thành công!");
        // Redirect to movie list or clear form after success
        setTimeout(() => {
          if (result.data && result.data._id) {
            navigate(`/admin/chitietphim/${result.data._id}`);
          } else {
            // Reset form
            setMovie({
              ten_phim: "",
              ma_phim: "",
              mo_ta: "",
              thoi_luong: "",
              ngay_cong_chieu: "",
              url_poster: "",
              url_trailer: "",
              gioi_han_tuoi: "P",
              ngon_ngu: "Tiếng Việt",
              danh_gia: 0,
              phien_ban: "1.0"
            });
          }
        }, 2000);
      } else {
        throw new Error(result.message || "Lỗi khi thêm phim mới");
      }
    } catch (err) {
      console.error("Lỗi khi thêm phim mới:", err);
      setError(`Không thể thêm phim mới: ${err.message}`);
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
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
    requiredIndicator: {
      color: "red",
      marginLeft: "2px",
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
    ratingContainer: {
      display: "flex",
      alignItems: "center",
      gap: "8px",
    },
    infoText: {
      fontSize: "0.85rem",
      color: "#666",
      marginTop: "5px",
    },
  };

  return (
    <div style={styles.container}>
      <div style={styles.breadcrumb}>
        <span>Trang chủ / </span>
        <span style={styles.breadcrumbLink} onClick={() => navigate("/admin/ListMovies")}>
          Quản lý phim
        </span>
        <span> / Thêm phim mới</span>
      </div>

      <div style={styles.card}>
        <div style={styles.header}>
          <h1 style={styles.title}>Thêm phim mới</h1>
        </div>

        {error && <div style={styles.errorMessage}>{error}</div>}
        {successMessage && <div style={styles.successMessage}>{successMessage}</div>}

        <form style={styles.form} onSubmit={handleSubmit}>
          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="ten_phim">
                Tên phim <span style={styles.requiredIndicator}>*</span>
              </label>
              <input
                style={styles.input}
                type="text"
                id="ten_phim"
                name="ten_phim"
                value={movie.ten_phim}
                onChange={handleChange}
                required
                placeholder="Nhập tên phim"
              />
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="ma_phim">
                Mã phim <span style={styles.requiredIndicator}>*</span>
              </label>
              <input
                style={styles.input}
                type="text"
                id="ma_phim"
                name="ma_phim"
                value={movie.ma_phim}
                onChange={handleChange}
                required
                placeholder="Nhập mã phim (VD: MP001)"
              />
              <div style={styles.infoText}>
                Mã phim là duy nhất và không thể thay đổi sau khi tạo
              </div>
            </div>
          </div>

          <div style={styles.formGroup}>
            <label style={styles.label} htmlFor="mo_ta">Mô tả</label>
            <textarea
              style={styles.textarea}
              id="mo_ta"
              name="mo_ta"
              value={movie.mo_ta}
              onChange={handleChange}
              placeholder="Nhập mô tả phim"
            />
          </div>

          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="thoi_luong">
                Thời lượng (phút) <span style={styles.requiredIndicator}>*</span>
              </label>
              <input
                style={styles.input}
                type="number"
                id="thoi_luong"
                name="thoi_luong"
                value={movie.thoi_luong}
                onChange={handleChange}
                min="1"
                required
                placeholder="VD: 120"
              />
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="ngay_cong_chieu">
                Ngày công chiếu <span style={styles.requiredIndicator}>*</span>
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
              <label style={styles.label} htmlFor="ngon_ngu">Ngôn ngữ</label>
              <input
                style={styles.input}
                type="text"
                id="ngon_ngu"
                name="ngon_ngu"
                value={movie.ngon_ngu}
                onChange={handleChange}
                placeholder="VD: Tiếng Việt, Tiếng Anh"
              />
            </div>
          </div>

          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="url_poster">Đường dẫn Poster</label>
              <input
                style={styles.input}
                type="url"
                id="url_poster"
                name="url_poster"
                value={movie.url_poster}
                onChange={handleChange}
                placeholder="https://example.com/poster.jpg"
              />
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="url_trailer">Đường dẫn Trailer</label>
              <input
                style={styles.input}
                type="url"
                id="url_trailer"
                name="url_trailer"
                value={movie.url_trailer}
                onChange={handleChange}
                placeholder="https://youtube.com/watch?v=..."
              />
            </div>
          </div>

          <div style={styles.formSection}>
            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="gioi_han_tuoi">
                Giới hạn tuổi <span style={styles.requiredIndicator}>*</span>
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
              <label style={styles.label} htmlFor="danh_gia">Đánh giá</label>
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
                  placeholder="0.0"
                />
                <span>/5</span>
              </div>
            </div>

            <div style={styles.formGroup}>
              <label style={styles.label} htmlFor="phien_ban">Phiên bản</label>
              <input
                style={styles.input}
                type="text"
                id="phien_ban"
                name="phien_ban"
                value={movie.phien_ban}
                onChange={handleChange}
                placeholder="VD: 1.0"
              />
            </div>
          </div>

          {movie.url_poster && (
            <div style={styles.previewSection}>
              <h3 style={styles.previewTitle}>Xem trước poster</h3>
              <img
                src={movie.url_poster}
                alt="Poster preview"
                style={styles.posterPreview}
                onError={(e) => {
                  e.target.onerror = null;
                  e.target.parentNode.innerHTML = '<div style="width: 200px; height: 300px; display: flex; align-items: center; justify-content: center; background-color: #f5f5f5; border-radius: 8px; color: #999;">URL poster không hợp lệ</div>';
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
              {saving ? "Đang tạo..." : "Tạo phim"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ThemPhimMoi;