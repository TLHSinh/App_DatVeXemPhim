import React, { useEffect, useState, useContext } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { toast } from "react-toastify";
import { BASE_URL } from "../../../config";
import { AuthContext } from "../../../context/AuthContext";
import HashLoader from "react-spinners/HashLoader";
import Breadcrumb from "../../../Components/Breadcrumb";

const ChinhSuaNhanVien = () => {
  const { id } = useParams();
  const { token } = useContext(AuthContext);
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState({
    email: "",
    matKhau: "",
    hoTen: "",
    sodienthoai: "",
    ngaySinh: "",
    cccd: "",
    gioiTinh: "",
    chucVu: "",
    diaChi: "",
    hinhAnh: "",
    role: "nhanvien",
    trangThai: true,
    diemTichLuy: 0,
  });

  useEffect(() => {
    const fetchEmployee = async () => {
      try {
        const res = await fetch(`${BASE_URL}/api/v1/employee/${id}`, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
        });
        const result = await res.json();
        if (result.success) {
          setFormData(result.data);
        } else {
          throw new Error(result.message || "Không tìm thấy nhân viên");
        }
      } catch (error) {
        toast.error(`Lỗi: ${error.message}`);
      } finally {
        setLoading(false);
      }
    };
    fetchEmployee();
  }, [id, token]);

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleUpdate = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const res = await fetch(`${BASE_URL}/api/v1/employee/${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(formData),
      });
      const result = await res.json();
      if (result.success) {
        toast.success("Cập nhật thành công!");
        navigate("/admin/danhsachbacsi");
      } else {
        throw new Error(result.message || "Cập nhật không thành công");
      }
    } catch (error) {
      toast.error(`Lỗi: ${error.message}`);
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    navigate(`/admin/danhsachbacsi`);
  };

  if (loading) return <p>Đang tải dữ liệu...</p>;

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
            <div className="header-list-card">
              <h1 className="title-ad">CHỈNH SỬA THÔNG TIN NHÂN VIÊN</h1>
            </div>
            <form onSubmit={handleUpdate} className="form">
              <div className="input-box">
                <label>Họ và tên</label>
                <input
                  type="text"
                  name="hoTen"
                  value={formData.hoTen}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="input-box">
                <label>Ngày sinh</label>
                <input
                  type="date"
                  name="ngaySinh"
                  value={formData.ngaySinh}
                  onChange={handleInputChange}
                />
              </div>
              <div className="input-box">
                <label>Số điện thoại</label>
                <input
                  type="text"
                  name="sodienthoai"
                  value={formData.sodienthoai}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="input-box">
                <label>Email</label>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  readOnly
                />
              </div>
              <div className="input-box">
                <label>Địa chỉ</label>
                <input
                  type="text"
                  name="diaChi"
                  value={formData.diaChi}
                  onChange={handleInputChange}
                />
              </div>
              <div className="input-box">
                <label>Chức vụ</label>
                <input
                  type="text"
                  name="chucVu"
                  value={formData.chucVu}
                  onChange={handleInputChange}
                />
              </div>
              <div className="input-box">
                <label>Mật khẩu mới (nếu đổi)</label>
                <input
                  type="password"
                  name="matKhau"
                  value={formData.matKhau}
                  onChange={handleInputChange}
                />
              </div>
              <div className="col-12" style={{ textAlign: "right" }}>
                <button
                  className="submitform-ad"
                  type="submit"
                  disabled={saving}
                >
                  {saving ? (
                    <HashLoader size={35} color="#ffffff" />
                  ) : (
                    "Cập nhật"
                  )}
                </button>
                <button
                  className="cancelform-ad"
                  type="button"
                  onClick={handleCancel}
                >
                  Huỷ
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChinhSuaNhanVien;
