import { useState, useContext } from "react";
import { Link, useNavigate } from "react-router-dom";
import { BASE_URL } from "../../config.js";
import { toast } from "react-toastify";
import HashLoader from "react-spinners/HashLoader";
import { AuthContext } from "../../context/AuthContext.jsx";

const Login = () => {
  const [formData, setFormData] = useState({
    email: "",
    matKhau: "",
  });

  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  // Sử dụng AuthContext để dispatch action và truy cập token, role
  const { dispatch } = useContext(AuthContext);

  const submitHandler = async (event) => {
    event.preventDefault();
    setLoading(true);

    try {
      const res = await fetch(`${BASE_URL}/api/v1/auth/loginAdmin`, {
        method: "post",
        headers: {
          "Content-type": "application/json",
        },
        body: JSON.stringify(formData),
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.message);
      }

      // Dispatch action khi đăng nhập thành công và lưu token, role vào context
      dispatch({
        type: "LOGIN_SUCCESS",
        payload: {
          user: data.data,
          token: data.token,
          role: data.role,
        },
      });

      toast.success(data.message);

      // Điều hướng dựa trên role
      if (data.data.role === "nhanvien") {
        navigate("/admin/Dashboard");
      }
    } catch (err) {
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  return (
    <section className="px-3 lg:px-0">
      <div className="w-full max-w-[400px] mx-auto rounded-lg shadow-md md:p-6 mt-16">
        <h3 className="text-headingColor text-[20px] leading-8 font-bold mb-6">
          Hello! <span className="text-primaryColor">Welcome</span> Back{" "}
          <span role="img" aria-label="wave">
            👋
          </span>
        </h3>

        <form className="py-3 md:py-0" onSubmit={submitHandler}>
          <div className="mb-4">
            <input
              type="email"
              placeholder="Email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border-b border-solid border-[#0066ff61] focus:outline-none focus:border-b-primaryColor text-[16px] leading-6 text-headingColor placeholder:text-textColor rounded-md cursor-pointer"
              required
            />
          </div>

          <div className="mb-4">
            <input
              type="password"
              placeholder="Mật Khẩu"
              name="matKhau"
              value={formData.matKhau}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border-b border-solid border-[#0066ff61] focus:outline-none focus:border-b-primaryColor text-[16px] leading-6 text-headingColor placeholder:text-textColor rounded-md cursor-pointer"
              required
            />
          </div>

          <div className="mt-6">
            <button
              disabled={loading}
              type="submit"
              className="w-full bg-primaryColor text-black text-[16px] leading-[28px] rounded-lg px-3 py-2"
            >
              {loading ? <HashLoader size={35} color="#ee0033" /> : "Đăng Nhập"}
            </button>
          </div>

          <p className="mt-4 text-textColor text-center text-[14px]">
            Bạn chưa có tài khoản?{" "}
            <Link to="/register" className="text-primaryColor font-medium ml-1">
              Đăng Ký Ngay
            </Link>
          </p>
        </form>
      </div>
    </section>
  );
};

export default Login;
