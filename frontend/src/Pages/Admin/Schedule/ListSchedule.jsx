import React, { useState, useEffect } from "react";
import {
  Plus,
  Edit,
  Eye,
  Trash,
  Search,
  RefreshCw,
  Filter,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

const LichChieuPhim = () => {
  const navigate = useNavigate();
  const [showModal, setShowModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [modalType, setModalType] = useState("");
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState({
    id_phim: "",
    id_rap: "",
    id_phong: "",
    thoi_gian_chieu: "",
    gia_ve: "",
  });
  const [searchTerm, setSearchTerm] = useState("");

  // Thêm state cho danh sách phim, rạp và phòng
  const [movies, setMovies] = useState([]);
  const [theaters, setTheaters] = useState([]);
  const [rooms, setRooms] = useState([]);

  // Thêm state loading cho từng loại dữ liệu
  const [loadingMovies, setLoadingMovies] = useState(false);
  const [loadingTheaters, setLoadingTheaters] = useState(false);
  const [loadingRooms, setLoadingRooms] = useState(false);

  // Tải dữ liệu lịch chiếu từ API
  const fetchData = async () => {
    setLoading(true);
    try {
      const response = await fetch(
        "http://localhost:5000/api/v1/admin/movies/allschedule"
      );
      if (!response.ok) {
        throw new Error("Không thể tải dữ liệu");
      }
      const result = await response.json();
      setData(result);
      setError(null);
    } catch (err) {
      setError(err.message);
      console.error("Lỗi khi tải dữ liệu:", err);
    } finally {
      setLoading(false);
    }
  };

  // Hàm tải danh sách phim từ API
  const fetchMovies = async () => {
    setLoadingMovies(true);
    try {
      const response = await fetch(
        "http://localhost:5000/api/v1/movie/Allphims"
      );
      if (!response.ok) {
        throw new Error("Không thể tải danh sách phim");
      }
      const result = await response.json();
      setMovies(result);
    } catch (err) {
      console.error("Lỗi khi tải danh sách phim:", err);
    } finally {
      setLoadingMovies(false);
    }
  };

  // Hàm tải danh sách rạp từ API
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

      // Add debugging to see the actual structure
      console.log("Theater data received:", result);

      // Fix: Check the structure and handle accordingly
      const theaterArray = Array.isArray(result)
        ? result
        : result.data
        ? result.data
        : result.theaters
        ? result.theaters
        : [];

      setTheaters(theaterArray);
    } catch (err) {
      console.error("Lỗi khi tải danh sách rạp:", err);
      // Always set to an empty array on error
      setTheaters([]);
    } finally {
      setLoadingTheaters(false);
    }
  };

  // Hàm tải danh sách phòng dựa theo ID rạp từ API
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

      // Add debugging to see the actual structure
      console.log("Room data received:", result);

      // Fix: Ensure rooms is always an array
      const roomsArray = Array.isArray(result)
        ? result
        : result.data
        ? result.data
        : result.rooms
        ? result.rooms
        : [];

      setRooms(roomsArray);
    } catch (err) {
      console.error("Lỗi khi tải danh sách phòng:", err);
      setRooms([]);
    } finally {
      setLoadingRooms(false);
    }
  };

  // Thêm lịch chiếu
  const addSchedule = async () => {
    try {
      const response = await fetch(
        "http://localhost:5000/api/v1/admin/movies/addschedules",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(formData),
        }
      );

      if (!response.ok) {
        throw new Error("Không thể thêm lịch chiếu");
      }

      closeModal();
      fetchData(); // Tải lại dữ liệu sau khi thêm
      alert("Thêm lịch chiếu thành công!");
    } catch (err) {
      console.error("Lỗi khi thêm lịch chiếu:", err);
      alert("Lỗi khi thêm lịch chiếu: " + err.message);
    }
  };

  // Xóa lịch chiếu
  const deleteSchedule = async (id) => {
    if (window.confirm("Bạn có chắc chắn muốn xóa lịch chiếu này?")) {
      try {
        const response = await fetch(
          `http://localhost:5000/api/v1/admin/movies/deleteSchedule/${id}`,
          {
            method: "DELETE",
          }
        );

        if (!response.ok) {
          throw new Error("Không thể xóa lịch chiếu");
        }

        fetchData(); // Tải lại dữ liệu sau khi xóa
        alert("Xóa lịch chiếu thành công!");
      } catch (err) {
        console.error("Lỗi khi xóa lịch chiếu:", err);
        alert("Lỗi khi xóa lịch chiếu: " + err.message);
      }
    }
  };

  // Tải dữ liệu khi component mount
  useEffect(() => {
    fetchData();
  }, []);

  // Chuyển đổi thời gian cho dễ đọc
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return `${date.getDate()}/${
      date.getMonth() + 1
    }/${date.getFullYear()} ${date.getHours()}:${
      date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes()
    }`;
  };

  // Chuyển đổi giá tiền có dấu phân cách
  const formatCurrency = (amount) => {
    return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".") + " đ";
  };

  // Hàm mở modal theo loại
  const openModal = (type, item = null) => {
    setModalType(type);
    setSelectedItem(item);

    // Reset form data và danh sách phòng
    setRooms([]);

    if (type === "add") {
      setFormData({
        id_phim: "",
        id_rap: "",
        id_phong: "",
        thoi_gian_chieu: "",
        gia_ve: "",
      });

      // Tải danh sách phim và rạp khi mở modal thêm mới
      fetchMovies();
      fetchTheaters();
    } else if (type === "edit" && item) {
      // Tải danh sách phim và rạp khi mở modal chỉnh sửa
      fetchMovies();
      fetchTheaters();

      // Thiết lập dữ liệu form từ item được chọn
      setFormData({
        id_phim: item.id_phim._id,
        id_rap: item.id_rap._id,
        id_phong: item.id_phong._id,
        thoi_gian_chieu: new Date(item.thoi_gian_chieu)
          .toISOString()
          .slice(0, 16),
        gia_ve: item.gia_ve,
      });

      // Tải danh sách phòng dựa trên rạp đã chọn
      fetchRoomsByTheaterId(item.id_rap._id);
    }

    setShowModal(true);
  };

  // Hàm đóng modal
  const closeModal = () => {
    setShowModal(false);
    setSelectedItem(null);
  };

  // Xử lý thay đổi form
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
  };

  // Xử lý submit form
  const handleSubmit = (e) => {
    e.preventDefault();
    addSchedule();
  };

  // Lọc dữ liệu theo từ khóa tìm kiếm
  const filteredData = data.filter(
    (item) =>
      item.id_phim.ten_phim.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.id_rap.ten_rap.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.id_phong.ten_phong.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <div className="max-w-6xl mx-auto">
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex justify-between items-center mb-6">
            <h1 className="text-2xl font-bold text-gray-800">
              Danh sách lịch chiếu phim
            </h1>
            <button
              onClick={() => openModal("add")}
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center gap-2"
            >
              <Plus size={18} />
              Thêm lịch chiếu
            </button>
          </div>

          <div className="flex justify-between items-center mb-6">
            <div className="relative w-64">
              <input
                type="text"
                placeholder="Tìm kiếm..."
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
              <Search
                className="absolute left-3 top-2.5 text-gray-400"
                size={18}
              />
            </div>

            <div className="flex gap-2">
              <button className="border border-gray-300 bg-white hover:bg-gray-50 px-3 py-2 rounded-md flex items-center gap-1">
                <Filter size={16} />
                Lọc
              </button>
              <button
                className="border border-gray-300 bg-white hover:bg-gray-50 px-3 py-2 rounded-md flex items-center gap-1"
                onClick={fetchData}
              >
                <RefreshCw size={16} />
                Làm mới
              </button>
            </div>
          </div>

          {loading ? (
            <div className="flex justify-center items-center py-8">
              <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
            </div>
          ) : error ? (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
              <p>Lỗi: {error}</p>
              <button
                onClick={fetchData}
                className="mt-2 bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded-md text-sm"
              >
                Thử lại
              </button>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      STT
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Tên phim
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Rạp
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Phòng
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Giới hạn tuổi
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Thời gian chiếu
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Giá vé
                    </th>
                    <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Thao tác
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredData.length === 0 ? (
                    <tr>
                      <td
                        colSpan="8"
                        className="px-6 py-8 text-center text-gray-500"
                      >
                        Không tìm thấy dữ liệu phù hợp
                      </td>
                    </tr>
                  ) : (
                    filteredData.map((item, index) => (
                      <tr key={item._id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {index + 1}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="h-10 w-10 flex-shrink-0">
                              <img
                                className="h-10 w-10 rounded-md object-cover"
                                src={
                                  item.id_phim.url_poster
                                    ? `https://rapchieuphim.com${item.id_phim.url_poster}`
                                    : "https://via.placeholder.com/40x60"
                                }
                                alt="Poster"
                                onError={(e) =>
                                  (e.target.src =
                                    "https://via.placeholder.com/40x60")
                                }
                              />
                            </div>
                            <div className="ml-4">
                              <div className="text-sm font-medium text-gray-900">
                                {item.id_phim.ten_phim}
                              </div>
                              <div className="text-sm text-gray-500">
                                {item.id_phim.thoi_luong} phút
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {item.id_rap.ten_rap}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {item.id_phong.ten_phong}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                            {item.id_phim.gioi_han_tuoi}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {formatDate(item.thoi_gian_chieu)}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-800 font-medium">
                          {formatCurrency(item.gia_ve)}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          <div className="flex justify-center space-x-2">
                            <button
                              onClick={() => openModal("view", item)}
                              className="text-blue-600 hover:text-blue-800 p-1 rounded hover:bg-blue-50"
                              title="Xem chi tiết"
                            >
                              <Eye size={18} />
                            </button>
                            <button
                              onClick={() => openModal("edit", item)}
                              className="text-amber-600 hover:text-amber-800 p-1 rounded hover:bg-amber-50"
                              title="Chỉnh sửa"
                            >
                              <Edit size={18} />
                            </button>
                            <button
                              onClick={() => deleteSchedule(item._id)}
                              className="text-red-600 hover:text-red-800 p-1 rounded hover:bg-red-50"
                              title="Xóa"
                            >
                              <Trash size={18} />
                            </button>
                            <button
                              onClick={() =>
                                // navigate(`ListSeatSchedules/${item.id}`)
                                navigate(`/admin/ListSeatSchedules/${item._id}`)
                              }
                              className="text-red-600 hover:text-red-800 p-1 rounded hover:bg-red-50"
                              title="Xem danh sách ghế"
                            >
                              <Trash size={18} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}

          <div className="flex justify-between items-center mt-6">
            <div className="text-sm text-gray-700">
              Hiển thị <span className="font-medium">1</span> đến{" "}
              <span className="font-medium">{filteredData.length}</span> trong
              tổng số <span className="font-medium">{data.length}</span> bản ghi
            </div>
            <div className="flex space-x-1">
              <button className="px-3 py-1 border border-gray-300 rounded-md bg-white hover:bg-gray-50 text-sm">
                Trước
              </button>
              <button className="px-3 py-1 border border-gray-300 rounded-md bg-blue-600 text-white hover:bg-blue-700 text-sm">
                1
              </button>
              <button className="px-3 py-1 border border-gray-300 rounded-md bg-white hover:bg-gray-50 text-sm">
                Sau
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 overflow-y-auto z-50 flex items-center justify-center">
          <div
            className="fixed inset-0 bg-black opacity-40"
            onClick={closeModal}
          ></div>
          <div className="relative bg-white rounded-lg shadow-xl max-w-3xl w-full mx-4 z-10">
            <div className="flex justify-between items-center border-b px-6 py-4">
              <h3 className="text-xl font-medium text-gray-900">
                {modalType === "add" && "Thêm lịch chiếu mới"}
                {modalType === "edit" && "Chỉnh sửa lịch chiếu"}
                {modalType === "view" && "Chi tiết lịch chiếu"}
              </h3>
              <button
                onClick={closeModal}
                className="text-gray-400 hover:text-gray-500 focus:outline-none"
              >
                &times;
              </button>
            </div>

            <div className="p-6">
              {modalType === "view" && selectedItem && (
                <div className="space-y-4">
                  <div className="flex">
                    <div className="w-1/3">
                      <img
                        className="h-96 w-80   rounded-md object-cover"
                        src={
                          selectedItem.id_phim.url_poster
                            ? `https://rapchieuphim.com${selectedItem.id_phim.url_poster}`
                            : "https://via.placeholder.com/150x200"
                        }
                        alt="Poster"
                        onError={(e) =>
                          (e.target.src = "https://via.placeholder.com/150x200")
                        }
                      />
                    </div>
                    <div className="w-2/3 pl-6 space-y-3">
                      <h4 className="text-xl font-bold">
                        {selectedItem.id_phim.ten_phim}
                      </h4>
                      <p>
                        <span className="font-medium">Giới hạn tuổi:</span>{" "}
                        {selectedItem.id_phim.gioi_han_tuoi}
                      </p>
                      <p>
                        <span className="font-medium">Thời lượng:</span>{" "}
                        {selectedItem.id_phim.thoi_luong} phút
                      </p>
                      <p>
                        <span className="font-medium">Rạp chiếu:</span>{" "}
                        {selectedItem.id_rap.ten_rap}
                      </p>
                      <p>
                        <span className="font-medium">Phòng chiếu:</span>{" "}
                        {selectedItem.id_phong.ten_phong}
                      </p>
                      <p>
                        <span className="font-medium">Thời gian chiếu:</span>{" "}
                        {formatDate(selectedItem.thoi_gian_chieu)}
                      </p>
                      <p>
                        <span className="font-medium">Giá vé:</span>{" "}
                        {formatCurrency(selectedItem.gia_ve)}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {(modalType === "add" || modalType === "edit") && (
                <form className="space-y-4" onSubmit={handleSubmit}>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Chọn phim
                      </label>
                      <select
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                        name="id_phim"
                        value={formData.id_phim}
                        onChange={handleInputChange}
                        required
                        disabled={loadingMovies}
                      >
                        <option value="">-- Chọn phim --</option>
                        {loadingMovies ? (
                          <option value="" disabled>
                            Đang tải danh sách phim...
                          </option>
                        ) : (
                          movies.map((movie) => (
                            <option key={movie._id} value={movie._id}>
                              {movie.ten_phim}
                            </option>
                          ))
                        )}
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Chọn rạp
                      </label>
                      <select
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                        name="id_rap"
                        value={formData.id_rap}
                        onChange={handleInputChange}
                        required
                        disabled={loadingTheaters}
                      >
                        <option value="">-- Chọn rạp --</option>
                        {loadingTheaters ? (
                          <option value="" disabled>
                            Đang tải danh sách rạp...
                          </option>
                        ) : (
                          theaters.map((theater) => (
                            <option key={theater._id} value={theater._id}>
                              {theater.ten_rap}
                            </option>
                          ))
                        )}
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Chọn phòng
                      </label>
                      <select
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                        name="id_phong"
                        value={formData.id_phong}
                        onChange={handleInputChange}
                        required
                        disabled={loadingRooms || !formData.id_rap}
                      >
                        <option value="">-- Chọn phòng --</option>
                        {!formData.id_rap ? (
                          <option value="" disabled>
                            Vui lòng chọn rạp trước
                          </option>
                        ) : loadingRooms ? (
                          <option value="" disabled>
                            Đang tải danh sách phòng...
                          </option>
                        ) : rooms.length === 0 ? (
                          <option value="" disabled>
                            Không có phòng nào cho rạp này
                          </option>
                        ) : (
                          rooms.map((room) => (
                            <option key={room._id} value={room._id}>
                              {room.ten_phong}
                            </option>
                          ))
                        )}
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Thời gian chiếu
                      </label>
                      <input
                        type="datetime-local"
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                        name="thoi_gian_chieu"
                        value={formData.thoi_gian_chieu}
                        onChange={handleInputChange}
                        required
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Giá vé (VNĐ)
                      </label>
                      <input
                        type="number"
                        className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="Nhập giá vé..."
                        name="gia_ve"
                        value={formData.gia_ve}
                        onChange={handleInputChange}
                        required
                      />
                    </div>
                  </div>

                  <div className="bg-gray-50 px-6 py-4 flex justify-end border-t mt-4 -mx-6 -mb-6">
                    <button
                      type="button"
                      onClick={closeModal}
                      className="border border-gray-300 bg-white hover:bg-gray-50 text-gray-700 px-4 py-2 rounded-md mr-2"
                    >
                      Hủy
                    </button>

                    <button
                      type="submit"
                      className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md"
                    >
                      {modalType === "add" ? "Thêm mới" : "Cập nhật"}
                    </button>
                  </div>
                </form>
              )}
            </div>

            {modalType === "view" && (
              <div className="bg-gray-50 px-6 py-4 flex justify-end border-t">
                <button
                  onClick={closeModal}
                  className="border border-gray-300 bg-white hover:bg-gray-50 text-gray-700 px-4 py-2 rounded-md"
                >
                  Đóng
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default LichChieuPhim;
