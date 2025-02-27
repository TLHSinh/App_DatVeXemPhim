import React from "react";
import "./Login.css";
import { FaUser, FaLock } from "react-icons/fa";

const Login = () => {
    return (
        <div className="container-Login">
            <div className="header-Login">
                <div className="text-Login">Đăng Nhập</div>
                <div className="underline-Login"></div>
            </div>

            <div className="inputs-Login">
                <div className="input-Login">
                    <FaUser size={20} className="img" />
                    <input type="text" placeholder="Tên đăng nhập" />
                </div>

                <div className="input-Login">
                    <FaLock size={20} className="img" />
                    <input type="password" placeholder="Mật khẩu" />
                </div>
            </div>

            <div className="submit-container-Login">
                <div className="submit">Đăng Nhập</div>
            </div>
        </div>
    );
};

export default Login;
