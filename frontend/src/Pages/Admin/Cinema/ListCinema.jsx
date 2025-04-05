import React, { useState, useEffect } from "react";
import {
  Eye,
  Info,
  Edit,
  Trash,
  Plus,
  Search,
  ChevronLeft,
  ChevronRight,
  Film,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

const TheaterList = () => {
  const navigate = useNavigate();
  const [theaters, setTheaters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(5);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    const fetchTheaters = async () => {
      try {
        setLoading(true);
        const response = await fetch(
          "http://localhost:5000/api/v1/admin/theaters"
        );

        if (!response.ok) {
          throw new Error("Không thể tải dữ liệu rạp phim");
        }

        const data = await response.json();

        // Kiểm tra cấu trúc dữ liệu và đảm bảo theaters là một mảng
        if (data && Array.isArray(data)) {
          setTheaters(data);
        } else if (
          data &&
          typeof data === "object" &&
          data.data &&
          Array.isArray(data.data)
        ) {
          // Xử lý trường hợp API trả về dạng { data: [...] }
          setTheaters(data.data);
        } else {
          // Đặt mảng rỗng nếu dữ liệu không đúng định dạng
          console.error("Dữ liệu API không đúng định dạng:", data);
          setTheaters([]);
          setError("Dữ liệu không đúng định dạng");
        }

        setLoading(false);
      } catch (err) {
        console.error("Lỗi khi tải dữ liệu:", err);
        setError(err.message);
        setTheaters([]);
        setLoading(false);
      }
    };

    fetchTheaters();
  }, []);

  // Xử lý tìm kiếm - kiểm tra theaters là array trước khi filter
  const filteredTheaters = Array.isArray(theaters)
    ? theaters.filter(
        (theater) =>
          theater.ten_rap?.toLowerCase().includes(searchTerm.toLowerCase()) ||
          theater.dia_chi?.toLowerCase().includes(searchTerm.toLowerCase()) ||
          theater.ma_rap?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    : [];

  // Phân trang
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentTheaters = filteredTheaters.slice(
    indexOfFirstItem,
    indexOfLastItem
  );
  const totalPages = Math.ceil(filteredTheaters.length / itemsPerPage);

  // Xử lý các hành động
  const handleViewRooms = (theaterId) => {
    console.log("Theater ID:", theaterId); // Debug xem giá trị truyền vào có đúng không
    if (!theaterId) {
      alert("Lỗi: Không tìm thấy ID rạp!");
      return;
    }
    navigate(`/admin/ListRooms/${theaterId}/rooms`);
  };

  const handleViewDetails = (theaterId) => {
    console.log(`Xem chi tiết rạp ${theaterId}`);
    // Thực hiện chuyển hướng hoặc mở modal để xem chi tiết
  };

  const handleEdit = (theaterId) => {
    console.log(`Sửa rạp ${theaterId}`);
    // Thực hiện chuyển hướng hoặc mở modal để sửa
  };

  const handleDelete = async (theaterId) => { 
    if (!window.confirm("Bạn có chắc chắn muốn xoá rạp này không?")) return;

    try {
        const response = await fetch(`http://localhost:5000/api/v1/admin/theaters/${theaterId}`, {
            method: "DELETE",
            headers: { "Content-Type": "application/json" },
        });

        const data = await response.json();

        if (response.ok) {
            alert("Xoá rạp thành công!");

            setTheaters((prevTheaters) => prevTheaters.filter(theater => theater._id !== theaterId));
            // Cập nhật danh sách rạp sau khi xoá thành công (nếu cần)
        } else {
            if (response.status === 400) {
                alert(`Lỗi: ${data.message || "Rạp đang có đơn đặt vé, không thể xoá."}`);
            } else {
                alert(data.message || "Có lỗi xảy ra khi xoá rạp.");
            }
        }
    } catch (error) {
        console.error("Lỗi khi xoá rạp:", error);
        alert("Lỗi server khi xoá rạp.");
    }
};

  const handleAdd = () => {
    console.log("Thêm rạp mới");
    // Thực hiện chuyển hướng hoặc mở modal để thêm
  };

  // Thêm hàm debug để kiểm tra dữ liệu
  const logTheaterData = () => {
    console.log("Dữ liệu theaters:", theaters);
    console.log("Loại dữ liệu:", typeof theaters);
    console.log("Có phải array không:", Array.isArray(theaters));
  };

  if (loading)
    return (
      <div className="flex justify-center items-center h-64">
        Đang tải dữ liệu...
      </div>
    );

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800">
          Quản lý danh sách rạp
        </h1>
        <div className="flex space-x-2">
          <button
            onClick={logTheaterData}
            className="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-md"
          >
            Debug Data
          </button>
          <button
            onClick={handleAdd}
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center"
          >
            <Plus size={18} className="mr-1" />
            Thêm rạp mới
          </button>
        </div>
      </div>

      {/* Hiển thị lỗi nếu có */}
      {error && (
        <div className="mb-4 p-4 bg-red-100 text-red-700 rounded-md">
          Lỗi: {error}
        </div>
      )}

      {/* Thanh tìm kiếm */}
      <div className="mb-6">
        <div className="relative">
          <input
            type="text"
            placeholder="Tìm kiếm rạp theo tên, mã, địa chỉ..."
            className="w-full pl-10 pr-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
        </div>
      </div>

      {/* Bảng danh sách */}
      <div className="overflow-x-auto">
        <table className="min-w-full bg-white border rounded-lg">
          <thead className="bg-gray-100">
            <tr>
              <th className="py-3 px-4 text-left font-medium text-gray-600">
                Mã rạp
              </th>
              <th className="py-3 px-4 text-left font-medium text-gray-600">
                Hình ảnh
              </th>
              <th className="py-3 px-4 text-left font-medium text-gray-600">
                Tên rạp
              </th>
              <th className="py-3 px-4 text-left font-medium text-gray-600">
                Địa chỉ
              </th>
              <th className="py-3 px-4 text-left font-medium text-gray-600">
                Số điện thoại
              </th>
              <th className="py-3 px-4 text-center font-medium text-gray-600">
                Thao tác
              </th>
            </tr>
          </thead>
          <tbody>
            {currentTheaters.length > 0 ? (
              currentTheaters.map((theater) => (
                <tr key={theater._id} className="border-t hover:bg-gray-50">
                  <td className="py-3 px-4">{theater.ma_rap}</td>
                  <td className="py-3 px-4">
                    <img
                      src={
                        `https://rapchieuphim.com${theater.anh}` ||
                        "/api/placeholder/80/80"
                      }
                      alt={theater.ten_rap}
                      className="w-16 h-16 object-cover rounded"
                    />
                  </td>
                  <td className="py-3 px-4 font-medium">{theater.ten_rap}</td>
                  <td className="py-3 px-4 max-w-xs truncate">
                    {theater.dia_chi}
                  </td>
                  <td className="py-3 px-4">{theater.so_dien_thoai}</td>
                  <td className="py-3 px-4">
                    <div className="flex justify-center space-x-2">
                      <button
                        onClick={() => handleViewRooms(theater._id)}
                        title="Xem phòng chiếu"
                        className="p-1.5 bg-purple-100 text-purple-600 rounded-md hover:bg-purple-200"
                      >
                        <Film size={18} />
                      </button>
                      <button
                        onClick={() => handleViewDetails(theater._id)}
                        title="Xem chi tiết"
                        className="p-1.5 bg-blue-100 text-blue-600 rounded-md hover:bg-blue-200"
                      >
                        <Info size={18} />
                      </button>
                      <button
                        onClick={() => handleEdit(theater._id)}
                        title="Sửa thông tin"
                        className="p-1.5 bg-yellow-100 text-yellow-600 rounded-md hover:bg-yellow-200"
                      >
                        <Edit size={18} />
                      </button>
                      <button
                        onClick={() => handleDelete(theater._id)}
                        title="Xóa rạp"
                        className="p-1.5 bg-red-100 text-red-600 rounded-md hover:bg-red-200"
                      >
                        <Trash size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="6" className="py-6 text-center text-gray-500">
                  {loading ? "Đang tải dữ liệu..." : "Không tìm thấy rạp nào"}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Phân trang */}
      {filteredTheaters.length > 0 && (
        <div className="flex items-center justify-between mt-6">
          <div className="text-sm text-gray-600">
            Hiển thị {indexOfFirstItem + 1} -{" "}
            {Math.min(indexOfLastItem, filteredTheaters.length)} của{" "}
            {filteredTheaters.length} rạp
          </div>

          <div className="flex space-x-1">
            <button
              onClick={() => setCurrentPage((page) => Math.max(page - 1, 1))}
              disabled={currentPage === 1}
              className={`p-2 rounded ${
                currentPage === 1
                  ? "text-gray-400 cursor-not-allowed"
                  : "text-gray-700 hover:bg-gray-100"
              }`}
            >
              <ChevronLeft size={20} />
            </button>

            {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
              <button
                key={page}
                onClick={() => setCurrentPage(page)}
                className={`px-3 py-1 rounded ${
                  currentPage === page
                    ? "bg-blue-600 text-white"
                    : "hover:bg-gray-100"
                }`}
              >
                {page}
              </button>
            ))}

            <button
              onClick={() =>
                setCurrentPage((page) => Math.min(page + 1, totalPages))
              }
              disabled={currentPage === totalPages || totalPages === 0}
              className={`p-2 rounded ${
                currentPage === totalPages || totalPages === 0
                  ? "text-gray-400 cursor-not-allowed"
                  : "text-gray-700 hover:bg-gray-100"
              }`}
            >
              <ChevronRight size={20} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default TheaterList;
