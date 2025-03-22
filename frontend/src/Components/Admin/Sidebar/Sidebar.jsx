import React from "react";
import "./Sidebar.css";
import { Link } from "react-router-dom";
import { MdOutlineSpaceDashboard } from "react-icons/md";
import { FaCapsules, FaHospitalUser, FaUserDoctor } from "react-icons/fa6";

const Sidebar = ({ isActive }) => {
  return (
    <div className={`menu-ad ${isActive ? "active" : ""}`}>
      <div className="menu-list-ad">
        <Link to="/admin/dashboard" className="item-ad">
          <MdOutlineSpaceDashboard className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Dashboard</span>}
        </Link>
        <Link to="/admin/ListUsers" className="item-ad">
          <FaHospitalUser className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Khách Hàng</span>}
        </Link>
        <Link to="/admin/ListEmployees" className="item-ad">
          <FaUserDoctor className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Nhân Viên</span>}
        </Link>
        <Link to="/admin/ListCinemas" className="item-ad">
          <MdOutlineSpaceDashboard className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Danh sách rạp</span>}
        </Link>
        <Link to="/admin/ListMovies" className="item-ad">
          <FaCapsules className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Phim</span>}
        </Link>
        <Link to="/admin/ListSchedules" className="item-ad">
          <FaCapsules className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Phim</span>}
        </Link>
      </div>
    </div>
  );
};

export default Sidebar;
