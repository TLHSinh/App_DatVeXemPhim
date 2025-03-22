import React, { useEffect, useState, useRef, useContext } from "react";
import { useParams, Link } from "react-router-dom";
import { BASE_URL } from "../../../config";
import { AuthContext } from "../../../context/AuthContext";
import { FaChevronLeft } from "react-icons/fa6";
import Breadcrumb from "../../../Components/Breadcrumb";
import "./ChiTietNhanVien.css"; // Tạo file CSS tương ứng

const ChiTietNhanVien = () => {
  const { id } = useParams();
  const { token } = useContext(AuthContext);
  const [employee, setEmployee] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeTab, setActiveTab] = useState("personalInfo");
  const underlineRef = useRef(null);
  const buttonRefs = useRef([]);

  // Lấy thông tin nhân viên
  const fetchEmployeeDetail = async () => {
    try {
      const res = await fetch(`${BASE_URL}/api/v1/employee/${id}`, {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });
      const result = await res.json();
      if (result.success) setEmployee(result.data);
      else
        throw new Error(result.message || "Không tìm thấy thông tin nhân viên");
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchEmployeeDetail();
  }, [id]);

  // Cập nhật vị trí của underline khi tab thay đổi
  useEffect(() => {
    const currentButton =
      buttonRefs.current[activeTab === "personalInfo" ? 0 : 1];
    if (currentButton && underlineRef.current) {
      const { offsetLeft, offsetWidth } = currentButton;
      underlineRef.current.style.left = `${offsetLeft}px`;
      underlineRef.current.style.width = `${offsetWidth}px`;
    }
  }, [activeTab]);

  if (loading) return <p>Đang tải dữ liệu...</p>;
  if (error) return <p>Lỗi: {error}</p>;

  // Format ngày tạo
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("vi-VN", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    });
  };

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
              <div style={{ float: "left" }}>
                <h1 className="title-ad">CHI TIẾT NHÂN VIÊN</h1>
              </div>
              <div style={{ float: "right" }}>
                <Link to="/admin/danhsachbacsi" className="back-button">
                  <FaChevronLeft /> Quay lại
                </Link>
              </div>
            </div>

            <div className="avt-name-detail">
              <img
                src={employee.hinhAnh}
                alt={`Hình của ${employee.hoTen}`}
                style={{ width: "150px", height: "150px", borderRadius: "50%" }}
              />
            </div>
            <h2 style={{ textAlign: "center" }}>{employee.hoTen}</h2>
            <div className="button-group-details">
              <button
                className={`view-button ${
                  activeTab === "personalInfo" ? "active" : ""
                }`}
                onClick={() => setActiveTab("personalInfo")}
                ref={(el) => (buttonRefs.current[0] = el)}
              >
                Thông tin cá nhân
              </button>
              <button
                className={`view-button ${
                  activeTab === "accountInfo" ? "active" : ""
                }`}
                onClick={() => setActiveTab("accountInfo")}
                ref={(el) => (buttonRefs.current[1] = el)}
              >
                Thông tin tài khoản
              </button>
              <div className="underline" ref={underlineRef}></div>
            </div>

            {activeTab === "personalInfo" && employee && (
              <div className="user-info">
                <div className="info-section">
                  <form className="form">
                    <div className="column">
                      <div className="input-box">
                        <label>Họ và tên</label>
                        <div className="item-detail">{employee.hoTen}</div>
                      </div>
                      <div className="input-box">
                        <label>Giới tính</label>
                        <div className="item-detail">{employee.gioiTinh}</div>
                      </div>
                    </div>
                    <div className="column">
                      <div className="input-box">
                        <label>Email</label>
                        <div className="item-detail">{employee.email}</div>
                      </div>
                      <div className="input-box">
                        <label>Vai trò</label>
                        <div className="item-detail">{employee.role}</div>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
            )}

            {activeTab === "accountInfo" && employee && (
              <div className="user-info">
                <div className="info-section">
                  <form className="form">
                    <div className="column">
                      <div className="input-box">
                        <label>ID</label>
                        <div className="item-detail">{employee._id}</div>
                      </div>
                      <div className="input-box">
                        <label>Trạng thái</label>
                        <div className="item-detail">
                          <span
                            className={`status-badge ${
                              employee.trangThai ? "active" : "inactive"
                            }`}
                          >
                            {employee.trangThai
                              ? "Hoạt động"
                              : "Không hoạt động"}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="column">
                      <div className="input-box">
                        <label>Điểm tích lũy</label>
                        <div className="item-detail">
                          {employee.diemTichLuy}
                        </div>
                      </div>
                      <div className="input-box">
                        <label>Ngày tạo</label>
                        <div className="item-detail">
                          {formatDate(employee.createdAt)}
                        </div>
                      </div>
                    </div>
                    <div className="column">
                      <div className="input-box">
                        <label>Cập nhật cuối</label>
                        <div className="item-detail">
                          {formatDate(employee.updatedAt)}
                        </div>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChiTietNhanVien;
