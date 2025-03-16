import React from "react";
import { Link, useLocation } from "react-router-dom";
import "./Breadcrumb.css"; 

const Breadcrumb = () => {
  const location = useLocation();

  // Tách các phần từ đường dẫn
  const paths = location.pathname.split("/").filter((path) => path);

  return (
    <nav className="breadcrumb">
      <ul>
        {paths.map((path, index) => {
          const to = `/${paths.slice(0, index + 1).join("/")}`;
          const isLast = index === paths.length - 1;

          // Đổi tên các đoạn URL sang dạng dễ đọc
          const readablePath = {
            admin: "Admin",
            bacsi: "Bác sĩ",
            danhsachbacsi: "Danh sách bác sĩ",
            danhsachkhachhang: "Danh sách khách hàng",
            danhsachthuocvattu: "Danh sách thuốc - vật tư",
            danhsachlichhen: "Danh sách lịch hẹn",
            themkhachhang: "Thêm khách hàng",
            thembacsi: "Thêm bác sĩ",
            themlichhen: "Thêm lịch hẹn",
            themthuocvattu: "Thêm thuốc vật tư",
            chinhsuakhachhang: "Chỉnh sửa khách hàng",
            chinhsuabacsi: "Chỉnh sửa bác sĩ",
            chinhsuathuocvattu: "Chỉnh sửa thuốc - vật tư",
            chitietbacsi: "Chi tiết bác sĩ",
            chitietkhachhang: "Chi tiết khách hàng",
            chitietthuocvattu: "Chi tiết thuốc vật tư",
          }[path] || path;

          return (
            <li key={to} className={isLast ? "breadcrumb-item active" : "breadcrumb-item"}>
              {!isLast ? (
                <Link to={to}>{readablePath}</Link>
              ) : (
                <span>{readablePath}</span>
              )}
            </li>
          );
        })}
      </ul>
    </nav>
  );
};

export default Breadcrumb;
