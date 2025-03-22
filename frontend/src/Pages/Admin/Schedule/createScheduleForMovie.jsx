import React, { useState, useEffect } from "react";
import {
  Calendar,
  Clock,
  Building,
  DollarSign,
  X,
  Save,
  AlertCircle,
  ChevronRight,
  Film,
  Info,
} from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";

const ThemLichChieu = ({ onClose, onSuccess }) => {
  // State cho form
  const [formData, setFormData] = useState({
    id_rap: "",
    id_phong: "",
    thoi_gian_chieu: "",
    gia_ve: "",
  });

  // State cho danh sách rạp và phòng
  const [theaters, setTheaters] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [movieInfo, setMovieInfo] = useState(null);
  const [scheduleId, setScheduleId] = useState(null);

  // State loading
  const [loadingTheaters, setLoadingTheaters] = useState(false);
  const [loadingRooms, setLoadingRooms] = useState(false);
  const [loadingMovie, setLoadingMovie] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const { id_phim } = useParams();
  const navigate = useNavigate();

  // State error
  const [error, setError] = useState(null);
  // State success
  const [success, setSuccess] = useState(false);

  // Hàm tải thông tin phim
  const fetchMovieInfo = async () => {
    if (!id_phim) return;

    setLoadingMovie(true);
    try {
      const response = await fetch(
        `http://localhost:5000/api/v1/movie/phims/${id_phim}`
      );
      if (!response.ok) {
        throw new Error("Không thể tải thông tin phim");
      }
      const result = await response.json();
      setMovieInfo(result);
    } catch (err) {
      console.error("Lỗi khi tải thông tin phim:", err);
      setError("Không thể tải thông tin phim");
    } finally {
      setLoadingMovie(false);
    }
  };

  // Hàm tải danh sách rạp
  const fetchTheaters = async () => {
    setLoadingTheaters(true);
    try {
      const response = await fetch(
        "http://localhost:5000/api/v1/admin/theaters"
      );
      if (!response.ok) {
        throw new Error("Không thể tải danh sách rạp");
      }
      const result = await response.json();

      // Xử lý cấu trúc dữ liệu trả về
      const theaterArray = Array.isArray(result)
        ? result
        : result.data
        ? result.data
        : result.theaters
        ? result.theaters
        : [];

      setTheaters(theaterArray);
      setError(null);
    } catch (err) {
      console.error("Lỗi khi tải danh sách rạp:", err);
      setError("Không thể tải danh sách rạp");
      setTheaters([]);
    } finally {
      setLoadingTheaters(false);
    }
  };

  // Hàm tải danh sách phòng theo ID rạp
  const fetchRoomsByTheaterId = async (theaterId) => {
    if (!theaterId) {
      setRooms([]);
      return;
    }

    setLoadingRooms(true);
    try {
      const response = await fetch(
        `http://localhost:5000/api/v1/admin/theaters/${theaterId}/rooms`
      );
      if (!response.ok) {
        throw new Error("Không thể tải danh sách phòng");
      }
      const result = await response.json();

      // Xử lý cấu trúc dữ liệu trả về
      const roomsArray = Array.isArray(result)
        ? result
        : result.data
        ? result.data
        : result.rooms
        ? result.rooms
        : [];

      setRooms(roomsArray);
      setError(null);
    } catch (err) {
      console.error("Lỗi khi tải danh sách phòng:", err);
      setError("Không thể tải danh sách phòng");
      setRooms([]);
    } finally {
      setLoadingRooms(false);
    }
  };

  // Hàm thêm lịch chiếu
  const addSchedule = async () => {
    if (!validateForm()) return;

    setSubmitting(true);
    try {
      const response = await fetch(
        `http://localhost:5000/api/v1/admin/movies/${id_phim}/schedule`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(formData),
        }
      );

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Không thể thêm lịch chiếu");
      }

      // Lấy ID lịch chiếu từ response
      const result = await response.json();
      const newScheduleId = result._id || result.data?._id || null;
      setScheduleId(newScheduleId);

      // Hiển thị thông báo thành công
      setSuccess(true);
      setError(null);

      // Không tự động chuyển trang, chỉ hiển thị thông báo thành công
      onSuccess && onSuccess();
      onClose && onClose();
    } catch (err) {
      console.error("Lỗi khi thêm lịch chiếu:", err);
      setError(err.message || "Đã xảy ra lỗi khi thêm lịch chiếu");
    } finally {
      setSubmitting(false);
    }
  };

  // Kiểm tra hợp lệ form trước khi submit
  const validateForm = () => {
    if (!formData.id_rap) {
      setError("Vui lòng chọn rạp chiếu");
      return false;
    }
    if (!formData.id_phong) {
      setError("Vui lòng chọn phòng chiếu");
      return false;
    }
    if (!formData.thoi_gian_chieu) {
      setError("Vui lòng chọn thời gian chiếu");
      return false;
    }
    if (!formData.gia_ve || formData.gia_ve <= 0) {
      setError("Vui lòng nhập giá vé hợp lệ");
      return false;
    }
    return true;
  };

  // Xử lý thay đổi input
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value,
    });

    // Khi chọn rạp, tải danh sách phòng tương ứng
    if (name === "id_rap") {
      // Reset phòng đã chọn khi thay đổi rạp
      setFormData((prev) => ({
        ...prev,
        id_phong: "",
      }));
      fetchRoomsByTheaterId(value);
    }

    // Xóa thông báo lỗi khi người dùng thay đổi giá trị
    setError(null);
  };

  // Xử lý submit form
  const handleSubmit = (e) => {
    e.preventDefault();
    addSchedule();
  };

  // Format giá tiền
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(amount);
  };

  // Format date time nhập vào cho input datetime-local
  const formatDateTimeForInput = () => {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0");
    const day = String(now.getDate()).padStart(2, "0");
    const hours = String(now.getHours()).padStart(2, "0");
    const minutes = String(now.getMinutes()).padStart(2, "0");

    return `${year}-${month}-${day}T${hours}:${minutes}`;
  };

  // Tải dữ liệu khi component mount
  useEffect(() => {
    fetchMovieInfo();
    fetchTheaters();

    // Set default date time
    setFormData((prev) => ({
      ...prev,
      thoi_gian_chieu: formatDateTimeForInput(),
    }));
  }, [id_phim]);

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-2xl mx-4 overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-indigo-700 px-6 py-4 flex justify-between items-center">
          <h3 className="text-xl font-semibold text-white flex items-center">
            <Film size={20} className="mr-2" />
            Thêm lịch chiếu phim
          </h3>
          <button
            onClick={onClose}
            className="text-white/80 hover:text-white focus:outline-none transition-all duration-200 bg-white/10 rounded-full p-1"
            disabled={submitting || success}
          >
            <X size={20} />
          </button>
        </div>

        {/* Body */}
        <div className="p-6">
          {/* Success message */}
          {success && (
            <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg text-green-700 flex items-center animate-pulse">
              <div className="mr-3 bg-green-100 text-green-500 p-2 rounded-full">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fillRule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                    clipRule="evenodd"
                  />
                </svg>
              </div>
              <div>
                <p className="font-medium">Thêm lịch chiếu thành công!</p>
                <p className="text-sm mt-1">
                  Đang chuyển đến trang chi tiết lịch chiếu...
                </p>
              </div>
            </div>
          )}

          {/* Movie info section */}
          {loadingMovie ? (
            <div className="flex justify-center items-center py-6">
              <div className="animate-spin rounded-full h-10 w-10 border-t-2 border-b-2 border-blue-500"></div>
            </div>
          ) : movieInfo ? (
            <div className="mb-6 bg-gradient-to-r from-gray-50 to-blue-50 p-4 rounded-lg shadow-sm">
              <div className="flex items-start gap-4">
                <div className="w-1/4">
                  <div className="rounded-md overflow-hidden aspect-[2/3] flex items-center justify-center shadow-md">
                    {movieInfo.hinh_anh ? (
                      <img
                        src={movieInfo.hinh_anh}
                        alt={movieInfo.ten_phim}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full bg-gray-300 flex items-center justify-center">
                        <Film size={40} className="text-gray-400" />
                      </div>
                    )}
                  </div>
                </div>
                <div className="w-3/4">
                  <h4 className="font-bold text-lg text-blue-800">
                    {movieInfo.ten_phim}
                  </h4>
                  <div className="mt-3 space-y-2 text-sm">
                    <div className="flex items-center text-gray-700">
                      <Clock size={16} className="mr-2 text-blue-500" />
                      <span className="font-medium">Thời lượng:</span>{" "}
                      <span className="ml-1">{movieInfo.thoi_luong} phút</span>
                    </div>
                    <div className="flex items-center text-gray-700">
                      <Calendar size={16} className="mr-2 text-blue-500" />
                      <span className="font-medium">Khởi chiếu:</span>{" "}
                      <span className="ml-1">
                        {new Date(movieInfo.ngay_khoi_chieu).toLocaleDateString(
                          "vi-VN"
                        )}
                      </span>
                    </div>
                    <div className="flex items-center text-gray-700">
                      <Info size={16} className="mr-2 text-blue-500" />
                      <span className="font-medium">Giới hạn tuổi:</span>{" "}
                      <span className="ml-1 px-2 py-0.5 bg-red-100 text-red-800 rounded-full text-xs font-semibold">
                        {movieInfo.gioi_han_tuoi || "P"}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ) : null}

          {/* Error message */}
          {error && (
            <div className="mb-4 p-4 bg-red-50 border-l-4 border-red-500 rounded-md text-red-600 flex items-center">
              <AlertCircle size={18} className="mr-2 flex-shrink-0" />
              <p>{error}</p>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit}>
            <div className="space-y-5">
              {/* Rạp chiếu */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Rạp chiếu <span className="text-red-500">*</span>
                </label>
                <div className="relative group">
                  <select
                    name="id_rap"
                    value={formData.id_rap}
                    onChange={handleInputChange}
                    className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 group-hover:border-blue-300 transition-all duration-200"
                    disabled={loadingTheaters || submitting || success}
                    required
                  >
                    <option value="">-- Chọn rạp chiếu --</option>
                    {theaters.map((theater) => (
                      <option key={theater._id} value={theater._id}>
                        {theater.ten_rap}
                      </option>
                    ))}
                  </select>
                  <div className="absolute left-3 top-2.5 text-blue-500 bg-white">
                    <Building size={18} />
                  </div>
                </div>
              </div>

              {/* Phòng chiếu */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Phòng chiếu <span className="text-red-500">*</span>
                </label>
                <div className="relative group">
                  <select
                    name="id_phong"
                    value={formData.id_phong}
                    onChange={handleInputChange}
                    className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 group-hover:border-blue-300 transition-all duration-200"
                    disabled={
                      loadingRooms || !formData.id_rap || submitting || success
                    }
                    required
                  >
                    <option value="">
                      {!formData.id_rap
                        ? "-- Vui lòng chọn rạp trước --"
                        : loadingRooms
                        ? "-- Đang tải danh sách phòng --"
                        : "-- Chọn phòng chiếu --"}
                    </option>
                    {rooms.map((room) => (
                      <option key={room._id} value={room._id}>
                        {room.ten_phong} ({room.loai_phong || "Thường"})
                      </option>
                    ))}
                  </select>
                  <div className="absolute left-3 top-2.5 text-blue-500 bg-white">
                    <Building size={18} />
                  </div>
                </div>
              </div>

              {/* Thời gian chiếu */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Thời gian chiếu <span className="text-red-500">*</span>
                </label>
                <div className="relative group">
                  <input
                    type="datetime-local"
                    name="thoi_gian_chieu"
                    value={formData.thoi_gian_chieu}
                    onChange={handleInputChange}
                    className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 group-hover:border-blue-300 transition-all duration-200"
                    disabled={submitting || success}
                    required
                  />
                  <div className="absolute left-3 top-2.5 text-blue-500 bg-white">
                    <Calendar size={18} />
                  </div>
                </div>
              </div>

              {/* Giá vé */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Giá vé (VNĐ) <span className="text-red-500">*</span>
                </label>
                <div className="relative group">
                  <input
                    type="number"
                    name="gia_ve"
                    value={formData.gia_ve}
                    onChange={handleInputChange}
                    placeholder="Nhập giá vé..."
                    className="w-full pl-10 pr-16 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 group-hover:border-blue-300 transition-all duration-200"
                    min="0"
                    step="1000"
                    disabled={submitting || success}
                    required
                  />
                  <div className="absolute left-3 top-2.5 text-blue-500 bg-white">
                    <DollarSign size={18} />
                  </div>
                  <span className="absolute right-3 top-2.5 text-gray-500 text-sm font-medium">
                    VNĐ
                  </span>
                </div>
                {formData.gia_ve && (
                  <div className="mt-2 text-sm text-gray-500">
                    <span className="font-medium text-gray-600">
                      {formatCurrency(formData.gia_ve)}
                    </span>
                  </div>
                )}
              </div>
            </div>

            {/* Footer */}
            <div className="mt-8 pt-4 border-t flex justify-end">
              {!success && (
                <>
                  <button
                    type="button"
                    onClick={onClose}
                    className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 mr-3 hover:bg-gray-50 transition-colors duration-200"
                    disabled={submitting}
                  >
                    Hủy
                  </button>
                  <button
                    type="submit"
                    className="px-5 py-2 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-lg hover:from-blue-700 hover:to-indigo-700 focus:ring-2 focus:ring-blue-300 transition-all duration-200 shadow-md flex items-center"
                    disabled={submitting}
                  >
                    {submitting ? (
                      <>
                        <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                        Đang lưu...
                      </>
                    ) : (
                      <>
                        <Save size={18} className="mr-2" />
                        Lưu lịch chiếu
                      </>
                    )}
                  </button>
                </>
              )}
              {success && (
                <button
                  type="button"
                  onClick={() => navigate(`/admin/schedule/${scheduleId}`)}
                  className="px-5 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-lg hover:from-green-700 hover:to-green-800 focus:ring-2 focus:ring-green-300 transition-all duration-200 shadow-md flex items-center"
                >
                  Xem chi tiết
                  <ChevronRight size={18} className="ml-1" />
                </button>
              )}
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default ThemLichChieu;
