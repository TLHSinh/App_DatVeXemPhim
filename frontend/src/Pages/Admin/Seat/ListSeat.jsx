import React, { useState, useEffect } from "react";
import axios from "axios";
import { useParams } from "react-router-dom";

const SeatManagement = () => {
  const [seats, setSeats] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedSeats, setSelectedSeats] = useState([]);
  const [updateStatus, setUpdateStatus] = useState(null);
  const [showStatusModal, setShowStatusModal] = useState(false);
  const { roomId } = useParams();

  useEffect(() => {
    fetchSeats();
  }, [roomId]);

  const fetchSeats = async () => {
    setLoading(true);
    try {
      console.log("roomId", roomId);
      const response = await axios.get(
        `http://localhost:5000/api/v1/admin/rooms/${roomId}/seats`
      );
      setSeats(response.data.data || []);
      setError(null);
    } catch (err) {
      setError(
        "Lỗi khi tải dữ liệu ghế: " +
          (err.response?.data?.message || err.message)
      );
      setSeats([]);
    } finally {
      setLoading(false);
    }
  };
  const handleRoomChange = (e) => {
    roomId(e.target.value);
  };

  const handleLoadSeats = () => {
    if (roomId) {
      fetchSeats(roomId);
    }
  };

  const toggleSeatSelection = (seat) => {
    // Removed the condition that prevented selecting seats with "hư hỏng" status
    setSelectedSeats((prev) => {
      const isSelected = prev.some((s) => s._id === seat._id);
      if (isSelected) {
        return prev.filter((s) => s._id !== seat._id);
      } else {
        return [...prev, seat];
      }
    });
  };

  const updateSeatStatus = async (status) => {
    setUpdateStatus({
      loading: true,
      message: "Đang cập nhật...",
      type: "info",
    });
    try {
      const seatIds = selectedSeats.map((seat) => seat._id);

      // Sử dụng API mới với id_phong và id_ghe
      await axios.put(
        `http://localhost:5000/api/v1/admin/rooms/${roomId}/seats/status/${seatIds.join(
          ","
        )}`,
        {
          trang_thai: status,
        }
      );

      // Cập nhật trạng thái trên giao diện
      setSeats((prev) =>
        prev.map((seat) =>
          selectedSeats.some((s) => s._id === seat._id)
            ? { ...seat, trang_thai: status }
            : seat
        )
      );

      // Removed code that cleared selected seats when marked as damaged

      setUpdateStatus({
        loading: false,
        message: `Đã cập nhật ${seatIds.length} ghế thành "${status}"`,
        type: "success",
      });

      // Tự động đóng thông báo sau 3 giây
      setTimeout(() => {
        setUpdateStatus(null);
      }, 3000);
    } catch (err) {
      setUpdateStatus({
        loading: false,
        message:
          "Lỗi khi cập nhật trạng thái ghế: " +
          (err.response?.data?.message || err.message),
        type: "error",
      });
    }
  };

  const openStatusModal = () => {
    if (selectedSeats.length > 0) {
      setShowStatusModal(true);
    }
  };

  // Group seats by row for display
  const groupedSeats = seats.reduce((acc, seat) => {
    const row = seat.so_ghe.charAt(0);
    if (!acc[row]) acc[row] = [];
    acc[row].push(seat);
    return acc;
  }, {});

  // Sort rows alphabetically
  const sortedRows = Object.keys(groupedSeats).sort();

  // Mảng các trạng thái ghế có thể cập nhật
  const availableStatuses = [
    { value: "có sẵn", label: "Có sẵn", color: "bg-green-600" },
    { value: "đã đặt trước", label: "Đã đặt", color: "bg-gray-600" },
    { value: "hư hỏng", label: "Hư hỏng", color: "bg-red-600" },
    { value: "bảo trì", label: "Bảo trì", color: "bg-yellow-600" },
  ];

  return (
    <div className="p-6 bg-gray-100 min-h-screen">
      <div className="max-w-5xl mx-auto bg-white rounded-lg shadow-md p-6">
        <h1 className="text-2xl font-bold mb-6 text-gray-800">
          Quản lý danh sách ghế
        </h1>

        {/* Room selection */}
        <div className="flex gap-4 mb-6">
          <input
            type="text"
            value={roomId}
            onChange={handleRoomChange}
            placeholder="Nhập ID phòng"
            className="flex-1 p-2 border border-gray-300 rounded"
          />
          <button
            onClick={handleLoadSeats}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            disabled={loading}
          >
            {loading ? "Đang tải..." : "Tải danh sách ghế"}
          </button>
        </div>

        {/* Error message */}
        {error && (
          <div className="mb-4 p-3 bg-red-100 text-red-700 rounded">
            {error}
          </div>
        )}

        {/* Status update message */}
        {updateStatus && (
          <div
            className={`mb-4 p-3 rounded flex justify-between items-center ${
              updateStatus.type === "success"
                ? "bg-green-100 text-green-700"
                : updateStatus.type === "error"
                ? "bg-red-100 text-red-700"
                : "bg-blue-100 text-blue-700"
            }`}
          >
            <div className="flex items-center">
              {updateStatus.loading && (
                <svg
                  className="animate-spin -ml-1 mr-2 h-4 w-4"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                >
                  <circle
                    className="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    strokeWidth="4"
                  ></circle>
                  <path
                    className="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  ></path>
                </svg>
              )}
              {updateStatus.message}
            </div>
            <button
              onClick={() => setUpdateStatus(null)}
              className="text-sm hover:underline"
            >
              Đóng
            </button>
          </div>
        )}

        {loading && !updateStatus?.loading ? (
          <div className="flex justify-center items-center h-40">
            <div className="flex items-center">
              <svg
                className="animate-spin -ml-1 mr-3 h-5 w-5 text-blue-600"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                ></circle>
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
              <p className="text-gray-600">Đang tải dữ liệu...</p>
            </div>
          </div>
        ) : seats.length > 0 ? (
          <>
            {/* Selected seats actions */}
            {selectedSeats.length > 0 && (
              <div className="mb-6 p-4 bg-blue-50 rounded-lg flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                  <p className="mb-1 font-medium">
                    Đã chọn {selectedSeats.length} ghế
                  </p>
                  <div className="flex flex-wrap gap-1 max-w-md">
                    {selectedSeats.slice(0, 10).map((seat) => (
                      <span
                        key={seat._id}
                        className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded"
                      >
                        {seat.so_ghe}
                      </span>
                    ))}
                    {selectedSeats.length > 10 && (
                      <span className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
                        +{selectedSeats.length - 10} ghế khác
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={openStatusModal}
                    className="px-3 py-2 bg-blue-600 text-white text-sm rounded hover:bg-blue-700 flex items-center"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      className="h-4 w-4 mr-1"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
                      />
                    </svg>
                    Cập nhật trạng thái
                  </button>
                  <button
                    onClick={() => setSelectedSeats([])}
                    className="px-3 py-2 bg-gray-600 text-white text-sm rounded hover:bg-gray-700"
                  >
                    Bỏ chọn tất cả
                  </button>
                </div>
              </div>
            )}

            {/* Status update modal */}
            {showStatusModal && (
              <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                <div className="bg-white rounded-lg p-6 max-w-md w-full">
                  <h3 className="text-lg font-medium mb-4">
                    Cập nhật trạng thái ghế
                  </h3>
                  <p className="mb-4">
                    Cập nhật {selectedSeats.length} ghế đã chọn:
                  </p>

                  <div className="grid grid-cols-2 gap-2 mb-6">
                    {availableStatuses.map((status) => (
                      <button
                        key={status.value}
                        onClick={() => {
                          updateSeatStatus(status.value);
                          setShowStatusModal(false);
                        }}
                        className={`${status.color} text-white p-3 rounded flex items-center justify-center hover:opacity-90`}
                      >
                        {status.label}
                      </button>
                    ))}
                  </div>

                  <div className="flex justify-end">
                    <button
                      onClick={() => setShowStatusModal(false)}
                      className="px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300"
                    >
                      Hủy
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* Screen representation */}
            <div className="w-full bg-gray-300 h-8 rounded-lg mb-10 flex items-center justify-center text-gray-700 text-sm font-medium">
              Màn hình
            </div>

            {/* Seat map */}
            <div className="mb-10 overflow-x-auto">
              <div className="min-w-max">
                {sortedRows.map((row) => (
                  <div key={row} className="flex justify-center mb-4">
                    <div className="w-8 h-8 flex items-center justify-center font-bold text-gray-700">
                      {row}
                    </div>
                    <div className="flex gap-2 flex-wrap">
                      {groupedSeats[row]
                        .sort((a, b) => {
                          const numA = parseInt(a.so_ghe.substring(1));
                          const numB = parseInt(b.so_ghe.substring(1));
                          return numA - numB;
                        })
                        .map((seat) => {
                          const isSelected = selectedSeats.some(
                            (s) => s._id === seat._id
                          );
                          let bgClass = "";

                          if (isSelected) {
                            bgClass = "bg-blue-600 text-white";
                          } else if (seat.trang_thai === "có sẵn") {
                            bgClass =
                              "bg-green-100 hover:bg-green-200 text-green-800";
                          } else if (seat.trang_thai === "hư hỏng") {
                            bgClass =
                              "bg-red-300 text-red-800 hover:bg-red-400";
                          } else if (seat.trang_thai === "bảo trì") {
                            bgClass =
                              "bg-yellow-300 text-yellow-800 hover:bg-yellow-400";
                          } else {
                            bgClass =
                              "bg-gray-300 text-gray-600 hover:bg-gray-400";
                          }

                          return (
                            <button
                              key={seat._id}
                              className={`w-10 h-10 rounded flex items-center justify-center text-sm font-medium transition-colors ${bgClass} cursor-pointer`}
                              onClick={() => toggleSeatSelection(seat)}
                              title={`${seat.so_ghe} - ${seat.trang_thai}`}
                            >
                              {seat.so_ghe}
                            </button>
                          );
                        })}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Legend */}
            <div className="flex justify-center gap-4 mb-6 flex-wrap">
              <div className="flex items-center">
                <div className="w-6 h-6 bg-green-100 rounded mr-2"></div>
                <span className="text-sm text-gray-700">Có sẵn</span>
              </div>
              <div className="flex items-center">
                <div className="w-6 h-6 bg-blue-600 rounded mr-2"></div>
                <span className="text-sm text-gray-700">Đã chọn</span>
              </div>
              <div className="flex items-center">
                <div className="w-6 h-6 bg-red-300 rounded mr-2"></div>
                <span className="text-sm text-gray-700">Hư hỏng</span>
              </div>
              <div className="flex items-center">
                <div className="w-6 h-6 bg-yellow-300 rounded mr-2"></div>
                <span className="text-sm text-gray-700">Bảo trì</span>
              </div>
              <div className="flex items-center">
                <div className="w-6 h-6 bg-gray-300 rounded mr-2"></div>
                <span className="text-sm text-gray-700">Đã đặt</span>
              </div>
            </div>
          </>
        ) : (
          <div className="flex justify-center items-center h-40">
            <p className="text-gray-600">
              Không có dữ liệu ghế. Vui lòng nhập ID phòng và tải dữ liệu.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default SeatManagement;
