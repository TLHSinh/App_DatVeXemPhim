import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import uploadImageToCloudinary from "../../utils/uploadCloudinary.js";
import { BASE_URL } from "../../config.js";
import { toast } from 'react-toastify';
import HashLoader from 'react-spinners/HashLoader';

const SignUp = () => {
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewURL, setPreviewURL] = useState("");
  const [loading, setLoading] = useState(false);

  // Điều chỉnh các trường formData theo schema của backend
  const [formData, setFormData] = useState({
    ten: "",             // Tên bệnh nhân
    email: "",           // Email
    matKhau: "",         // Mật khẩu
    rePassword: "",      // Xác nhận mật khẩu
    hinhAnh: selectedFile, // Hình ảnh (URL)
    gioiTinh: "",        // Giới tính
    role: "BenhNhan",    // Vai trò: mặc định là bệnh nhân
  });

  const navigate = useNavigate();

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFileInputChange = async (event) => {
    const file = event.target.files[0];
    const data = await uploadImageToCloudinary(file);
    setPreviewURL(data.url);
    setSelectedFile(data.url);
    setFormData({ ...formData, hinhAnh: data.url });
  };

  const submitHandler = async (event) => {
    event.preventDefault();
    setLoading(true);

    // Kiểm tra password và rePassword
    if (formData.matKhau !== formData.rePassword) {
      toast.error("Mật khẩu và xác nhận mật khẩu không khớp.");
      setLoading(false);
      return;
    }

    try {
      const res = await fetch(`${BASE_URL}/api/v1/auth/register`, {
        method: 'post',
        headers: {
          'Content-type': 'application/json'
        },
        body: JSON.stringify(formData)  // Gửi formData lên backend
      });

      const { message } = await res.json();

      if (!res.ok) {
        throw new Error(message);
      }

      setLoading(false);
      toast.success(message);
      navigate("/customer/login");

    } catch (err) {
      toast.error(err.message);
      setLoading(false);
    }
  };

  return (
    <section className="px-2 xl:px-0 py-10">
      <div className="max-w-[800px] mx-auto">
        <div className="grid grid-cols-1 lg:grid-cols-2 bg-white rounded-lg shadow-lg overflow-hidden">
          <div className="hidden lg:flex bg-primaryColor justify-center items-center ">
            <img src="/banner_SignUp.png" alt="Background" className="w-[75%]" />
          </div>

          <div className="p-6 bg-gray-50 flex flex-col justify-center">
            <h3 className="text-headingColor text-[18px] leading-7 font-bold mb-6 text-center lg:text-left">
              Tạo Tài <span className="text-primaryColor">Khoản</span>
            </h3>

            <form onSubmit={submitHandler}>
              <div className="mb-4">
                <input
                  type="text"
                  placeholder="Họ và Tên"
                  name="ten"  // Tên phải là 'ten' theo schema
                  value={formData.ten}
                  onChange={handleInputChange}
                  className="w-full px-2 py-2 border-b border-solid border-[#0066ff61] focus:outline-none focus:border-b-primaryColor text-[14px] leading-6 text-headingColor placeholder:text-textColor rounded-md cursor-pointer"
                  required
                />
              </div>

              <div className="mb-4">
                <input
                  type="email"
                  placeholder="Email"
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  className="w-full px-2 py-2 border-b border-solid border-[#0066ff61] focus:outline-none focus:border-b-primaryColor text-[14px] leading-6 text-headingColor placeholder:text-textColor rounded-md cursor-pointer"
                  required
                />
              </div>

              <div className="mb-4">
                <input
                  type="password"
                  placeholder="Mật Khẩu"
                  name="matKhau"  // Phải là 'matKhau' theo schema
                  value={formData.matKhau}
                  onChange={handleInputChange}
                  className="w-full px-2 py-2 border-b border-solid border-[#0066ff61] focus:outline-none focus:border-b-primaryColor text-[14px] leading-6 text-headingColor placeholder:text-textColor rounded-md cursor-pointer"
                  required
                />
              </div>

              <div className="mb-4">
                <input
                  type="password"
                  placeholder="Xác Nhận Mật Khẩu"
                  name="rePassword"
                  value={formData.rePassword}
                  onChange={handleInputChange}
                  className="w-full px-2 py-2 border-b border-solid border-[#0066ff61] focus:outline-none focus:border-b-primaryColor text-[14px] leading-6 text-headingColor placeholder:text-textColor rounded-md cursor-pointer"
                  required
                />
              </div>

              <div className="mb-4 flex items-center justify-between">
                <label className="text-headingColor font-bold text-[13px] leading-6 inline-flex items-center">
                  Giới Tính:
                  <select
                    name="gioiTinh"  // Phải là 'gioiTinh' theo schema
                    value={formData.gioiTinh}
                    onChange={handleInputChange}
                    className="text-textColor font-semibold text-[13px] leading-6 px-2 py-2 focus:outline-none ml-2"
                  >
                    <option value="">Chọn</option>
                    <option value="nam">Nam</option>
                    <option value="nu">Nữ</option>
                    <option value="khac">Khác</option>
                  </select>
                </label>
              </div>

              <div className="mb-4 flex items-center gap-2">
                {selectedFile && (
                  <figure className="w-[50px] h-[50px] mt-3 rounded-full border-2 border-solid border-primaryColor flex items-center justify-center overflow-hidden">
                    <img src={previewURL} alt="" className="w-full h-full object-cover" />
                  </figure>
                )}

                <div className="relative w-[110px] h-[40px]">
                  <input
                    type="file"
                    name="hinhAnh"  // Phải là 'hinhAnh' theo schema
                    id="customFile"
                    onChange={handleFileInputChange}
                    accept=".jpg, .png"
                    className="absolute top-0 left-0 w-full h-full opacity-0 cursor-pointer"
                  />
                  <label
                    htmlFor="customFile"
                    className="absolute top-0 left-0 w-full h-full flex items-center px-[0.75rem] py-[0.375rem] text-[13px] leading-6 overflow-hidden bg-[#0066ff46] text-headingColor font-semibold rounded-lg truncate cursor-pointer"
                  >
                    Hình ảnh
                  </label>
                </div>
              </div>

              <div className="mt-6">
                <button
                  disabled={loading}
                  type="submit"
                  className="w-full bg-primaryColor text-white text-[14px] leading-[26px] rounded-lg px-2 py-2"
                >
                  {loading ? <HashLoader size={35} color="#ffffff" /> : 'Đăng Ký'}
                </button>
              </div>

              <p className="mt-4 text-textColor text-center text-[13px]">
                Bạn đã có tài khoản?{" "}
                <Link to="/login" className="text-primaryColor font-medium ml-1">
                  Đăng nhập
                </Link>
              </p>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
};

export default SignUp;








// quan trọng ko đc xoá sau này mở ra h đóng cho tiện 
    // Kiểm tra độ dài và điều kiện của mật khẩu
/*     const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{7,}$/;
    if (!passwordRegex.test(formData.password)) {
      toast.error("Mật khẩu phải chứa ít nhất 8 ký tự, bao gồm cả chữ cái và số.");
      setLoading(false);
      return;
    } */