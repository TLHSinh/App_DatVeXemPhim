import React, { useEffect, useState } from "react";
import { BASE_URL, token } from "../../../config";
import { useNavigate } from "react-router-dom";

const Dashboard = () => {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    TotalBookings: 0,
    MoviesShowing: 0,
    Customers: 0,
    Revenue: 0,
  });

  useEffect(() => {
    // Fetch số liệu thống kê từ API
    const fetchStats = async () => {
      try {
        const res = await fetch(`${BASE_URL}/api/v1/dashboard/stats`, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
        });
        const data = await res.json();
        if (res.ok) {
          setStats(data);
        } else {
          console.error(data.message);
        }
      } catch (err) {
        console.error("Lỗi khi lấy dữ liệu thống kê:", err.message);
      }
    };
    fetchStats();
  }, []);

  return (
    <div className="bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-800 to-indigo-700 py-6 px-6 shadow-lg">
        <h1 className="text-3xl font-bold text-white">
          Quản Lý Đặt Vé Xem Phim
        </h1>
        <p className="text-purple-100 mt-1">Thống kê tổng quan hệ thống</p>
      </div>

      {/* Stats Cards */}
      <div className="px-6 py-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Card 1 */}
          <div className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300">
            <div className="flex items-center p-6">
              <div className="bg-blue-100 p-3 rounded-lg">
                <svg
                  className="w-8 h-8 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M5 5h14a2 2 0 012 2v3a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2z"
                  ></path>
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M15 11v10M5 11v10M19 11v10"
                  ></path>
                </svg>
              </div>
              <div className="ml-4">
                <h2 className="text-sm font-medium text-gray-500">
                  Tổng Vé Đã Đặt
                </h2>
                <p className="text-2xl font-bold text-gray-800">
                  {stats.TotalBookings}
                </p>
              </div>
            </div>
            <div className="px-6 py-3 bg-blue-50">
              <a
                href="/bookings"
                className="text-sm text-blue-600 font-medium hover:text-blue-800"
              >
                Xem chi tiết &rarr;
              </a>
            </div>
          </div>

          {/* Card 2 */}
          <div className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300">
            <div className="flex items-center p-6">
              <div className="bg-red-100 p-3 rounded-lg">
                <svg
                  className="w-8 h-8 text-red-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M7 4v16M17 4v16M3 8h4m10 0h4M3 12h18M3 16h4m10 0h4M4 20h16a1 1 0 001-1V5a1 1 0 00-1-1H4a1 1 0 00-1 1v14a1 1 0 001 1z"
                  ></path>
                </svg>
              </div>
              <div className="ml-4">
                <h2 className="text-sm font-medium text-gray-500">
                  Phim Đang Chiếu
                </h2>
                <p className="text-2xl font-bold text-gray-800">
                  {stats.MoviesShowing}
                </p>
              </div>
            </div>
            <div className="px-6 py-3 bg-red-50">
              <a
                onClick={() => navigate("/admin/ListSchedules")}
                // href="/movies"
                className="text-sm text-red-600 font-medium hover:text-red-800"
              >
                Xem chi tiết &rarr;
              </a>
            </div>
          </div>

          {/* Card 3 */}
          <div className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300">
            <div className="flex items-center p-6">
              <div className="bg-green-100 p-3 rounded-lg">
                <svg
                  className="w-8 h-8 text-green-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                  ></path>
                </svg>
              </div>
              <div className="ml-4">
                <h2 className="text-sm font-medium text-gray-500">
                  Khách Hàng
                </h2>
                <p className="text-2xl font-bold text-gray-800">
                  {stats.Customers}
                </p>
              </div>
            </div>
            <div className="px-6 py-3 bg-green-50">
              <a
                onClick={() => navigate("/admin/ListUsers")}
                className="text-sm text-green-600 font-medium hover:text-green-800"
              >
                Xem chi tiết &rarr;
              </a>
            </div>
          </div>

          {/* Card 4 */}
          <div className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300">
            <div className="flex items-center p-6">
              <div className="bg-purple-100 p-3 rounded-lg">
                <svg
                  className="w-8 h-8 text-purple-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  ></path>
                </svg>
              </div>
              <div className="ml-4">
                <h2 className="text-sm font-medium text-gray-500">Doanh Thu</h2>
                <p className="text-2xl font-bold text-gray-800">
                  {new Intl.NumberFormat("vi-VN", {
                    style: "currency",
                    currency: "VND",
                  }).format(stats.Revenue)}
                </p>
              </div>
            </div>
            <div className="px-6 py-3 bg-purple-50">
              <a
                href="/revenue"
                className="text-sm text-purple-600 font-medium hover:text-purple-800"
              >
                Xem chi tiết &rarr;
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Bookings Section */}
      <div className="px-6 pb-8">
        <div className="bg-white rounded-xl shadow-md overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-800">
              Đặt Vé Gần Đây
            </h3>
          </div>
          <div className="p-6">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th
                      scope="col"
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      ID
                    </th>
                    <th
                      scope="col"
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Khách Hàng
                    </th>
                    <th
                      scope="col"
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Phim
                    </th>
                    <th
                      scope="col"
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Suất Chiếu
                    </th>
                    <th
                      scope="col"
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Trạng Thái
                    </th>
                    <th
                      scope="col"
                      className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider"
                    >
                      Hành Động
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {/* Placeholder data - would be replaced with actual data in a real app */}
                  <tr>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {/* #B12345 */}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {/* Nguyễn Văn A */}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {/* Avengers: Endgame */}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {/* 20:30 - 04/04/2025 */}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                        {/* Đã thanh toán */}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <a
                        href="#"
                        className="text-indigo-600 hover:text-indigo-900"
                      >
                        {/* Chi tiết */}
                      </a>
                    </td>
                  </tr>
                  <tr>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {/* #B12346 */}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {/* Trần Thị B */}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {/* Dune: Part Two */}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {/* 18:15 - 04/04/2025 */}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                        {/* Chờ xác nhận */}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <a
                        href="#"
                        className="text-indigo-600 hover:text-indigo-900"
                      >
                        {/* Chi tiết */}
                      </a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div className="px-6 py-4 border-t border-gray-200 bg-gray-50">
            <a
              href="/bookings"
              className="text-sm text-indigo-600 font-medium hover:text-indigo-800"
            >
              Xem tất cả đơn đặt vé &rarr;
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
