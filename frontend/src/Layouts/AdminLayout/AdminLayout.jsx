import React, { useContext, useState } from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import Sidebar from '../../Components/Admin/Sidebar/Sidebar';
import '../AdminLayout/AdminLayout.css';
import { IoMenu } from "react-icons/io5";
import { AuthContext } from '../../context/AuthContext';
import { FaArrowRightFromBracket } from "react-icons/fa6";

const AdminLayout = () => {
  const location = useLocation();
  const hideNavAndFooter = location.pathname === '/admin/login' || location.pathname === '/admin/register';

  const [isSidebarActive, setIsSidebarActive] = useState(true);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  const handleToggleSidebar = () => {
    setIsSidebarActive(prev => !prev);
  };

  const { user, dispatch } = useContext(AuthContext);
  const navigate = useNavigate();


  const handleDropdownToggle = () => {
    setIsDropdownOpen(prev => !prev);
  };

  const handleNavigate = (path) => {
    setIsDropdownOpen(false); // Đóng dropdown khi chọn tùy chọn
    navigate(path);
  };


  const [isConfirmDialogOpen, setIsConfirmDialogOpen] = useState(false);

  const handleLogout = () => {
    setIsConfirmDialogOpen(true);
  };

  const confirmLogout = () => {
    dispatch({ type: 'LOGOUT' });
    navigate('/login');
    setIsConfirmDialogOpen(false);
  };

  const cancelLogout = () => {
    setIsConfirmDialogOpen(false);
  };




  return (
    <div className="admin-layout">
      <div className={`topbar-ad ${isSidebarActive ? 'active' : ''}`}>
        <div className={`logo-toggle-ad ${isSidebarActive ? 'active' : ''}`}>
          <div className="logo-ad">
            <img src="/logo_sta512.png" alt="STA HOSPITAL Logo" className="logo-img" />
            {!isSidebarActive && <span className="logo-text-ad">STA HOSPITAL</span>}
          </div>

          <div className="toggle-ad" onClick={handleToggleSidebar}>
            <IoMenu size={"2em"} color="#66B5A3" />
          </div>
        </div>




        {/* Sidebar Profile */}
        <div className="sidebar_profile flex" onClick={handleDropdownToggle}>
          <div className="data_text">
            <div className="name">{user.ten}</div>
            <div className="email">{user.email}</div>
          </div>
          <span className="nav_image">
            <img src={user.hinhAnh} alt="User Avatar" className="user-pic" />
          </span>

          {/* Dropdown */}
          {isDropdownOpen && (
            <div className="dropdown-ad-profile">
              <div className="dropdown-ad-profile-item" onClick={() => handleNavigate('/profile/details')}>Chi tiết</div>
              <div className="dropdown-ad-profile-item" onClick={() => handleNavigate('/profile/edit')}>Chỉnh sửa</div>
              <div className="dropdown-ad-profile-item" onClick={handleLogout}>Đăng xuất</div>
            </div>
          )}
        </div>

        {isConfirmDialogOpen && (
          <div className="confirm-dialog-overlay">
            <div className="confirm-dialog">
              <p>Bạn có chắc chắn muốn đăng xuất?</p>
              <button onClick={confirmLogout}>Đồng ý</button>
              <button onClick={cancelLogout}>Hủy</button>
            </div>
          </div>
        )}
      </div>

      {/* Sidebar */}
      {!hideNavAndFooter && (
        <Sidebar isActive={isSidebarActive} />

      )}

      <div className={`layout-content-ad ${isSidebarActive ? 'active' : ''}`}>
        <div style={{ padding: "30px 30px 0" }}>
          <Outlet />
        </div>
      </div>

    </div>
  );
};

export default AdminLayout;
