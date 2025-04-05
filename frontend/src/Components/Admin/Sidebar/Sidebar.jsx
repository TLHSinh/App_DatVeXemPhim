import React from "react";
import "./Sidebar.css";
import { Link } from "react-router-dom";
import { MdOutlineSpaceDashboard } from "react-icons/md";
import { FaUser, FaFilm, FaUserTie } from "react-icons/fa6";
import { GrSchedulePlay } from "react-icons/gr";

const Sidebar = ({ isActive }) => {
  return (
    <div className={`menu-ad ${isActive ? "active" : ""}`}>
      <div className="menu-list-ad">
        <Link to="/admin/dashboard" className="item-ad">
          <MdOutlineSpaceDashboard className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Dashboard</span>}
        </Link>
        <Link to="/admin/ListUsers" className="item-ad">
          <FaUser className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Khách Hàng</span>}
        </Link>
        <Link to="/admin/ListEmployees" className="item-ad">
          <FaUserTie className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Nhân Viên</span>}
        </Link>
        <Link to="/admin/ListCinemas" className="item-ad">
          <MdOutlineSpaceDashboard className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Danh sách rạp</span>}
        </Link>
        <Link to="/admin/ListMovies" className="item-ad">
          <FaFilm  les className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Phim</span>}
        </Link>
        <Link to="/admin/ListSchedules" className="item-ad">
          <GrSchedulePlay className="icon" size={"1.25em"} />
          {!isActive && <span className="menu-text">Phim</span>}
        </Link>
      </div>
    </div>
  );
};

export default Sidebar;
