import React, { useState, useEffect } from "react";
import axios from "axios";
import {
  Clipboard,
  Theater,
  Users,
  Calendar,
  RefreshCw,
  Settings,
  Info,
} from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";

const TheaterRoomsList = () => {
  const navigate = useNavigate(); // Gọi hook đúng cách
  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedRoom, setSelectedRoom] = useState(null);
  const { theaterId } = useParams(); // Lấy ID từ URL

  useEffect(() => {
    fetchRooms();
  }, [theaterId]);

  const fetchRooms = async () => {
    setLoading(true);
    try {
      console.log("Theater ID:", theaterId);
      const response = await axios.get(
        `http://localhost:5000/api/v1/admin/theaters/${theaterId}/rooms`
      );
      if (response.data.success) {
        setRooms(response.data.data);
        if (response.data.data.length > 0) {
          setSelectedRoom(response.data.data[0]);
        }
      } else {
        setError("Không thể tải dữ liệu phòng chiếu");
      }
    } catch (err) {
      setError(`Đã xảy ra lỗi: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  const handleRoomSelect = (room) => {
    setSelectedRoom(room);
  };
  const handleListSeat = (roomId) => {
    console.log("Theater ID:", roomId); // Debug xem giá trị truyền vào có đúng không
    if (!roomId) {
      alert("Lỗi: Không tìm thấy ID rạp!");
      return;
    }
    navigate(`/admin/ListSeats/${roomId}/seat`);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("vi-VN", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getCapacityColor = (capacity) => {
    if (capacity >= 150) return "bg-green-100 text-green-800";
    if (capacity >= 100) return "bg-blue-100 text-blue-800";
    return "bg-yellow-100 text-yellow-800";
  };

  const getCapacityType = (capacity) => {
    if (capacity >= 150) return "VIP";
    if (capacity >= 100) return "Tiêu chuẩn";
    return "Nhỏ";
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-t-red-500 border-r-red-500 border-b-transparent border-l-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-4 text-lg text-gray-700 font-medium">
            Đang tải dữ liệu phòng chiếu...
          </p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50">
        <div className="max-w-md w-full bg-white p-8 rounded-lg shadow-lg">
          <div className="w-16 h-16 mx-auto mb-4 text-red-500">
            <Info size={64} />
          </div>
          <h2 className="text-2xl font-bold text-center text-gray-800 mb-4">
            Đã xảy ra lỗi
          </h2>
          <p className="text-gray-600 text-center mb-6">{error}</p>
          <button
            onClick={fetchRooms}
            className="w-full bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded-lg transition duration-200 flex items-center justify-center"
          >
            <RefreshCw className="mr-2 h-5 w-5" />
            Thử lại
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                {rooms.length > 0 && rooms[0].id_rap && rooms[0].id_rap.ten_rap
                  ? rooms[0].id_rap.ten_rap
                  : "Danh sách phòng chiếu"}
              </h1>
              <p className="text-gray-500 mt-1">
                Quản lý thông tin các phòng chiếu phim
              </p>
            </div>
            <div className="mt-4 md:mt-0">
              <button
                onClick={fetchRooms}
                className="bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded-lg shadow transition duration-200 flex items-center"
              >
                <RefreshCw className="mr-2 h-4 w-4" />
                Làm mới
              </button>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow-lg overflow-hidden">
              <div className="bg-gradient-to-r from-red-600 to-red-700 px-6 py-4">
                <h2 className="text-xl font-semibold text-white flex items-center">
                  <Theater className="mr-2 h-5 w-5" />
                  Danh sách phòng chiếu ({rooms.length})
                </h2>
              </div>

              {rooms.length === 0 ? (
                <div className="p-8 text-center">
                  <p className="text-gray-500">
                    Không có phòng chiếu nào được tìm thấy
                  </p>
                </div>
              ) : (
                <div className="divide-y divide-gray-100">
                  {rooms.map((room) => (
                    <div
                      key={room._id}
                      className={`p-4 cursor-pointer transition duration-150 hover:bg-red-50 flex items-center
                        ${
                          selectedRoom && selectedRoom._id === room._id
                            ? "bg-red-50 border-l-4 border-red-500"
                            : ""
                        }`}
                      onClick={() => handleRoomSelect(room)}
                    >
                      <div className="bg-red-100 rounded-lg p-3 mr-4">
                        <Theater className="h-6 w-6 text-red-600" />
                      </div>
                      <div className="flex-grow">
                        <h3 className="text-lg font-semibold text-gray-800">
                          {room.ten_phong}
                        </h3>
                        <div className="flex items-center mt-1">
                          <Users className="h-4 w-4 text-gray-500 mr-1" />
                          <span className="text-sm text-gray-600">
                            {room.tong_so_ghe} ghế
                          </span>
                        </div>
                      </div>
                      <div>
                        <span
                          className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getCapacityColor(
                            room.tong_so_ghe
                          )}`}
                        >
                          {getCapacityType(room.tong_so_ghe)}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          <div className="lg:col-span-1">
            {selectedRoom ? (
              <div className="bg-white rounded-lg shadow-lg overflow-hidden">
                <div className="bg-gradient-to-r from-red-600 to-red-700 px-6 py-4">
                  <h2 className="text-xl font-semibold text-white flex items-center">
                    <Info className="mr-2 h-5 w-5" />
                    Chi tiết phòng chiếu
                  </h2>
                </div>
                <div className="p-6">
                  <div className="flex items-center mb-6">
                    <div className="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center mr-4">
                      <span className="text-xl font-bold text-red-600">
                        {selectedRoom.ten_phong.split(" ").length > 1
                          ? selectedRoom.ten_phong.split(" ")[1]
                          : selectedRoom.ten_phong.charAt(0)}
                      </span>
                    </div>
                    <div>
                      <h3 className="text-2xl font-bold text-gray-800">
                        {selectedRoom.ten_phong}
                      </h3>
                      <p className="text-sm text-gray-500">
                        {selectedRoom.id_rap && selectedRoom.id_rap.ten_rap
                          ? selectedRoom.id_rap.ten_rap
                          : "Rạp phim"}
                      </p>
                    </div>
                  </div>

                  <div className="space-y-4">
                    <div className="bg-gray-50 p-4 rounded-lg">
                      <h4 className="text-sm font-medium text-gray-500 mb-2">
                        ID Phòng
                      </h4>
                      <div className="flex items-center">
                        <p className="text-sm font-mono bg-gray-100 p-1 rounded flex-grow overflow-x-auto">
                          {selectedRoom._id}
                        </p>
                        <button className="ml-2 text-gray-500 hover:text-red-500">
                          <Clipboard className="h-4 w-4" />
                        </button>
                      </div>
                    </div>

                    <div className="bg-gray-50 p-4 rounded-lg">
                      <h4 className="text-sm font-medium text-gray-500 mb-2">
                        Thông tin cơ bản
                      </h4>
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <p className="text-xs text-gray-500">Số ghế</p>
                          <p className="text-lg font-semibold text-gray-800">
                            {selectedRoom.tong_so_ghe}
                          </p>
                        </div>
                        <div>
                          <p className="text-xs text-gray-500">Loại phòng</p>
                          <span
                            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getCapacityColor(
                              selectedRoom.tong_so_ghe
                            )}`}
                          >
                            {getCapacityType(selectedRoom.tong_so_ghe)}
                          </span>
                        </div>
                      </div>
                    </div>

                    {selectedRoom.createdAt && selectedRoom.updatedAt && (
                      <div className="bg-gray-50 p-4 rounded-lg">
                        <h4 className="text-sm font-medium text-gray-500 mb-2">
                          Thời gian
                        </h4>
                        <div className="space-y-2">
                          <div>
                            <div className="flex items-center text-xs text-gray-500 mb-1">
                              <Calendar className="h-3 w-3 mr-1" />
                              Ngày tạo
                            </div>
                            <p className="text-sm text-gray-800">
                              {formatDate(selectedRoom.createdAt)}
                            </p>
                          </div>
                          <div>
                            <div className="flex items-center text-xs text-gray-500 mb-1">
                              <Calendar className="h-3 w-3 mr-1" />
                              Cập nhật gần nhất
                            </div>
                            <p className="text-sm text-gray-800">
                              {formatDate(selectedRoom.updatedAt)}
                            </p>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>

                  <div className="mt-6 space-y-3">
                    <button className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg w-full transition duration-150 flex items-center justify-center">
                      <Settings className="mr-2 h-4 w-4" />
                      Quản lý phòng
                    </button>
                    <button
                      onClick={() =>
                        navigate(`/admin/ListSeats/${selectedRoom._id}/seats`)
                      }
                      className="bg-gray-100 hover:bg-gray-200 text-gray-800 px-4 py-2 rounded-lg w-full transition duration-150"
                    >
                      Xem sơ đồ ghế
                    </button>
                  </div>
                </div>
              </div>
            ) : (
              <div className="bg-white rounded-lg shadow-lg p-8 flex flex-col items-center justify-center h-full">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                  <Info className="h-8 w-8 text-gray-400" />
                </div>
                <p className="text-gray-500 text-center mb-4">
                  Vui lòng chọn một phòng để xem chi tiết
                </p>
                <button
                  onClick={fetchRooms}
                  className="text-red-600 hover:text-red-700 text-sm flex items-center"
                >
                  <RefreshCw className="mr-1 h-4 w-4" />
                  Làm mới danh sách
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TheaterRoomsList;
