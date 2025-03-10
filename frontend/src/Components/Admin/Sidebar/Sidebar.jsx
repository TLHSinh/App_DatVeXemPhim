import React from 'react';
import './Sidebar.css';
import { Link } from "react-router-dom";
import { MdOutlineSpaceDashboard } from "react-icons/md";
import { FaCapsules, FaHospitalUser, FaUserDoctor, FaCalendarDays } from "react-icons/fa6";

const Sidebar = ({ isActive }) => {
    return (
        <div className={`menu-ad ${isActive ? 'active' : ''}`}>
            <div className="menu-list-ad">
                <Link to="/admin/dashboard" className="item-ad">
                    <MdOutlineSpaceDashboard className="icon" size={"1.25em"} />
                    {!isActive && <span className="menu-text">Dashboard</span>}
                </Link>
                <Link to="/admin/danhsachkhachhang" className="item-ad">
                    <FaHospitalUser className="icon" size={"1.25em"} />
                    {!isActive && <span className="menu-text">Khách Hàng</span>}
                </Link>
                <Link to="/admin/danhsachbacsi" className="item-ad">
                    <FaUserDoctor className="icon" size={"1.25em"} />
                    {!isActive && <span className="menu-text">Bác Sĩ</span>}
                </Link>
                <Link to="/admin/danhsachlichhen" className="item-ad">
                    <FaCalendarDays className="icon" size={"1.25em"} />
                    {!isActive && <span className="menu-text">Lịch Hẹn</span>}
                </Link>
                <Link to="/admin/danhsachthuocvattu" className="item-ad">
                    <FaCapsules className="icon" size={"1.25em"} />
                    {!isActive && <span className="menu-text">Thuốc</span>}
                </Link>
            </div>
        </div>
    );
};

export default Sidebar;
