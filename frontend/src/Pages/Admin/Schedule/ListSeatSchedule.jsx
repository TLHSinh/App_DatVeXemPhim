import React, { useState, useEffect } from "react";
import axios from "axios";
import { useParams } from "react-router-dom";

const SeatManagement = () => {
  const [seats, setSeats] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedSeat, setSelectedSeat] = useState(null);
  const [ticketInfo, setTicketInfo] = useState(null);
  const [ticketLoading, setTicketLoading] = useState(false);
  const { idLichChieu } = useParams();
  const [roomId, setRoomId] = useState(idLichChieu || "");

  useEffect(() => {
    if (idLichChieu) {
      setRoomId(idLichChieu);
      fetchSeats();
    }
  }, [idLichChieu]);

  const fetchSeats = async () => {
    if (!roomId) return;

    setLoading(true);
    try {
      console.log("ID Phòng", roomId);
      const response = await axios.get(
        `http://localhost:5000/api/v1/seat/${roomId}`
      );

      // Xử lý dữ liệu theo định dạng mới
      if (response.data && response.data.danh_sach_ghe) {
        setSeats(response.data.danh_sach_ghe || []);
      } else {
        setSeats([]);
      }

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
    setRoomId(e.target.value);
  };

  const handleLoadSeats = () => {
    if (roomId) {
      fetchSeats();
    }
  };

  const fetchTicketInfo = async (seatId) => {
    setTicketLoading(true);
    try {
      const response = await axios.get(
        `http://localhost:5000/api/v1/ticket/ticket/${seatId}/${roomId}`
      );
      setTicketInfo(response.data);
      console.log("Thông tin vé:", response.data);
    } catch (err) {
      console.error("Lỗi khi lấy thông tin vé:", err);
      setTicketInfo(null);
    } finally {
      setTicketLoading(false);
    }
  };

  const handleSeatClick = (seat) => {
    setSelectedSeat(seat);
    fetchTicketInfo(seat._id_Ghe);
  };

  // Format date for display
  const formatDate = (dateString) => {
    if (!dateString) return "N/A";

    const date = new Date(dateString);
    return new Intl.DateTimeFormat("vi-VN", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date);
  };

  // Format currency
  const formatCurrency = (amount) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(amount);
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

  return (
    <div className="p-6 bg-gray-100 min-h-screen">
      <div className="max-w-5xl mx-auto bg-white rounded-lg shadow-md p-6">
        <h1 className="text-2xl font-bold mb-6 text-gray-800">
          Thông tin ghế và vé
        </h1>

        {/* Room selection */}
        <div className="flex gap-4 mb-6">
          <input
            type="text"
            value={roomId}
            onChange={handleRoomChange}
            placeholder="Nhập ID xuất chiếu"
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

        <div className="flex flex-col md:flex-row gap-6">
          <div className="md:w-2/3">
            {loading ? (
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
                              const isSelected =
                                selectedSeat &&
                                selectedSeat._id_Ghe === seat._id_Ghe;
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
                                  key={seat._id_Ghe}
                                  className={`w-10 h-10 rounded flex items-center justify-center text-sm font-medium transition-colors ${bgClass} cursor-pointer`}
                                  onClick={() => handleSeatClick(seat)}
                                  title={`${seat.so_ghe} - ${seat.trang_thai}`}
                                >
                                  {seat.so_ghe.substring(1)}
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
                    <span className="text-sm text-gray-700">Ghế đang xem</span>
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
                  Không có dữ liệu ghế. Vui lòng nhập ID xuất chiếu và tải dữ
                  liệu.
                </p>
              </div>
            )}
          </div>

          {/* Ticket Information Panel */}
          <div className="md:w-1/3 bg-gray-50 p-4 rounded-lg">
            <h2 className="text-xl font-semibold mb-4">Thông tin vé</h2>
            {selectedSeat ? (
              <>
                <div className="mb-4 p-3 bg-blue-50 rounded-lg border border-blue-100">
                  <p className="font-medium text-blue-800">
                    Ghế đã chọn: {selectedSeat.so_ghe}
                  </p>
                  <p className="text-sm text-blue-700">
                    Trạng thái: {selectedSeat.trang_thai}
                  </p>
                </div>

                {ticketLoading ? (
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
                      <p className="text-gray-600">Đang tải thông tin vé...</p>
                    </div>
                  </div>
                ) : ticketInfo ? (
                  <div className="space-y-4">
                    {/* Ticket Card */}
                    <div className="bg-white rounded-xl overflow-hidden shadow-md border border-gray-200">
                      {/* Ticket Header */}
                      <div className="bg-blue-600 text-white p-4">
                        <div className="flex justify-between items-center">
                          <h3 className="font-bold text-lg">Thông tin vé</h3>
                          <span className="px-2 py-1 bg-white text-blue-600 rounded-full text-xs font-bold uppercase">
                            {ticketInfo.trang_thai}
                          </span>
                        </div>
                      </div>

                      {/* Ticket Body */}
                      <div className="p-4">
                        {/* User Info */}
                        <div className="mb-4">
                          <h4 className="text-sm text-gray-500 uppercase font-medium mb-1">
                            Khách hàng
                          </h4>
                          <p className="font-medium">
                            {ticketInfo.id_nguoi_dung?.email ||
                              "Không có thông tin"}
                          </p>
                        </div>

                        {/* Seat Info */}
                        <div className="mb-4">
                          <h4 className="text-sm text-gray-500 uppercase font-medium mb-1">
                            Ghế
                          </h4>
                          <div className="flex flex-wrap gap-2">
                            {ticketInfo.danh_sach_ghe?.map((ghe, index) => (
                              <span
                                key={index}
                                className="inline-block bg-blue-100 text-blue-800 px-2 py-1 rounded-lg font-medium"
                              >
                                {ghe.so_ghe}
                              </span>
                            ))}
                          </div>
                        </div>

                        {/* Price Info */}
                        <div className="mb-4">
                          <h4 className="text-sm text-gray-500 uppercase font-medium mb-1">
                            Thông tin thanh toán
                          </h4>
                          <div className="space-y-1">
                            <div className="flex justify-between">
                              <span className="text-gray-600">Tổng tiền:</span>
                              <span>
                                {formatCurrency(ticketInfo.tong_tien || 0)}
                              </span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-gray-600">Tiền giảm:</span>
                              <span className="text-red-600">
                                -{formatCurrency(ticketInfo.tien_giam || 0)}
                              </span>
                            </div>
                            <div className="flex justify-between font-bold border-t border-gray-200 pt-1 mt-1">
                              <span>Thanh toán:</span>
                              <span className="text-green-600">
                                {formatCurrency(
                                  ticketInfo.tien_thanh_toan || 0
                                )}
                              </span>
                            </div>
                          </div>
                        </div>

                        {/* Voucher Info */}
                        {ticketInfo.id_voucher && (
                          <div className="mb-4">
                            <h4 className="text-sm text-gray-500 uppercase font-medium mb-1">
                              Voucher áp dụng
                            </h4>
                            <div className="bg-yellow-50 p-2 rounded-lg border border-yellow-100">
                              <div className="flex items-center gap-2">
                                {ticketInfo.id_voucher.url_hinh && (
                                  <img
                                    src={ticketInfo.id_voucher.url_hinh}
                                    alt="Voucher"
                                    className="w-12 h-12 object-cover rounded"
                                  />
                                )}
                                <div>
                                  <p className="font-medium text-yellow-800">
                                    {ticketInfo.id_voucher.ma_voucher}
                                  </p>
                                  <p className="text-xs text-yellow-700">
                                    {ticketInfo.id_voucher.loai_giam_gia ===
                                    "tien_mat"
                                      ? `Giảm ${formatCurrency(
                                          ticketInfo.id_voucher.gia_tri_giam
                                        )}`
                                      : `Giảm ${ticketInfo.id_voucher.gia_tri_giam}%`}
                                  </p>
                                </div>
                              </div>
                            </div>
                          </div>
                        )}

                        {/* Food Info */}
                        {ticketInfo.danh_sach_do_an &&
                          ticketInfo.danh_sach_do_an.length > 0 && (
                            <div className="mb-4">
                              <h4 className="text-sm text-gray-500 uppercase font-medium mb-1">
                                Đồ ăn & Nước uống
                              </h4>
                              <ul className="list-disc pl-5">
                                {ticketInfo.danh_sach_do_an.map(
                                  (item, index) => (
                                    <li key={index} className="text-gray-700">
                                      {item.ten_do_an || "Không có tên"} :{" "}
                                      {item.so_luong || 1} x {item.gia || 1}
                                    </li>
                                  )
                                )}
                              </ul>
                            </div>
                          )}

                        {/* Creation Date */}
                        <div className="text-xs text-gray-500 mt-4">
                          <p>Ngày tạo: {formatDate(ticketInfo.createdAt)}</p>
                          <p>Cập nhật: {formatDate(ticketInfo.updatedAt)}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-200 text-yellow-800">
                    <div className="flex items-center gap-2 mb-2">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-5 w-5"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                          clipRule="evenodd"
                        />
                      </svg>
                      <span className="font-medium">
                        Không tìm thấy thông tin vé
                      </span>
                    </div>
                    <p className="text-sm">
                      Không tìm thấy thông tin vé cho ghế này hoặc có lỗi xảy ra
                      khi tải dữ liệu.
                    </p>
                  </div>
                )}
              </>
            ) : (
              <div className="bg-gray-100 p-6 rounded-lg text-gray-600 text-center">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-12 w-12 mx-auto mb-3 text-gray-400"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 14l-7 7m0 0l-7-7m7 7V3"
                  />
                </svg>
                <p className="font-medium">
                  Vui lòng chọn một ghế để xem thông tin vé
                </p>
                <p className="text-sm mt-1 text-gray-500">
                  Thông tin chi tiết về vé sẽ hiển thị tại đây
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default SeatManagement;
